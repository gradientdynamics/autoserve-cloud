#!/bin/bash

# Exit immediately if a command exits with a non-zero status.
set -e

# Configuration variables
BUILD_DIR="$(pwd)/u22.04-autoinstall-ISO"
SOURCE_DIR="${BUILD_DIR}/source-files"
ISO_NAME="jammy-live-server-amd64.iso"
ISO_URL="https://cdimage.ubuntu.com/ubuntu-server/jammy/daily-live/current/${ISO_NAME}"
BOOT_DIR="${BUILD_DIR}/BOOT"
SERVER_DIR="${SOURCE_DIR}/server"
USER_DATA_FILE="${SERVER_DIR}/user-data"
META_DATA_FILE="${SERVER_DIR}/meta-data"
GRUB_TIMEOUT=2
GRUB_CFG="${SOURCE_DIR}/boot/grub/grub.cfg"
REQUIRED_SPACE_MB=5000 # Required space in MB

# Install necessary packages
install_packages() {
    echo "Installing necessary packages..."
    sudo apt-get update && sudo apt-get install -y p7zip-full wget xorriso
}

# Prepare the build directory
prepare_build_dir() {
    if [ -d "${BUILD_DIR}" ]; then
        read -rp "The directory ${BUILD_DIR} exists. Overwrite it? [y/N] " response
        if [[ $response =~ ^([yY][eE][sS]|[yY])$ ]]; then
            backup_user_data
            clean_build_dir
        else
            echo "Exiting without making changes."
            exit 1
        fi
    fi
}

backup_user_data() {
    if [ -f "${USER_DATA_FILE}" ]; then
        echo "Backing up user-data file..."
        cp "${USER_DATA_FILE}" "${USER_DATA_FILE}.bak"
        echo "user-data file backed up."
    fi
}

clean_build_dir() {
    echo "Cleaning up ${BUILD_DIR}, preserving ${ISO_NAME}..."
    find "${BUILD_DIR}" -mindepth 1 -not -name "${ISO_NAME}" -exec rm -rf {} +
}

# Check available disk space
check_disk_space() {
    local available_space_kb
    available_space_kb=$(df "${BUILD_DIR}" --output=avail | tail -n 1)
    available_space_mb=$((available_space_kb / 1024))

    if [ "${available_space_mb}" -lt "${REQUIRED_SPACE_MB}" ]; then
        echo "Insufficient disk space. Required: ${REQUIRED_SPACE_MB} MB, Available: ${available_space_mb} MB."
        exit 1
    fi
}

# Download the ISO if it doesn't already exist
download_iso() {
    if [ ! -f "${ISO_NAME}" ]; then
        echo "Downloading Ubuntu 22.04 server ISO..."
        wget -c "${ISO_URL}" -O "${ISO_NAME}"
    else
        echo "ISO ${ISO_NAME} already downloaded."
    fi
}

# Unpack ISO contents
unpack_iso() {
    echo "Unpacking the ISO..."
    7z x "${ISO_NAME}" -y -o"${SOURCE_DIR}"
}

# Organize boot files
organize_boot_files() {
    if [ -d "${SOURCE_DIR}/[BOOT]" ]; then
        echo "Organizing boot files..."
        mv "${SOURCE_DIR}/[BOOT]" "${BOOT_DIR}"
    else
        echo "Boot files already organized."
    fi
}

# Edit the grub.cfg file
edit_grub_cfg() {
    echo "Editing the grub.cfg file..."
    if [ ! -f "${GRUB_CFG}" ]; then
        echo "Grub configuration file does not exist."
        exit 1
    fi

    local new_menu_entry
    new_menu_entry=$(cat <<EOF
menuentry "Autoinstall Ubuntu Server" {
	set gfxpayload=keep
	linux	/casper/vmlinuz quiet autoinstall ds=nocloud\;s=/cdrom/server/ ---
	initrd	/casper/initrd
}
EOF
    )

    echo "Updating grub.cfg with new timeout and autoinstall menu entry..."
    awk -v timeout="$GRUB_TIMEOUT" -v new_entry="$new_menu_entry" '
        BEGIN { added=0; modified=0 }
        /^set timeout=[0-9]+$/ && !modified { print "set timeout="timeout; modified=1; next }
        /^menuentry/ && !added { print new_entry; added=1 }
        { print }
        END { if(!added) print new_entry }
    ' "$GRUB_CFG" > temp_grub.cfg && mv temp_grub.cfg "$GRUB_CFG"

    echo "Autoinstall menu entry added successfully."
}

# Prepare autoinstall configuration files
prepare_autoinstall_config() {
    echo "Preparing autoinstall configuration files..."
    mkdir -p "${SERVER_DIR}"

    if [ ! -f "${USER_DATA_FILE}.bak" ]; then
        create_user_data_file
    else
        restore_user_data_file
    fi

    touch "${META_DATA_FILE}"
}

create_user_data_file() {
    echo "Creating new user-data file..."
    cat <<EOF >"${USER_DATA_FILE}"
#cloud-config
autoinstall:
  version: 1
  identity:
    hostname: ubuntu-server
    username: ubuntu
    password: \$6\$i6Jsr8GaCvRCGpua\$argpe0Rl6VlwHg03FTo9DsJ0WIElY61MYYhrJYBCPI026SNIhrDfnkVwFuihU.dODs6kp2xNRmonFf8gmf.HS/
# Password is "ubuntu"
EOF
}

restore_user_data_file() {
    echo "Restoring user-data file from backup."
    if [ -f "${USER_DATA_FILE}.bak" ]; then
        mv "${USER_DATA_FILE}.bak" "${USER_DATA_FILE}"
    else
        echo "Backup of user-data file not found. Cannot restore."
        exit 1
    fi
}

main() {
    install_packages
    prepare_build_dir
    check_disk_space
    cd "${BUILD_DIR}"
    download_iso
    unpack_iso
    organize_boot_files
    edit_grub_cfg
    prepare_autoinstall_config
    echo "Autoinstall ISO preparation script completed successfully."
}

main "$@"
