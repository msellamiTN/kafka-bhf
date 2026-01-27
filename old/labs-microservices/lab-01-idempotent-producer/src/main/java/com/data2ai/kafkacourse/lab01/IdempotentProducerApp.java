package com.data2ai.kafkacourse.lab01;

import org.apache.kafka.clients.producer.*;
import org.apache.kafka.common.serialization.StringSerializer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Properties;
import java.util.concurrent.ExecutionException;

public class IdempotentProducerApp {
    private static final Logger log = LoggerFactory.getLogger(IdempotentProducerApp.class);

    public static void main(String[] args) {
        Properties props = new Properties();
        props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
        props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());

        // Idempotent producer constraints
        props.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, true);
        props.put(ProducerConfig.ACKS_CONFIG, "all");
        props.put(ProducerConfig.RETRIES_CONFIG, Integer.MAX_VALUE);
        props.put(ProducerConfig.MAX_IN_FLIGHT_REQUESTS_PER_CONNECTION, 5);

        try (Producer<String, String> producer = new KafkaProducer<>(props)) {
            String topic = "lab01-idempotent-topic";
            String key = "order-123";
            String value = "{\"orderId\":\"order-123\",\"amount\":100.0,\"status\":\"CREATED\"}";

            log.info("Sending record with idempotent producer...");
            ProducerRecord<String, String> record = new ProducerRecord<>(topic, key, value);

            try {
                RecordMetadata metadata = producer.send(record).get();
                log.info("Record sent successfully to topic {} partition {} offset {}",
                        metadata.topic(), metadata.partition(), metadata.offset());
            } catch (InterruptedException | ExecutionException e) {
                log.error("Failed to send record", e);
            }
        }
    }
}
