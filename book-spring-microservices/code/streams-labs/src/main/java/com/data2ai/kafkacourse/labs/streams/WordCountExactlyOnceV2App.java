package com.data2ai.kafkacourse.labs.streams;

import java.util.Arrays;
import java.util.Properties;
import org.apache.kafka.common.serialization.Serdes;
import org.apache.kafka.streams.KafkaStreams;
import org.apache.kafka.streams.StreamsBuilder;
import org.apache.kafka.streams.StreamsConfig;
import org.apache.kafka.streams.kstream.Consumed;
import org.apache.kafka.streams.kstream.Grouped;
import org.apache.kafka.streams.kstream.KStream;
import org.apache.kafka.streams.kstream.KTable;
import org.apache.kafka.streams.kstream.Materialized;
import org.apache.kafka.streams.kstream.Produced;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class WordCountExactlyOnceV2App {
  private static final Logger logger = LoggerFactory.getLogger(WordCountExactlyOnceV2App.class);

  public static void main(String[] args) {
    String bootstrap = args.length > 0 ? args[0] : "localhost:9092";
    String inputTopic = args.length > 1 ? args[1] : "text-input";
    String outputTopic = args.length > 2 ? args[2] : "word-count-output";
    String appId = args.length > 3 ? args[3] : "wordcount-eosv2";

    Properties props = new Properties();
    props.put(StreamsConfig.APPLICATION_ID_CONFIG, appId);
    props.put(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG, bootstrap);

    props.put(StreamsConfig.DEFAULT_KEY_SERDE_CLASS_CONFIG, Serdes.String().getClass());
    props.put(StreamsConfig.DEFAULT_VALUE_SERDE_CLASS_CONFIG, Serdes.String().getClass());

    String stateDir = System.getProperty("java.io.tmpdir") + "/kstreams-" + appId;
    props.put(StreamsConfig.STATE_DIR_CONFIG, stateDir);

    props.put(StreamsConfig.PROCESSING_GUARANTEE_CONFIG, StreamsConfig.EXACTLY_ONCE_V2);

    StreamsBuilder builder = new StreamsBuilder();

    KStream<String, String> textLines = builder.stream(inputTopic, Consumed.with(Serdes.String(), Serdes.String()));

    KTable<String, Long> counts = textLines
        .peek((k, v) -> logger.info("in key={} value={}", k, v))
        .mapValues(v -> v == null ? "" : v.toLowerCase())
        .flatMapValues(v -> Arrays.asList(v.split("\\W+")))
        .filter((k, word) -> word != null && !word.isBlank())
        .groupBy((k, word) -> word, Grouped.with(Serdes.String(), Serdes.String()))
        .count(Materialized.as("word-counts"));

    counts.toStream().to(outputTopic, Produced.with(Serdes.String(), Serdes.Long()));

    KafkaStreams streams = new KafkaStreams(builder.build(), props);

    Runtime.getRuntime().addShutdownHook(new Thread(streams::close));

    streams.start();
  }
}
