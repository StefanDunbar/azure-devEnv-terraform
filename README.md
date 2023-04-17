# azure-devEnv-terraform
Creating a, Linux-based, Dev Environment in Azure using Terraform (IaC)

- Open in VS Code
- Add 'Terraform' extension
- Add 'Remote SSH' extension
- Make sure to update 'variables.tf' file with your public IP and a unique Resource Group name !It won't work without these!
- Using VS Code terminal:
  - Run 'az login' and continue to login to your Azure account (Alternatively you can run 'az login --use-device-code)
  - Run 'az account show' (This is to confirm you have logged in, you should see your account details)
  - Run 'Terraform fmt'
  - Run 'Terraform init'
  - Run 'Terraform plan' to see what actions will be carried out
  - Run 'Terraform apply' to execute the creation of your Dev Env
- Once setup is complete you can run VS Code on the newly created VM:
  - Open 'Command Palette' (Ctrl+Shift+P)
  - Type 'Remote-SSH:Connect to Host'
  - Select the IP at the bottom
  - Select 'Continue'

- Once you are done you can delete it all with the following command:
  - 'Terraform destroy -auto-approve'