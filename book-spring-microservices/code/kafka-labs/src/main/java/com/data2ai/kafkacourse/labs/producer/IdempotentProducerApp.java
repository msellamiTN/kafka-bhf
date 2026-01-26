package com.data2ai.kafkacourse.labs.producer;

import java.time.Instant;
import java.util.Properties;
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.clients.producer.RecordMetadata;
import org.apache.kafka.common.serialization.StringSerializer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class IdempotentProducerApp {
  private static final Logger logger = LoggerFactory.getLogger(IdempotentProducerApp.class);

  public static void main(String[] args) throws Exception {
    String topic = args.length > 0 ? args[0] : "expert02-events";
    String bootstrap = args.length > 1 ? args[1] : "localhost:9092";
    int count = args.length > 2 ? Integer.parseInt(args[2]) : 100;

    Properties props = new Properties();
    props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrap);
    props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
    props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());

    props.put(ProducerConfig.ACKS_CONFIG, "all");
    props.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, "true");
    props.put(ProducerConfig.MAX_IN_FLIGHT_REQUESTS_PER_CONNECTION, 5);
    props.put(ProducerConfig.RETRIES_CONFIG, 10);

    try (KafkaProducer<String, String> producer = new KafkaProducer<>(props)) {
      for (int i = 0; i < count; i++) {
        String key = "order-" + (i % 10);
        String value = "event#" + i + "@" + Instant.now();

        ProducerRecord<String, String> record = new ProducerRecord<>(topic, key, value);
        RecordMetadata md = producer.send(record).get();

        logger.info("sent topic={} key={} partition={} offset={}", topic, key, md.partition(), md.offset());
      }

      producer.flush();
    }
  }
}
