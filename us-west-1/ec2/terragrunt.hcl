include "root" {
  path = find_in_parent_folders()
}

locals {
  root_config = read_terragrunt_config(find_in_parent_folders())
}

dependency "sg" {
  config_path = "../sg"
}

terraform {
  source = "tfr:///terraform-aws-modules/ec2-instance/aws?version=5.0.0"

  after_hook "ansible" {
    commands = ["apply"]
    execute = [
      "bash", 
      "-c", 
      <<-EOT
        # Wait for SSH to be available
        while ! nc -z $(terraform output -raw public_ip) 22; do
          echo "Waiting for SSH to become available..."
          sleep 10
        done
        
        # Run Ansible playbook
        terraform output -raw public_ip > ip.txt && \
        ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
          -i $(cat ip.txt), \
          -u ec2-user \
          --private-key ~/.ssh/terragrunt-key.pem \
          --extra-vars "gitlab_url=${local.root_config.locals.gitlab_url} gitlab_token=${local.root_config.locals.gitlab_token} gitlab_tags=${local.root_config.locals.gitlab_tags}" \
          ansible/playbook.yml
      EOT
    ]
  }
}

inputs = {
  name = "terragrunt-gitlab-runner-instance"

  ami                    = local.root_config.locals.ami
  instance_type          = local.root_config.locals.instance_type
  monitoring             = false
  vpc_security_group_ids = [dependency.sg.outputs.security_group_id]
  key_name               = local.root_config.locals.key_name
  
  tags = {
    Environment = local.root_config.locals.environment
    Project     = "terragrunt-gitlab-runner"
  }
}
