#!/bin/bash

# Define the branch name
TARGET_BRANCH="jfrog-mig"

# Loop through all directories in the current directory
for dir in */; do
    if [ -d "$dir/.git" ]; then
        echo "Processing repository in $dir"
        cd "$dir" || exit

        # Get the current branch
        CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
        echo "Current branch: $CURRENT_BRANCH"

        if [ "$CURRENT_BRANCH" != "$TARGET_BRANCH" ]; then
            # Check if the target branch exists
            if git show-ref --quiet refs/heads/"$TARGET_BRANCH"; then
                echo "Switching to branch $TARGET_BRANCH"
                git checkout "$TARGET_BRANCH"
            else
                echo "Branch $TARGET_BRANCH does not exist. Creating it."
                git checkout -b "$TARGET_BRANCH"
            fi
        else
            echo "Already on $TARGET_BRANCH"
        fi

        cd ..
        echo "-----------------------------------------"
    fi
done
