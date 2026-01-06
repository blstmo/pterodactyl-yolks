#!/bin/bash

# Default the TZ environment variable to UTC.
TZ=${TZ:-UTC}
export TZ

# Set environment variable that holds the Internal Docker IP
INTERNAL_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
export INTERNAL_IP

# check if LOG_PREFIX is set
if [ -z "$LOG_PREFIX" ]; then
    LOG_PREFIX="\033[1m\033[33mcontainer@pterodactyl~\033[0m"
fi

# Switch to the container's working directory
cd /home/container || exit 1

# Print Java version
printf "${LOG_PREFIX} java -version\n"
java -version

JAVA_MAJOR_VERSION=$(java -version 2>&1 | awk -F '"' '/version/ {print $2}' | awk -F '.' '{print $1}')

if [[ "$OVERRIDE_STARTUP" == "1" ]]; then
    FLAGS=("-Dterminal.jline=false -Dterminal.ansi=true")

    # Add custom JVM flags if provided
    if [[ -n "$JVM_FLAGS" ]]; then
        FLAGS+=($JVM_FLAGS)
    fi

    # SIMD Operations are only for Java 16 - 21
    if [[ "$SIMD_OPERATIONS" == "1" ]]; then
        if [[ "$JAVA_MAJOR_VERSION" -ge 16 ]] && [[ "$JAVA_MAJOR_VERSION" -le 21 ]]; then
            FLAGS+=("--add-modules=jdk.incubator.vector")
        else
            echo -e "${LOG_PREFIX} SIMD Operations are only available for Java 16 - 21, skipping..."
        fi
    fi

    if [[ "$ADDITIONAL_FLAGS" == "Aikar's Flags" ]]; then
        FLAGS+=("-XX:+DisableExplicitGC -XX:+ParallelRefProcEnabled -XX:+PerfDisableSharedMem -XX:+UnlockExperimentalVMOptions -XX:+UseG1GC -XX:G1HeapRegionSize=8M -XX:G1HeapWastePercent=5 -XX:G1MaxNewSizePercent=40 -XX:G1MixedGCCountTarget=4 -XX:G1MixedGCLiveThresholdPercent=90 -XX:G1NewSizePercent=30 -XX:G1RSetUpdatingPauseTimePercent=5 -XX:G1ReservePercent=20 -XX:InitiatingHeapOccupancyPercent=15 -XX:MaxGCPauseMillis=200 -XX:MaxTenuringThreshold=1 -XX:SurvivorRatio=32 -Dusing.aikars.flags=https://mcflags.emc.gs -Daikars.new.flags=true")
    fi

    SERVER_MEMORY_REAL=$(($SERVER_MEMORY*$MAXIMUM_RAM/100))
    PARSED="java ${FLAGS[*]} -Xms256M -Xmx${SERVER_MEMORY_REAL}M -jar ${SERVER_JARFILE}"

    # Display the command we're running in the output, and then execute it with the env
    # from the container itself.
    printf "${LOG_PREFIX} %s\n" "$PARSED"
    # shellcheck disable=SC2086
    exec env ${PARSED}
else
    # Convert all of the "{{VARIABLE}}" parts of the command into the expected shell
    # variable format of "${VARIABLE}" before evaluating the string and automatically
    # replacing the values.
    PARSED=$(echo "${STARTUP}" | sed -e 's/{{/${/g' -e 's/}}/}/g' | eval echo "$(cat -)")

    # Display the command we're running in the output, and then execute it with the env
    # from the container itself.
    printf "${LOG_PREFIX} %s\n" "$PARSED"
    # shellcheck disable=SC2086
    exec env ${PARSED}
fi

