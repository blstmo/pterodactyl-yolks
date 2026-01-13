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
CDN_URL=${CDN_URL:-"https://ht-cdn.lagless.gg"}

# Function to download and verify server JAR
download_server() {
    echo "Fetching manifest from CDN..."
    
    # Download manifest
    if ! curl -sSL -f "$CDN_URL/manifest.json" -o manifest.json; then
        echo "ERROR: Failed to fetch manifest from CDN"
        return 1
    fi
    
    # Extract latest version info
    LATEST_VERSION=$(jq -r '.latest_version' manifest.json)
    LATEST_SHA256=$(jq -r '.versions[] | select(.version == "'$LATEST_VERSION'") | .sha256' manifest.json)
    
    if [ -z "$LATEST_VERSION" ] || [ -z "$LATEST_SHA256" ]; then
        echo "ERROR: Failed to parse manifest"
        return 1
    fi
    
    echo "Latest version: $LATEST_VERSION"
    
    # Check if we already have this version
    if [ -f "$SERVER_JARFILE" ]; then
        CURRENT_SHA256=$(sha256sum "$SERVER_JARFILE" | awk '{print $1}')
        if [ "$CURRENT_SHA256" = "$LATEST_SHA256" ]; then
            echo "Server is up to date (SHA256 match)"
            return 0
        fi
        echo "Server JAR outdated, downloading new version..."
    else
        echo "Server JAR not found, downloading..."
    fi
    
    # Download latest server JAR
    echo "Downloading from $CDN_URL/download/latest/HytaleServer.jar"
    if ! curl -sSL -f "$CDN_URL/download/latest/HytaleServer.jar" -o "${SERVER_JARFILE}.tmp"; then
        echo "ERROR: Failed to download server JAR"
        rm -f "${SERVER_JARFILE}.tmp"
        return 1
    fi
    
    # Verify SHA256
    DOWNLOADED_SHA256=$(sha256sum "${SERVER_JARFILE}.tmp" | awk '{print $1}')
    if [ "$DOWNLOADED_SHA256" != "$LATEST_SHA256" ]; then
        echo "ERROR: SHA256 mismatch!"
        echo "Expected: $LATEST_SHA256"
        echo "Got: $DOWNLOADED_SHA256"
        rm -f "${SERVER_JARFILE}.tmp"
        return 1
    fi
    
    echo "SHA256 verified successfully"
    mv "${SERVER_JARFILE}.tmp" "$SERVER_JARFILE"
    echo "Server JAR downloaded: $LATEST_VERSION"
    
    # Clean up
    rm -f manifest.json
    return 0
}

# Download/update server
download_server

# Verify server jar exists
if [ ! -f "$SERVER_JARFILE" ]; then
    echo "ERROR: Server JAR not found after download attempt"
    exit 1
fi

# Calculate memory
SERVER_MEMORY_REAL=$((SERVER_MEMORY * MAXIMUM_RAM / 100))

# Build startup command
STARTUP_CMD="java -Xms256M -Xmx${SERVER_MEMORY_REAL}M"
[ -n "$JVM_FLAGS" ] && STARTUP_CMD+=" $JVM_FLAGS"
STARTUP_CMD+=" -jar $SERVER_JARFILE --nogui --port $SERVER_PORT --world-dir $HYTALE_WORLD --config $HYTALE_CONFIG"

echo "Starting: $STARTUP_CMD"

# shellcheck disable=SC2086
exec $STARTUP_CMD
