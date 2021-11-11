pip3 install azure-keyvault==1.1.0

INSTANCE_NAME=$(hostname)
az login --identity --allow-no-subscriptions
az keyvault secret download --vault-name ${VAULT_NAME} --name ${SECRET_NAME} --file secret.txt
DEVOPS_ORG_TOKEN=$(cat ./secret.txt)
rm ./secret.txt