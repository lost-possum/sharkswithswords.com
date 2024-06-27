#!/bin/bash

# Define directories
assets="assets/"
otherDirectories="!assets/"

# Initialize an empty array to hold the file names from assets
assetNames=()

# Collect file names from directory/A
while IFS= read -r -d '' file; do
    file_name=$(basename "$file")
    file_names+=("$file_name")
done < <(find "$assets" -type f -print0)

# Initialize an array to hold the files to be searched
searchAssets=()

# Collect all files in directory except those in assets
while IFS= read -r -d '' file; do
    searchAssets+=("$file")
done < <(find "$otherDirectories" -type f -not -path "$assets/*" -print0)

# Search for instances of the collected file names in the remaining files
declare -A fileMatches

for file_name in "${file_names[@]}"; do
    file_matches["$file_name"]=0
    for search_file in "${search_files[@]}"; do
        match_count=$(grep -o "$file_name" "$search_file" | wc -l)
        file_matches["$file_name"]=$((file_matches["$file_name"] + match_count))
    done
done

# Print statements based on the matches found
for file_name in "${file_names[@]}"; do
    if (( file_matches["$file_name"] > 0 )); then
        echo "$file_name is linked ${file_matches["$file_name"]} times in this directory."
    else
        echo "$file_name has not been referenced. Would you like to remove it from directory/A? (yes/no)"
        read -r answer
        if [[ "$answer" == "yes" ]]; then
            file_to_remove="$dir_A/$file_name"
            if rm "$file_to_remove"; then
                echo "$file_to_remove has been removed."
            else
                echo "Failed to remove $file_to_remove."
            fi
        fi
    fi
done