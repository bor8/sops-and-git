#!/bin/bash
set -e -u  # Exit immediately if a command exits with a non-zero status and treat unset variables as an error

PARENT_PID=$(ps -o ppid= -p $$)
PARENT_NAME=$(ps -o comm= -p $PARENT_PID)

echo "The script ${PARENT_NAME} -> $0 is executed and decrypts certain YAML, YML, and JSON files"  # Print a message indicating the script's purpose

is_rebase_in_progress() {
    if [ -d "$(git rev-parse --git-dir)/rebase-apply" ] || [ -d "$(git rev-parse --git-dir)/rebase-merge" ]; then
        return 0
    else
        return 1
    fi
}

if is_rebase_in_progress; then
    echo "Rebase in action - skip"
    exit 0
fi

ACTION=0  # Initialize an ACTION variable to track if any files were decrypted
REPO_ROOT=$(git rev-parse --show-toplevel)
FILES_TO_DECRYPT=$(find "${REPO_ROOT}" -type f -iregex '^.*\.\(yaml\|yml\|json\)$' -exec realpath '{}' \;)  # Define the files or directories you want to decrypt
IFS=$'\n'  # Set the internal field separator to newline to handle filenames with spaces

for FILE in ${FILES_TO_DECRYPT}; do
    if grep -q 'ENC\[' "${FILE}"; then  # Check if the file contains encrypted data
        ACTION=1  # Set ACTION to 1 to indicate that a file was decrypted
        echo "Decrypting file in place: ${FILE}"  # Print a message indicating the file is being decrypted
        sops --config ~/.sops.yaml -d -i "${FILE}" || true
    fi
done
unset IFS  # Reset the internal field separator to its default value

if [ ${ACTION} -eq 0 ]; then
    echo "Nothing was decrypted"
fi

