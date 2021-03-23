# azure-datadog-log-forwarder 

sending logs received from eventhub to datadog

# Origination

This function has been inspired by:

[datadog github repo](https://github.com/DataDog/datadog-serverless-functions/tree/master/azure/activity_logs_monitoring)

At the moment it is necessary to manually sync the triggers after deployment to get the EventHub trigger running. See [Microsoft Documentation 1](https://docs.microsoft.com/en-us/azure/azure-functions/run-functions-from-deployment-package#enabling-functions-to-run-from-a-package) and [Microsoft Documentation 2](https://docs.microsoft.com/en-us/azure/azure-functions/functions-deployment-technologies#trigger-syncing)
