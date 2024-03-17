#!/bin/bash

# Welcome message
dialog --msgbox "Welcome to the SSH Configuration and Directory Copying Tool!" 10 40

# Alert message
dialog --msgbox "IMPORTANT: Please make sure that the deployed files and applications are on the same version on both main and backup. Otherwise, you will face huge problems!" 12 60

# Check if dialog is installed, if not, install it
if ! command -v dialog &> /dev/null; then
    echo "Please install dialog to proceed."
    exit 1
fi

# Function to configure SSH for a host
configure_ssh() {
    host_name="$1"
    user_name="$2"

    # Prompt for password
    password=$(dialog --clear --insecure --passwordbox "Enter password for $user_name@$host_name:" 10 30 3>&1 1>&2 2>&3 3>&-)

    # Configure SSH
    ssh-copy-id "$user_name@$host_name" &> /dev/null

    # Check if SSH setup was successful
    if [ $? -eq 0 ]; then
        echo "$host_name $user_name" >> hosts.conf
        dialog --clear --msgbox "SSH configuration for $host_name completed successfully." 8 40
    else
        dialog --clear --msgbox "Failed to configure SSH for $host_name. Please check your credentials and try again." 8 60
    fi
}

# Function to copy directories
copy_directories() {
    source_host="$1"
    source_user="$2"
    dest_host="$3"
    dest_user="$4"

    # Check if directories.txt exists
    if [ ! -f directories.txt ]; then
        dialog --clear --msgbox "directories.txt not found. Please create the file and try again." 8 60
        return
    fi

    # Confirm copy operation
    dialog --yesno "Are you sure you want to copy the directories listed in directories.txt from $source_host to $dest_host?" 10 40
    response=$?
    if [ $response -ne 0 ]; then
        return
    fi

    # Exclude pattern
    exclude_opt=""
    if [ -f .exclude ]; then
        exclude_opt="--exclude-from=.exclude"
    fi

    # Copy directories
    while IFS= read -r directory; do
        rsync -avz --progress $exclude_opt -e "ssh -o StrictHostKeyChecking=no" "$source_user@$source_host:$directory" "$dest_user@$dest_host:$directory"
    done < directories.txt

    dialog --clear --msgbox "Directories copied successfully." 8 40
}

# Main menu
while true; do
    exec 3>&1
    selection=$(dialog \
        --clear \
        --backtitle "SSH Configuration" \
        --title "Main Menu" \
        --menu "Choose an option:" 15 40 5 \
        1 "Configure Host1" \
        2 "Configure Host2" \
        3 "Copy Directories from Host1 to Host2" \
        4 "Copy Directories from Host2 to Host1" \
        5 "Exit" \
        2>&1 1>&3)
    exit_status=$?
    exec 3>&-

    # Exit if Cancel is pressed or Esc is pressed
    if [ $exit_status -ne 0 ]; then
        exit
    fi

    case "$selection" in
    1)
        # Configure Host1
        host1_name=$(dialog --clear --inputbox "Enter Host1 name:" 10 30 3>&1 1>&2 2>&3 3>&-)
        user1_name=$(dialog --clear --inputbox "Enter Host1 username:" 10 30 3>&1 1>&2 2>&3 3>&-)
        configure_ssh "$host1_name" "$user1_name"
        ;;
    2)
        # Configure Host2
        host2_name=$(dialog --clear --inputbox "Enter Host2 name:" 10 30 3>&1 1>&2 2>&3 3>&-)
        user2_name=$(dialog --clear --inputbox "Enter Host2 username:" 10 30 3>&1 1>&2 2>&3 3>&-)
        configure_ssh "$host2_name" "$user2_name"
        ;;
    3)
        # Copy directories from Host1 to Host2
        copy_directories "$host1_name" "$user1_name" "$host2_name" "$user2_name"
        ;;
    4)
        # Copy directories from Host2 to Host1
        copy_directories "$host2_name" "$user2_name" "$host1_name" "$user1_name"
        ;;
    5)
        exit
        ;;
    esac
done
