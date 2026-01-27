package com.data2ai.kafkacourse.lab04;

import org.apache.kafka.clients.consumer.*;
import org.apache.kafka.clients.producer.*;
import org.apache.kafka.common.serialization.StringDeserializer;
import org.apache.kafka.common.serialization.StringSerializer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.time.Duration;
import java.util.Collections;
import java.util.Properties;

public class EosReadProcessWriteApp {
    private static final Logger log = LoggerFactory.getLogger(EosReadProcessWriteApp.class);

    public static void main(String[] args) {
        Properties consumerProps = new Properties();
        consumerProps.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
        consumerProps.put(ConsumerConfig.GROUP_ID_CONFIG, "lab04-eos-group");
        consumerProps.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        consumerProps.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        consumerProps.put(ConsumerConfig.ISOLATION_LEVEL_CONFIG, "read_committed");
        consumerProps.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, "false");

        Properties producerProps = new Properties();
        producerProps.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
        producerProps.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        producerProps.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        producerProps.put(ProducerConfig.TRANSACTIONAL_ID_CONFIG, "lab04-eos-transactional");
        producerProps.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, true);

        try (KafkaConsumer<String, String> consumer = new KafkaConsumer<>(consumerProps);
             KafkaProducer<String, String> producer = new KafkaProducer<>(producerProps)) {

            producer.initTransactions();
            log.info("EOS Read-Process-Write initialized");

            String inputTopic = "lab02-transactional-topic";
            String outputTopic = "lab04-eos-output-topic";
            
            consumer.subscribe(Collections.singletonList(inputTopic));

            while (true) {
                ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(1000));
                
                if (!records.isEmpty()) {
                    try {
                        producer.beginTransaction();
                        log.info("Started transaction for {} records", records.count());

                        for (ConsumerRecord<String, String> record : records) {
                            // Process the record
                            String processedValue = processRecord(record);
                            
                            // Send to output topic
                            ProducerRecord<String, String> outputRecord = 
                                new ProducerRecord<>(outputTopic, record.key(), processedValue);
                            producer.send(outputRecord);
                            
                            log.info("Processed and sent: {} -> {}", record.value(), processedValue);
                        }

                        // Send offsets to transaction
                        Map<TopicPartition, OffsetAndMetadata> offsets = 
                            consumer.committed(Collections.singleton(new TopicPartition(inputTopic, 0)));
                        producer.sendOffsetsToTransaction(offsets, consumer);
                        
                        producer.commitTransaction();
                        log.info("Transaction committed successfully");
                        
                    } catch (Exception e) {
                        log.error("Error in transaction, aborting", e);
                        producer.abortTransaction();
                    }
                }
            }
        }
    }

    private static String processRecord(ConsumerRecord<String, String> record) {
        // Simple processing: add "PROCESSED" prefix
        return "PROCESSED: " + record.value();
    }
}
