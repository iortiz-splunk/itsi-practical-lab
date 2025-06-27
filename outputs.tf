output "ec2_instances_table" {
  value = {
    large_instances = [
      for idx, instance in aws_instance.large_instances :
      {
        name    = var.large_instance_names[idx]
        public_ip = instance.public_ip
        ssh_command = "ssh -i ${var.pem_key_path} ec2-user@${instance.public_ip}"
      }
    ]
    medium_instances = [
      for idx, instance in aws_instance.medium_instances :
      {
        name    = var.medium_instance_names[idx]
        public_ip = instance.public_ip
        ssh_command = "ssh -i ${var.pem_key_path} ec2-user@${instance.public_ip}"
      }
    ]
  }
}

output "ssh_commands" {
  value = {
    all_instances = [
      for instance in concat(aws_instance.large_instances, aws_instance.medium_instances) :
      {
        name = instance.tags["Name"]
        ssh_command = "ssh -i ${var.pem_key_path} ec2-user@${instance.public_ip}"
      }
    ]
  }
}