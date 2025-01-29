#!/bin/bash

# Check if CONDA_SYNC_IMPORTS is disabled
if [[ "$CONDA_SYNC_IMPORTS" == "0" ]]; then
    echo "Conda import sync is disabled. Skipping package checks."
    exit 0
fi

# Directory for import tracking
IMPORT_TRACK_DIR="$HOME/.conda_import_tracking"
REQUIREMENTS_FILE="$IMPORT_TRACK_DIR/requirements_conda.txt"
IMPORT_LOG="$IMPORT_TRACK_DIR/import_changes.log"

echo "Checking for new imports to install and redundant packages to remove..."

# Ensure the requirements file exists
if [[ ! -f "$REQUIREMENTS_FILE" ]]; then
    echo "No requirements file found. Skipping package checks."
    exit 0
fi

# Get the list of required packages from the requirements file
REQUIRED_PACKAGES=$(cat "$REQUIREMENTS_FILE")

# Get the list of currently installed packages in the environment
INSTALLED_PACKAGES=$(pip list --format=freeze | awk -F= '{print $1}')

# Determine packages to install
PACKAGES_TO_INSTALL=$(comm -23 <(echo "$REQUIRED_PACKAGES" | sort) <(echo "$INSTALLED_PACKAGES" | sort))

# Determine packages to uninstall
PACKAGES_TO_UNINSTALL=$(comm -13 <(echo "$REQUIRED_PACKAGES" | sort) <(echo "$INSTALLED_PACKAGES" | sort))

# Install new packages
if [[ -n "$PACKAGES_TO_INSTALL" ]]; then
    echo "Installing new packages..."
    echo "$PACKAGES_TO_INSTALL" | while read -r package; do
        if [[ -n "$package" ]]; then
            echo "Installing $package..."
            pip install "$package"
        fi
    done
else
    echo "No new packages to install."
fi

# Uninstall redundant packages
if [[ -n "$PACKAGES_TO_UNINSTALL" ]]; then
    echo "Removing redundant packages..."
    echo "$PACKAGES_TO_UNINSTALL" | while read -r package; do
        if [[ -n "$package" ]]; then
            echo "Uninstalling $package..."
            pip uninstall -y "$package"
        fi
    done
else
    echo "No redundant packages to remove."
fi

echo "Package synchronization complete."


