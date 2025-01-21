#!/bin/bash

# Loop through all directories in the current directory
for dir in */; do
    # Enter the directory
    if [ -d "$dir/.git" ]; then
        echo "Updating repository in $dir"
        cd "$dir" || exit
        git pull
        git status
        cd ..
        echo "-----------------------------------------"
    fi
done
