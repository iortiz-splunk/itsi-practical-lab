# itsi-practical-lab
Terraform to set up ec2 instances for ITSI practical lab



# Terraform Project for Splunk EC2 Instances Setup

## Overview
This Terraform project sets up the following AWS infrastructure:
- **4 EC2 Instances (c5.4xlarge)**:
  - Named: `sh1`, `idx1`, `idx2`, `idx3`
  - Each with 100 GB storage
- **2 EC2 Instances (t2.medium)**:
  - Named: `licdeploy`, `cmanager`
  - Default storage
- **Common Configuration**:
  - Instances are tagged with:
    - `splunkit_golden_ami = true`
    - `splunkit_data_classification = public`
  - SSH access enabled via a user-provided PEM key
  - Security group allows Splunk-related ports: 22 (SSH), 8000, 8089, and full outbound access.


## Prerequisites

Before using this Terraform configuration, ensure you have the following:

1. **AWS Account**:
   - Ensure you have the necessary IAM permissions to create VPCs, Subnets, EC2 instances, Security Groups, and Internet Gateways.

2. **AWS CLI**:
   - Installed and configured. Instructions are provided below.

3. **Terraform Installed**:
   - Install Terraform on your system. You can download it from [Terraform's official website](https://www.terraform.io/downloads.html).

4. **PEM Key**:
   - Ensure you have an existing PEM key in your AWS account for SSH access. If you don’t have one, instructions are provided below to create one.

5. **AMI ID**:
   - Obtain the AMI ID for the region you are deploying in. Ensure the AMI is compatible with the selected instance types.

---

## Setting Up AWS CLI and Testing It

The AWS CLI (Command Line Interface) is required to interact with your AWS account. Follow these steps to set up and test it:

### Step 1: Install AWS CLI
- Download and install the AWS CLI by following the instructions for your operating system:
  - [AWS CLI Installation Guide](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html)

### Step 2: Configure AWS CLI
Run the following command to configure the AWS CLI with your credentials:
```bash
aws configure
```

You will be prompted to provide:

AWS Access Key ID: Found in your AWS IAM account.
AWS Secret Access Key: Found in your AWS IAM account.
Default Region: e.g., us-east-1.
Output Format: Use json (recommended).

### Step 3: Test the AWS CLI

Run the following command to verify that the AWS CLI is working properly:
```bash
aws sts get-caller-identity
```

This should return your account information, like so:
```bash
{
    "UserId": "ABCDEFGHIJKLMNO1234567",
    "Account": "123456789012",
    "Arn": "arn:aws:iam::123456789012:user/YourUserName"
}
```

## Creating a PEM Key for SSH Access

If you don’t already have an SSH key pair (PEM key) to access your EC2 instances, follow these steps:

### Step 1: Generate a Key Pair in AWS
Log in to the AWS Management Console.
Navigate to the EC2 Dashboard.
In the left-hand menu, click Key Pairs under Network & Security.
Click Create Key Pair.
Provide a name for your key pair (e.g., my-ssh-key) and choose PEM as the file format.
Click Create Key Pair. The PEM file will be downloaded automatically.

### Step 2: Store the PEM File Securely
Place the PEM file in a secure location on your local system.
Update the permissions of the PEM file to restrict access:
```bash
chmod 400 my-ssh-key.pem
```
### Step 3: Use the PEM Key in Terraform
Specify the key pair name (e.g., my-ssh-key) in the terraform.tfvars file:
```json
pem_key_name = "my-ssh-key"
```
Ensure the PEM file is available locally for SSH access.


## Configure Variables
- `region`= AWS region for deployment (e.g., `us-east-1`)
- `ami_id`= AMI ID for EC2 instances
- `pem_key_name`= Name of the PEM key for SSH access
- `pem_key_path`= Path of your PEM key file eg (`~/.ssh/my-key.pem`)
  
Optional: Override instance names if needed
- `large_instance_names` = ["splunk-sh1", "splunk-idx1", "splunk-idx2", "splunk-idx3"]
- `medium_instance_names` = ["splunk-licdeploy", "splunk-cmanager"]

## Outputs
- A table listing the EC2 instance names, public IPs, and SSH commands to access them.


## Usage
### Clone the Repository:
```bash
git clone https://github.com/iortiz-splunk/itsi-practical-lab.git
cd itsi-practical-lab
```

### Initialize Terraform:
Initialize the Terraform project to download required providers and modules:
```bash
terraform init
```

### Review the Plan:
```bash
terraform plan
```

### Apply the Configuration:
Deploy the infrastructure:
```bash
terraform apply
```
### Specify a Different Variable File (Optional):
If you have multiple .tfvars files (e.g., dev.tfvars, prod.tfvars), you can specify which one to use:
```bash
terraform apply -var-file="dev.tfvars"
```

### View Outputs:
After deployment, the output will include:
- EC2 instance names.
- Public IP addresses.
- SSH commands to connect to the instances.

## SSH Command
```bash
ssh -i <path-to-pem-file> ec2-user@<public-ip>
``` 

## Clean Up
```bash
terraform destroy
``` 