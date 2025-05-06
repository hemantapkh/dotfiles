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
