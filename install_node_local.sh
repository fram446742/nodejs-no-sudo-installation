#!/bin/bash

# Check if script is executed with sudo
if [ "$(id -u)" != "0" ]; then
    echo "This script must be run with sudo."
    exit 1
fi

# Function to check if a command is available
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to prompt the user for cleaning the folder
prompt_clean_folder() {
    read -p "The $1 folder already exists. Do you want to clean it before continuing? (yes/no): " choice
    case "$choice" in
    yes | YES | y | Y)
        # Clean the folder
        echo "Cleaning $1 folder..."
        rm -rf $2/*
        ;;
    no | NO | n | N)
        echo "Skipping cleaning of $1 folder. Proceeding..."
        ;;
    *)
        echo "Invalid choice. Please enter yes or no."
        prompt_clean_folder "$1" "$2"
        ;;
    esac
}

# Function to prompt the user for hiding a folder
prompt_hide_folder() {
    read -p "Do you want to hide the $1 folder? (yes/no): " choice
    case "$choice" in
    yes | YES | y | Y)
        # Rename the folder to make it hidden
        mv $1 $2
        $3 = $2
        ;;
    no | NO | n | N)
        echo "Keeping $1 folder visible."
        ;;
    *)
        echo "Invalid choice. Please enter yes or no."
        prompt_hide_folder "$1" "$2"
        ;;
    esac
}

n_directory="$HOME/n"

node_directory="$HOME/nodejs"

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

# Check if $HOME/nodejs folder exists
if [ -d $HOME/nodejs ]; then
    prompt_clean_folder "~/nodejs" "~/nodejs"
elif [ -d $HOME/.nodejs ]; then
    prompt_clean_folder "~/.nodejs" "~/.nodejs"
fi

# Create nodejs directory in the home directory
if [ ! -d $HOME/nodejs ]; then
    echo "Creating ~/nodejs directory..."
    mkdir -p $HOME/nodejs
fi

cd $HOME/nodejs

# Get the latest version of Node.js from the official website
echo "Fetching the latest version of Node.js..."
NODE_VERSION=$(curl -sL https://nodejs.org/dist/latest/ | grep -o 'node-v[0-9.]*-linux-x64.tar.xz' | head -n 1)

# Download and extract the latest version
echo "Downloading and extracting Node.js $NODE_VERSION..."
wget https://nodejs.org/dist/latest/$NODE_VERSION
tar xvf $NODE_VERSION

# Prompt for hiding the ~/nodejs folder
prompt_hide_folder "$HOME/nodejs" "$HOME/.nodejs" node_directory

# Set environment variables for the latest version of Node.js
export NODE_HOME=$node_directory/$(basename $NODE_VERSION .tar.xz)
export PATH=$NODE_HOME/bin:$PATH

# Update PATH in the current session
echo "Updating PATH in the current session..."
echo "export NODE_HOME=$node_directory/$(basename $NODE_VERSION .tar.xz)" >>$HOME/.bashrc
echo "export PATH=\$NODE_HOME/bin:\$PATH" >>$HOME/.bashrc
source $HOME/.bashrc

# Display Node.js environment variables
echo "NODE_HOME: $NODE_HOME"
echo "PATH: $PATH"

# Check if ~/.n folder exists
if [ -d $HOME/n ]; then
    prompt_clean_folder "$HOME/n" "$HOME/n"
elif [ -d $HOME/.n ]; then
    prompt_clean_folder "$HOME/.n" "$HOME/.n"
fi

# Create n directory in the home directory
if [ ! -d $HOME/n ]; then
    echo "Creating ~/n directory..."
    mkdir -p $HOME/n
fi

# Prompt for hiding the ~/.n folder
prompt_hide_folder "$HOME/n" "$HOME/.n" n_directory

export N_PREFIX=$n_directory
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
echo "export N_PREFIX=$n_directory" >>$HOME/.bashrc
echo "export PATH=\"\$N_PREFIX/bin:\$PATH\"" >>$HOME/.bashrc

# Display Node.js versions installed
echo "Installed Node.js versions:"
ls -l $n_directory/versions/node

# Update PATH in the current session
source $HOME/.bashrc

echo "Node.js installation script completed."
