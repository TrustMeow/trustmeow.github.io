#!/bin/bash

# Check if Firefox is installed
if ! command -v firefox &> /dev/null
then
    echo "Firefox is not installed. Please install Firefox first."
    exit 1
fi

# Open the website in Firefox
firefox "https://trustmeow.github.io" &
