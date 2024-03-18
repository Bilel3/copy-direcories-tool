#!/bin/bash

# Remote host details
remote_host="username@remote_host"
remote_path="/path/to/remote/directory"

# Local folder to copy
local_folder="/path/to/local/folder"

# Check if SSH key exists, if not, create one
if [ ! -f ~/.ssh/id_rsa ]; then
    ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa
fi

# Check if passwordless SSH access is set up
if ! ssh -o "BatchMode=yes" "$remote_host" true; then
    echo "First time connecting to remote host. Enter SSH password:"
    read -s ssh_password
    # Copy SSH key to remote host
    sshpass -p "$ssh_password" ssh-copy-id -i ~/.ssh/id_rsa.pub "$remote_host"
fi

# Copy folders listed in directories.txt to remote host, excluding files matching regex pattern in .exclude
exclude_pattern=$(<.exclude)
while IFS= read -r folder; do
    rsync -av --exclude="$exclude_pattern" "$local_folder/$folder" "$remote_host":"$remote_path"
done < directories.txt
