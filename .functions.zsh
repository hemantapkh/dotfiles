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
    (( $# == 0 )) && { echo "Usage: killport <port>"; return 1; }

    local port=$1
    local -a pids
    pids=( $(lsof -ti :$port 2>/dev/null) )   # array assignment + word splitting

    if (( ${#pids} == 0 )); then
        echo "No process is running on port $port"
        return 0
    fi

    echo "Killing ${#pids} process(es) on port $port..."

    kill -9 $pids 2>/dev/null

    (( $? == 0 )) && echo "Successfully killed ✓" || { echo "Failed to kill"; return 1; }
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
