# Set variables
$resourceGroup = "yourResourceGroup"
$cosmosAccountName = "yourCosmosAccountName"
$databaseName = "yourDatabaseName"
$containerName = "yourContainerName"
$partitionKeyPath = "/yourPartitionKeyPath"
$documentId = "yourDocumentId"
$documentFilePath = "C:\path\to\yourDocumentId.json"
$updatedDocumentFilePath = "C:\path\to\yourDocumentId-updated.json"

# Create a Cosmos DB database with a container
New-AzCosmosDBSqlDatabase -ResourceGroupName $resourceGroup -AccountName $cosmosAccountName -Name $databaseName
$container = New-AzCosmosDBSqlContainer -ResourceGroupName $resourceGroup -AccountName $cosmosAccountName -DatabaseName $databaseName -Name $containerName -PartitionKeyPath $partitionKeyPath

# Create a simple document in the container
$document = Get-Content -Raw -Path $documentFilePath | ConvertFrom-Json
$container | Add-AzCosmosDBSqlContainerDocument -DocumentObject $document

# Update the document in the container
$updatedDocument = Get-Content -Raw -Path $updatedDocumentFilePath | ConvertFrom-Json
$container | Update-AzCosmosDBSqlContainerDocument -DocumentId $documentId -PartitionKeyValue $document.$partitionKeyPath -DocumentObject $updatedDocument

# Delete the document from the container
$container | Remove-AzCosmosDBSqlContainerDocument -DocumentId $documentId -PartitionKeyValue $document.$partitionKeyPath
