#!/bin/bash

# Hytale Server Entrypoint

TZ=${TZ:-UTC}
export TZ

INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

cd /home/container || exit 1

# Set default values
SERVER_JARFILE=${SERVER_JARFILE:-"HytaleServer.jar"}
SERVER_PORT=${SERVER_PORT:-"5520"}
HYTALE_WORLD=${HYTALE_WORLD:-"world"}
HYTALE_CONFIG=${HYTALE_CONFIG:-"server.properties"}
MAXIMUM_RAM=${MAXIMUM_RAM:-"90"}
JVM_FLAGS=${JVM_FLAGS:-"-XX:+UseG1GC"}
HYTALE_PATCHLINE=${HYTALE_PATCHLINE:-""}
AUTH_WAIT=${AUTH_WAIT:-"15"}

DOWNLOADER_PATH="./hytale-downloader-linux-amd64"
DOWNLOADER_URL="https://downloader.hytale.com/hytale-downloader.zip"

# Function to download the hytale-downloader
download_hytale_downloader() {
    echo "Downloading hytale-downloader..."
    curl -sSL -o hytale-downloader.zip "$DOWNLOADER_URL"
    if [ -f "hytale-downloader.zip" ]; then
        unzip -o hytale-downloader.zip
        rm -f hytale-downloader.zip
        chmod +x "$DOWNLOADER_PATH"
        echo "hytale-downloader installed."
    else
        echo "ERROR: Failed to download hytale-downloader"
        exit 1
    fi
}

# Check if downloader exists, if not download it
if [ ! -f "$DOWNLOADER_PATH" ]; then
    echo "hytale-downloader not found, downloading..."
    download_hytale_downloader
fi

# Check for downloader updates
echo "Checking for updates..."
$DOWNLOADER_PATH -check-update

# Download/update server if jar is missing
if [ ! -f "$SERVER_JARFILE" ]; then
    echo "Server JAR not found, downloading..."
    if [ -n "$HYTALE_PATCHLINE" ]; then
        $DOWNLOADER_PATH -patchline "$HYTALE_PATCHLINE"
    else
        $DOWNLOADER_PATH
    fi
fi

# Verify server jar exists
if [ ! -f "$SERVER_JARFILE" ]; then
    echo "ERROR: Failed to download $SERVER_JARFILE"
    exit 1
fi

# Calculate memory
SERVER_MEMORY_REAL=$((SERVER_MEMORY * MAXIMUM_RAM / 100))

# Build startup command
STARTUP_CMD="java -Xms256M -Xmx${SERVER_MEMORY_REAL}M"
[ -n "$JVM_FLAGS" ] && STARTUP_CMD+=" $JVM_FLAGS"
STARTUP_CMD+=" -jar $SERVER_JARFILE --nogui --port $SERVER_PORT --world-dir $HYTALE_WORLD --config $HYTALE_CONFIG"

echo "Starting: $STARTUP_CMD"

# Auto-auth: wait for server, check status, login if needed, then pass through stdin
# shellcheck disable=SC2086
{
    sleep "$AUTH_WAIT"
    echo "/auth status"
    sleep 2
    echo "/auth login device"
    cat
} | exec $STARTUP_CMD
