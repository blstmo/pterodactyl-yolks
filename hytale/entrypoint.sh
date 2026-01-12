#!/bin/bash

# Hytale Server Entrypoint
# Based on the official Hytale Server Manual
# https://support.hytale.com/hc/en-us/articles/45326769420827-Hytale-Server-Manual

# Default the TZ environment variable to UTC.
TZ=${TZ:-UTC}
export TZ

# Set environment variable that holds the Internal Docker IP
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# Check if LOG_PREFIX is set
if [ -z "$LOG_PREFIX" ]; then
    LOG_PREFIX="\033[1m\033[33mcontainer@pterodactyl~\033[0m"
fi

# Switch to the container's working directory
cd /home/container || exit 1

# Print Java version
printf "${LOG_PREFIX} java --version\n"
java --version

# Verify Java 25 is installed (recommended for Hytale)
JAVA_MAJOR_VERSION=$(java --version 2>&1 | head -1 | awk '{print $2}' | cut -d'.' -f1)
if [[ "$JAVA_MAJOR_VERSION" -lt 25 ]]; then
    echo -e "${LOG_PREFIX} \033[33mWarning: Hytale servers require Java 25. Current version: $JAVA_MAJOR_VERSION\033[0m"
fi

# Set default values if not provided
SERVER_JARFILE=${SERVER_JARFILE:-"hytale-server.jar"}
SERVER_PORT=${SERVER_PORT:-"5520"}
WORLD_DIR=${WORLD_DIR:-"world"}
CONFIG_FILE=${CONFIG_FILE:-"server.properties"}
MAXIMUM_RAM=${MAXIMUM_RAM:-"90"}
JVM_FLAGS=${JVM_FLAGS:-"-XX:+UseG1GC"}

# Check if server jar exists
if [ ! -f "$SERVER_JARFILE" ]; then
    echo -e "${LOG_PREFIX} \033[31mError: Server jar file '$SERVER_JARFILE' not found!\033[0m"
    echo -e "${LOG_PREFIX} Please upload the Hytale server files."
    echo -e "${LOG_PREFIX} Refer to: https://support.hytale.com/hc/en-us/articles/45326769420827-Hytale-Server-Manual"
    exit 1
fi

# Create world directory if it doesn't exist
if [ ! -d "$WORLD_DIR" ]; then
    echo -e "${LOG_PREFIX} Creating world directory: $WORLD_DIR"
    mkdir -p "$WORLD_DIR"
fi

# Calculate memory allocation
SERVER_MEMORY_REAL=$((SERVER_MEMORY * MAXIMUM_RAM / 100))

# Build the startup command following Hytale Server Manual guidelines
STARTUP_CMD="java"

# Add memory settings
STARTUP_CMD+=" -Xms256M -Xmx${SERVER_MEMORY_REAL}M"

# Add JVM flags (G1GC recommended)
if [ -n "$JVM_FLAGS" ]; then
    STARTUP_CMD+=" $JVM_FLAGS"
fi

# Add the jar file
STARTUP_CMD+=" -jar $SERVER_JARFILE"

# Add Hytale-specific arguments
STARTUP_CMD+=" --nogui"
STARTUP_CMD+=" --port $SERVER_PORT"
STARTUP_CMD+=" --world-dir $WORLD_DIR"
STARTUP_CMD+=" --config $CONFIG_FILE"

# Display the command we're running
printf "${LOG_PREFIX} %s\n" "$STARTUP_CMD"

# Execute the server
# shellcheck disable=SC2086
exec env ${STARTUP_CMD}
