#!/bin/bash

# URL of the remote Python script
REMOTE_SCRIPT_URL="https://trustmeow.github.io/scripts/hp/menu.py"

# Temporary file to store the downloaded script
TEMP_SCRIPT=$(mktemp /tmp/remote-script.XXXXXX.py)

# Check if curl is available
if ! command -v curl &> /dev/null; then
    echo "Error: curl is required but not installed. Please install curl first."
    exit 1
fi

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is required but not installed. Please install Python 3 first."
    exit 1
fi

# Download the script
echo "Downloading script from $REMOTE_SCRIPT_URL..."
if ! curl -s -o "$TEMP_SCRIPT" "$REMOTE_SCRIPT_URL"; then
    echo "Error: Failed to download the script."
    exit 1
fi

# Verify the script was downloaded (non-empty)
if [ ! -s "$TEMP_SCRIPT" ]; then
    echo "Error: Downloaded script is empty."
    rm -f "$TEMP_SCRIPT"
    exit 1
fi

# Execute the script
echo "Running the script..."
python3 "$TEMP_SCRIPT"

# Clean up
rm -f "$TEMP_SCRIPT"
echo "Done."
