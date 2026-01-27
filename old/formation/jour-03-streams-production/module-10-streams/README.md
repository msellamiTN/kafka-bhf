# Module 10 - Kafka Streams WordCount EOS v2

## 📚 Théorie (30%) - Kafka Streams Architecture

### 10.1 Streams Architecture

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│Source Topic │───▶│   Stream    │───▶│Output Topic │
│   Input     │    │ Processing  │    │   Result    │
└─────────────┘    └─────────────┘    └─────────────┘
                           │
                   ┌─────────────┐
                   │ State Store │
                   │ (Local)     │
                   └─────────────┘
```

### 10.2 Exactly-Once v2 vs v1

| Caractéristique | EOS v1 | EOS v2 |
|----------------|--------|--------|
| **Performance** | 2-phase commit | Optimisé |
| **Latency** | Élevée | Réduite |
| **Scalabilité** | Limitée | Améliorée |
| **Complexité** | Simple | Moderée |

### 10.3 WordCount Topology

```
Input Topic          Stream Processing          Output Topic
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│"hello world"│───▶│  ["hello", │───▶│"hello": 3   │
│"kafka rocks"│    │   "world"]  │    │"world": 2   │
│"hello kafka"│    │   ["kafka", │    │"kafka": 2   │
└─────────────┘    │   "rocks"]  │    │"rocks": 1   │
                   └─────────────┘    └─────────────┘
                           │
                   ┌─────────────┐
                   │   Count     │
                   │ Aggregation │
                   └─────────────┘
```

---

## 🛠️ Pratique (70%) - Streams WordCount EOS v2

### Lab 10.1 - Application Streams BHF

#### Étape 1 : Configuration Maven

```xml
<dependencies>
    <dependency>
        <groupId>org.apache.kafka</groupId>
        <artifactId>kafka-streams</artifactId>
        <version>3.4.1</version>
    </dependency>
    <dependency>
        <groupId>org.slf4j</groupId>
        <artifactId>slf4j-api</artifactId>
        <version>1.7.36</version>
    </dependency>
    <dependency>
        <groupId>ch.qos.logback</groupId>
        <artifactId>logback-classic</artifactId>
        <version>1.2.12</version>
    </dependency>
</dependencies>
```

#### Étape 2 : Application Streams

```java
package com.bhf.kafka.streams;

import org.apache.kafka.common.serialization.Serdes;
import org.apache.kafka.streams.KafkaStreams;
import org.apache.kafka.streams.StreamsBuilder;
import org.apache.kafka.streams.StreamsConfig;
import org.apache.kafka.streams.Topology;
import org.apache.kafka.streams.kstream.KStream;
import org.apache.kafka.streams.kstream.Produced;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Properties;
import java.util.concurrent.CountDownLatch;

public class BhfWordCountStreamsApp {
    private static final Logger log = LoggerFactory.getLogger(BhfWordCountStreamsApp.class);

    public static void main(String[] args) {
        // 🔥 Configuration Streams EOS v2
        Properties props = new Properties();
        props.put(StreamsConfig.APPLICATION_ID_CONFIG, "bhf-wordcount-eos-v2");
        props.put(StreamsConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
        props.put(StreamsConfig.DEFAULT_KEY_SERDE_CLASS_CONFIG, Serdes.String().getClass());
        props.put(StreamsConfig.DEFAULT_VALUE_SERDE_CLASS_CONFIG, Serdes.String().getClass());

        // 🔥 Exactly-Once v2 pour BHF
        props.put(StreamsConfig.PROCESSING_GUARANTEE_CONFIG, StreamsConfig.EXACTLY_ONCE_V2);
        props.put(StreamsConfig.STATE_DIR_CONFIG, "/tmp/kafka-streams/bhf-wordcount");
        props.put(StreamsConfig.NUM_STREAM_THREADS_CONFIG, 3);
        props.put(StreamsConfig.COMMIT_INTERVAL_MS_CONFIG, 1000);

        StreamsBuilder builder = new StreamsBuilder();

        // 🔥 Construction de la topology WordCount
        KStream<String, String> textLines = builder.stream("bhf-transaction-events");
        
        KStream<String, Long> wordCounts = textLines
            .flatMapValues(textLine -> textLine.toLowerCase().split("\\W+"))
            .groupBy((key, word) -> word)
            .count();

        wordCounts.toStream().to("bhf-wordcount-output", 
            Produced.with(Serdes.String(), Serdes.Long()));

        Topology topology = builder.build();
        log.info("🏦 Topology BHF WordCount: {}", topology.describe());

        KafkaStreams streams = new KafkaStreams(topology, props);
        CountDownLatch latch = new CountDownLatch(1);

        // 🔥 Shutdown handler gracieux
        Runtime.getRuntime().addShutdownHook(new Thread(() -> {
            log.info("🔄 Arrêt de l'application Streams BHF");
            streams.close();
            latch.countDown();
        }));

        try {
            streams.start();
            log.info("✅ Application BHF WordCount EOS v2 démarrée");
            latch.await();
        } catch (Throwable e) {
            log.error("💥 Erreur application BHF Streams", e);
            System.exit(1);
        }
    }
}
```

#### Étape 3 : Test de l'application

```powershell
# 1. Créer les topics BHF
docker exec kafka kafka-topics --create --topic bhf-transaction-events --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1
docker exec kafka kafka-topics --create --topic bhf-wordcount-output --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1

# 2. Compiler et exécuter
mvn clean package
java -jar target/bhf-wordcount-streams.jar
```

#### Étape 4 : Envoi de données BHF

```powershell
# Producer d'événements de transaction BHF
docker exec -it kafka kafka-console-producer --topic bhf-transaction-events --bootstrap-server localhost:9092

# Envoyer des événements BHF
> payment-processed:{"amount":1500.00,"status":"COMPLETED","timestamp":1643723400123}
> payment-validated:{"amount":250.50,"status":"VALIDATED","timestamp":1643723400456}
> payment-failed:{"amount":100.00,"status":"FAILED","timestamp":1643723400789}
> payment-processed:{"amount":500.00,"status":"COMPLETED","timestamp":1643723401123}
```

#### Étape 5 : Vérification des résultats

```powershell
# Consumer des résultats de comptage
docker exec kafka kafka-console-consumer --topic bhf-wordcount-output --bootstrap-server localhost:9092 --from-beginning --property print.key=true --property key.separator="="
```

**Résultat attendu :**
```
payment	3
processed	2
amount	4
1500.00	1
250.50	1
100.00	1
500.00	1
status	3
completed	2
validated	1
failed	1
timestamp	4
1643723400123	1
1643723400456	1
1643723400789	1
1643723401123	1
```

#### Étape 6 : Test de l'EOS v2

```powershell
# Envoyer les mêmes messages plusieurs fois
# Observer que le comptage reste cohérent (pas de double comptage)
```

---

## 🎯 Checkpoint Module 10

### ✅ Validation des compétences

- [ ] Application Streams configurée avec EOS v2
- [ ] Topology WordCount fonctionnelle
- [ State stores locaux créés
- [ ] Exactly-Once garanti (pas de double comptage)

### 📝 Questions de checkpoint

1. **Pourquoi EOS v2 est meilleur pour BHF ?**
   - Latence réduite pour transactions temps réel
   - Scalabilité améliorée pour gros volumes

2. **Quel est l'impact des state stores ?**
   - Persistance locale pour reprise après crash
   - Performance accrue pour agrégations

3. **Comment monitorer une application Streams ?**
   - JMX metrics pour throughput/latence
   - State store size pour monitoring

---

## 🚀 Prochain module

**Module 11** : Monitoring Kafka - JMX, Prometheus, et alertes BHF.
