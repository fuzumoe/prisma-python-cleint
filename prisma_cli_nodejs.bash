#!/bin/bash   
if [ $EUID != 0 ]; then
    sudo "$0" "$@"
    exit $?
fi

INSTALL_DIR="$HOME/prisma-engines"
VENV_DIR="$HOME/prisma_env"
NODE_VERSION="v22.0.0"
NODE_DIR="node-${NODE_VERSION}-linux-x64"
NODE_TARBALL="${NODE_DIR}.tar.xz"
NODE_DOWNLOAD_URL="https://nodejs.org/dist/${NODE_VERSION}/${NODE_TARBALL}"
NODE_PATH="$(pwd)/prisma_env/node"
NODE_VERSION="v22.0.0"
NODE_DIR="node-${NODE_VERSION}-linux-x64"
NODE_TARBALL="${NODE_DIR}.tar.xz"
NODE_DOWNLOAD_URL="https://nodejs.org/dist/${NODE_VERSION}/${NODE_TARBALL}"
NODE_PATH="${VENV_DIR}/prisma_env/node"


# Step 1: Create and activate Python virtual environment
echo "Creating and activating Python virtual environment..."
python3 -m venv ${VENV_DIR}
source ${VENV_DIR}/bin/activate

# Step 2: Download and set up Node.js version 22 within the virtual environment
echo "Downloading Node.js version ${NODE_VERSION}..."
curl -O ${NODE_DOWNLOAD_URL}

echo "Extracting Node.js into the virtual environment..."
mkdir -p ${NODE_PATH}
tar -xf ${NODE_TARBALL} -C ${NODE_PATH} --strip-components=1

# Step 3: Add Node.js binary to PATH, specific to the virtual environment
export PATH=$NODE_PATH/bin:$PATH

rm -r  ${NODE_TARBALL}
# Step 4:  Step 3: Install Prisma Python client
echo "Installing Prisma Python client..."
pip install prisma --break-system-packages
 