using Confluent.Kafka;

namespace M02ProducerReliability.Api.Services
{
    public interface IKafkaProducerService
    {
        Task<DeliveryResult<string, string>> SendMessageAsync(
            string topic, 
            string key, 
            string message,
            bool isIdempotent = true,
            bool isAsync = false);
    }

    public class KafkaProducerService : IKafkaProducerService, IDisposable
    {
        private readonly IProducer<string, string> _plainProducer;
        private readonly IProducer<string, string> _idempotentProducer;
        private readonly ILogger<KafkaProducerService> _logger;

        public KafkaProducerService(IConfiguration configuration, ILogger<KafkaProducerService> logger)
        {
            _logger = logger;
            var bootstrapServers = configuration["Kafka:BootstrapServers"] ?? "localhost:9092";

            // Configuration pour Producer Plain
            var plainConfig = new ProducerConfig
            {
                BootstrapServers = bootstrapServers,
                Acks = Acks.Leader,
                EnableIdempotence = false,
                MessageSendMaxRetries = 2,
                RetryBackoffMs = 500,
                MessageTimeoutMs = 3000
            };

            // Configuration pour Producer Idempotent
            var idempotentConfig = new ProducerConfig
            {
                BootstrapServers = bootstrapServers,
                Acks = Acks.All,
                EnableIdempotence = true,
                MessageSendMaxRetries = 3,
                RetryBackoffMs = 1000,
                MessageTimeoutMs = 5000,
                MaxInFlight = 5
            };

            _plainProducer = new ProducerBuilder<string, string>(plainConfig).Build();
            _idempotentProducer = new ProducerBuilder<string, string>(idempotentConfig).Build();
        }

        public async Task<DeliveryResult<string, string>> SendMessageAsync(
            string topic, 
            string key, 
            string message,
            bool isIdempotent = true,
            bool isAsync = false)
        {
            try
            {
                var producer = isIdempotent ? _idempotentProducer : _plainProducer;
                var msg = new Message<string, string>
                {
                    Key = key,
                    Value = message,
                    Headers = new Headers()
                };

                // Ajouter des headers pour le suivi
                msg.Headers.Add("producer-mode", System.Text.Encoding.UTF8.GetBytes(isIdempotent ? "idempotent" : "plain"));
                msg.Headers.Add("send-mode", System.Text.Encoding.UTF8.GetBytes(isAsync ? "async" : "sync"));
                msg.Headers.Add("timestamp", System.Text.Encoding.UTF8.GetBytes(DateTime.UtcNow.ToString("O")));

                _logger.LogInformation("Sending message to topic {Topic} with mode {Mode}", 
                    topic, isIdempotent ? "idempotent" : "plain");

                if (isAsync)
                {
                    return await producer.ProduceAsync(topic, msg);
                }
                else
                {
                    producer.Produce(topic, msg, (deliveryReport) =>
                    {
                        if (deliveryReport.Error.IsError)
                        {
                            _logger.LogError("Failed to deliver message: {Error}", deliveryReport.Error.Reason);
                        }
                        else
                        {
                            _logger.LogInformation("Message delivered to {Topic} partition {Partition} offset {Offset}", 
                                deliveryReport.Topic, deliveryReport.Partition, deliveryReport.Offset);
                        }
                    });
                    
                    // Pour le mode synchrone, nous devons flush
                    producer.Flush(TimeSpan.FromSeconds(10));
                    return new DeliveryResult<string, string>
                    {
                        Topic = topic,
                        Partition = 0,
                        Offset = 0,
                        Message = msg
                    };
                }
            }
            catch (ProduceException<string, string> ex)
            {
                _logger.LogError(ex, "Error producing message to topic {Topic}", topic);
                throw;
            }
        }

        public void Dispose()
        {
            _plainProducer?.Dispose();
            _idempotentProducer?.Dispose();
        }
    }
}
