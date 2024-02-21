# Ubuntu 22.04 Server Autoinstall ISO Generation Scripts

## Overview

This documentation covers two scripts designed to automate the creation of a custom Ubuntu 22.04 Server autoinstall ISO. These scripts streamline the process of setting up an Ubuntu Server with pre-configured settings using `cloud-init` and `user-data` files for unattended installations.

### Scripts

1. **setup_autoinstall_env.sh**: Prepares the environment for generating the autoinstall ISO.
2. **generate_autoinstall_iso.sh**: Generates the autoinstall ISO with custom or default `user-data`.

Create a new folder for managing the autoinstall ISO process. This folder will be used for downloading the Ubuntu ISO, script execution, and storing generated files:

1. **Create the Folder**:
    -    This is where the Ubuntu ISO will be downloaded, and the scripts will generate necessary files for customization and creating the final autoinstall image.

   ```bash
   mkdir UbuntuISOGenerator && cd UbuntuISOGenerator
   ```


2. **Add Scripts to This Folder**: 
   
   - Copy or move the `setup_autoinstall_env.sh` and `generate_autoinstall_iso.sh` scripts into the `UbuntuISOGenerator` folder.


3. **Make Scripts Executable**:   
    - To ensure the scripts are executable and ready to run, assign execute permissions using the `chmod` command. Open your terminal, navigate to the directory containing the scripts, and execute the following:

    ```bash
    chmod +x setup_autoinstall_env.sh generate_autoinstall_iso.sh
    ```

## 1. `setup_autoinstall_env.sh`

### Purpose

Prepares the necessary environment for ISO generation, including downloading the Ubuntu Server ISO, extracting its contents, and setting up the directory structure for the custom autoinstall configuration.

### Functionality

- Downloads the Ubuntu 22.04 Server ISO if it's not already present.
- Creates a working directory structure and extracts the ISO contents.
- Prepares the `grub.cfg` for unattended installation.

### How to Use

Execute the script without any parameters. Ensure you have sufficient permissions and internet connectivity for downloading the ISO.

```bash
./setup_autoinstall_env.sh
```

## 2. `generate_autoinstall_iso.sh`

### Purpose

Generates an Ubuntu 22.04 Server autoinstall ISO using a `user-data` file for automated installations. This script allows customization of the installation process through `user-data`, supporting different configurations and setups.

### Functionality

- Accepts a custom `user-data` file path as an optional parameter.
- Searches for a suitable `user-data` file in the current directory if no custom path is provided.
- Falls back to a default `user-data` file if no other options are found.
- Generates a new ISO that includes the `user-data` (and `meta-data` if necessary) for autoinstallations.

### How to Use

**Parameters:**

- Optional: Path to a custom `user-data` file.

```bash
./generate_autoinstall_iso.sh [path_to_custom_user_data_file]
```

**User-Data File Discovery Order:**

1. **Custom `user-data` File Path**: If provided as a parameter, this file is used for the autoinstall configuration.
   
2. **Current Directory Search**: If no custom path is provided, the script searches the current directory for files named `user-data`, `user-data.yaml`, or `user-data.yml`, excluding any files ending with `.bak`.

3. **Default `user-data` File**: If no custom or suitable file is found in the current directory, the script uses the default `user-data` file located at `${SERVER_DIR}/user-data`.

### Notes

- The script generates the ISO in the directory specified by `BUILD_DIR` and outputs the path to the generated ISO upon completion.
- Ensure the `xorriso` tool is installed and accessible for ISO generation.
- It's recommended to run the script in the directory where the Ubuntu Server ISO was prepared by `setup_autoinstall_env.sh`.


These scripts facilitate the creation of a custom Ubuntu Server 22.04 autoinstall ISO, making it easier to deploy Ubuntu Server installations with predefined configurations.