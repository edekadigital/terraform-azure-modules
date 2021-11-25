pip3 install azure-keyvault==1.1.0

INSTANCE_NAME=$(hostname)
az login --identity --allow-no-subscriptions
DEVOPS_ORG_TOKEN=$(az keyvault secret show --vault-name $VAULT_NAME --name $SECRET_NAME --query value --output tsv)
