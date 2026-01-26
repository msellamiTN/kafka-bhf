package com.data2ai.kafkacourse.labs.producer;

import java.time.Instant;
import java.util.Properties;
import org.apache.kafka.clients.producer.KafkaProducer;
import org.apache.kafka.clients.producer.ProducerConfig;
import org.apache.kafka.clients.producer.ProducerRecord;
import org.apache.kafka.common.serialization.StringSerializer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class TransactionalProducerApp {
  private static final Logger logger = LoggerFactory.getLogger(TransactionalProducerApp.class);

  public static void main(String[] args) {
    String topic = args.length > 0 ? args[0] : "txn-topic";
    String bootstrap = args.length > 1 ? args[1] : "localhost:9092";
    String transactionalId = args.length > 2 ? args[2] : "txn-producer-1";
    int totalRecords = args.length > 3 ? Integer.parseInt(args[3]) : 50;
    int abortEveryTxn = args.length > 4 ? Integer.parseInt(args[4]) : 0; // 0 => never abort

    Properties props = new Properties();
    props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrap);
    props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
    props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());

    props.put(ProducerConfig.ACKS_CONFIG, "all");
    props.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, "true");
    props.put(ProducerConfig.MAX_IN_FLIGHT_REQUESTS_PER_CONNECTION, 5);
    props.put(ProducerConfig.RETRIES_CONFIG, Integer.MAX_VALUE);

    props.put(ProducerConfig.TRANSACTIONAL_ID_CONFIG, transactionalId);

    int batchSize = 10;

    try (KafkaProducer<String, String> producer = new KafkaProducer<>(props)) {
      producer.initTransactions();

      int txnIndex = 0;
      int sent = 0;

      while (sent < totalRecords) {
        txnIndex++;
        producer.beginTransaction();

        int toSend = Math.min(batchSize, totalRecords - sent);
        for (int i = 0; i < toSend; i++) {
          String key = "k" + ((sent + i) % 3);
          String value = "txn=" + txnIndex + " seq=" + (sent + i) + " @" + Instant.now();
          producer.send(new ProducerRecord<>(topic, key, value));
        }

        boolean abort = abortEveryTxn > 0 && (txnIndex % abortEveryTxn == 0);
        if (abort) {
          producer.abortTransaction();
          logger.info("ABORT txn={} records={}", txnIndex, toSend);
        } else {
          producer.commitTransaction();
          logger.info("COMMIT txn={} records={}", txnIndex, toSend);
        }

        sent += toSend;
      }

    } catch (Exception e) {
      logger.error("transactional producer error", e);
      throw new RuntimeException(e);
    }
  }
}
