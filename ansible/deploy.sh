#!/bin/bash

# This script runs the Ansible playbook to deploy the Talos cluster on Hyper-V.

# Ensure Ansible is installed
if ! command -v ansible-playbook &> /dev/null
then
    echo "Ansible is not installed. Please install Ansible to proceed."
    exit 1
fi

# Run the Ansible playbook
echo "Starting Talos Hyper-V cluster deployment with Ansible..."
cd ansible && ansible-playbook playbook.yml -i inventory.ini --ask-become-pass "$@"

if [ $? -eq 0 ]; then
    echo "Ansible playbook completed successfully."
else
    echo "Ansible playbook failed."
    exit 1
fi