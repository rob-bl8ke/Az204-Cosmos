
### Benefits of Azure Cosmos DB

Azure Cosmos DB is a fully managed NoSQL database that offers several key benefits. It provides low latency, elastic scalability of throughput, and well-defined semantics for data consistency. With Azure Cosmos DB, you can configure your databases to be globally distributed and available in multiple Azure regions. This allows you to reduce latency by placing data closer to your users and ensures high availability. One notable feature is the ability to add or remove regions associated with your account without pausing or redeploying your application. Azure Cosmos DB also offers global distribution benefits, such as unlimited elastic write and read scalability, 99.999% read and write availability worldwide, and guaranteed reads and writes served in less than 10 milliseconds. Data replication between regions is handled internally by Azure Cosmos DB with consistency level guarantees. Overall, Azure Cosmos DB enables you to achieve a highly available and globally distributed database for your applications.

### Cosmos DB Components

An Azure Cosmos DB account is the fundamental unit of global distribution and high availability, managed through the Azure portal, Azure CLI, or SDKs. Multiple Azure regions can be added or removed to distribute data and throughput. The next level is an Azure Cosmos DB container, which allows virtually unlimited provisioned throughput and storage. Containers are partitioned and replicated across regions, with items automatically grouped into logical partitions based on the specified partition key. Containers can have dedicated or shared provisioned throughput modes. Azure Cosmos DB databases act as namespaces for managing sets of containers. Finally, Azure Cosmos DB items can represent documents, rows, or nodes/edges depending on the API used.

### Consistency Levels

The provided markdown discusses different consistency levels in Azure Cosmos DB and provides a summary of each level. Here is a condensed summary of the information:

- **Strong Consistency**: Offers linearizability guarantee, ensuring that reads return the most recent committed version of an item. Uncommitted or partial writes are never seen.
- **Bounded Staleness Consistency**: Guarantees reads honor the consistent-prefix guarantee. Reads may lag behind writes by a specified number of versions or a time interval.
- **Session Consistency**: Ensures that within a single client session, reads honor consistent-prefix, monotonic reads, monotonic writes, read-your-writes, and write-follows-reads guarantees.
- **Consistent Prefix Consistency**: Provides eventual consistency for single document writes, and consistency for batch writes within a transaction. Write operations within a transaction of multiple documents are always visible together.
- **Eventual Consistency**: Offers no ordering guarantee for reads. Replicas eventually converge, and clients may read values older than previously read values.

Each consistency level has its own trade-offs and can be suitable for different scenarios. Azure Cosmos DB provides comprehensive SLAs for each consistency level.

### Request Units

With Azure Cosmos DB, you pay for the provisioned throughput and storage consumed on an hourly basis. The cost of database operations is measured in request units (RUs), representing the system resources required for those operations. For example, a point read for a 1-KB item costs 1RU. Regardless of the API used, all costs in Azure Cosmos DB are measured in RUs. There are three modes to create an Azure Cosmos DB account: provisioned throughput mode, where RUs are provisioned on a per-second basis; serverless mode, where no throughput provisioning is required, and you are billed for consumed RUs; and autoscale mode, which allows automatic scaling of throughput based on usage, ideal for mission-critical workloads with variable traffic patterns and high-performance requirements.