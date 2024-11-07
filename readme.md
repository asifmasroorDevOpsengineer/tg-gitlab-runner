## Prerequisites

- Install terragrunt
- Install ansible

## Configuration

- Add your ssh key to the root folder ~/.ssh/
- configure the terragrunt.hcl file with your desired configuration

## Run the project
```
cd /us-west-1/ec2
terragrunt run-all apply
```

## Destroy the project

```
cd /us-west-1/ec2
terragrunt run-all destroy
```
