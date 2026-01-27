package com.data2ai.kafkacourse.lab05;

import org.apache.kafka.common.serialization.Serdes;
import org.apache.kafka.streams.KafkaStreams;
import org.apache.kafka.streams.StreamsBuilder;
import org.apache.kafka.streams.StreamsConfig;
import org.apache.kafka.streams.Topology;
import org.apache.kafka.streams.kstream.KStream;
import org.apache.kafka.streams.kstream.KTable;
import org.apache.kafka.streams.kstream.Produced;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Properties;
import java.util.concurrent.CountDownLatch;

public class WordCountExactlyOnceV2App {
    private static final Logger log = LoggerFactory.getLogger(WordCountExactlyOnceV2App.class);

    public static void main(String[] args) {
        Properties props = new Properties();
        props.put(StreamsConfig.APPLICATION_ID_CONFIG, "lab05-wordcount-eos-v2");
        props.put(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
        props.put(StreamsConfig.DEFAULT_KEY_SERDE_CLASS_CONFIG, Serdes.String().getClass());
        props.put(StreamsConfig.DEFAULT_VALUE_SERDE_CLASS_CONFIG, Serdes.String().getClass());

        // Exactly-Once v2 processing guarantee
        props.put(StreamsConfig.PROCESSING_GUARANTEE_CONFIG, StreamsConfig.EXACTLY_ONCE_V2);
        props.put(StreamsConfig.STATE_DIR_CONFIG, "/tmp/kafka-streams/lab05");

        StreamsBuilder builder = new StreamsBuilder();

        // Build the WordCount topology
        KStream<String, String> textLines = builder.stream("lab05-text-input-topic");
        
        KTable<String, Long> wordCounts = textLines
            .flatMapValues(textLine -> textLine.toLowerCase().split("\\W+"))
            .groupBy((key, word) -> word)
            .count();

        wordCounts.toStream().to("lab05-wordcount-output-topic", 
            Produced.with(Serdes.String(), Serdes.Long()));

        Topology topology = builder.build();
        log.info("Topology: {}", topology.describe());

        KafkaStreams streams = new KafkaStreams(topology, props);
        CountDownLatch latch = new CountDownLatch(1);

        // Attach shutdown handler
        Runtime.getRuntime().addShutdownHook(new Thread(() -> {
            log.info("Shutting down streams...");
            streams.close();
            latch.countDown();
        }));

        try {
            streams.start();
            log.info("WordCount EOS v2 application started");
            latch.await();
        } catch (Throwable e) {
            log.error("Application error", e);
            System.exit(1);
        }
    }
}
