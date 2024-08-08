# csexercise

This repo is a solution for the coding exercise as requested

# Configuration

- Update the variables in variables.tf with the appropriate project, region and zone
- Update the variable in variables.tf with the desired user account to authenticate to resources and external IP to access resources

# Deployment

  Ensure your GCP project has the following

  - Service account created to deploy terraform: https://registry.terraform.io/providers/hashicorp/google/latest/docs/guides/getting_started#adding-credentials
  - Run `terraform init` to initalize the workspace
  - Run `terraform validate` to validate the code with updated variables
  - Run `terraform apply`