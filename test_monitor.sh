#!/bin/bash


MONITOR_DIR="sample_dir"
IS_MONITORING="NO"
# Function to monitor directory and write CLOSE_WRITE events to a file (excluding .swp files)
monitor_directory() {
    # Store the process ID of inotifywait
    inotifywait -q -m -e close_write --exclude '\.swp$' --format "%w%f " "$1" -o events.log &
    INOTIFY_PID=$!
    IS_MONITORING="YES"
    
}

# Function to tail the events file and display them using dialog
display_events() {
    while true; do
        dialog --title "Monitoring $MONITOR_DIR" --backtitle "ACTIVELY RUNNING: $IS_MONITORING" --tailbox events.log 20 50
        status=$?
        case $status in
            0)
                # User pressed "OK" or Enter
                stop_monitoring
                dialog --title "Message" --msgbox "You pressed Enter. Stopping monitoring. ACTIVE: $IS_MONITORING" 10 30
                break
                ;;
        esac
    done
}

# Function to stop monitoring
stop_monitoring() {
    # Kill the inotifywait process
    if [ -n "$INOTIFY_PID" ]; then
        kill -TERM $INOTIFY_PID 
        IS_MONITORING="NO"
    fi
}

# Function to start monitoring
start_monitoring() {
    monitor_directory $MONITOR_DIR 
    display_events 
}

# Function to display the menu
display_menu() {
    status_line="[ Monitoring State: $IS_MONITORING ]"
    dialog --no-ok --no-cancel --title "Main Menu" --backtitle "ACTIVELY RUNNING: $IS_MONITORING" --menu "Choose an option:" 12 40 4 \
        "1" "Start Monitoring" \
        "2" "Stop Monitoring" \
        "3" "Exit" \
        2>&1 >/dev/tty
}

# Main loop to handle user input
while true; do
    choice=$(display_menu)
    case $choice in
        "1")  ##start button
            start_monitoring
            ;;
        "2") ##stop button
            stop_monitoring 
            ;;
        "3")  ##exit button
            stop_monitoring 
            clear
            echo "Goodbye"
            break
            ;;
    esac
done
