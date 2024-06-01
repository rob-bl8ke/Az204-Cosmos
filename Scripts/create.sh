#!/bin/bash

# Set variables
resourceGroup="yourResourceGroup"
cosmosAccountName="yourCosmosAccountName"
databaseName="yourDatabaseName"
containerName="yourContainerName"
partitionKeyPath="/yourPartitionKeyPath"
documentId="yourDocumentId"

# Create a Cosmos DB database with a container
az cosmosdb sql database create \
  --resource-group $resourceGroup \
  --account-name $cosmosAccountName \
  --name $databaseName

az cosmosdb sql container create \
  --resource-group $resourceGroup \
  --account-name $cosmosAccountName \
  --database-name $databaseName \
  --name $containerName \
  --partition-key-path $partitionKeyPath

