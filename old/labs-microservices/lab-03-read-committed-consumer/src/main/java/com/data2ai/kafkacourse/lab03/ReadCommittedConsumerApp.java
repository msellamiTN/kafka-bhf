package com.data2ai.kafkacourse.lab03;

import org.apache.kafka.clients.consumer.*;
import org.apache.kafka.common.serialization.StringDeserializer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.Duration;
import java.util.Collections;
import java.util.Properties;

public class ReadCommittedConsumerApp {
    private static final Logger log = LoggerFactory.getLogger(ReadCommittedConsumerApp.class);

    public static void main(String[] args) {
        Properties props = new Properties();
        props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
        props.put(ConsumerConfig.GROUP_ID_CONFIG, "lab03-read-committed-group");
        props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());

        // Read committed configuration
        props.put(ConsumerConfig.ISOLATION_LEVEL_CONFIG, "read_committed");
        props.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, "false");
        props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest");

        try (KafkaConsumer<String, String> consumer = new KafkaConsumer<>(props)) {
            String topic = "lab02-transactional-topic";
            consumer.subscribe(Collections.singletonList(topic));
            log.info("Read-committed consumer subscribed to {}", topic);

            while (true) {
                ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(1000));
                
                for (ConsumerRecord<String, String> record : records) {
                    log.info("Received record: key={}, value={}, partition={}, offset={}",
                            record.key(), record.value(), record.partition(), record.offset());
                    
                    // Process the record
                    processRecord(record);
                }

                if (!records.isEmpty()) {
                    // Manual commit after processing
                    consumer.commitSync();
                    log.info("Offsets committed");
                }
            }
        }
    }

    private static void processRecord(ConsumerRecord<String, String> record) {
        // Simulate processing
        try {
            Thread.sleep(100);
            log.info("Processed record: {}", record.key());
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
}
