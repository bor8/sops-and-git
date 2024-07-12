#!/bin/bash
set -e -u  # Exit immediately if a command exits with a non-zero status and treat unset variables as an error

echo "The script $0 is executed and encrypts certain YAML, YML, and JSON files"  # Print a message indicating the script's purpose

# Get the directory of the current script
SCRIPT_DIR=$(dirname "$(realpath "$0")")

ACTION=0  # Initialize an ACTION variable to track if any files were encrypted

# Function to read .sopsignore and compile regex patterns
get_ignored_files() {
    if [ -f "${SCRIPT_DIR}/.sopsignore" ]; then
        while IFS= read -r LINE || [[ -n "${LINE}" ]]; do
            # Skip empty lines and comments
            if [[ -z "${LINE}" || "${LINE}" =~ ^\s*# ]]; then
                continue
            fi
            # Collect regex patterns
            IGNORED_FILES+=("${LINE}")
        done < "${SCRIPT_DIR}/.sopsignore"
    fi
}

# Determine whether to encrypt staged files or all files
if [ "${1:-}" == "--staged-files-only" ]; then
    FILES_TO_ENCRYPT=$(git diff --cached --name-only --diff-filter=ACM)
else
    REPO_ROOT=$(git rev-parse --show-toplevel)
    ALL_FILES=$(find "${REPO_ROOT}" -iregex '^.*\.\(yaml\|yml\|json\)$')
    FILES_TO_ENCRYPT=${ALL_FILES}
fi

IFS=$'\n'  # Set the internal field separator to newline to handle filenames with spaces

# Initialize an array to hold ignored file patterns
IGNORED_FILES=()
get_ignored_files

for FILE in ${FILES_TO_ENCRYPT}; do  # Loop through each file in the list
    # Check if the file should be ignored
    IGNORE=false
    for PATTERN in "${IGNORED_FILES[@]}"; do
        if [[ "${FILE}" =~ ${PATTERN} ]]; then
            IGNORE=true
            break
        fi
    done
    if $IGNORE; then
        echo "Ignoring file: ${FILE}"
        continue
    fi

    if [[ "${FILE}" =~ \.(yaml|yml|json)$ ]]; then  # Check if the file has a YAML, YML, or JSON extension
        if sops --config ~/.sops.yaml -e "${FILE}" | grep -m 1 -P -q '(?!mac: )ENC\['; then  # Check if the temporary output contains encrypted data
            ACTION=1  # Set ACTION to 1 to indicate that a file was encrypted
            echo "Encrypting file and re-add: ${FILE}"  # Print a message indicating the file is being encrypted and re-added
            sops --config ~/.sops.yaml -e -i "${FILE}"  # Encrypt the file in place
	    if [ "${1:-}" == "--staged-files-only" ]; then
                git add "${FILE}"  # Add the encrypted file back to the staging area
            fi
        fi
    fi
done
unset IFS  # Reset the internal field separator to its default value

# Inform if no files were encrypted
if [ ${ACTION} -eq 0 ]; then  # Check if no files were encrypted
    echo "Nothing was encrypted"  # Print a message indicating that no files were encrypted
fi

