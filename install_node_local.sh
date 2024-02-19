#!/bin/bash

# Function to check if a command is available
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check if curl and grep are installed
if ! command_exists curl || ! command_exists grep; then
    echo "curl or grep is not installed. Installing..."
    # Check the package manager and install curl and grep
    if command_exists apt-get; then
        sudo apt-get install -y curl grep
    elif command_exists yum; then
        sudo yum install -y curl grep
    else
        echo "Cannot determine the package manager. Please install curl and grep manually."
        exit 1
    fi
fi

# Continue with the rest of your script here
echo "Both curl and grep are installed. Proceeding with the script..."

# Function to prompt the user for cleaning the folder
prompt_clean_folder() {
    read -p "The ~/nodejs folder already exists. Do you want to clean it before continuing? (yes/no): " choice
    case "$choice" in
    yes | YES | y | Y)
        # Clean the folder
        echo "Cleaning ~/nodejs folder..."
        rm -rf ~/nodejs/*
        ;;
    no | NO | n | N)
        echo "Skipping cleaning of ~/nodejs folder. Proceeding..."
        ;;
    *)
        echo "Invalid choice. Please enter yes or no."
        prompt_clean_folder
        ;;
    esac
}

# Check if ~/nodejs folder exists
if [ -d ~/nodejs ]; then
    prompt_clean_folder
fi

# Create nodejs directory in the home directory
echo "Creating ~/nodejs directory..."
mkdir -p ~/nodejs
cd ~/nodejs

# Get the latest version of Node.js from the official website
echo "Fetching the latest version of Node.js..."
NODE_VERSION=$(curl -sL https://nodejs.org/dist/latest/ | grep -o 'node-v[0-9.]*-linux-x64.tar.xz' | head -n 1)

# Download and extract the latest version
echo "Downloading and extracting Node.js $NODE_VERSION..."
wget https://nodejs.org/dist/latest/$NODE_VERSION
tar xvf $NODE_VERSION

# Set environment variables for the latest version of Node.js
export NODE_HOME=~/nodejs/$(basename $NODE_VERSION .tar.xz)
export PATH=$NODE_HOME/bin:$PATH

# Update PATH in the current session
echo "Updating PATH in the current session..."
echo "export NODE_HOME=~/nodejs/$(basename $NODE_VERSION .tar.xz)" >>~/.bashrc
echo "export PATH=\$NODE_HOME/bin:\$PATH" >>~/.bashrc
source ~/.bashrc

# Display Node.js environment variables
echo "NODE_HOME: $NODE_HOME"
echo "PATH: $PATH"

# Check if ~/.n folder exists
if [ -d ~/.n ]; then
    prompt_clean_folder
fi

# Install and use 'n' to manage Node.js versions
echo "Installing 'n' to manage Node.js versions..."
mkdir -p ~/.n
export N_PREFIX=~/.n
export PATH="$N_PREFIX/bin:$PATH"

npm install -g n

# Prompt for Node.js versions to install
read -p "Enter Node.js versions to install (separated by space, e.g., '18 20 latest'): " node_versions

# Install selected Node.js versions
echo "Installing Node.js versions: $node_versions..."
for version in $node_versions; do
    n $version
done

# Update .bashrc with 'n' environment variables
echo "Updating .bashrc with 'n' environment variables..."
echo "export N_PREFIX=~/.n" >>~/.bashrc
echo "export PATH=\"\$N_PREFIX/bin:\$PATH\"" >>~/.bashrc

# Display Node.js versions installed
echo "Installed Node.js versions:"
ls -l ~/.n/versions/node

# Update PATH in the current session
source ~/.bashrc

echo "Node.js installation script completed."
