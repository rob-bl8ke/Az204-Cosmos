# Sample Application: CRUD Operations

Your project file looks something like this...

```xml
<Project Sdk="Microsoft.NET.Sdk">

  <PropertyGroup>
    <OutputType>Exe</OutputType>
    <TargetFramework>net7.0</TargetFramework>
    <ImplicitUsings>enable</ImplicitUsings>
    <Nullable>enable</Nullable>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Microsoft.Azure.Cosmos" Version="3.32.3" />
    <PackageReference Include="Microsoft.Extensions.Configuration.Binder" Version="7.0.4" />
    <PackageReference Include="Microsoft.Extensions.Configuration.Json" Version="7.0.0" />
    <PackageReference Include="Microsoft.Extensions.Hosting" Version="7.0.1" />
  </ItemGroup>

</Project>
```

Your settings file contains:
- The Cosmos DB Account you've created
- The access key (authorization key)
- The database name and container name
- The overall throughput cap

Your settings file looks something like this..

```json
{
    "CosmosDb": {
        "Account": "https://mycosmosdbaccount.documents.azure.com:443/",
        "Key": "rlbEi8V...4Qw==",
        "DatabaseName": "Tasks",
        "ContainerName": "Item",
        "ThroughPut": 400
    }
}
```

## Code

### Document Model

```csharp
// Does not support System.Text.Json in Cosmos DB v3
// Looks like the intention is to change this with v4 so leaving this here for now...
using Newtonsoft.Json;

public class ToDoActivity
{
    [JsonProperty("id")]
    public string Id { get; set; } = null!;

    [JsonProperty("name")]
    public string Name { get; set; } = null!;

    [JsonProperty("description")]
    public string Description { get; set; } = null!;

    [JsonProperty("completed")]
    public bool Completed { get; set; }
}
```

### Exercise Code

Here is some experimental code that exercises some simple CRUD operations.

```csharp
using Microsoft.Azure.Cosmos;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;

using IHost host = Host.CreateDefaultBuilder(args).Build();

IConfiguration config = host.Services.GetRequiredService<IConfiguration>();

string? accountEndpoint = config.GetValue<string>("CosmosDb:Account");
string? authKey = config.GetValue<string>("CosmosDb:Key");
string? databaseName = config.GetValue<string>("CosmosDb:DatabaseName");
string? containerName = config.GetValue<string>("CosmosDb:ContainerName");
int throughput = config.GetValue<int>("CosmosDb:ThroughPut");

// Create the database
CosmosClient client = new CosmosClient(accountEndpoint, authKey);
DatabaseResponse databaseResponse = await client.CreateDatabaseIfNotExistsAsync(databaseName, throughput);

// databaseName - Referred to as the database Id
Database database = client.GetDatabase(databaseName);
DatabaseResponse databaseResponse2 = await database.ReadAsync();

// containerName - Referred to as the container Id
ContainerResponse containerResponse = await databaseResponse.Database.CreateContainerIfNotExistsAsync(containerName, "/id");

Container container = database.GetContainer(containerName);
ContainerProperties containerProperties = await container.ReadContainerAsync();

try
{
    // Create an item
    ToDoActivity newActivity = new ToDoActivity { Id = "1", Name = "Learn guitar", Description = "Learn the A chord" };
    ItemResponse<ToDoActivity> createdResponse = await container.CreateItemAsync(newActivity, new PartitionKey(newActivity.Id));

    Console.WriteLine(createdResponse.ActivityId);

    string id = newActivity.Id;
    string accountNumber = newActivity.Id;
    ItemResponse<ToDoActivity> existingResponse = await container.ReadItemAsync<ToDoActivity>(id, new PartitionKey(newActivity.Id));

    // Update an item
    ToDoActivity existingActivity = existingResponse.Resource;
    existingActivity.Completed = true;
    await container.UpsertItemAsync(existingActivity, new PartitionKey(existingResponse.Resource.Id));

    ItemResponse<ToDoActivity> updatedResponse = await container.ReadItemAsync<ToDoActivity>(id, new PartitionKey(newActivity.Id));
    Console.WriteLine(updatedResponse.Resource.Completed);

    // Add some more items
    await container.CreateItemAsync(new ToDoActivity { Id = "2", Name = "Learn guitar", Description = "Learn the C chord" }, new PartitionKey("2"));
    await container.CreateItemAsync(new ToDoActivity { Id = "3", Name = "Learn guitar", Description = "Learn the D chord" }, new PartitionKey("3"));
    await container.CreateItemAsync(new ToDoActivity { Id = "4", Name = "Learn C#", Description = "Learn to use records" }, new PartitionKey("4"));

    // Query for a record
    QueryDefinition query = new QueryDefinition("select * from todos t where t.id = @Id")
        .WithParameter("@Id", "3");
    
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

    while (feedIterator.HasMoreResults)
    {
        FeedResponse<ToDoActivity> activities = await feedIterator.ReadNextAsync();
        foreach (ToDoActivity activity in activities)
        {
            Console.WriteLine(activity.Description);
        }
    }
}
catch (CosmosException ce) when (ce.StatusCode == System.Net.HttpStatusCode.Forbidden)
{
    Console.WriteLine(ce.Message);
}

// Delete containers and database
await database.GetContainer(containerName).DeleteContainerAsync();
await database.DeleteAsync();

await host.RunAsync();
```