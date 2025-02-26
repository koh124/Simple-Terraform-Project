# AWS Lambda + APIGateway

Simple API working with AWS Lambda + APIGateway.

## How to use

```bash
git clone https://github.com/koh124/Simple-Terraform-Project.git
cd Simple-Terraform-Project
terraform init
terraform plan
terraform apply
```

After deploying, you can verify that your API works with the following steps:

```bash
terraform output api_gateway_api_key # Get your API Key
curl -X POST "{YOUR-API-ENDPOINT}" -H "x-api-key: {YOUR_API_KEY}" # Expected response: {"message":"OK"}
```
