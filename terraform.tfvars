region         = "us-west-2"  # Update with your desired AWS region
ami_id         = "ami-013b25a16d62caa76" # Replace with your desired AMI ID
pem_key_name   = "my-key-name"   # Replace with the name of your PEM key, do not include ".pem"
pem_key_path   = "~/.ssh/itsi/my-key-name.pem" # Replace with the full path to your PEM key

# Optional: Override instance names if needed
#large_instance_names = ["splunk-sh1", "splunk-idx1", "splunk-idx2", "splunk-idx3"]
#medium_instance_names = ["splunk-licdeploy", "splunk-cmanager"]
