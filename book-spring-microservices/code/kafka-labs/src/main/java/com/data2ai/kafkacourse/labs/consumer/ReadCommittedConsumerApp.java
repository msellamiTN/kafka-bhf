package com.data2ai.kafkacourse.labs.consumer;

import java.time.Duration;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;
import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.clients.consumer.OffsetAndMetadata;
import org.apache.kafka.common.TopicPartition;
import org.apache.kafka.common.serialization.StringDeserializer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ReadCommittedConsumerApp {
  private static final Logger logger = LoggerFactory.getLogger(ReadCommittedConsumerApp.class);

  public static void main(String[] args) {
    String topic = args.length > 0 ? args[0] : "txn-topic";
    String bootstrap = args.length > 1 ? args[1] : "localhost:9092";
    String groupId = args.length > 2 ? args[2] : "read-committed-group";

    Properties props = new Properties();
    props.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrap);
    props.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
    props.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
    props.put(ConsumerConfig.GROUP_ID_CONFIG, groupId);
    props.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest");
    props.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, "false");
    props.put(ConsumerConfig.ISOLATION_LEVEL_CONFIG, "read_committed");

    try (KafkaConsumer<String, String> consumer = new KafkaConsumer<>(props)) {
      consumer.subscribe(Collections.singletonList(topic));

      Map<TopicPartition, OffsetAndMetadata> offsets = new HashMap<>();

      while (true) {
        ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(500));

        for (ConsumerRecord<String, String> record : records) {
          logger.info("recv topic={} partition={} offset={} key={} value={}", record.topic(), record.partition(),
              record.offset(), record.key(), record.value());

          offsets.put(new TopicPartition(record.topic(), record.partition()), new OffsetAndMetadata(record.offset() + 1));
        }

        if (!offsets.isEmpty()) {
          consumer.commitSync(offsets);
          offsets.clear();
        }
      }
    }
  }
}
