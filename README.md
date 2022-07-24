# Purpose
The repository demonstarte AWS Image Builder to be used as source for Golden AMIs creation and distribution.
Organizations using Ansible or TF/Packer can leverage AWS Image Builder as one stop shop for their automated Golden Image creation process.

## automation-role

Automation role for SSM to be used to provision Windows Golden AMIs

## Important

- If you are not using the default vpc, must provide the subnet id and a security group so that instance can launch accordingly.
- A S3 bucket for storing assets shall be created automatically. It will hold any binaries/ insatllers/ config files that you will upload as part of process
- Do create a local folder and replace path in TF scripts to get binaries uploaded to assets S3 bucket

