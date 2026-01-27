using Confluent.Kafka;
using System.Collections.Concurrent;

var builder = WebApplication.CreateBuilder(args);

var app = builder.Build();

static int IntEnv(string key, int defaultValue)
{
    var raw = Environment.GetEnvironmentVariable(key);
    return int.TryParse(raw, out var v) ? v : defaultValue;
}

static IProducer<string, string> BuildProducer(bool idempotent)
{
    var bootstrapServers = Environment.GetEnvironmentVariable("KAFKA_BOOTSTRAP_SERVERS") ?? "localhost:9092";

    var config = new ProducerConfig
    {
        BootstrapServers = bootstrapServers,
        ClientId = $"m02-dotnet-{Environment.MachineName}",
        RequestTimeoutMs = IntEnv("KAFKA_REQUEST_TIMEOUT_MS", 1000),
        MessageTimeoutMs = IntEnv("KAFKA_DELIVERY_TIMEOUT_MS", 120000),
        RetryBackoffMs = IntEnv("KAFKA_RETRY_BACKOFF_MS", 100),
        MessageSendMaxRetries = IntEnv("KAFKA_RETRIES", 10),
        LingerMs = IntEnv("KAFKA_LINGER_MS", 0)
    };

    if (idempotent)
    {
        config.EnableIdempotence = true;
        config.Acks = Acks.All;
        config.MaxInFlight = 5;
    }
    else
    {
        config.EnableIdempotence = false;
        config.Acks = Acks.Leader;
    }

    return new ProducerBuilder<string, string>(config).Build();
}

var plainProducer = new Lazy<IProducer<string, string>>(() => BuildProducer(false));
var idempotentProducer = new Lazy<IProducer<string, string>>(() => BuildProducer(true));

var statusByRequestId = new ConcurrentDictionary<string, object>();

app.MapGet("/health", () => Results.Ok("OK"));

app.Lifetime.ApplicationStopping.Register(() =>
{
    try
    {
        if (plainProducer.IsValueCreated)
        {
            plainProducer.Value.Flush(TimeSpan.FromSeconds(5));
            plainProducer.Value.Dispose();
        }
    }
    catch
    {
    }

    try
    {
        if (idempotentProducer.IsValueCreated)
        {
            idempotentProducer.Value.Flush(TimeSpan.FromSeconds(5));
            idempotentProducer.Value.Dispose();
        }
    }
    catch
    {
    }
});

app.MapGet("/api/v1/status", (HttpRequest request) =>
{
    var requestId = request.Query["requestId"].ToString();
    if (string.IsNullOrWhiteSpace(requestId))
        return Results.BadRequest("Missing query parameter: requestId");

    return statusByRequestId.TryGetValue(requestId, out var status)
        ? Results.Ok(status)
        : Results.NotFound();
});

app.MapPost("/api/v1/send", async (HttpRequest request) =>
{
    var mode = request.Query["mode"].ToString();
    var eventId = request.Query["eventId"].ToString();
    var topic = request.Query["topic"].ToString();
    var sendMode = request.Query["sendMode"].ToString();
    var key = request.Query["key"].ToString();
    var partitionRaw = request.Query["partition"].ToString();

    if (string.IsNullOrWhiteSpace(mode))
        return Results.BadRequest("Missing query parameter: mode");
    if (string.IsNullOrWhiteSpace(eventId))
        return Results.BadRequest("Missing query parameter: eventId");
    if (string.IsNullOrWhiteSpace(topic))
        topic = "bhf-transactions";
    if (string.IsNullOrWhiteSpace(sendMode))
        sendMode = "sync";
    if (string.IsNullOrWhiteSpace(key))
        key = eventId;

    int? partition = null;
    if (!string.IsNullOrWhiteSpace(partitionRaw) && int.TryParse(partitionRaw, out var p))
        partition = p;

    var idempotent = mode.Equals("idempotent", StringComparison.OrdinalIgnoreCase);

    var async = sendMode.Equals("async", StringComparison.OrdinalIgnoreCase)
                || sendMode.Equals("asynchronous", StringComparison.OrdinalIgnoreCase);

    var value = $$"{\"eventId\":\"{{eventId}}\",\"mode\":\"{{mode}}\",\"sendMode\":\"{{sendMode}}\",\"api\":\"dotnet\",\"ts\":\"{{DateTimeOffset.UtcNow:O}}\"}";
    var message = new Message<string, string> { Key = key, Value = value };

    var producer = idempotent ? idempotentProducer.Value : plainProducer.Value;

    try
    {
        if (async)
        {
            var requestId = Guid.NewGuid().ToString();
            statusByRequestId[requestId] = new { requestId, state = "PENDING" };

            Action<DeliveryReport<string, string>> handler = report =>
            {
                if (report.Error.IsError)
                {
                    statusByRequestId[requestId] = new
                    {
                        requestId,
                        state = "ERROR",
                        error = report.Error.ToString()
                    };
                }
                else
                {
                    statusByRequestId[requestId] = new
                    {
                        requestId,
                        state = "OK",
                        topic = report.Topic,
                        partition = report.Partition.Value,
                        offset = report.Offset.Value
                    };
                }
            };

            if (partition.HasValue)
                producer.Produce(new TopicPartition(topic, new Partition(partition.Value)), message, handler);
            else
                producer.Produce(topic, message, handler);

            return Results.Accepted($"/api/v1/status?requestId={requestId}", new
            {
                requestId,
                state = "PENDING",
                eventId,
                mode,
                sendMode,
                topic,
                key,
                partition
            });
        }

        DeliveryResult<string, string> result;
        if (partition.HasValue)
            result = await producer.ProduceAsync(new TopicPartition(topic, new Partition(partition.Value)), message);
        else
            result = await producer.ProduceAsync(topic, message);

        return Results.Ok(new
        {
            eventId,
            mode,
            sendMode,
            topic,
            key,
            partition = result.Partition.Value,
            offset = result.Offset.Value
        });
    }
    catch (Exception ex)
    {
        return Results.Problem(ex.Message);
    }
});

app.Run();
