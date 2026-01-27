package com.bhf.m03.kafka;

import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.annotation.PreDestroy;
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.common.serialization.StringSerializer;
import org.springframework.stereotype.Service;

import java.time.Instant;
import java.util.Map;
import java.util.Properties;

@Service
public class TransactionalProducerService {

    private final ObjectMapper objectMapper;
    private final KafkaProducer<String, String> producer;

    private final String topic;

    public TransactionalProducerService(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
        this.topic = System.getenv().getOrDefault("KAFKA_TOPIC", "bhf-read-committed-demo");

        Properties props = new Properties();
        props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, System.getenv().getOrDefault("KAFKA_BOOTSTRAP_SERVERS", "localhost:9092"));
        props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());

        props.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, true);
        props.put(ProducerConfig.ACKS_CONFIG, "all");
        props.put(ProducerConfig.RETRIES_CONFIG, Integer.MAX_VALUE);
        props.put(ProducerConfig.MAX_IN_FLIGHT_REQUESTS_PER_CONNECTION, 5);

        props.put(ProducerConfig.TRANSACTIONAL_ID_CONFIG, System.getenv().getOrDefault("KAFKA_TRANSACTIONAL_ID", "m03-tx-producer"));

        this.producer = new KafkaProducer<>(props);

        initTransactionsWithRetry();
    }

    public void produceCommitted(String txId) throws Exception {
        producer.beginTransaction();
        try {
            producer.send(new ProducerRecord<>(topic, txId, payload(txId, "COMMITTED"))).get();
            producer.commitTransaction();
        } catch (Exception e) {
            producer.abortTransaction();
            throw e;
        }
    }

    public void produceAborted(String txId) throws Exception {
        producer.beginTransaction();
        try {
            producer.send(new ProducerRecord<>(topic, txId, payload(txId, "ABORTED"))).get();
            producer.abortTransaction();
        } catch (Exception e) {
            producer.abortTransaction();
            throw e;
        }
    }

    private String payload(String txId, String status) throws Exception {
        return objectMapper.writeValueAsString(
                Map.of(
                        "txId", txId,
                        "status", status,
                        "ts", Instant.now().toString(),
                        "api", "java"
                )
        );
    }

    private void initTransactionsWithRetry() {
        for (int i = 0; i < 60; i++) {
            try {
                producer.initTransactions();
                return;
            } catch (Exception e) {
                try {
                    Thread.sleep(1000);
                } catch (InterruptedException ie) {
                    Thread.currentThread().interrupt();
                    throw new RuntimeException("Interrupted while initializing transactions", ie);
                }
            }
        }

        throw new RuntimeException("Failed to initTransactions after retries");
    }

    @PreDestroy
    public void shutdown() {
        try {
            producer.close();
        } catch (Exception ignored) {
        }
    }
}
