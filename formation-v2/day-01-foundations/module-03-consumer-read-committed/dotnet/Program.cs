using Confluent.Kafka;
using System.Collections.Concurrent;
using System.Text.Json;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddSingleton<ConsumerState>();
builder.Services.AddHostedService<KafkaConsumerHostedService>();

var app = builder.Build();

app.MapGet("/health", () => "OK");

app.MapGet("/api/v1/metrics", (ConsumerState state) => Results.Ok(new
{
    processedCount = state.ProcessedCount,
    processedTxIds = state.GetProcessedTxIds()
}));

app.Run();

sealed class ConsumerState
{
    private long _processedCount;
    private readonly ConcurrentQueue<string> _processedTxIds = new();

    public long ProcessedCount => Interlocked.Read(ref _processedCount);

    public void RememberTxId(string? txId)
    {
        if (string.IsNullOrWhiteSpace(txId))
        {
            return;
        }

        Interlocked.Increment(ref _processedCount);
        _processedTxIds.Enqueue(txId);

        while (_processedTxIds.Count > 20)
        {
            _processedTxIds.TryDequeue(out _);
        }
    }

    public IReadOnlyList<string> GetProcessedTxIds() => _processedTxIds.ToArray();
}

sealed class KafkaConsumerHostedService : BackgroundService
{
    private readonly ConsumerState _state;

    public KafkaConsumerHostedService(ConsumerState state)
    {
        _state = state;
    }

    protected override async Task ExecuteAsync(CancellationToken stoppingToken)
    {
        var bootstrapServers = Environment.GetEnvironmentVariable("KAFKA_BOOTSTRAP_SERVERS") ?? "localhost:9092";
        var topic = Environment.GetEnvironmentVariable("KAFKA_TOPIC") ?? "bhf-read-committed-demo";
        var groupId = Environment.GetEnvironmentVariable("KAFKA_GROUP_ID") ?? "m03-dotnet-consumer";

        var config = new ConsumerConfig
        {
            BootstrapServers = bootstrapServers,
            GroupId = groupId,
            AutoOffsetReset = AutoOffsetReset.Earliest,
            EnableAutoCommit = false,
            IsolationLevel = IsolationLevel.ReadCommitted,
        };

        while (!stoppingToken.IsCancellationRequested)
        {
            try
            {
                using var consumer = new ConsumerBuilder<string, string>(config)
                    .SetKeyDeserializer(Deserializers.Utf8)
                    .SetValueDeserializer(Deserializers.Utf8)
                    .Build();

                consumer.Subscribe(topic);

                while (!stoppingToken.IsCancellationRequested)
                {
                    var result = consumer.Consume(stoppingToken);
                    if (result?.Message?.Value is null)
                    {
                        continue;
                    }

                    var txId = ExtractTxId(result.Message.Value);
                    _state.RememberTxId(txId);

                    consumer.Commit(result);
                }

                consumer.Close();
            }
            catch (OperationCanceledException)
            {
                return;
            }
            catch
            {
                try
                {
                    await Task.Delay(2000, stoppingToken);
                }
                catch (OperationCanceledException)
                {
                    return;
                }
            }
        }
    }

    private static string? ExtractTxId(string json)
    {
        try
        {
            using var doc = JsonDocument.Parse(json);
            if (doc.RootElement.TryGetProperty("txId", out var txId))
            {
                return txId.GetString();
            }
            return null;
        }
        catch
        {
            return null;
        }
    }
}
