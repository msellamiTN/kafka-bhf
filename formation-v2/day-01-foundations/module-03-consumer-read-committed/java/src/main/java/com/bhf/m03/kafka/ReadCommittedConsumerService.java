package com.bhf.m03.kafka;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.annotation.PreDestroy;
import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.common.serialization.StringDeserializer;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Map;
import java.util.Properties;
import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.concurrent.atomic.AtomicBoolean;
import java.util.concurrent.atomic.AtomicLong;

@Service
public class ReadCommittedConsumerService {

    private final ObjectMapper objectMapper;

    private final AtomicLong processedCount = new AtomicLong(0);
    private final ConcurrentLinkedQueue<String> processedTxIds = new ConcurrentLinkedQueue<>();

    private final AtomicBoolean running = new AtomicBoolean(true);
    private final Thread consumerThread;

    public ReadCommittedConsumerService(ObjectMapper objectMapper) {
        this.objectMapper = objectMapper;
        this.consumerThread = new Thread(this::runLoop, "m03-consumer");
        this.consumerThread.setDaemon(true);
        this.consumerThread.start();
    }

    public Map<String, Object> metrics() {
        List<String> ids = new ArrayList<>(processedTxIds);
        return Map.of(
                "processedCount", processedCount.get(),
                "processedTxIds", ids
        );
    }

    private void rememberTxId(String txId) {
        if (txId == null || txId.isBlank()) {
            return;
        }

        processedTxIds.add(txId);
        while (processedTxIds.size() > 20) {
            processedTxIds.poll();
        }
    }

    private void runLoop() {
        while (running.get()) {
            try (KafkaConsumer<String, String> consumer = new KafkaConsumer<>(consumerProps())) {
                String topic = System.getenv().getOrDefault("KAFKA_TOPIC", "bhf-read-committed-demo");
                consumer.subscribe(Collections.singletonList(topic));

                while (running.get()) {
                    ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(500));

                    for (ConsumerRecord<String, String> record : records) {
                        String txId = extractTxId(record.value());
                        rememberTxId(txId);
                        processedCount.incrementAndGet();
                    }

                    if (!records.isEmpty()) {
                        consumer.commitSync();
                    }
                }
            } catch (Exception e) {
                try {
                    Thread.sleep(2000);
                } catch (InterruptedException ie) {
                    Thread.currentThread().interrupt();
                    return;
                }
            }
        }
    }

    private String extractTxId(String rawJson) {
        if (rawJson == null) {
            return null;
        }
        try {
            JsonNode node = objectMapper.readTree(rawJson);
            JsonNode txId = node.get("txId");
            if (txId == null || txId.isNull()) {
                return null;
            }
            return txId.asText();
        } catch (Exception e) {
            return null;
        }
    }

    private Properties consumerProps() {
        String bootstrapServers = System.getenv().getOrDefault("KAFKA_BOOTSTRAP_SERVERS", "localhost:9092");
        String groupId = System.getenv().getOrDefault("KAFKA_GROUP_ID", "m03-java-consumer");

        Properties props = new Properties();
        props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrapServers);
        props.put(ConsumerConfig.GROUP_ID_CONFIG, groupId);
        props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
        props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest");
        props.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, false);
        props.put(ConsumerConfig.ISOLATION_LEVEL_CONFIG, "read_committed");
        props.put(ConsumerConfig.MAX_POLL_RECORDS_CONFIG, 50);

        return props;
    }

    @PreDestroy
    public void shutdown() {
        running.set(false);
        consumerThread.interrupt();
        try {
            consumerThread.join(2000);
        } catch (InterruptedException e) {
            Thread.currentThread().interrupt();
        }
    }
}
