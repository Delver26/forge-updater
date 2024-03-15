#!/bin/bash

# Set the local path where the file will be downloaded and extracted
downloadPath="/home/delver/Applications/forge-gui"
extractPath="/home/delver/Applications/forge-gui"
baseUrl="https://downloads.cardforge.org/dailysnapshots/"

# Get the current version number from the local file
currentVersion=""
if [ -f "$downloadPath/version.txt" ]; then
    currentVersion=$(cat "$downloadPath/version.txt")
fi

# Function to extract file URL from website
fileName=$(wget -qO- $baseUrl | grep -o '<a [^>]*href="[^"]*"' | sed -e 's/<a [^>]*href="//' -e 's/"//g' | grep '^forge-gui-desktop')
webVersion="${fileName#forge-gui-desktop-}"  # Removing prefix "forge-gui-desktop-"
webVersion="${webVersion%.tar.bz2}"             # Removing suffix ".tar.bz2"
echo "web version: $webVersion"
echo "local version: $currentVersion"

# Compare versions
if [ "$webVersion" \> "$currentVersion" ]; then
    
    # Download the new version
    wget -O "$downloadPath/$fileName" "$baseUrl$fileName"

    # Extract the downloaded file
    tar -xjf "$downloadPath/$fileName" -C "$extractPath" --overwrite

    # Update the version file
    echo "$webVersion" > "$downloadPath/version.txt"

    echo "New version '$webVersion' downloaded and extracted."
else
    echo "No new version available."
fi

echo "Cleaning old versions..."

files_found=$(find "$extractPath" -type f -name "*.tar.bz2" ! -name "$fileName")

# Check if files are found
if [ -n "$files_found" ]; then
    echo "$(find "$extractPath" -type f -name "*.tar.bz2" ! -name "$fileName")"
    echo "Files found, deleting..."
    echo "$files_found" | xargs rm
    echo "done!"
else
    echo "No files found."
fi
