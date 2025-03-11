#!/bin/bash
if [ "$#" -lt 3 ]; then
    echo "Usage: $0 <source_directory> <destination_directory> <pattern-or-item> [pattern-or-item]..."
    exit 1
fi

source_dir="$1"
destination_dir="$2"
if [[ "$destination_dir" != /* ]]; then
    destination_dir="$(pwd)/$destination_dir"
fi

echo "Source directory: $source_dir"
echo "Destination directory: $destination_dir"

# Shift the source and destination directories off the argument list. Now only file patterns or abs path remain.
# E.g. $1 = "*file.txt", $2 = "file.txt", $3 = "subdir/file.txt", $4 = "subdir", $5 = "anotherdir/"
shift 2

# Check that source and destination directories exist.
if [ ! -d "$source_dir" ]; then
    echo "Error: Source directory '$source_dir' does not exist."
    exit 1
fi

if [ ! -d "$destination_dir" ]; then
    echo "Destination directory '$destination_dir' does not exist. Creating it..."
    mkdir -p "$destination_dir" || {
        echo "Failed to create destination directory '$destination_dir'."
        exit 1
    }
fi

# Change to the source directory so that rsync -aR will recreate the relative paths.
cd "$source_dir" || {
    echo "Failed to change directory to $source_dir"
    exit 1
}

# Process each argument (pattern, file, or directory)
for arg in "$@"; do
    # Normalize the argument:
    # If it is an absolute path, ensure it's inside the source directory and strip the source prefix.
    normalized="$arg"
    if [[ "$arg" == /* ]]; then
        if [[ "$arg" == "$source_dir"* ]]; then
            normalized="${arg#$source_dir/}"
        else
            echo "Warning: '$arg' is an absolute path not under the source directory '$source_dir'. Skipping..."
            continue
        fi
    fi

    # Check if the normalized argument contains wildcard characters.
    if [[ "$normalized" == *[\*\?\[]* ]]; then
        # Argument contains wildcards – treat it as a glob pattern (that may match files and directories).
        if [[ "$normalized" == */* ]]; then
            # Contains a slash: use find's -path.
            search_pattern="$normalized"
            if [[ "$search_pattern" != ./* ]]; then
                search_pattern="./$search_pattern"
            fi
            echo "Searching for items with path pattern: $search_pattern"
            found_any=false
            while IFS= read -r -d '' item; do
                # Skip the current directory if encountered.
                if [ "$item" = "." ]; then
                    continue
                fi
                rsync -aR "$item" "$destination_dir"
                echo "Copied: $item"
                found_any=true
            done < <(find . -path "$search_pattern" -print0)
            if [ "$found_any" = false ]; then
                echo "No items matching pattern '$arg' found."
            fi
        else
            # No slash: use find's -name.
            echo "Searching for items with name pattern: $normalized"
            found_any=false
            while IFS= read -r -d '' item; do
                if [ "$item" = "." ]; then
                    continue
                fi
                rsync -aR "$item" "$destination_dir"
                echo "Copied: $item"
                found_any=true
            done < <(find . -name "$normalized" -print0)
            if [ "$found_any" = false ]; then
                echo "No items matching pattern '$arg' found."
            fi
        fi
    else
        # No wildcards.
        if [[ "$normalized" == */* ]]; then
            # Contains a slash: assume it's an exact path (file or directory) relative to source.
            if [ -e "$normalized" ]; then
                echo "Copying exact item: $normalized"
                rsync -aR "$normalized" "$destination_dir"
            else
                echo "Exact item '$normalized' not found."
            fi
        else
            # Bare name – search for all items (files or directories) matching that name.
            echo "Searching for items with name pattern: $normalized"
            found_any=false
            while IFS= read -r -d '' item; do
                if [ "$item" = "." ]; then
                    continue
                fi
                rsync -aR "$item" "$destination_dir"
                echo "Copied: $item"
                found_any=true
            done < <(find . -name "$normalized" -print0)
            if [ "$found_any" = false ]; then
                echo "No items named '$normalized' found."
            fi
        fi
    fi
done

echo "Copy operation complete."
