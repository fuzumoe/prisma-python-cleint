#!/bin/bash
if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi

# Variables
REPO_URL="https://github.com/prisma/prisma-engines.git"
BRANCH="5.17.0"
TARGET_DIR="${PWD}/prisma-engines"
INSTALL_DIR="${HOME}/prisma-engines"
VENV_DIR="${HOME}/prisma_env"

# Create and activate Python virtual environment
echo "Creating and activating Python virtual environment..."
python3 -m venv "$VENV_DIR"
source "$VENV_DIR/bin/activate"
 
# Ensure Rust and Cargo are installed
if ! command -v cargo &> /dev/null; then
    echo "Rust is not installed. Installing Rust..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source $HOME/.cargo/env
fi

# Clone the Prisma engines repository if it does not already exist
if [ ! -d "$TARGET_DIR" ]; then
    echo "Cloning Prisma Engines repository..."
    git clone "$REPO_URL" --branch "$BRANCH" 
fi

# Navigate to the Prisma directory
cd "$TARGET_DIR" || { echo "Failed to change directory"; exit 1; }

# Step 3: Build the Prisma binaries using cargo
echo "Building Prisma using Cargo..."
cargo build --release

# Remove previous binaries
echo "Removing previous binaries from $INSTALL_DIR..."
if [ -d "$INSTALL_DIR" ]; then
    sudo rm -r "$INSTALL_DIR"
    echo "Removed directory: $INSTALL_DIR"
else
    echo "Directory does not exist: $INSTALL_DIR"
fi

# Create installation directory
echo "Moving binaries to $INSTALL_DIR..."
mkdir -p "$INSTALL_DIR"

# Move the built binaries to the installation directory
mv -f target/release/query-engine "$INSTALL_DIR"
mv -f target/release/schema-engine "$INSTALL_DIR"
mv -f target/release/prisma-fmt "$INSTALL_DIR"

# Make binaries executable
chmod +x "$INSTALL_DIR/query-engine"
chmod +x "$INSTALL_DIR/schema-engine"
chmod +x "$INSTALL_DIR/prisma-fmt"

#  Set environment variables to point to the new binaries
export PRISMA_QUERY_ENGINE_BINARY="$INSTALL_DIR/query-engine"
export PRISMA_FMT_BINARY="$INSTALL_DIR/schema-engine" 
export PRISMA_FMT_BINARY="$INSTALL_DIR/prisma-fmt" 

# Make the environment variables persistent
echo "Setting environment variables in ~/.bashrc..."
echo 'export PRISMA_QUERY_ENGINE_BINARY="$HOME/prisma-engines/query-engine"' >> ~/.bashrc
echo 'export PRISMA_FMT_BINARY="$HOME/prisma-engines/schema-engine"' >> ~/.bashrc  
echo 'export PRISMA_FMT_BINARY="$HOME/prisma-engines/prisma-fmt"' >> ~/.bashrc  


# Cleanup: Remove the cloned Prisma engines repository
echo "Removing the cloned repository to clean up..." 
sudo rm -r "$TARGET_DIR"

# Check if Prisma was successfully installed
echo "Prisma binaries were successfully built and installed."

echo "Installing Prisma Python client..."
pip install prisma --break-system-packages

 