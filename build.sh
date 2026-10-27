#!/bin/bash

# Configuration variables
FINAL_ZIP_NAME="cloudscaile.starterTemplateExperience"
FOLDERS=('web' 'js')
SKIP_ROOT=('build.sh')

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored messages
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to cleanup temporary directory
cleanup() {
    if [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]]; then
        print_info "Cleaning up temporary directory: $TEMP_DIR"
        rm -rf "$TEMP_DIR"
    fi
}

# Set up trap to cleanup on exit
trap cleanup EXIT

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_error "Not in a git repository. Please run this script from within a git repository."
    exit 1
fi

# Create temporary directory
TEMP_DIR=$(mktemp -d)
if [[ ! -d "$TEMP_DIR" ]]; then
    print_error "Failed to create temporary directory"
    exit 1
fi

print_info "Created temporary directory: $TEMP_DIR"

# Create git archive and extract to temporary directory
print_info "Creating git archive..."
ARCHIVE_FILE="$TEMP_DIR/archive.zip"
if ! git archive --format=zip HEAD > "$ARCHIVE_FILE"; then
    print_error "Failed to create git archive"
    exit 1
fi

if ! (cd "$TEMP_DIR" && unzip -q "archive.zip"); then
    print_error "Failed to extract git archive"
    exit 1
fi

# Remove the archive file as it's no longer needed
rm -f "$ARCHIVE_FILE"

print_info "Git archive extracted to temporary directory"

# Process each folder in the FOLDERS array
for folder in "${FOLDERS[@]}"; do
    folder_path="$TEMP_DIR/$folder"
    
    if [[ ! -d "$folder_path" ]]; then
        print_warning "Folder '$folder' not found in repository, skipping..."
        continue
    fi
    
    print_info "Processing folder: $folder"
    
    # Navigate to the folder and create zip
    if ! (cd "$folder_path" && zip -r "../${folder}.zip" . > /dev/null 2>&1); then
        print_error "Failed to create zip for folder: $folder"
        exit 1
    fi
    
    print_info "Created ${folder}.zip"
    
    # Remove the original folder
    if ! rm -rf "$folder_path"; then
        print_error "Failed to remove original folder: $folder"
        exit 1
    fi
    
    print_info "Removed original folder: $folder"
done

# Remove files and folders specified in SKIP_ROOT array
for skip_item in "${SKIP_ROOT[@]}"; do
    skip_path="$TEMP_DIR/$skip_item"
    
    if [[ -e "$skip_path" ]]; then
        print_info "Removing skipped item: $skip_item"
        if ! rm -rf "$skip_path"; then
            print_error "Failed to remove skipped item: $skip_item"
            exit 1
        fi
    else
        print_warning "Skipped item '$skip_item' not found in repository"
    fi
done

# Create final zip file
print_info "Creating final zip file: ${FINAL_ZIP_NAME}.zip"
if ! (cd "$TEMP_DIR" && zip -r "../${FINAL_ZIP_NAME}.zip" . > /dev/null 2>&1); then
    print_error "Failed to create final zip file"
    exit 1
fi

# Move final zip to current directory
if ! mv "$TEMP_DIR/../${FINAL_ZIP_NAME}.zip" "./"; then
    print_error "Failed to move final zip file to current directory"
    exit 1
fi

print_info "Successfully created ${FINAL_ZIP_NAME}.zip in current directory"

# Check final zip file size
if [[ -f "${FINAL_ZIP_NAME}.zip" ]]; then
    file_size=$(du -h "${FINAL_ZIP_NAME}.zip" | cut -f1)
    print_info "Final zip file size: $file_size"
fi

print_info "Script completed successfully!"