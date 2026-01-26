# Module 02 - Producer Idempotent

## 📚 Théorie (30%) - Producteur Kafka & Idempotence

### 2.1 Cycle de vie du producteur

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Record     │───▶│   Serializer │───▶│   Partitioner│───▶│    Broker   │
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
```

### 2.2 Problème : Messages dupliqués

#### Scénario BHF typique :
```
1. Envoi transaction "paiement-1000€"
2. Timeout réseau
3. Retry automatique
4. Deux fois le même paiement ❌
```

#### Impact bancaire :
- **Double débit** : Inacceptable
- **Réglementaire** : Non conforme
- **Client** : Mécontent

### 2.3 Solution : Idempotence Kafka

#### 🔥 **Configuration idempotent**
```properties
enable.idempotence=true
acks=all
retries=Integer.MAX_VALUE
max.in.flight.requests.per.connection=5
```

#### 🎯 **Garanties**
- **Unicité** : Pas de doublons sur retries
- **Ordre** : Messages dans l'ordre d'envoi
- **Performance** : Impact minimal sur latence

### 2.4 Contraintes techniques

| Configuration | Valeur requise | Pourquoi ? |
|---------------|----------------|------------|
| `enable.idempotence` | `true` | Active l'anti-doublon |
| `acks` | `all` | Garantie de persistance |
| `max.in.flight.requests` | `≤ 5` | Ordre garanti |
| `retries` | `Integer.MAX_VALUE` | Retry infini |

---

## 🛠️ Pratique (70%) - Producer Idempotent BHF

### Lab 02.1 - Producer Idempotent pour Transactions BHF

#### Étape 1 : Configuration Maven

Créer `pom.xml` :
```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>com.bhf.kafka</groupId>
  <artifactId>idempotent-producer</artifactId>
  <version>1.0.0</version>

  <properties>
    <maven.compiler.source>11</maven.compiler.source>
    <maven.compiler.target>11</maven.compiler.target>
    <kafka.version>3.4.1</kafka.version>
  </properties>

  <dependencies>
    <dependency>
      <groupId>org.apache.kafka</groupId>
      <artifactId>kafka-clients</artifactId>
      <version>${kafka.version}</version>
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

  <build>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-compiler-plugin</artifactId>
        <version>3.11.0</version>
        <configuration>
          <source>11</source>
          <target>11</target>
        </configuration>
      </plugin>
    </plugins>
  </build>
</project>
```

#### Étape 2 : Code Producer Idempotent

Créer `src/main/java/com/bhf/kafka/IdempotentProducerApp.java` :
```java
package com.bhf.kafka;

import org.apache.kafka.clients.producer.*;
import org.apache.kafka.common.serialization.StringSerializer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Properties;
import java.util.concurrent.ExecutionException;

public class IdempotentProducerApp {
    private static final Logger log = LoggerFactory.getLogger(IdempotentProducerApp.class);

    public static void main(String[] args) {
        // 🔥 Configuration producer idempotent
        Properties props = new Properties();
        props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
        props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());

        // Configuration idempotent BHF
        props.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, true);
        props.put(ProducerConfig.ACKS_CONFIG, "all");
        props.put(ProducerConfig.RETRIES_CONFIG, Integer.MAX_VALUE);
        props.put(ProducerConfig.MAX_IN_FLIGHT_REQUESTS_PER_CONNECTION, 5);
        props.put(ProducerConfig.DELIVERY_TIMEOUT_MS_CONFIG, 30000);

        try (KafkaProducer<String, String> producer = new KafkaProducer<>(props)) {
            String topic = "bhf-transactions";
            
            // Transaction BHF de test
            String transactionId = "TXN-" + System.currentTimeMillis();
            String key = "account-" + (int)(Math.random() * 1000);
            String value = String.format(
                "{\"transactionId\":\"%s\",\"amount\":%.2f,\"currency\":\"EUR\",\"type\":\"DEBIT\",\"status\":\"PENDING\"}",
                transactionId, 100 + Math.random() * 1000
            );

            log.info("🏦 Envoi transaction BHF : {}", transactionId);

            try {
                ProducerRecord<String, String> record = new ProducerRecord<>(topic, key, value);
                
                // 🔥 Envoi synchrone pour garantir la réception
                RecordMetadata metadata = producer.send(record).get();
                
                log.info("✅ Transaction envoyée avec succès :");
                log.info("   Topic : {}", metadata.topic());
                log.info("   Partition : {}", metadata.partition());
                log.info("   Offset : {}", metadata.offset());
                log.info("   Timestamp : {}", metadata.timestamp());
                
            } catch (InterruptedException | ExecutionException e) {
                log.error("❌ Erreur lors de l'envoi de la transaction", e);
            }
        }
    }
}
```

#### Étape 3 : Test de l'idempotence

```powershell
# 1. Compiler le projet
mvn clean compile

# 2. Créer le topic BHF
docker exec kafka kafka-topics --create --topic bhf-transactions --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1

# 3. Exécuter le producer 3 fois pour tester l'idempotence
for ($i=1; $i -le 3; $i++) {
    Write-Host "🔄 Exécution $i/3"
    mvn exec:java -Dexec.mainClass="com.bhf.kafka.IdempotentProducerApp"
    Start-Sleep 1
}
```

#### Étape 4 : Vérification des résultats

```powershell
# Consommer pour vérifier l'unicité
docker exec kafka kafka-console-consumer --topic bhf-transactions --bootstrap-server localhost:9092 --from-beginning --property print.key=true
```

**Résultat attendu (1 seul message malgré 3 envois) :**
```
account-456	{"transactionId":"TXN-1643723400123","amount":1250.75,"currency":"EUR","type":"DEBIT","status":"PENDING"}
```

#### Étape 5 : Test avec retries réseau (simulation)

```java
// Ajouter une configuration pour simuler des timeouts
props.put(ProducerConfig.REQUEST_TIMEOUT_MS_CONFIG, 1000); // Timeout court
props.put(ProducerConfig.RETRY_BACKOFF_MS_CONFIG, 100); // Retry rapide
```

**Observation des logs :**
```
2024-01-01 10:00:00 INFO  IdempotentProducerApp - 🏦 Envoi transaction BHF : TXN-1643723400123
2024-01-01 10:00:01 WARN  NetworkClient - Connection to node 1 could not be established. Broker may not be available.
2024-01-01 10:00:02 INFO  IdempotentProducerApp - ✅ Transaction envoyée avec succès
# Retry automatique mais 1 seul message dans Kafka
```

---

## 🎯 Checkpoint Module 02

### ✅ Validation des compétences

- [ ] Producer idempotent configuré
- [ ] Messages uniques malgré retries
- [ ] Configuration BHF appliquée
- [ ] Logs de retry et succès observés

### 📝 Questions de checkpoint

1. **Pourquoi `acks=all` est obligatoire avec l'idempotence ?**
   - Garantit que tous les replicas ont persisté avant l'ACK
   - Essentiel pour la déduplication

2. **Quel est l'impact sur la performance ?**
   - Latence légèrement augmentée (attente de tous les replicas)
   - Mais garantie forte pour transactions bancaires

3. **Comment BHF utilise-t-il l'idempotence en production ?**
   - Évite les doubles débits
   - Garantit l'intégrité des transactions
   - Conforme aux exigences réglementaires

---

## 🚀 Prochain module

**Module 03** : Consumer Read-Committed - Stratégies de commit et isolation des transactions.
