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

