#!/bin/bash

# Directory to store tracked imports
IMPORT_TRACK_DIR="$HOME/.conda_import_tracking"
IMPORT_LOG="$IMPORT_TRACK_DIR/import_changes.log"
CURRENT_IMPORTS_FILE="$IMPORT_TRACK_DIR/current_imports.txt"
REQUIREMENTS_FILE="$IMPORT_TRACK_DIR/requirements_conda.txt"

# Ensure the tracking directory exists
mkdir -p "$IMPORT_TRACK_DIR"

# Temporary file for detected imports
TEMP_IMPORTS_FILE="$(mktemp)"

# Extract imported packages from all .py files
echo "Scanning .py files for imported packages..."
find . -type f -name "*.py" | while read -r file; do
    # Extract lines starting with "import" or "from"
    grep -E '^\s*(import|from) ' "$file" | awk '{print $2}' | cut -d '.' -f 1
done | sort | uniq > "$TEMP_IMPORTS_FILE"

# Compare with the previous requirements file
if [[ -f "$REQUIREMENTS_FILE" ]]; then
    NEW_IMPORTS=$(comm -23 "$TEMP_IMPORTS_FILE" "$REQUIREMENTS_FILE")
    REMOVED_IMPORTS=$(comm -13 "$TEMP_IMPORTS_FILE" "$REQUIREMENTS_FILE")
else
    echo "No previous requirements file found. Assuming all imports are new."
    cp "$TEMP_IMPORTS_FILE" "$CURRENT_IMPORTS_FILE"
    NEW_IMPORTS=$(cat "$TEMP_IMPORTS_FILE")
    REMOVED_IMPORTS=""
fi

# Log changes
if [[ -n "$NEW_IMPORTS" || -n "$REMOVED_IMPORTS" ]]; then
    echo "Changes detected in imports:" >> "$IMPORT_LOG"
    [[ -n "$NEW_IMPORTS" ]] && echo -e "New imports:\n$NEW_IMPORTS" >> "$IMPORT_LOG"
    [[ -n "$REMOVED_IMPORTS" ]] && echo -e "Removed imports:\n$REMOVED_IMPORTS" >> "$IMPORT_LOG"
    echo "" >> "$IMPORT_LOG"
fi

# Update the requirements file
mv "$TEMP_IMPORTS_FILE" "$REQUIREMENTS_FILE"

# Cleanup temporary file
rm -f "$TEMP_IMPORTS_FILE"


