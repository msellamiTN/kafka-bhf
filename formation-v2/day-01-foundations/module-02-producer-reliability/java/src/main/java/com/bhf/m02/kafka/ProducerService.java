package com.bhf.m02.kafka;

import jakarta.annotation.PreDestroy;
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.clients.producer.RecordMetadata;
import org.apache.kafka.common.serialization.StringSerializer;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.Map;
import java.util.Properties;
import java.util.UUID;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class ProducerService {

    private final KafkaProducer<String, String> plainProducer;
    private final KafkaProducer<String, String> idempotentProducer;

    private final ConcurrentHashMap<String, Map<String, Object>> statusByRequestId = new ConcurrentHashMap<>();

    public ProducerService() {
        String bootstrapServers = System.getenv().getOrDefault("KAFKA_BOOTSTRAP_SERVERS", "localhost:9092");

        Properties baseProps = new Properties();
        baseProps.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServers);
        baseProps.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        baseProps.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());

        baseProps.put(ProducerConfig.REQUEST_TIMEOUT_MS_CONFIG, intEnv("KAFKA_REQUEST_TIMEOUT_MS", 1000));
        baseProps.put(ProducerConfig.DELIVERY_TIMEOUT_MS_CONFIG, intEnv("KAFKA_DELIVERY_TIMEOUT_MS", 120000));
        baseProps.put(ProducerConfig.RETRY_BACKOFF_MS_CONFIG, intEnv("KAFKA_RETRY_BACKOFF_MS", 100));
        baseProps.put(ProducerConfig.RETRIES_CONFIG, intEnv("KAFKA_RETRIES", 10));
        baseProps.put(ProducerConfig.LINGER_MS_CONFIG, intEnv("KAFKA_LINGER_MS", 0));

        Properties plainProps = new Properties();
        plainProps.putAll(baseProps);
        plainProps.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, false);
        plainProps.put(ProducerConfig.ACKS_CONFIG, System.getenv().getOrDefault("KAFKA_ACKS_PLAIN", "1"));

        Properties idempotentProps = new Properties();
        idempotentProps.putAll(baseProps);
        idempotentProps.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, true);
        idempotentProps.put(ProducerConfig.ACKS_CONFIG, "all");
        idempotentProps.put(ProducerConfig.MAX_IN_FLIGHT_REQUESTS_PER_CONNECTION, 5);

        this.plainProducer = new KafkaProducer<>(plainProps);
        this.idempotentProducer = new KafkaProducer<>(idempotentProps);
    }

    public RecordMetadata sendSync(boolean idempotent, String topic, Integer partition, String key, String value) throws Exception {
        KafkaProducer<String, String> producer = idempotent ? idempotentProducer : plainProducer;

        ProducerRecord<String, String> record = partition == null
                ? new ProducerRecord<>(topic, key, value)
                : new ProducerRecord<>(topic, partition, key, value);

        return producer.send(record).get();
    }

    public String sendAsync(boolean idempotent, String topic, Integer partition, String key, String value) {
        KafkaProducer<String, String> producer = idempotent ? idempotentProducer : plainProducer;

        String requestId = UUID.randomUUID().toString();

        Map<String, Object> pending = new HashMap<>();
        pending.put("requestId", requestId);
        pending.put("state", "PENDING");
        statusByRequestId.put(requestId, pending);

        ProducerRecord<String, String> record = partition == null
                ? new ProducerRecord<>(topic, key, value)
                : new ProducerRecord<>(topic, partition, key, value);

        try {
            producer.send(record, (metadata, exception) -> {
                Map<String, Object> status = new HashMap<>();
                status.put("requestId", requestId);

                if (exception != null) {
                    status.put("state", "ERROR");
                    status.put("error", exception.getClass().getSimpleName() + ": " + exception.getMessage());
                } else {
                    status.put("state", "OK");
                    status.put("topic", metadata.topic());
                    status.put("partition", metadata.partition());
                    status.put("offset", metadata.offset());
                }

                statusByRequestId.put(requestId, status);
            });
        } catch (RuntimeException e) {
            Map<String, Object> status = new HashMap<>();
            status.put("requestId", requestId);
            status.put("state", "ERROR");
            status.put("error", e.getClass().getSimpleName() + ": " + e.getMessage());
            statusByRequestId.put(requestId, status);
        }

        return requestId;
    }

    public Map<String, Object> getStatus(String requestId) {
        return statusByRequestId.get(requestId);
    }

    @PreDestroy
    public void shutdown() {
        try {
            plainProducer.close();
        } catch (Exception ignored) {
        }
        try {
            idempotentProducer.close();
        } catch (Exception ignored) {
        }
    }

    private static int intEnv(String key, int defaultValue) {
        String raw = System.getenv(key);
        if (raw == null || raw.isBlank()) {
            return defaultValue;
        }
        try {
            return Integer.parseInt(raw);
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }
}
