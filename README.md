
# AutoServe

AutoServe is a utility designed to simplify the process of creating a customized Ubuntu Server 22.04 LTS autoinstall ISO with cloud-init. 

It automates the preparation of `user-data` YAML file and provides scripts to facilitate the generation of the ISO, making it easy to deploy Ubuntu Server configurations at scale.

AutoServe's `user-data` configuration tool is freely accessible via [AutoServe Cloud](https://autoserve-cloud.web.app/).

---

# Creating and Verifying an Autoinstall ISO with Cloud-Init for Ubuntu Server 22.04 LTS

This guide offers step-by-step instructions for creating a customized Ubuntu Server 22.04 LTS autoinstall ISO using cloud-init and verifying its configurations on a virtual machine (VM). 
The process entails preparing a `user-data` YAML file for cloud-init, building the ISO, transferring it to a VM, and verifying the installation.

---
## Quick Reference
1. **Prepare `user-data`:** Edit or replace the `user-data` file with custom configurations for Cloud-Init manually, or by using this package (available for local build or via [AutoServe Cloud](https://autoserve-cloud.web.app/)).
2. **Setup Environment:** Use `/scripts/setup_autoinstall_env.sh` to prepare your system, ensuring dependencies are installed and the Ubuntu Server ISO is downloaded.
3. **Generate ISO:** Execute `/scripts/generate_autoinstall_iso.sh` to create the custom autoinstall ISO.
4. **Install and Verify:** Mount the ISO on a VM, install, and verify by checking system configurations and files, such as `cat /var/log/installer/autoinstall-user-data` to inspect the final configuration and `df -Thv` for partitions and storage information.

* For more comprehensive instructions, see below.

---

## Prerequisites

Before you begin, ensure you have the following:
- A Linux environment with internet access and at least 5GB of disk space available.
- A pre-configured VM for testing the autoinstall ISO (hereafter referred to as `ubuntu22.04-vm`).
- The scripts located in `/scripts`. See [`/scripts/README.md`](https://github.com/gradientdynamics/autoserve-cloud/blob/master/scripts/autoinstall/README.md) for more details.

### Setting up the Environment

Two scripts are designed to automate the creation of a custom Ubuntu 22.04 Server autoinstall ISO:
- **setup_autoinstall_env.sh**: Prepares the environment for generating the autoinstall ISO.
- **generate_autoinstall_iso.sh**: Generates the autoinstall ISO with either custom or default `user-data`.

#### Prepare the Directory

Create a new folder for managing the autoinstall ISO process. This folder will be used to download the Ubuntu ISO, execute scripts, and store generated files:

   1. **Create the Folder**:
      - This is where you will download the Ubuntu ISO and where the scripts will generate necessary files for customization and creating the final autoinstall image.
   
      ```bash
      mkdir UbuntuISOGenerator && cd UbuntuISOGenerator
      ```
      
   2. **Add Scripts to This Folder**:
      - Copy or move the `setup_autoinstall_env.sh` and `generate_autoinstall_iso.sh` scripts into the `UbuntuISOGenerator` folder.
   
   3. **Make Scripts Executable**:
      - To ensure the scripts are executable and ready to run, assign execute permissions using the `chmod` command. Open your terminal, navigate to the directory containing the scripts, and execute the following command:

      ```bash
      chmod +x setup_autoinstall_env.sh generate_autoinstall_iso.sh
      ```

#### Run the Setup Script

Use the `setup_autoinstall_env.sh` script located in your `UbuntuISOGenerator` directory to prepare your environment for creating the Ubuntu Autoinstall ISO with Cloud-init. This script performs several tasks, including ensuring your system has `wget`, `xorriso`, and `p7zip-full` installed, downloading the Ubuntu Server ISO, extracting its contents, and preparing the directory structure for the autoinstall ISO creation.

Navigate to the script's directory and execute:

```bash
./setup_autoinstall_env.sh
```

The script will:
- Install any missing packages.
- Download the Ubuntu Server 22.04 LTS ISO if it's not already present.
- Prepare the necessary directory structure in the specified build directory (`u22.04-autoinstall-ISO`).

After running the script, your environment will be set up, and you'll be ready to proceed with configuring your installation preferences.

## Step 1: Prepare the `user-data` File

The `user-data` file is crucial for Cloud-Init as it contains all the necessary autoinstall configuration details, such as user setup, package installation, and other settings.

1. **Navigate to your project's directory** where the autoinstall ISO will be prepared. This directory was created by the `setup_autoinstall_env.sh` script:

```bash
cd ~/u22.04-autoinstall-ISO/source-files/server
```

2. **Replace or edit the `user-data` file** with your customized Cloud-Init configuration.
    - This configuration can be manually crafted or generated with the configuration tool freely hosted at [https://autoserve-cloud.web.app/](https://autoserve-cloud.web.app/).

## Step 2: Create the Autoinstall ISO

Use the `generate_autoinstall_iso.sh` script located in your `UbuntuISOGenerator` directory to generate the Ubuntu 22.04 Server autoinstall ISO.

Execute the following command to create your custom ISO:

```bash
./generate_autoinstall_iso.sh
```

This command produces the `ubuntu-22.04-autoinstall.iso` within the `UbuntuISOGenerator/u22.04-autoinstall-ISO/` directory.

## Step 3: Install Using the Autoinstall ISO

Mount the ISO to the virtual CD-ROM drive in your VM and proceed with these steps:

1. Boot the VM, `ubuntu22.04-vm`, with the ISO attached.
2. Select the boot option for "Auto Install" from the virtual CD-ROM drive to commence the installation.  The setup should occur automatically and reboot once finished.
3. Upon completion, log in using the credentials defined in your `user-data` file.

## Step 4: Verify the Installation

Post-installation, validate the setup to ensure all configurations from the `user-data` file are correctly applied:

1. **Check storage and partitions** using commands such as `lsblk -f` and `df -Thv`.
2. **Confirm configurations** like users, SSH keys, locale, and installed packages align with your `user-data` specifications.
3. **Review Cloud-Init logs** for evidence of executed commands and configurations.

### Viewing the Processed `user-data` File After Installation

Post-installation, Ubuntu generates a copy of the processed `user-data` file, stored at `/var/log/installer/autoinstall-user-data`. Accessing this file is essential for verifying the applied configuration and troubleshooting:

1. **Log into your system** directly or via SSH.
2. **View the `autoinstall-user-data` file** with

`cat /var/log/installer/autoinstall-user-data` to inspect the final configurations.

### Importance of Reviewing the Processed `user-data`

Comparing the final `/var/log/installer/autoinstall-user-data` is an effective way to diagnose any misconfigurations in the pre-installation `user-data` file and ensures all intended configurations were correctly applied

### Additional Resources for a Comprehensive Review

- **Cloud-Init Logs:** Found in `/var/log`, logs such as `/var/log/cloud-init.log` and `/var/log/cloud-init-output.log` detail each action taken by Cloud-Init.
- **Cloud-Init Runtime Data:** Stored in `/var/lib/cloud/instance`, including the original `user-data` and applied configurations.

Further Reading and Tools:
- [Cloud-Init Documentation Examples](https://cloudinit.readthedocs.io/en/latest/reference/examples.html): A comprehensive collection of example `user-data` scripts and configurations.
- [Ubuntu Server Autoinstall Documentation](https://ubuntu.com/server/docs/install/autoinstall): Official Ubuntu documentation on using the autoinstall feature.
- [Ubuntu 22.04 Server Autoinstall - Puget Systems](https://www.pugetsystems.com/labs/hpc/ubuntu-22-04-server-autoinstall-iso/): Instructions on how to manually create the Autoinstall ISO, written by Donald Kinghorn.
- [AutoServe Cloud](https://autoserve-cloud.web.app/): A web-based configuration tool for generating custom Cloud-Init `user-data` configurations.

---

Following these steps will allow you to successfully create a customized Ubuntu Server 22.04 LTS autoinstall ISO with cloud-init and verify its installation on a virtual machine.
