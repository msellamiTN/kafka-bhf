package com.data2ai.kafkacourse.labs.transactions;

import java.time.Duration;
import java.util.Collections;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;
import org.apache.kafka.clients.consumer.ConsumerConfig;
import org.apache.kafka.clients.consumer.ConsumerRecord;
import org.apache.kafka.clients.consumer.ConsumerRecords;
import org.apache.kafka.clients.consumer.ConsumerGroupMetadata;
import org.apache.kafka.clients.consumer.KafkaConsumer;
import org.apache.kafka.clients.consumer.OffsetAndMetadata;
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.common.TopicPartition;
import org.apache.kafka.common.serialization.StringDeserializer;
import org.apache.kafka.common.serialization.StringSerializer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class ReadProcessWriteTransactionalApp {
  private static final Logger logger = LoggerFactory.getLogger(ReadProcessWriteTransactionalApp.class);

  public static void main(String[] args) {
    String inputTopic = args.length > 0 ? args[0] : "txn-input";
    String outputTopic = args.length > 1 ? args[1] : "txn-output";
    String bootstrap = args.length > 2 ? args[2] : "localhost:9092";
    String groupId = args.length > 3 ? args[3] : "txn-rpw-group";
    String transactionalId = args.length > 4 ? args[4] : "txn-rpw-1";

    Properties consumerProps = new Properties();
    consumerProps.put(ConsumerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrap);
    consumerProps.put(ConsumerConfig.KEY_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
    consumerProps.put(ConsumerConfig.VALUE_DESERIALIZER_CLASS_CONFIG, StringDeserializer.class.getName());
    consumerProps.put(ConsumerConfig.GROUP_ID_CONFIG, groupId);
    consumerProps.put(ConsumerConfig.AUTO_OFFSET_RESET_CONFIG, "earliest");
    consumerProps.put(ConsumerConfig.ENABLE_AUTO_COMMIT_CONFIG, "false");
    consumerProps.put(ConsumerConfig.ISOLATION_LEVEL_CONFIG, "read_committed");

    Properties producerProps = new Properties();
    producerProps.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrap);
    producerProps.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
    producerProps.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
    producerProps.put(ProducerConfig.ACKS_CONFIG, "all");
    producerProps.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, "true");
    producerProps.put(ProducerConfig.MAX_IN_FLIGHT_REQUESTS_PER_CONNECTION, 5);
    producerProps.put(ProducerConfig.RETRIES_CONFIG, Integer.MAX_VALUE);
    producerProps.put(ProducerConfig.TRANSACTIONAL_ID_CONFIG, transactionalId);

    try (KafkaConsumer<String, String> consumer = new KafkaConsumer<>(consumerProps);
        KafkaProducer<String, String> producer = new KafkaProducer<>(producerProps)) {

      producer.initTransactions();
      consumer.subscribe(Collections.singletonList(inputTopic));

      while (true) {
        ConsumerRecords<String, String> records = consumer.poll(Duration.ofMillis(500));
        if (records.isEmpty()) {
          continue;
        }

        Map<TopicPartition, OffsetAndMetadata> offsets = new HashMap<>();
        ConsumerGroupMetadata groupMetadata = consumer.groupMetadata();

        producer.beginTransaction();
        try {
          for (ConsumerRecord<String, String> record : records) {
            String outValue = record.value() == null ? null : record.value().toUpperCase();
            producer.send(new ProducerRecord<>(outputTopic, record.key(), outValue));

            offsets.put(new TopicPartition(record.topic(), record.partition()), new OffsetAndMetadata(record.offset() + 1));
          }

          producer.sendOffsetsToTransaction(offsets, groupMetadata);
          producer.commitTransaction();

          logger.info("processed batch size={} offsetsCommitted={}", records.count(), offsets.size());

        } catch (Exception e) {
          producer.abortTransaction();
          logger.error("transaction aborted", e);
        }
      }
    }
  }
}
