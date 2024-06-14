#!/bin/bash

# monitor.sh

CONFIG_DIR="$HOME/.config"
CONFIG_FILE="$CONFIG_DIR/external_monitor_config"

# Function to get the highest resolution of a monitor
get_highest_resolution() {
    xrandr --query | grep -A1 "^$1 connected" | tail -n 1 | awk '{print $1}'
}

# Function to set up the external monitor
setup_external_monitor() {
    local monitor=$1
    local direction=$2
    local mode=$(get_highest_resolution "$monitor")

    echo "Setting up $monitor in $direction of the built-in display with resolution $mode."
    xrandr --output "$monitor" --mode "$mode" --"$direction-of" eDP1

    # Save the command for future use
    mkdir -p "$CONFIG_DIR"
    echo "xrandr --output \"$monitor\" --mode \"$mode\" --\"$direction-of\" eDP1" > "$CONFIG_FILE"
}

# Function to load the last saved configuration
load_saved_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
        external_monitor=$(xrandr | grep ' connected' | grep -v 'eDP1' | awk '{print $1}')
        if [[ ! -z "$external_monitor" ]]; then
            echo "Applying saved monitor configuration."
            source "$CONFIG_FILE"
        else
            echo "No external monitor detected. Skipping configuration load."
        fi
    else
        echo "No saved configuration found."
    fi
}

# Main script
if [[ "$1" == "--load-config" ]]; then
    load_saved_config
else
    echo "Detecting connected displays..."
    external_monitor=$(xrandr | grep ' connected' | grep -v 'eDP1' | awk '{print $1}')

    if [[ -z "$external_monitor" ]]; then
        echo "No external monitors detected. Disconnecting any previous setup."
        xrandr --auto  # This resets to default display settings
    else
        echo "External monitor detected: $external_monitor"

        # Prompt user for input
        echo "Choose the position for the external monitor using arrow keys: LEFT | UP | RIGHT"
        echo "Press any other key to cancel"

        # Reading arrow key inputs
        while IFS= read -rsn1 key; do
            # Interpret input
            case $key in
                $'\x1b')    # First character of escape sequence
                    read -rsn2 -t 0.1 key  # Read next two chars
                    case $key in
                        '[D') setup_external_monitor "$external_monitor" "left" ;;
                        '[A') setup_external_monitor "$external_monitor" "above" ;;
                        '[C') setup_external_monitor "$external_monitor" "right" ;;
                        *) echo "Invalid input. Exiting." ;;
                    esac
                    break
                    ;;
                *) echo "Invalid input. Exiting."
                    break
                    ;;
            esac
        done
    fi
fi
