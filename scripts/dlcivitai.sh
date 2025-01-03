#!/bin/bash

# Check for CIVITAI_API_KEY environment variable
if [ -z "$CIVITAI_API_KEY" ]; then
  echo "Error: Environment variable CIVITAI_API_KEY not set. Please set it and try again."
  exit 1
fi

# Log file path
LOG_FILE="dlcivitai.log"

# Prompt user for the Civitai model URL
read -p "Enter the Civitai model URL: " model_url

# Extract the VersionId from the URL query parameter
version_id=$(echo "$model_url" | grep -oP 'modelVersionId=\K[0-9]+')
if [ -z "$version_id" ]; then
  echo "Error: Could not find modelVersionId in the URL. Please check the URL and try again."
  exit 1
fi

# Construct the download URL using the extracted VersionId
download_url="https://civitai.com/api/download/models/${version_id}"

# Extract title from the main page to use as the filename
title=$(curl -s "$model_url" | grep -oP '(?<=<title>).*?(?=</title>)')
if [ -z "$title" ]; then
  echo "Error: Unable to extract the model name from the URL. Please check the URL and try again."
  exit 1
fi

# Replace characters that are invalid in file names (e.g., / or \)
file_name=$(echo "$title" | sed 's/[\/\\]/_/g').safetensors

# Check if the file already exists and determine whether to resume download
if [ -f "$file_name" ]; then
  echo "Partial download detected. Resuming download for $file_name."
  resume_option="-C -"  # Resume from where it left off
else
  resume_option=""
fi

# Download the file using curl with the authorization header
curl -L -H "Authorization: Bearer $CIVITAI_API_KEY" $resume_option -o "$file_name" "$download_url"

# Check if the download was successful
if [ $? -eq 0 ]; then
  echo "Download completed successfully: $file_name"

  # Append log entry
  echo "$(date '+%Y-%m-%d %H:%M:%S') - URL: $model_url - Saved as: $file_name" >> "$LOG_FILE"
else
  echo "Download failed. Please check the URL or your API key and try again."

  # Append log entry for failure
  echo "$(date '+%Y-%m-%d %H:%M:%S') - URL: $model_url - FAILED" >> "$LOG_FILE"
fi