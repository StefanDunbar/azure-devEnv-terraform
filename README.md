# azure-devEnv-terraform
Creating a, Linux-based, Dev Environment in Azure using Terraform (IaC)

- Open in VS Code
- Add 'Terraform' extension
- Add 'Remote SSH' extension
- Make sure to add your public IP to variables.tf 'personal_ip' under 'default' (This will allow you to access your VM once created)
- Using VS Code terminal:
  - Run 'az login' and continue to login to your Azure account (Alternatively you can run 'az login --use-device-code)
  - Run 'az account show' (This is to confirm you have logged in, you should see your account details)
  - Run 'Terraform fmt'
  - Run 'Terraform init'
  - Run 'Terraform plan' to see what actions will be carried out
  - Run 'Terraform apply' to execute the creation of your Dev Env
- Once you are done you can delete it all with the following command:
  - 'Terraform destroy -auto-approve'