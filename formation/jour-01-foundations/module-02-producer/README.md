# Module 02 - Producer Idempotent (Ubuntu Enterprise)

## 📚 Théorie (30%) - Producteur Kafka & Idempotence

### 2.1 Cycle de vie du producteur

```mermaid
graph TD
    A[Application BHF] --> B[Producer Record]
    B --> C[Serializer]
    C --> D[Partitioner]
    D --> E[Record Accumulator]
    E --> F[Network Sender]
    F --> G[Kafka Broker]
    G --> H[Leader Replica]
    H --> I[Follower Replicas]
    I --> J[ACK Response]
    J --> K[Producer Callback]
    
    style A fill:#e1f5fe
    style G fill:#f3e5f5
    style H fill:#e8f5e8
```

### 2.2 Problème : Messages dupliqués

#### 🏦 **Scénario BHF critique**
```mermaid
sequenceDiagram
    participant App as Application BHF
    participant Net as Network
    participant Kafka as Kafka Broker
    
    App->>Net: Envoi transaction 1000€
    Net-->>App: Timeout (500ms)
    App->>Net: Retry transaction 1000€
    Net->>Kafka: Transaction 1000€ (1er envoi)
    Net->>Kafka: Transaction 1000€ (retry)
    Kafka-->>App: ACK 1er envoi
    Kafka-->>App: ACK retry
    
    Note over App,Kafka: 💥 DOUBLE DÉBIT = 2000€
```

#### ⚠️ **Impact bancaire**
- **Perte financière** : Double débit = perte directe
- **Réglementaire** : Non-conformité ACPR/ECB
- **Réputation** : Perte de confiance client
- **Opérationnel** : Processus de remboursement manuel

### 2.3 Solution : Idempotence Kafka

#### 🔥 **Configuration idempotent BHF**
```properties
# Configuration obligatoire pour BHF
enable.idempotence=true
acks=all
retries=Integer.MAX_VALUE
max.in.flight.requests.per.connection=5

# Tuning production BHF
delivery.timeout.ms=30000
request.timeout.ms=20000
retry.backoff.ms=100
max.block.ms=60000
```

#### 🎯 **Mécanisme interne**
```mermaid
graph LR
    A[Producer ID] --> B[Sequence Number]
    B --> C[Broker State]
    C --> D[Deduplication]
    
    A1["PID:12345"] --> B1["Seq:001"]
    B1 --> C1["(PID:12345, Seq:001)"]
    C1 --> D1["Accept"]
    
    A2["PID:12345"] --> B2["Seq:001"]
    B2 --> C2["(PID:12345, Seq:001)"]
    C2 --> D2["Duplicate → Reject"]
    
    style D1 fill:#e8f5e8
    style D2 fill:#ffebee
```

### 2.4 Contraintes techniques - Matrix BHF

| Configuration | Valeur | Impact BHF | Pourquoi ? |
|---------------|--------|------------|------------|
| `enable.idempotence` | `true` | ✅ Sécurité | Active l'anti-doublon |
| `acks` | `all` | ✅ Durabilité | Garantit persistance complète |
| `max.in.flight.requests` | `≤ 5` | ✅ Ordre | Préserve l'ordre des transactions |
| `retries` | `Integer.MAX_VALUE` | ✅ Résilience | Retry infini pour haute disponibilité |
| `delivery.timeout.ms` | `30000` | ✅ SLA | Timeout 30s pour transactions critiques |

---

## 🛠️ Pratique (70%) - Producer Idempotent BHF Ubuntu

### Lab 02.1 - Producer Idempotent pour Transactions BHF

#### Étape 1 : Configuration Maven Ubuntu

**pom.xml optimisé pour Ubuntu Enterprise :**
```xml
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>com.bhf.kafka</groupId>
  <artifactId>idempotent-producer</artifactId>
  <version>1.0.0</version>
  <name>BHF Idempotent Producer</name>
  <description>Kafka Idempotent Producer for BHF Banking - Ubuntu Enterprise</description>

  <properties>
    <maven.compiler.source>17</maven.compiler.source>
    <maven.compiler.target>17</maven.compiler.target>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <kafka.version>3.4.1</kafka.version>
    <slf4j.version>1.7.36</slf4j.version>
    <logback.version>1.2.12</logback.version>
  </properties>

  <dependencies>
    <!-- Kafka Core -->
    <dependency>
      <groupId>org.apache.kafka</groupId>
      <artifactId>kafka-clients</artifactId>
      <version>${kafka.version}</version>
    </dependency>
    
    <!-- Logging -->
    <dependency>
      <groupId>org.slf4j</groupId>
      <artifactId>slf4j-api</artifactId>
      <version>${slf4j.version}</version>
    </dependency>
    <dependency>
      <groupId>ch.qos.logback</groupId>
      <artifactId>logback-classic</artifactId>
      <version>${logback.version}</version>
    </dependency>
    
    <!-- JSON Processing -->
    <dependency>
      <groupId>com.fasterxml.jackson.core</groupId>
      <artifactId>jackson-databind</artifactId>
      <version>2.15.2</version>
    </dependency>
    
    <!-- Testing -->
    <dependency>
      <groupId>junit</groupId>
      <artifactId>junit</artifactId>
      <version>4.13.2</version>
      <scope>test</scope>
    </dependency>
  </dependencies>

  <build>
    <plugins>
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-compiler-plugin</artifactId>
        <version>3.11.0</version>
        <configuration>
          <source>17</source>
          <target>17</target>
          <encoding>UTF-8</encoding>
        </configuration>
      </plugin>
      
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-jar-plugin</artifactId>
        <version>3.2.2</version>
        <configuration>
          <archive>
            <manifest>
              <mainClass>com.bhf.kafka.IdempotentProducerApp</mainClass>
            </manifest>
          </archive>
        </configuration>
      </plugin>
      
      <plugin>
        <groupId>org.apache.maven.plugins</groupId>
        <artifactId>maven-surefire-plugin</artifactId>
        <version>3.0.0-M9</version>
      </plugin>
    </plugins>
  </build>
</project>
```

#### Étape 2 : Code Producer Idempotent Ubuntu - Étape par Étape

##### 📋 **Étape 2.1 - Structure du projet**

```bash
# Créer la structure des dossiers
mkdir -p src/main/java/com/bhf/kafka
mkdir -p src/main/resources
mkdir -p src/test/java/com/bhf/kafka
mkdir -p logs
```

##### 📝 **Étape 2.2 - Code Producer Idempotent**

Créer `src/main/java/com/bhf/kafka/IdempotentProducerApp.java` :

```java
package com.bhf.kafka;

import org.apache.kafka.clients.producer.*;
import org.apache.kafka.common.serialization.StringSerializer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Properties;
import java.util.concurrent.ExecutionException;
import java.util.UUID;

/**
 * 🏦 Producer Idempotent BHF - Application principale
 * 
 * Ce producteur garantit l'unicité des messages même en cas de retry
 * pour éviter les doubles débits dans le contexte bancaire BHF.
 */
public class IdempotentProducerApp {
    private static final Logger log = LoggerFactory.getLogger(IdempotentProducerApp.class);

    public static void main(String[] args) {
        log.info("🏦 Démarrage du Producer Idempotent BHF");
        
        // 🔥 Étape 1 : Configuration du producer
        Properties props = configureProducer();
        
        try (KafkaProducer<String, String> producer = new KafkaProducer<>(props)) {
            
            // 🔥 Étape 2 : Création de la transaction BHF
            Transaction transaction = createBHFTransaction();
            
            // 🔥 Étape 3 : Envoi de la transaction
            sendTransaction(producer, transaction);
            
            // 🔥 Étape 4 : Vérification du résultat
            log.info("✅ Transaction BHF envoyée avec succès");
            
        } catch (Exception e) {
            log.error("❌ Erreur lors de l'envoi de la transaction", e);
            System.exit(1);
        }
    }
    
    /**
     * 🔥 Configuration du producer idempotent BHF
     */
    private static Properties configureProducer() {
        Properties props = new Properties();
        
        // Configuration de base
        props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
        props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
        
        // 🔥 Configuration idempotent BHF - OBLIGATOIRE
        props.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, true);
        props.put(ProducerConfig.ACKS_CONFIG, "all");
        props.put(ProducerConfig.RETRIES_CONFIG, Integer.MAX_VALUE);
        props.put(ProducerConfig.MAX_IN_FLIGHT_REQUESTS_PER_CONNECTION, 5);
        
        // Tuning production BHF
        props.put(ProducerConfig.DELIVERY_TIMEOUT_MS_CONFIG, 30000);
        props.put(ProducerConfig.REQUEST_TIMEOUT_MS_CONFIG, 20000);
        props.put(ProducerConfig.RETRY_BACKOFF_MS_CONFIG, 100);
        
        log.info("📋 Configuration producer idempotent terminée");
        return props;
    }
    
    /**
     * 🏦 Création d'une transaction BHF de test
     */
    private static Transaction createBHFTransaction() {
        String transactionId = "TXN-" + UUID.randomUUID().toString().substring(0, 8).toUpperCase();
        String accountId = "ACC-" + String.format("%06d", (int)(Math.random() * 999999));
        double amount = 100 + Math.random() * 10000;
        
        return new Transaction(transactionId, accountId, amount, "EUR", "DEBIT", "PENDING");
    }
    
    /**
     * 🏦 Envoi de la transaction avec monitoring détaillé
     */
    private static void sendTransaction(KafkaProducer<String, String> producer, Transaction transaction) {
        String topic = "bhf-transactions";
        String key = transaction.getAccountId();
        String value = transaction.toJson();
        
        log.info("📤 Envoi transaction BHF :");
        log.info("   Transaction ID : {}", transaction.getTransactionId());
        log.info("   Compte : {}", transaction.getAccountId());
        log.info("   Montant : {} {}", transaction.getAmount(), transaction.getCurrency());
        log.info("   Type : {}", transaction.getTransactionType());
        log.info("   Statut : {}", transaction.getStatus());
        
        try {
            ProducerRecord<String, String> record = new ProducerRecord<>(topic, key, value);
            
            // 🔥 Envoi synchrone pour garantir la réception
            RecordMetadata metadata = producer.send(record).get();
            
            log.info("✅ Transaction envoyée avec succès :");
            log.info("   Topic : {}", metadata.topic());
            log.info("   Partition : {}", metadata.partition());
            log.info("   Offset : {}", metadata.offset());
            log.info("   Timestamp : {}", metadata.timestamp());
            
            // Mise à jour du statut
            transaction.setStatus("COMPLETED");
            
        } catch (InterruptedException | ExecutionException e) {
            log.error("❌ Erreur lors de l'envoi de la transaction {}", transaction.getTransactionId(), e);
            transaction.setStatus("FAILED");
            Thread.currentThread().interrupt();
        }
    }
    
    /**
     * 🏦 Modèle Transaction BHF
     */
    private static class Transaction {
        private String transactionId;
        private String accountId;
        private double amount;
        private String currency;
        private String transactionType;
        private String status;
        private long timestamp;
        
        public Transaction(String transactionId, String accountId, double amount, 
                          String currency, String transactionType, String status) {
            this.transactionId = transactionId;
            this.accountId = accountId;
            this.amount = amount;
            this.currency = currency;
            this.transactionType = transactionType;
            this.status = status;
            this.timestamp = System.currentTimeMillis();
        }
        
        // Getters
        public String getTransactionId() { return transactionId; }
        public String getAccountId() { return accountId; }
        public double getAmount() { return amount; }
        public String getCurrency() { return currency; }
        public String getTransactionType() { return transactionType; }
        public String getStatus() { return status; }
        public long getTimestamp() { return timestamp; }
        
        // Setters
        public void setStatus(String status) { this.status = status; }
        
        public String toJson() {
            return String.format(
                "{\"transactionId\":\"%s\",\"accountId\":\"%s\",\"amount\":%.2f,\"currency\":\"%s\",\"type\":\"%s\",\"status\":\"%s\",\"timestamp\":%d}",
                transactionId, accountId, amount, currency, transactionType, status, timestamp
            );
        }
    }
}
```
                
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

#### Étape 3 : Test de l'idempotence - Étape par Étape

##### 📋 **Étape 3.1 : Préparation de l'environnement**
```bash
# Vérifier que Kafka est démarré
if ! docker exec kafka kafka-topics --list --bootstrap-server localhost:9092 &>/dev/null; then
    echo "❌ Kafka n'est pas en cours d'exécution"
    echo "Démarrez Kafka avec: docker-compose -f docker-compose.enterprise.yml up -d"
    exit 1
fi

# Vérifier que le topic existe
if ! docker exec kafka kafka-topics --describe --topic bhf-transactions --bootstrap-server localhost:9092 &>/dev/null; then
    echo "📄 Création du topic bhf-transactions..."
    docker exec kafka kafka-topics --create --topic bhf-transactions --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1
fi

# Nettoyer les logs précédents
docker exec kafka kafka-console-consumer --topic bhf-transactions --bootstrap-server localhost:9092 --from-beginning --timeout-ms 1000 > /dev/null || true
```

##### 📝 **Étape 3.2 : Compilation et Build**
```bash
# Étape 3.2.1 : Compilation Maven
echo "📦 Étape 3.2.1 - Compilation Maven..."
mvn clean compile

# Vérification de la compilation
if [ $? -eq 0 ]; then
    echo "✅ Compilation réussie"
else
    echo "❌ Échecec de la compilation"
    exit 1
fi

# Étape 3.2.2 : Build Docker
echo "📦 Étape 3.2.2 - Build Docker..."
./scripts/build-deploy.sh docker
```

##### 📝 **Étape 3.3 : Déploiement**
```bash
# Étape 3.3.1 : Déploiement Docker Compose
echo "📦 Étape 3.3.1 - Déploiement Docker Compose..."
./scripts/build-deploy.sh deploy

# Étape 3.3.2 : Vérification du déploiement
echo "📦 Étape 3.3.2 - Vérification du déploiement..."
./scripts/build-deploy.sh verify
```

##### 📝 **Étape 3.4 : Test d'idempotence**
```bash
# Étape 3.4.1 : Test d'idempotence - 3 envois
echo "🔄 Étape 3.4.1 - Test d'idempotence (3 envois pour 1 seul message)"

# Étape 3.4.2 : Exécution du test
echo "📤 Envoi de la transaction 3 fois..."
for i in {1..3}; do
    echo "📤 Envoi $i/3"
    mvn exec:java -Dexec.mainClass="com.bhf.kafka.IdempotentProducerApp" -q
    sleep 1
done

# Étape 3.4.3 : Vérification des résultats
echo "🔍 Étape 3.4.3 - Vérification de l'unicité..."
message_count=$(docker exec kafka kafka-console-consumer --topic bhf-transactions --bootstrap-server localhost:9092 --from-beginning --timeout-ms 5000 2>/dev/null | wc -l)

if [ "$message_count" -eq 1 ]; then
    echo "✅ Test d'idempotence réussi : 1 seul message malgré 3 envois"
else
    echo "❌ Test d'idempotence échoué : $message_count messages trouvés"
    echo "🔍 Analyse des logs pour diagnostiquer..."
    docker-compose logs bhf-producer --tail=20
fi

# Étape 3.4.4 : Affichage du message unique
echo "📄 Message unique reçu :"
docker exec kafka kafka-console-consumer --topic bhf-transactions --bootstrap-server localhost:9092 --from-beginning --property print.key=true --timeout-ms 5000 2>/dev/null
```

##### 📝 **Étape 3.5 : Test de performance**
```bash
# Étape 3.5 : Test de performance - 100 envois rapides
echo "⚡ Étape 3.5 - Test de performance (100 envois rapides)"

# Démarrer le timer
start_time=$(date +%s%N)

# Envoi 100 messages en parallèle
for i in {1..100}; do
    mvn exec:java -Dexec.mainClass="com.bhf.kafka.IdempotentProducerApp" -q &
done

# Attendre fin de tous les processus
wait

# Calculer la durée
end_time=$(date +%s%N)
duration=$((($end_time - $start_time) / 1000000)) # Convertir en millisecondes

echo "📊 Performance: 100 envois en ${duration}ms"
echo "📈 Moyenne: $(($duration / 100))ms par envoi"
echo "📈 Throughput: $(($duration / 1000)) tx/sec"
```

---

#### Étape 4 : Vérification des résultats

```bash
# Étape 4.1 : Vérification de l'unicité
echo "🔍 Étape 4.1 - Vérification de l'unicité..."

# Compter les messages
message_count=$(docker exec kafka kafka-console-consumer --topic bhf-transactions --bootstrap-server localhost:9092 --from-beginning --timeout-ms 5000 2>/dev/null | wc -l)

# Validation
if [ "$message_count" -eq 1 ]; then
    echo "✅ Test d'idempotence réussi : 1 seul message malgré 3 envois"
    echo "🔍 Garantie d'unicité validée"
else
    echo "❌ Test d'idempotence échoué : $message_count messages trouvés"
    echo "🔍 Analyse des logs pour diagnostiquer..."
    docker-compose logs bhf-producer --tail=20
fi

# Étape 4.2 : Affichage du message unique
echo "📄 Message unique reçu :"
docker exec kafka kafka-console-consumer --topic bhf-transactions --bootstrap-server localhost:9092 --from-beginning --property print.key=true --timeout-ms 5000 2>/dev/null
```

#### Étape 4.3 : Monitoring et métriques
```bash
# Étape 4.3 : Monitoring du producer
echo "📊 Étape 4.3 - Monitoring du producer..."

# Statut du conteneur
docker ps | grep bhf-idempotent-producer

# Logs récents
docker-compose logs --tail=10 bhf-producer

# Métriques Kafka
docker exec kafka jcmd 1 VM.native_memory summary 2>/dev/null || echo "JMX non disponible"

# Performance réseau
netstat -an | grep :9092 | wc -l | xargs echo "Kafka connections:"
```

---

## 🎯 **Checkpoint Module 02 - Enhanced**

### ✅ **Validation des compétences techniques**

- [ ] **Configuration Maven** : pom.xml optimisé pour Ubuntu Enterprise
- [ ] **Dockerfile** : Multi-stage build optimisé avec sécurité
- [ **Docker Compose** : Services orchestrés avec health checks
- [ ] **Code Java** : Architecture claire et commentée étape par étape
- [ ] **Tests automatisés** : Scripts de validation et performance
- [ ] **Monitoring** : Logs centralisés et métriques temps réel

### 📝 **Questions de checkpoint avancées**

1. **Pourquoi `max.in.flight.requests.per.connection=5` est crucial ?**
   - Garantit l'ordre des messages avec retries
   - Préserve les garanties exactly-once
   - Impact sur latence vs ordering

2. **Comment Docker améliore-t-il le déploiement ?**
   - Isolation complète de l'environnement
   - Reproductibilité garantie
   - Déploiement one-command
   - Health checks automatiques

3. **Quelle est la différence entre `delivery.timeout.ms` et `request.timeout.ms` ?**
   - `delivery.timeout` : Temps total pour l'envoi complet
   - `request.timeout` : Timeout pour une seule requête
   - Impact sur la gestion des timeouts réseau

---

## 🚀 **Prochain Module 02 - Workflow Complet**

```mermaid
graph TD
    A[Début] --> B[Configuration Maven]
    B --> C[Build Docker]
    C --> D[Déploiement]
    D --> E[Tests]
    E --> F[Validation]
    F --> G[Monitoring]
    
    A --> B --> C --> D --> E --> F --> G
    
    style A fill:#e1f5fe
    style G fill:#e8f5e8
```

---

## 🎓 **Ressources Additionnelles**

### 📚 **Documentation technique**
- **Kafka Idempotence Guide** : Documentation officielle
- **Docker Best Practices** : Optimisation production
- **Ubuntu Performance Tuning** : Paramètres système pour Kafka
- **BHF Architecture Patterns** : Patterns spécifiques bancaires

### 🛠️ **Scripts et Outils**
- `build-deploy.sh` : Build et déploiement automatisé
- `test-idempotence.sh` : Tests d'idempotence et performance
- `monitor.sh` : Monitoring système et Kafka
- `cleanup.sh` : Nettoyage complet

### 🎯 **Support et Dépannage**
- **Logs centralisés** : Tous les logs dans `~/kafka-formation-bhf/logs/`
- **Health checks** : Monitoring automatique des services
- **Métriques temps réel** : Performance et disponibilité
- **Alertes automatiques** : Détection d'anomalies

---

## 🏦 **Conclusion Module 02**

Le Module 02 est maintenant **100% Ubuntu Enterprise** avec :

- ✅ **Étapes détaillées** pour chaque étape
- ✅ **Diagrammes Mermaid** pour visualisation
- ✅ **Code commenté** pour auto-formation
- ✅ **Docker complet** avec build et déploiement
- ✅ **Scripts automatisés** pour validation
- ✅ **Monitoring intégré** et optimisé

**Module 02 - Producer Idempotent - Ubuntu Enterprise Ready!** 🐧🐳🏦✅

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
