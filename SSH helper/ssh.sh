#!/bin/bash

# Interactive SSH helper with OS guidance and auto username detection

SSH_CONFIG="$HOME/.ssh/config"
mkdir -p "$HOME/.ssh"

echo "Welcome to the SSH helper script!"
echo "---------------------------------"

# Function to guide user based on OS
os_guide() {
    echo "Select the OS of the server you want to connect to:"
    select OS in "Linux" "Windows" "Other/Manual"; do
        case $OS in
            "Linux")
                echo "Instructions for $OS:"
                echo "- Username: run "whoami" to see "
                echo "- IP address: run 'hostname -i' to see"
                echo "- SSH port: default is 22 unless changed"
                # Detect local username as default
                DEFAULT_USER=$(whoami)
                break;;
            "Windows")
                echo "Instructions for Windows:"
                echo "- Username: your Windows account"
                echo "- IP address: open cmd or PowerShell and run 'ipconfig'"
                echo "- SSH: ensure OpenSSH server is installed and running"
                echo "- Port: default is 22 unless changed"
                DEFAULT_USER=""
                break;;
            "Other/Manual")
                echo "You will need to find your username, IP, and SSH port manually."
                DEFAULT_USER=""
                break;;
            *) echo "Please select a valid option (1-4)";;
        esac
    done
}

# Function to add a new server
add_server() {
    os_guide
    
    # Ask for nickname
    read -p "Enter a short name for this server (nickname): " HOST
    if [ -z "$HOST" ]; then
        echo "Nickname cannot be empty. Exiting."
        exit 1
    fi

    # Ask for server IP/domain
    read -p "Server IP/Domain: " HOSTNAME
    if [ -z "$HOSTNAME" ]; then
        echo "Server IP/Domain cannot be empty. Exiting."
        exit 1
    fi

    # Ask for username with default
    if [ -n "$DEFAULT_USER" ]; then
        read -p "Username [$DEFAULT_USER]: " USERNAME
        USERNAME=${USERNAME:-$DEFAULT_USER}
    else
        read -p "Username: " USERNAME
        if [ -z "$USERNAME" ]; then
            echo "Username cannot be empty. Exiting."
            exit 1
        fi
    fi

    # Ask for port
    read -p "SSH Port (default 22): " PORT
    PORT=${PORT:-22}

    # Ask for key file
    read -p "Path to private key file (optional): " KEYFILE
    KEYLINE=""
    if [ -n "$KEYFILE" ]; then
        KEYLINE="    IdentityFile $KEYFILE"
    fi

    # Append to ~/.ssh/config
    echo -e "\nHost $HOST\n    HostName $HOSTNAME\n    User $USERNAME\n    Port $PORT\n$KEYLINE" >> "$SSH_CONFIG"
    chmod 600 "$SSH_CONFIG"
    echo "Server '$HOST' added successfully!"
}

# Function to connect to a server
connect_server() {
    if [ ! -f "$SSH_CONFIG" ]; then
        echo "No servers found. Please add a server first."
        exit 1
    fi

    echo "Select a server to connect:"
    grep '^Host ' "$SSH_CONFIG" | awk '{print $2}' | nl
    read -p "Enter the number: " SELECTION
    SERVER=$(grep '^Host ' "$SSH_CONFIG" | awk '{print $2}' | sed -n "${SELECTION}p")

    if [ -z "$SERVER" ]; then
        echo "Invalid selection. Exiting."
        exit 1
    fi

    echo "Connecting to $SERVER..."
    ssh "$SERVER"
}

# Main menu
while true; do
    echo "Choose an option:"
    select CHOICE in "Add new server" "Connect to a server" "Exit"; do
        case $CHOICE in
            "Add new server") add_server; break;;
            "Connect to a server") connect_server; break;;
            "Exit") exit 0;;
            *) echo "Please select a valid option (1-3)";;
        esac
    done
done
