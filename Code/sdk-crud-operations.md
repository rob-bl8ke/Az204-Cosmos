# CRUD Operations

The following examples describe the API exposed by the `Microsoft.Azure.Cosmos` NuGet package: - [Azure Cosmos DB .NET SDK v3 GitHub repository .NET samples](https://github.com/Azure/azure-cosmos-dotnet-v3/tree/master/Microsoft.Azure.Cosmos.Samples/Usage).

## Settings

Lets assume that you have retrieved all your settings and stored them in the following variables:

| Variable | Description |
| --- | --- |
| `accountEndpoint` | The Cosmos DB Account you've created |
| `authKey` | The access key (authorization key) |
| `databaseName` | The database name (Id) |
| `containerName` | The container name (Id) |
| `throughput` | The overall throughput cap |

Here follow a typical way to create a simple C# console application. The `IConfiguration` instance will contain all the information required to connect to the existing Cosmos DB account and create the database artifacts.

```csharp
using Microsoft.Azure.Cosmos;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

using IHost host = Host.CreateDefaultBuilder(args).Build();
IConfiguration config = host.Services.GetRequiredService<IConfiguration>();

// All application code here...
// ...
// ...

// Run the console app
await host.RunAsync();
```

Retrieve all settings via the `IConfiguration` instance.

```csharp
string? accountEndpoint = config.GetValue<string>("CosmosDb:Account");
string? authKey = config.GetValue<string>("CosmosDb:Key");
string? databaseName = config.GetValue<string>("CosmosDb:DatabaseName");
string? containerName = config.GetValue<string>("CosmosDb:ContainerName");
int throughput = config.GetValue<int>("CosmosDb:ThroughPut");
```

## Create the Database and Container

Once you have retrieved all your values from the configuration, you're going to want to get a reference to your database so that you can work with it. Its possible that, although your account has been created, your database does not yet exist.

This code
- Connects to the database using a connection string and the access key.
- Creates a database (with a throughput cap) if it does not exist and then returns a reference to the existing database.

```csharp
CosmosClient client = new CosmosClient(accountEndpoint, authKey);
DatabaseResponse databaseResponse = await client.CreateDatabaseIfNotExistsAsync(databaseName, throughput);
```

The `DatabaseResponse` object has more information about the database.

There are two options to retrieving a reference to the database from this point. Note that both methods are synchronous as the `DatabaseResponse` and the `CosmosClient` obviously already contain a reference to the database.

```csharp
Database database = client.GetDatabase(databaseName);
// or
Database database = databaseResponse.Database;
```

Using the `Database` object, you can get access to operations that will allow you to create and get access to containers. To create a container you need to supply a container name and more importantly, a partition key. This partition key is used for logical partitioning and is the key to horizontal scaling. It needs to be carefully chosen.

The partion key is always assigned at the container level.

```csharp
ContainerResponse containerResponse = await databaseResponse.Database.CreateContainerIfNotExistsAsync(containerName, "/id");
```

Once the container exists, one can also get access to the container via the database. `ContainerProperties` provides some information about the container:

- Indexing and unique key policies
- Partition Key

... amongst others.

```csharp
Container container = database.GetContainer(containerName);
ContainerProperties containerProperties = await container.ReadContainerAsync();
```

## CRUD

### Create an Item

```csharp
    ToDoActivity newActivity = new ToDoActivity { Id = "1", Name = "Learn guitar", Description = "Learn the A chord" };

    ItemResponse<ToDoActivity> createdResponse = 
        await container.CreateItemAsync(newActivity, new PartitionKey(newActivity.Id));
```

### Read an Item

Note how one uses the `Resource` property of the response to get access to the original object. The document is deserialized into an `ToDoActivity` object intance. Note how in each case one needs the partition key to write back to the container. This is necessary so that Cosmos DB knows where to find the document.

```csharp
ItemResponse<ToDoActivity> existingResponse = 
    await container.ReadItemAsync<ToDoActivity>(newActivity.Id, new PartitionKey(newActivity.Id));

ToDoActivity existingActivity = existingResponse.Resource;
```

### Update an Item

Updates are `upserts`. The document will be created if it does not exist. Note how in each case one needs the partition key to write back to the container. This is necessary so that Cosmos DB knows where to find/store the document.

```csharp
ToDoActivity existingActivity = existingResponse.Resource;
existingActivity.Completed = true;

await container.UpsertItemAsync(existingActivity, new PartitionKey(existingResponse.Resource.Id));
```

## Queries

In order to query for records one needs to build up a `QueryDefinition` object instance.

```csharp
QueryDefinition query = 
    new QueryDefinition("select * from todos t where t.id = @Id")
        .WithParameter("@Id", "3");
```

In order to iterate through the results, a generic `FeedIterator` must be created using the `QueryDefinition` and some `QueryRequestOptions` that include the `PartitionKey` as an important component. Once again the `PartitionKey` is used to know where to look for the results and to avoid a "fan out" query which does not scale well.

```csharp
using FeedIterator<ToDoActivity> feedIterator = container.GetItemQueryIterator<ToDoActivity>
(
    query,
    null,
    requestOptions: new QueryRequestOptions()
    {
        PartitionKey = new PartitionKey("3")
        ,
        MaxItemCount = 1
    }
);
```

Now that the `FeedIterator` is referenced, the results of the query can be read and enumerated.

```csharp
while (feedIterator.HasMoreResults)
{
    FeedResponse<ToDoActivity> activities = await feedIterator.ReadNextAsync();
    foreach (ToDoActivity activity in activities)
    {
        Console.WriteLine(activity.Description);
    }
}
```

## Exception Handling

All CRUD and query operations should be wrapped within an exception handler and the `CosmosException` can be interrogated to retrieve more information about the exception and respond with one's own custom exceptions and handle the exception in the appropriate manner.

```csharp
try
{
    // CRUD Operations
}
catch (CosmosException ce) when (ce.StatusCode == System.Net.HttpStatusCode.Forbidden)
{
    // Some information included with the exception
    Console.WriteLine(ce.Message);
    Console.WriteLine(ce.StatusCode);
    Console.WriteLine(ce.ResponseBody);
    Console.WriteLine(ce.Data);
    Console.WriteLine(ce.Diagnostics);
}
```

## Deleting the Container and the Database

```csharp
await database.GetContainer(containerName).DeleteContainerAsync();
await database.DeleteAsync();
```