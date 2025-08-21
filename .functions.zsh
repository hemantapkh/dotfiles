# loadenv: Load environment variables from a specified file (default: .env)
loadenv() {
    local file="${1:-.env}"

    if [[ -f $file ]]; then
        set -a
        source "$file"
        set +a
        echo "Loaded environment variables from '$file'."
    else
        echo "File '$file' not found."
    fi
}

# killport: Kill the process running on the specified port
killport() {
    local port=$1
    if [ -z "$port" ]; then
        echo "Error: Please provide a port number"
        return 1
    fi

    # Get process ID(s) for the port
    local pids
    pids=$(lsof -t -i:$port 2>/dev/null)
    local lsof_status=$?

    if [ $lsof_status -ne 0 ] || [ -z "$pids" ]; then
        echo "No process found on port $port"
        return 1
    fi

    # Kill the process(es)
    kill -9 $pids 2>/dev/null
    local kill_status=$?

    if [ $kill_status -eq 0 ]; then
        echo "Process on port $port has been killed"
    else
        echo "Failed to kill process on port $port"
        return 1
    fi
}

# Zoxide + nvim
n() {
  local dir
  if [[ -z "$1" ]]; then
    # If no argument is provided, use interactive selection with fzf
    dir=$(zoxide query -l | fzf --height 40% --layout reverse --prompt="Select directory: ") || return 1
  else
    # Use zoxide to resolve the directory based on the argument
    dir=$(zoxide query --exclude "$(pwd)" -- "$1") || return 1
  fi
  cd "$dir" && nvim .
}

# ghclone: Clone a GitHub repo using gh s

ghclone() {
  local repo_name="$1"
  local owner="$2"

  # Check if repo_name is provided
  [ -z "$repo_name" ] && { echo "Error: Repo name required. Usage: ghclone <repo_name> [owner]"; return 1; }

  # Run gh s to get the repo URL
  local repo_url
  if [ -n "$owner" ]; then
    repo_url=$(gh s "$repo_name" -u "$owner")
  else
    repo_url=$(gh s "$repo_name")
  fi

  [ -z "$repo_url" ] && { echo "Error: No result found for '$repo_name'."; return 1; }
 
  git clone $repo_url
}

# atlasip: Whitelist an IP address in MongoDB Atlas
atlasip() {
    local use_specific_project=false
    local ip_address hours_duration comment_text project_id

    for arg in "$@"; do
        case $arg in
            --ip=*) ip_address="${arg#*=}" ;;
            --hours=*) hours_duration="${arg#*=}" ;;
            --comment=*) comment_text="${arg#*=}" ;;
            --project=*) project_id="${arg#*=}"; use_specific_project=true ;;
            --project) use_specific_project=true ;;
        esac
    done

    ip_address="${ip_address:---currentIp}"
    hours_duration="${hours_duration:-6}"
    comment_text="${comment_text:-$(whoami)}"
    expiry_date=$(date -u -v+"$hours_duration"H +%Y-%m-%dT%H:%M:%SZ)

    if [ "$use_specific_project" = true ]; then
        if [ -z "$project_id" ]; then
            project_id=$(atlas projects list --output json | jq -r '.results[] | "\(.id) \(.name)"' | fzf --height 40% --reverse --with-nth=2.. | awk '{print $1}')
            if [ -z "$project_id" ]; then
              echo "No project selected. Aborting."
              return 1
            fi
        fi
        [ -n "$project_id" ] && project_flags="--projectId $project_id"
    fi

    cmd="atlas accessLists create \"$ip_address\" --type ipAddress $project_flags --comment \"$comment_text\" --deleteAfter \"$expiry_date\""
    eval "$cmd"
}

