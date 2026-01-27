package com.bhf.kafka;

import org.apache.kafka.clients.producer.*;
import org.apache.kafka.common.serialization.StringSerializer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Properties;
import java.util.concurrent.ExecutionException;

public class IdempotentProducerApp {
    private static final Logger log = LoggerFactory.getLogger(IdempotentProducerApp.class);

    public static void main(String[] args) {
        // 🔥 Configuration producer idempotent
        Properties props = new Properties();
        props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
        props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());

        // Configuration idempotent BHF
        props.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, true);
        props.put(ProducerConfig.ACKS_CONFIG, "all");
        props.put(ProducerConfig.RETRIES_CONFIG, Integer.MAX_VALUE);
        props.put(ProducerConfig.MAX_IN_FLIGHT_REQUESTS_PER_CONNECTION, 5);
        props.put(ProducerConfig.DELIVERY_TIMEOUT_MS_CONFIG, 30000);

        try (KafkaProducer<String, String> producer = new KafkaProducer<>(props)) {
            String topic = "bhf-transactions";
            
            // Transaction BHF de test
            String transactionId = "TXN-" + System.currentTimeMillis();
            String key = "account-" + (int)(Math.random() * 1000);
            String value = String.format(
                "{\"transactionId\":\"%s\",\"amount\":%.2f,\"currency\":\"EUR\",\"type\":\"DEBIT\",\"status\":\"PENDING\"}",
                transactionId, 100 + Math.random() * 1000
            );

            log.info("🏦 Envoi transaction BHF : {}", transactionId);

            try {
                ProducerRecord<String, String> record = new ProducerRecord<>(topic, key, value);
                
                // 🔥 Envoi synchrone pour garantir la réception
                RecordMetadata metadata = producer.send(record).get();
                
                log.info("✅ Transaction envoyée avec succès :");
                log.info("   Topic : {}", metadata.topic());
                log.info("   Partition : {}", metadata.partition());
                log.info("   Offset : {}", metadata.offset());
                log.info("   Timestamp : {}", metadata.timestamp());
                
            } catch (InterruptedException | ExecutionException e) {
                log.error("❌ Erreur lors de l'envoi de la transaction", e);
            }
        }
    }
}
