#!/bin/bash


# Copyright 2024-present Gradient Dynamics LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.


set -e  # Exit immediately if a command exits with a non-zero status.

# Configuration variables.
BUILD_DIR="$(pwd)/u22.04-autoinstall-ISO"
SOURCE_DIR="${BUILD_DIR}/source-files"
BOOT_DIR="${BUILD_DIR}/BOOT"
INPUT_ISO="jammy-live-server-amd64.iso"
OUTPUT_ISO="${BUILD_DIR}/ubuntu-22.04-autoinstall.iso"
SERVER_DIR="${SOURCE_DIR}/server"
DEFAULT_USER_DATA_FILE="${SERVER_DIR}/user-data"
META_DATA_FILE="${SERVER_DIR}/meta-data"
USER_DATA_FILE_USED=""  # Variable to track the full path of the user-data file used

# Ensures the creation of essential directories.
ensure_directories() {
    echo "Ensuring necessary directories exist..."
    mkdir -p "${SERVER_DIR}"
}

# Copies the user-data file to the server directory and ensures meta-data file exists.
copy_user_data() {
    local full_path
    full_path=$(realpath "$1")
    echo "Copying user-data file to server directory: ${full_path}"
    cp "${full_path}" "${DEFAULT_USER_DATA_FILE}"
    USER_DATA_FILE_USED="${full_path}"

    # Ensure the meta-data file exists.
    if [ ! -f "${META_DATA_FILE}" ]; then
        touch "${META_DATA_FILE}"
        echo "meta-data file created."
    fi
}

# Searches for user-data files in the current directory or uses the default.
find_user_data() {
    local files=("user-data" "user-data.yaml" "user-data.yml")
    for file in "${files[@]}"; do
        if [ -f "$file" ] && [[ ! "$file" =~ \.bak$ ]]; then
            copy_user_data "$(pwd)/$file"
            return 0
        fi
    done

    # Fallback to the default user-data file if no other is found.
    if [ -f "${DEFAULT_USER_DATA_FILE}" ]; then
        echo "Using default user-data file."
        USER_DATA_FILE_USED="${DEFAULT_USER_DATA_FILE}"  # Update to default if used
        return 0
    else
        echo "No suitable user-data file found or provided. Exiting."
        exit 1
    fi
}

# Handles the selection and copying of the user-data file.
handle_user_data() {
    local custom_user_data_file="$1"
    if [ -n "${custom_user_data_file}" ]; then
        if [ ! -f "${custom_user_data_file}" ]; then
            echo "Error: The specified user-data file does not exist: ${custom_user_data_file}"
            exit 1
        fi
        copy_user_data "${custom_user_data_file}"
    else
        find_user_data || exit 1
    fi
}

# Generates the autoinstall ISO with the provided or found user-data file.
generate_iso() {
    echo "Generating new Ubuntu 22.04 server autoinstall ISO..."
    xorriso -indev "${INPUT_ISO}" -report_el_torito as_mkisofs

    cd "${SOURCE_DIR}" || exit 1

    xorriso -as mkisofs -r \
      -V 'Ubuntu 22.04 LTS AUTO (EFIBIOS)' \
      -o "${OUTPUT_ISO}" \
      --grub2-mbr "${BOOT_DIR}/1-Boot-NoEmul.img" \
      -partition_offset 16 \
      --mbr-force-bootable \
      -append_partition 2 28732ac11ff8d211ba4b00a0c93ec93b "${BOOT_DIR}/2-Boot-NoEmul.img" \
      -appended_part_as_gpt \
      -iso_mbr_part_type a2a0d0ebe5b9334487c068b6b72699c7 \
      -c "/boot.catalog" \
      -b "/boot/grub/i386-pc/eltorito.img" \
        -no-emul-boot -boot-load-size 4 -boot-info-table --grub2-boot-info \
      -eltorito-alt-boot \
      -e "--interval:appended_partition_2:::" \
      -no-emul-boot \
      .

    echo "Autoinstall ISO generated successfully: ${OUTPUT_ISO}"
}

# Main script execution.
main() {
    ensure_directories
    handle_user_data "$1"
    generate_iso
    echo "User-data file used: ${USER_DATA_FILE_USED}"
}

main "$@"
