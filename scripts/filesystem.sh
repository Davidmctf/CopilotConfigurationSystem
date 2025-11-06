#!/bin/bash
# Filesystem operations wrapper
# Purpose: Provide file system utilities for prompts and instructions

list_directory() {
    local path="${1:-.}"
    echo "Listing: $path"
    find "$path" -maxdepth 1 -type f -o -type d | sort
}

read_file() {
    local file="$1"
    if [ ! -f "$file" ]; then
        echo "Error: File not found: $file" >&2
        return 1
    fi
    cat "$file"
}

search_files() {
    local pattern="$1"
    local path="${2:-.}"
    echo "Searching for: $pattern in $path"
    find "$path" -type f -name "*$pattern*" 2>/dev/null
}

write_file() {
    local file="$1"
    local content="$2"
    mkdir -p "$(dirname "$file")"
    echo "$content" > "$file"
    echo "File written: $file"
}

count_files() {
    local path="${1:-.}"
    find "$path" -type f | wc -l
}

# Main dispatcher
case "${1:-help}" in
    list)   list_directory "$2" ;;
    read)   read_file "$2" ;;
    search) search_files "$2" "$3" ;;
    write)  write_file "$2" "$3" ;;
    count)  count_files "$2" ;;
    *)      echo "Usage: $0 {list|read|search|write|count} [args]" ;;
esac
