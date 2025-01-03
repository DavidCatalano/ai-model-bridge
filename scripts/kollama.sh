#!/usr/bin/env bash
#
# sync.sh
#
# Description:
#   - Lists discovered model manifests (only showing model names in whiptail),
#   - Uses an associative array to store hashed-file info (not shown in the menu),
#   - Links checked models (symlinks), unlinks unchecked ones,
#   - Leaves real/copied files intact (removes only symlinks).
#
# Requirements:
#   - Bash 4+ (associative arrays)
#   - whiptail (usually in the 'newt' package)
#   - jq

###############################################################################
# ADJUST THESE PATHS AS NEEDED
###############################################################################
koboldcpp_dir="/data/LLM/kobold"
ollama_dir="/data/LLM/ollama"

###############################################################################
# GLOBALS
###############################################################################
declare -A MODEL_HASH_MAP  # key = model_name, value = hashed_file
declare -a MENU_ARRAY=()   # array for whiptail arguments
declare -a ALL_MODELS=()   # array of all discovered model names

###############################################################################
# Check dependencies & directories
###############################################################################
if ! command -v jq &>/dev/null; then
    echo "ERROR: 'jq' is not installed."
    exit 1
fi

if [[ ! -d "$koboldcpp_dir" ]]; then
    echo "ERROR: koboldcpp_dir does not exist: $koboldcpp_dir"
    exit 1
fi

if [[ ! -d "$ollama_dir" ]]; then
    echo "ERROR: ollama_dir does not exist: $ollama_dir"
    exit 1
fi

###############################################################################
# Function to find manifest files
###############################################################################
get_model_files() {
    find "$ollama_dir/models/manifests" -type f
}

###############################################################################
# Build whiptail checklist items
#   We'll store hashed_file in MODEL_HASH_MAP, but whiptail sees only:
#     <model_name> <dummy_display> <ON|OFF>
###############################################################################
generate_menu_options() {
    local files="$1"

    while IFS= read -r file_path; do
        # Example: /data/LLM/ollama/models/manifests/Anubis-70B-v1-GGUF/Q4_K_L
        parent_dir=$(basename "$(dirname "$file_path")")
        quant=$(basename "$file_path")

        # Extract hashed file from JSON
        hashed_file=$(jq -r '
            .layers[] 
            | select(.mediaType == "application/vnd.ollama.image.model")
            | .digest
        ' "$file_path")
        hashed_file="${hashed_file#sha256:}"  # strip "sha256:"

        # Construct final model name (no spaces or quotes)
        model_name="${parent_dir}-${quant}"

        # Symlink name & target
        symlink_name="${koboldcpp_dir}/${model_name}.gguf"
        target_file="${ollama_dir}/models/blobs/sha256-${hashed_file}"

        # Default ON if there's already a symlink pointing to that target
        if [[ -L "$symlink_name" && "$(readlink -f "$symlink_name")" == "$target_file" ]]; then
            default_state="ON"
        else
            default_state="OFF"
        fi

        # Save hashed_file in an associative array
        MODEL_HASH_MAP["$model_name"]="$hashed_file"
        # Keep track of this model (for linking/unlinking later)
        ALL_MODELS+=("$model_name")

        # Add three arguments to MENU_ARRAY for whiptail:
        #   1) The "tag" (model_name)
        #   2) The "item" for display (we use a dash, so user sees e.g. "Midnight-Miqu-70B ...  -  ON")
        #   3) Default ON/OFF
        MENU_ARRAY+=( "$model_name" "" "$default_state" )
    done <<< "$files"
}

###############################################################################
# MAIN SCRIPT
###############################################################################

# 1) Gather all manifest files
model_files=$(get_model_files)
if [[ -z "$model_files" ]]; then
    echo "No manifest files found under '$ollama_dir/models/manifests'."
    exit 0
fi

# 2) Build an array of menu options
generate_menu_options "$model_files"

# 3) Show the whiptail checklist, passing the array
selection=$(
    whiptail --title "Manage Koboldcpp Models" \
             --checklist "Select Ollama models to link or unlink:" \
             20 78 12 \
             "${MENU_ARRAY[@]}" \
             3>&1 1>&2 2>&3
)

# If user hits Cancel or whiptail fails
if [[ $? -ne 0 ]]; then
    echo "Operation canceled."
    exit 0
fi

# Whiptail returns a string of double-quoted model names, e.g.:
#   "\"Midnight-Miqu-70B-v1.5-GGUF-IQ4_XS\" \"Mistral-Small-22B-ArliAI-RPMax...\""
# We'll parse that into a bash array:
IFS=' ' read -r -a selected_array <<< "$selection"

# Remove leading/trailing quotes from each selected item
selected_array_no_quotes=()
for sel in "${selected_array[@]}"; do
    tmp="${sel#\"}"  # remove leading quote
    tmp="${tmp%\"}"  # remove trailing quote
    selected_array_no_quotes+=( "$tmp" )
done

echo "User selected: ${selected_array_no_quotes[*]}"

###############################################################################
# 4) For every discovered model, link if selected, unlink if not selected
###############################################################################
for model in "${ALL_MODELS[@]}"; do
    symlink_name="${koboldcpp_dir}/${model}.gguf"
    hashed_file="${MODEL_HASH_MAP["$model"]}"
    target_file="${ollama_dir}/models/blobs/sha256-${hashed_file}"

    # Determine if user checked this model
    found=false
    for sel_item in "${selected_array_no_quotes[@]}"; do
        if [[ "$sel_item" == "$model" ]]; then
            found=true
            break
        fi
    done

    if $found; then
        # Link
        echo "Linking: $model -> $target_file"
        ln -sf "$target_file" "$symlink_name"
    else
        # Unlink if it's a symlink
        if [[ -L "$symlink_name" ]]; then
            echo "Unlinking symlink: $model"
            rm -f "$symlink_name"
        else
            echo "Skipping removal of '$symlink_name' (not a symlink)."
        fi
    fi
done

echo "Script completed."
