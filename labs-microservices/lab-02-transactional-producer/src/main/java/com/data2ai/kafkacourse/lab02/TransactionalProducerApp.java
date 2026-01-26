package com.data2ai.kafkacourse.lab02;

import org.apache.kafka.clients.producer.*;
import org.apache.kafka.common.serialization.StringSerializer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Properties;
import java.util.concurrent.ExecutionException;

public class TransactionalProducerApp {
    private static final Logger log = LoggerFactory.getLogger(TransactionalProducerApp.class);

    public static void main(String[] args) {
        Properties props = new Properties();
        props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
        props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());

        // Transactional producer configuration
        props.put(ProducerConfig.TRANSACTIONAL_ID_CONFIG, "lab02-transactional-producer");
        props.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, true);
        props.put(ProducerConfig.ACKS_CONFIG, "all");

        try (Producer<String, String> producer = new KafkaProducer<>(props)) {
            producer.initTransactions();
            log.info("Transactional producer initialized");

            String topic = "lab02-transactional-topic";
            String key = "payment-456";
            String value = "{\"paymentId\":\"payment-456\",\"amount\":250.0,\"currency\":\"USD\"}";

            try {
                producer.beginTransaction();
                log.info("Transaction started");

                ProducerRecord<String, String> record = new ProducerRecord<>(topic, key, value);
                producer.send(record).get();
                log.info("Record sent in transaction");

                // Simulate business logic decision
                boolean shouldCommit = true; // Change to false to test abort

                if (shouldCommit) {
                    producer.commitTransaction();
                    log.info("Transaction committed");
                } else {
                    producer.abortTransaction();
                    log.info("Transaction aborted");
                }
            } catch (Exception e) {
                log.error("Error in transaction, aborting", e);
                producer.abortTransaction();
            }
        }
    }
}
