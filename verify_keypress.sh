#!/bin/bash

log_file="/tmp/keypress_events.log"

# Start logging keyboard events
start_logging() {
    # Clear previous log
    rm -f "$log_file"
    # Use ioreg to monitor keyboard events
    ioreg -w 0 -f -r -c IOHIDElement | grep -i keyboard > "$log_file" &
    echo $! > /tmp/logger.pid
}

# Stop logging
stop_logging() {
    if [ -f /tmp/logger.pid ]; then
        kill $(cat /tmp/logger.pid)
        rm /tmp/logger.pid
    fi
}

# Check if key event was registered
verify_keypress() {
    local start_time=$(date +%s)
    local key="$1"
    
    # Start monitoring
    start_logging
    
    # Wait briefly for event
    sleep 1
    
    # Check log for key event
    if grep -q "$key" "$log_file"; then
        echo "Key '$key' was registered by the system"
        return 0
    else
        echo "No system event found for key '$key'"
        return 1
    fi
    
    # Cleanup
    stop_logging
}

# Run verification
verify_keypress "$1"
