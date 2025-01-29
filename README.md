# Conda Package Manager

This repository contains scripts to **automatically track imported Python packages** from your `.py` files and **synchronize them** with a Conda environment.

Since this is automatic, please do **NOT** use these scripts in conda environments you are maintaining as it could cause dependency issues. \newline
Use these scripts in conda environments you explore or experiment in


## Installation Instructions

### Clone the Repository
```
git clone <repo_url>
cd <repo_name>
```

### Ensure Conda is Installed
If Conda is not installed, download it from https://docs.conda.io/projects/conda/en/stable/user-guide/install/index.html.

### Activate Your Conda Environment
`conda activate <your_env_name>`

### Set Up the Conda Hooks Directory
Conda allows automatic execution of scripts upon environment activation and deactivation. These hooks are stored in:
```
$CONDA_PREFIX/etc/conda/{activate.d, deactivate.d}
```
Create the required directories if they do not exist:
```
mkdir -p "$CONDA_PREFIX/etc/conda/activate.d"
mkdir -p "$CONDA_PREFIX/etc/conda/deactivate.d"
```

### Install the Hook Scripts
#### Install Post-Activation Script (post_activation.sh)

This script:

- Tracks imported Python packages in .py files
- Updates the requirements file
- Syncs Conda packages based on detected imports

Copy it to the Conda activation hook directory:
```
cp post_activation.sh "$CONDA_PREFIX/etc/conda/activate.d/"
chmod +x "$CONDA_PREFIX/etc/conda/activate.d/post_activation.sh"
```

#### Install Pre-Deactivation Script (pre_deactivation.sh)

This script runs before the Conda environment is deactivated, allowing:

- Logging package changes
- Tracking modifications before environment closure
- Copy it to the Conda deactivation hook directory:
```
cp pre_deactivation.sh "$CONDA_PREFIX/etc/conda/deactivate.d/"
chmod +x "$CONDA_PREFIX/etc/conda/deactivate.d/pre_deactivation.sh"
```

### Set Up the Import Tracking Directory
These scripts rely on a tracking directory to store package information:
```
mkdir -p "$HOME/.conda_import_tracking"
touch "$HOME/.conda_import_tracking/requirements_conda.txt"
touch "$HOME/.conda_import_tracking/import_changes.log"
```

## How It Works

### Tracking Imports from Python Files
The **post_activation.sh** script:

- Scans all .py files in the current directory
- Extracts package names from import and from ... import statements
- Updates requirements_conda.txt with detected imports
- Logs newly added or removed imports to import_changes.log
  
### Synchronizing with Conda Environment
The **post_activation.sh** script:

- Reads requirements_conda.txt
- Installs missing packages
- Uninstalls unnecessary packages

### Logging Package Changes Before Deactivation
The **pre_deactivation.sh** script:

- Logs environment package modifications
- Can be modified for additional cleanup tasks

### Automatic Execution
Both scripts automatically run during Conda environment activation and deactivation.

## How to Enable/Disable Auto-Sync

By default, post_activation.sh runs every time a Conda environment is activated.

### Disable Auto-Sync (Temporarily)
To skip package synchronization for a session, use:
```
export CONDA_SYNC_IMPORTS=0
conda activate <your_env_name>
```

### Re-enable Auto-Sync
```
unset CONDA_SYNC_IMPORTS
conda activate <your_env_name>
```

### Permanently Disable Auto-Sync
To disable auto-sync for all Conda activations, add this line to your ~/.bashrc, ~/.zshrc, or shell profile:

`export CONDA_SYNC_IMPORTS=0`
Then restart the terminal.

### Disable Auto-Sync for One Conda Environment
To disable auto-sync only for a specific Conda environment, modify its activation script:

1. Open the Conda activation script:
`nano "$CONDA_PREFIX/etc/conda/activate.d/post_activation.sh"`
2. Add this line at the top:
`export CONDA_SYNC_IMPORTS=0  # Change to 1 to enable`
3. Save and exit.


## Running Scripts Manually

You can also run the scripts manually if needed.

### Manually Track Python Imports
To detect all imported packages and update the tracked requirements file:

`bash post_activation.sh`

### Manually Sync Conda Environment
To install missing packages and remove unused ones:

`bash post_activation.sh`

### Manually Log Pre-Deactivation Information
To log package changes before deactivation:

`bash pre_deactivation.sh`

## Uninstalling the Hook

To remove the scripts from the Conda activation and deactivation process:
```
rm "$CONDA_PREFIX/etc/conda/activate.d/post_activation.sh"
rm "$CONDA_PREFIX/etc/conda/deactivate.d/pre_deactivation.sh"
```
To completely remove the tracking setup:

`rm -rf "$HOME/.conda_import_tracking"`

## Troubleshooting

### "Permission denied"
Make sure the scripts have execution permission:
```
chmod +x "$CONDA_PREFIX/etc/conda/activate.d/post_activation.sh"
chmod +x "$CONDA_PREFIX/etc/conda/deactivate.d/pre_deactivation.sh"
```

### "Script doesn’t run on activation"
Ensure Conda activation scripts are enabled by checking:

`conda config --show`

### "No requirements file found. Skipping package checks."
Ensure that ~/.conda_import_tracking/requirements_conda.txt exists and is populated.

### "Packages aren’t syncing correctly"
Ensure requirements_conda.txt contains package names without versions (only the package name is used).
Ensure the environment variable CONDA_SYNC_IMPORTS=0 is not set if you expect the script to run.
