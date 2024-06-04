
# Change Feed 

![Azure Change Feed Processing](https://www.plantuml.com/plantuml/png/fLVRRXmt37tNLx1f0ITsT-q6IH47Hj3KJj0WTk36RliImE18z8om6d8gQUniY_nxmT7irNOlwBvOGuha4KaToZ-aZ36tdbsB7Jnw_KSV2OuRv9hWBP63yoYMKl9SFp8c-nm8nasIMabmykCdFXPEVKk0lAs3QudmGIv-FWLRd5whqrxzGMu8BaxU6sCiTjaBmsleA2QVCd66I5QY0xaUJHDa0GGhdD4pHV0yk93eAEfg3c9j7wVcMYHJN43VY4mtn3cj0LXNTiL0bguVFitqmvjB1Jyrnkp0gKzPWU8D-e1L8BLkARqqEz3atAMN-_jTGCvz6wPMslr1RRuQ_a2QKRRDt7pbsORU4Hn9mltWwoQpvtgrUcLsHXEBiHAUr17dAzcyabWlFrkCoUn0cddkC68B5TfP7QLdTon18dnDByYHDN-pu_3xmyF35yOSfJmFzCe006Yld65tuh5Mcpy7eVwcKIIlVUllnosF3kEi2ZrjR3hrJ4LT1RIp3TrRuLnqjutFAxilPXLN7Mx5NPdTYVZ5h4nPtCEMcm7_2UZsIU_kk6ZGoQtstTFfmORcOp6BsjHFdwyXNQnUEkfoy_ZWoODWxuPRWRrxa6smTtUim1wiWRs3wBl_WkY-PgWZpVz5bjRAZJ7AxLPKFUk5jYWykoE_RBoTiVB0mVJv0ncg8n7V5woIpq5D__qXpp3Mdk6xpGgVetDwfYtn6NxsRT_-vbrkuDd1TgA_cAFzyUQPlNLMDcOo6KY7UE2aaI3DP3AvMjAUpzGcPR92a9wrpBOfJDdW3K55nD2AyzUUtBHOOvgpRQAmz2dC0Tc1Pnkf9SuOmhpiSZxbwAi-amEqKPHbWrTgLVq4pZ5Y21GMbEgv7Z3hfCWH_RZn2ewHTp9S-w24lSR5IorBXaG4ZWBfZ2W1hk12hdCH4jpwtC3bvIbWWbk9CnoQR0Xu9ev2qkK4pllKZDOVoKhR4hiIIKCrP6TQ8isdEXcEdh945QQCcJvnW-m2EQZcmtYuPqvA74E5y3ySbroE3ie7O4W2PL_9mUGAJWKTL1YGhMPubDwN_57r9aQ9nSj2UWKNbXYZbwNRjwKSmj1Xp7uOpJEQBzJ71H0JkM4cwqIE4g13Ipe55_NJlIUO4LfVHnoA1u-5QP9zIn09NNfYpDuUV2HqSEDnEZLxUtjNSFJDQkHzujtTCeRVzcoBazL0pj7NDSMqkwkMUrVmIw9q_qp_n1KrdjsGu6I9APLen_U-08Al8iRvuFQ1GYlqCs6V9PBJrYxlak9rL0nLzvmevg7kVUSm4qX7OqRAxY5Drr7QrHtTE8LFK1Eh3JaDUqgOQ3laXVRIq5bOKn6zXaJHKzAoL2Ap5kCi3PW8RQELquVRQ7yi4frdpCiKkX9zlE5j7xBl0YtD53py92dh4x3j-apmZbD6jelmNHUy7GwgIHWqa1lC40RoIaDE8g7DfPF6XzwG2Ss1XX-RmaeV75Gq5lhNit7nlgyeCYdeSt6ZS5fQIHk2_UyzWNV4MNakmkCb4iQMdkW-EA50DUQ5ytTj5mR6WqfVYigcGMflXymXL9Xji_Om7QsElzxqi-YRzDDmQ-FHvQiYtojtjALSSZZAz4Q0S9WFsTdsNvAWk4Ce6Sqo8rvw_4YvZxosznBJh93kMlU-ITctc4UQkl2EBCQH1vO5sBeBXOlF29DUGvRfnfjSgucHe2Ds8wTSmRkIxZdSDgH08LaC1D9d4wWcBRhUS7FvJo_mnJjxoFp3pt6V87ajciRoY-fzQnmbNxFsiSI2OI9z_dPeEuiC5K4ZIQUOPxXH4knJYKbyuwEmkabJGrf0nMtC3yHk_7_fBm00 "Azure Change Feed Processing")

### [Start a Change Feed Processor](https://learn.microsoft.com/en-us/training/modules/work-with-cosmos-db/6-cosmos-db-change-feed)

- Note how you can use `WithPollInterval` to adjust the sleep time between polling.

```csharp
private static async Task<ChangeFeedProcessor> StartChangeFeedProcessorAsync(CosmosClient client, IConfiguration configuration)
{
    string databaseName = configuration["SourceDatabaseName"];
    string sourceContainerName = configuration["SourceContainerName"];
    string leaseContainerName = configuration["LeaseContainerName"];

    // Lease container will store the state of the change feed for every application instance using the "instance name"
    Container leaseContainer = cosmosClient.GetContainer(databaseName, leaseContainerName);

    // Create the change feed processor by providing a name and the delegate processing function.
    // Must also provide the lease container.
    StartChangeFeedProcessorAsync changeFeedProcessor = cosmosClient.GetContainer(databaseName, sourceContainerName)
        .GetChangeFeedProcessorBuilder<ToDoItem>(processorName: "changeFeedSample", onChangesDelete: HandleChangesAsync)
        .WithInstanceName("consoleHost")
        .WithLeasContainer("leaseContainer")
        .WithPollInterval(TimeSpan.FromSeconds(5))
        .Build();

    // Start the feed...
    await changeFeedProcessor.StartAsync();

    return changeFeedProcessor;
}
```

### The Delegate Function

```csharp
static async Task HandleChangesAsync(
    ChangeFeedProcessorContext context, 
    IReadOnlyCollection<ToDoItem> changes, CancellationToken cancellationToken
)
{
    Console.WriteLine($"Started handling changes for lease {context.LeaseToken}...");
    Console.WriteLine($"Change Feed request consumed {context.Headers.RequestCharge} RU.");
    // SessionToken if needed to enforce Session consistency on another client instance
    Console.WriteLine($"SessionToken ${context.Headers.Session}");

    // We may want to track any operation's Diagnostics that took longer than some threshold
    if (context.Diagnostics.GetClientElapsedTime() > TimeSpan.FromSeconds(5))
    {
        Console.WriteLine($"Change Feed request took longer than expected. Diagnostics:" + context.Diagnostics.ToString());
    }

    foreach (ToDoItem item in changes)
    {
        Console.WriteLine($"Detected operation for item with id {item.id}, created at {item.creationTime}.");
        // Simulate some asynchronous operation
        await Task.Delay(10);
    }

    Console.WriteLine("Finished handling changes.");
}
```

# Change Feed Estimator

```csharp
ChangesEstimationHandler changeEstimationDelegate = async (
    long estimation, 
    CancellationToken cancellationToken
) => {
    // Do something with the estimation
};
```

```csharp
ChangeFeedProcessor estimator = sourceContainer.GetChangeFeedEstimatorBuilder(
    processorName: "productItemEstimator",
    estimationDelegate: changeEstimationDelegate)
    .WithLeaseContainer(leaseContainer)
    .Build();
```