# Module 02 - Producer Idempotent - Lab Complet

## 🎯 Objectifs du Lab

À la fin de ce lab, vous serez capable de :
- ✅ Configurer un producer Kafka idempotent
- ✅ Comprendre le mécanisme d'anti-doublon
- ✅ Implémenter des transactions bancaires sécurisées
- ✅ Valider l'unicité des messages
- ✅ Mesurer les performances du producer

---

## 📋 Prérequis du Lab

### 🐧 **Ubuntu 22.04 LTS**
```bash
# Vérification système
lsb_release -a | grep "Ubuntu"
docker --version
java -version
mvn -version
```

### 📦 **Docker et Kafka**
```bash
# Démarrer Kafka si nécessaire
docker-compose -f ~/kafka-formation-bhf/docker-compose.enterprise.yml up -d

# Vérifier que Kafka est prêt
docker exec kafka kafka-topics --list --bootstrap-server localhost:9092
```

---

## 🧪 **Lab 02.1 - Configuration Maven**

### 🎯 **Objectif** : Configurer le projet Maven pour le producer idempotent

#### Étape 1 : Création du projet
```bash
# Créer le répertoire du lab
mkdir -p ~/kafka-formation-bhf/jour-01-foundations/module-02-producer
cd ~/kafka-formation-bhf/jour-01-foundations/module-02-producer

# Structure des dossiers
mkdir -p src/main/java/com/bhf/kafka
mkdir -p src/main/resources
mkdir -p src/test/java/com/bhf/kafka
mkdir -p logs
mkdir -p scripts
```

#### Étape 2 : Configuration pom.xml
```bash
# Créer le pom.xml
cat > pom.xml << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<project xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 http://maven.apache.org/xsd/maven-4.0.0.xsd">
  <modelVersion>4.0.0</modelVersion>

  <groupId>com.bhf.kafka</groupId>
  <artifactId>idempotent-producer</artifactId>
  <version>1.0.0</version>
  <name>BHF Idempotent Producer</name>
  <description>Kafka Idempotent Producer for BHF Banking</description>

  <properties>
    <maven.compiler.source>17</maven.compiler.source>
    <maven.compiler.target>17</maven.compiler.target>
    <project.build.sourceEncoding>UTF-8</project.build.sourceEncoding>
    <kafka.version>3.4.1</kafka.version>
    <slf4j.version>1.7.36</slf4j.version>
    <logback.version>1.2.12</logback.version>
    <jackson.version>2.15.2</jackson.version>
    <junit.version>4.13.2</junit.version>
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
      <version>${jackson.version}</version>
    </dependency>
    
    <!-- Testing -->
    <dependency>
      <groupId>junit</groupId>
      <artifactId>junit</artifactId>
      <version>${junit.version}</version>
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
    </plugins>
  </build>
</project>
EOF
```

#### Étape 3 : Validation de la configuration
```bash
# Compiler le projet
mvn clean compile

# Vérifier les dépendances
mvn dependency:tree

# Exécuter les tests
mvn test

# Créer le JAR
mvn package
```

#### ✅ **Checkpoint Lab 02.1**
- [ ] Projet Maven créé avec succès
- [ ] Dépendances Kafka configurées
- [ ] Compilation réussie
- [ ] JAR généré

---

## 🧪 **Lab 02.2 - Docker Configuration**

### 🎯 **Objectif** : Configurer Docker pour le déploiement du producer

#### Étape 1 : Création du Dockerfile
```bash
# Créer le Dockerfile optimisé
cat > Dockerfile << 'EOF'
FROM openjdk:17-jdk-slim

LABEL maintainer="BHF Kafka Formation"
LABEL version="1.0.0"
LABEL description="Producer Idempotent BHF pour Ubuntu Enterprise"

ENV APP_HOME=/app
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

WORKDIR $APP_HOME

# Installer les dépendances système
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        jq \
        netcat-traditional \
        && rm -rf /var/lib/apt/lists/*

# Copier et compiler
COPY pom.xml .
RUN mvn dependency:go-offline -B

COPY src ./src
RUN mvn clean package -DskipTests

# Sécurité : utilisateur non-root
RUN groupadd -r bhf && useradd -r -g bhf bhf
RUN chown -R bhf:bhf $APP_HOME
USER bhf

EXPOSE 8080

HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

CMD ["java", "-jar", "target/idempotent-producer-1.0.0.jar"]
EOF
```

#### Étape 2 : Création du docker-compose.yml
```bash
# Créer le docker-compose.yml
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  kafka:
    image: confluentinc/cp-kafka:7.4.0
    hostname: kafka
    container_name: kafka
    ports:
      - "9092:9092"
      - "29092:29092"
      - "9999:9999"
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: 'zookeeper:2181'
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka:29092,PLAINTEXT_HOST://localhost:9092
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
      KAFKA_TRANSACTION_STATE_LOG_MIN_ISR: 1
      KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR: 1
      KAFKA_AUTO_CREATE_TOPICS_ENABLE: "true"
      KAFKA_DELETE_TOPIC_ENABLE: "true"
      KAFKA_HEAP_OPTS: "-Xmx4G -Xms2G"
      KAFKA_JMX_PORT: 9999
    healthcheck:
      test: ["CMD", "kafka-topics", "--bootstrap-server", "localhost:9092", "--list"]
      interval: 30s
      timeout: 10s
      retries: 3
    restart: unless-stopped

  zookeeper:
    image: confluentinc/cp-zookeeper:7.4.0
    hostname: zookeeper
    container_name: zookeeper
    ports:
      - "2181:2181"
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
      ZOOKEEPER_TICK_TIME: 2000
    healthcheck:
      test: ["CMD", "nc", "-z", "localhost", "2181"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  bhf-producer:
    build:
      context: .
      dockerfile: Dockerfile
    container_name: bhf-idempotent-producer
    ports:
      - "8080:8080"
    environment:
      KAFKA_BOOTSTRAP_SERVERS: kafka:29092
      KAFKA_ENABLE_IDEMPOTENCE: "true"
      KAFKA_ACKS: "all"
      KAFKA_RETRIES: "2147483647"
      KAFKA_MAX_IN_FLIGHT_REQUESTS_PER_CONNECTION: "5"
      KAFKA_DELIVERY_TIMEOUT_MS: "30000"
      LOGGING_LEVEL_COM_BHF_KAFKA: "DEBUG"
    depends_on:
      kafka:
        condition: service_healthy
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/actuator/health"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
    restart: unless-stopped

  kafka-ui:
    image: provectuslabs/kafka-ui:latest
    ports:
      - "8081:8080"
    environment:
      KAFKA_CLUSTERS_0_NAME: BHF-Producer-Training
      KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS: kafka:29092
      KAFKA_CLUSTERS_0_ZOOKEEPERCONNECT: zookeeper:2181
    depends_on:
      kafka:
        condition: service_healthy
    restart: unless-stopped

volumes:
  kafka-data:
    driver: local
  kafka-logs:
    driver: local

networks:
  bhf-network:
    driver: bridge
EOF
```

#### Étape 3 : Validation Docker
```bash
# Vérifier la configuration Docker
docker-compose -f docker-compose.yml config

# Construire l'image Docker
docker build -t bhf/idempotent-producer:latest .

# Démarrer les services
docker-compose -f docker-compose.yml up -d

# Vérifier le statut
docker-compose -f docker-compose.yml ps
```

#### ✅ **Checkpoint Lab 02.2**
- [ ] Dockerfile créé et optimisé
- [ ] Docker Compose configuré
- [ ] Images construites avec succès
- [ ] Services démarrés et opérationnels

---

## 🧪 **Lab 02.3 - Implémentation Producer Idempotent**

### 🎯 **Objectif** : Implémenter le code du producer idempotent

#### Étape 1 : Création du code principal
```bash
# Créer le fichier Java principal
cat > src/main/java/com/bhf/kafka/IdempotentProducerApp.java << 'EOF'
package com.bhf.kafka;

import org.apache.kafka.clients.producer.*;
import org.apache.kafka.common.serialization.StringSerializer;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.Properties;
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
EOF
```

#### Étape 2 : Compilation et test
```bash
# Compiler le code
mvn clean compile

# Exécuter le producer
mvn exec:java -Dexec.mainClass="com.bhf.kafka.IdempotentProducerApp"

# Vérifier les logs
docker-compose logs --tail=10 bhf-producer
```

#### ✅ **Checkpoint Lab 02.3**
- [ ] Code Java implémenté
- [ ] Configuration idempotent correcte
- [ ] Transaction BHF créée
- [ ] Envoi réussi vers Kafka

---

## 🧪 **Lab 02.4 - Test d'Idempotence**

### 🎯 **Objectif** : Valider que le producer garantit l'unicité des messages

#### Étape 1 : Préparation du test
```bash
# Créer le script de test
cat > scripts/test-idempotence.sh << 'EOF'
#!/bin/bash

# Test Idempotent Producer - Ubuntu Enterprise
set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check Kafka
check_kafka() {
    if ! docker exec kafka kafka-topics --list --bootstrap-server localhost:9092 &>/dev/null; then
        log_error "Kafka n'est pas en cours d'exécution"
        exit 1
    fi
}

# Create topic
create_topic() {
    log_info "Création du topic bhf-transactions..."
    docker exec kafka kafka-topics --create --topic bhf-transactions --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1 2>/dev/null || log_info "Topic existe déjà"
}

# Test idempotence
test_idempotence() {
    log_info "🔄 Test d'idempotence - 3 exécutions pour 1 seul message"
    
    for i in {1..3}; do
        log_info "Exécution $i/3"
        mvn exec:java -Dexec.mainClass="com.bhf.kafka.IdempotentProducerApp" -q
        sleep 1
    done
}

# Verify results
verify_results() {
    log_info "🔍 Vérification de l'unicité..."
    message_count=$(docker exec kafka kafka-console-consumer --topic bhf-transactions --bootstrap-server localhost:9092 --from-beginning --timeout-ms 5000 2>/dev/null | wc -l)
    
    if [ "$message_count" -eq 1 ]; then
        log_success "✅ Test d'idempotence réussi : 1 seul message malgré 3 envois"
    else
        log_error "❌ Test d'idempotence échoué : $message_count messages trouvés"
        return 1
    fi
}

# Performance test
performance_test() {
    log_info "⚡ Test de performance - 100 envois rapides"
    
    start_time=$(date +%s%N)
    
    for i in {1..100}; do
        mvn exec:java -Dexec.mainClass="com.bhf.kafka.IdempotentProducerApp" -q &
    done
    
    wait
    
    end_time=$(date +%s%N)
    duration=$((($end_time - $start_time) / 1000000))
    
    log_info "📊 Performance: 100 envois en ${duration}ms"
    log_info "📈 Moyenne: $(($duration / 100))ms par envoi"
}

# Main execution
main() {
    echo "🏦 Test Idempotent Producer - BHF Formation"
    echo "=========================================="
    
    check_kafka
    create_topic
    test_idempotence
    verify_results
    
    read -p "⚡ Voulez-vous exécuter le test de performance (100 envois)? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        performance_test
    fi
    
    log_success "✅ Test d'idempotence terminé avec succès!"
}

main "$@"
EOF

chmod +x scripts/test-idempotence.sh
```

#### Étape 2 : Exécution du test
```bash
# Exécuter le test d'idempotence
./scripts/test-idempotence.sh

# Vérifier les résultats
docker exec kafka kafka-console-consumer --topic bhf-transactions --bootstrap-server localhost:9092 --from-beginning --property print.key=true --timeout-ms 5000
```

#### Étape 3 : Analyse des résultats
```bash
# Compter les messages
message_count=$(docker exec kafka kafka-console-consumer --topic bhf-transactions --bootstrap-server localhost:9092 --from-beginning --timeout-ms 5000 | wc -l)

echo "Nombre de messages reçus : $message_count"

# Afficher le message unique
echo "Message unique reçu :"
docker exec kafka kafka-console-consumer --topic bhf-transactions --bootstrap-server localhost:9092 --from-beginning --property print.key=true --timeout-ms 5000
```

#### ✅ **Checkpoint Lab 02.4**
- [ ] Test d'idempotence exécuté
- [ ] 1 seul message reçu malgré 3 envois
- [ ] Garantie d'unicité validée
- [ ] Performance mesurée

---

## 🧪 **Lab 02.5 - Monitoring et Métriques**

### 🎯 **Objectif** : Mettre en place le monitoring du producer

#### Étape 1 : Script de monitoring
```bash
# Créer le script de monitoring
cat > scripts/monitor.sh << 'EOF'
#!/bin/bash

echo "🏦 Kafka Performance Monitoring - BHF"
echo "===================================="

# System metrics
echo "📊 System Metrics:"
echo "CPU Usage: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}')"
echo "Memory Usage: $(free -h | awk 'NR==2{printf "%.2f%%", $3*100/$2}')"
echo "Disk Usage: $(df -h / | awk 'NR==2{print $5}')"

# Docker containers
echo ""
echo "🐳 Docker Containers:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Kafka topics
echo ""
echo "📚 Kafka Topics:"
docker exec kafka kafka-topics --list --bootstrap-server localhost:9092 2>/dev/null || echo "Kafka not running"

# Network connections
echo ""
echo "🌐 Network Connections:"
netstat -an | grep :9092 | wc -l | xargs echo "Kafka connections:"

echo ""
echo "✅ Monitoring completed"
EOF

chmod +x scripts/monitor.sh
```

#### Étape 2 : Métriques Kafka
```bash
# Monitoring système
./scripts/monitor.sh

# Métriques JMX
docker exec kafka jcmd 1 VM.native_memory summary 2>/dev/null || echo "JMX non disponible"

# Statut du producer
docker ps | grep bhf-idempotent-producer

# Logs récents
docker-compose logs --tail=20 bhf-producer
```

#### Étape 3 : Health checks
```bash
# Health check du producer
curl -f http://localhost:8080/actuator/health || echo "Producer non disponible"

# Health check Kafka
docker exec kafka kafka-topics --list --bootstrap-server localhost:9092 || echo "Kafka non disponible"

# Health check UI
curl -f http://localhost:8081 || echo "Kafka UI non disponible"
```

#### ✅ **Checkpoint Lab 02.5**
- [ ] Monitoring système configuré
- [ ] Métriques Kafka collectées
- [ ] Health checks implémentés
- [ ] Logs centralisés

---

## 🧪 **Lab 02.6 - Dépannage et Support**

### 🎯 **Objectif** : Résoudre les problèmes courants

#### Étape 1 : Diagnostic automatique
```bash
# Créer le script de diagnostic
cat > scripts/diagnose.sh << 'EOF'
#!/bin/bash

echo "🔍 Diagnostic Producer Idempotent BHF"
echo "=================================="

# Check environment
echo "📋 Environment Check:"
echo "Java: $(java -version 2>&1 | head -n 1)"
echo "Maven: $(mvn -version 2>&1 | head -n 1)"
echo "Docker: $(docker --version)"
echo "Docker Compose: $(docker-compose version)"

# Check Kafka
echo ""
echo "🔍 Kafka Status:"
if docker exec kafka kafka-topics --list --bootstrap-server localhost:9092 &>/dev/null; then
    echo "✅ Kafka is running"
    docker exec kafka kafka-topics --list --bootstrap-server localhost:9092
else
    echo "❌ Kafka is not running"
fi

# Check producer
echo ""
echo "🔍 Producer Status:"
if docker ps | grep -q bhf-idempotent-producer; then
    echo "✅ Producer container is running"
    docker ps | grep bhf-idempotent-producer
else
    echo "❌ Producer container is not running"
fi

# Check topics
echo ""
echo "🔍 Topics Status:"
if docker exec kafka kafka-topics --describe --topic bhf-transactions --bootstrap-server localhost:9092 &>/dev/null; then
    echo "✅ bhf-transactions topic exists"
    docker exec kafka kafka-topics --describe --topic bhf-transactions --bootstrap-server localhost:9092
else
    echo "❌ bhf-transactions topic does not exist"
fi

# Check logs
echo ""
echo "🔍 Recent Logs:"
docker-compose logs --tail=10 bhf-producer

echo ""
echo "✅ Diagnostic completed"
EOF

chmod +x scripts/diagnose.sh
```

#### Étape 2 : Problèmes courants et solutions
```bash
# Problème 1 : Kafka ne démarre pas
echo "🔧 Solution 1: Redémarrer Kafka"
docker-compose -f docker-compose.yml down
docker-compose -f docker-compose.yml up -d

# Problème 2 : Producer ne se connecte pas
echo "🔧 Solution 2: Vérifier la connectivité"
docker exec kafka kafka-topics --list --bootstrap-server localhost:9092
netstat -an | grep :9092

# Problème 3 : Messages dupliqués
echo "🔧 Solution 3: Vérifier la configuration idempotent"
grep -r "enable.idempotence" src/main/resources/
grep -r "ENABLE_IDEMPOTENCE" docker-compose.yml

# Problème 4 : Performance lente
echo "🔧 Solution 4: Optimisation des paramètres"
docker stats --no-stream
```

#### Étape 3 : Nettoyage et reset
```bash
# Créer le script de nettoyage
cat > scripts/cleanup.sh << 'EOF'
#!/bin/bash

echo "🧹 Nettoyage Producer Idempotent BHF"
echo "=================================="

# Arrêter les services
echo "🛑 Arrêt des services..."
docker-compose -f docker-compose.yml down

# Supprimer les conteneurs
echo "🗑️  Suppression des conteneurs..."
docker rm -f bhf-idempotent-producer kafka zookeeper kafka-ui 2>/dev/null || true

# Supprimer les images
echo "🗑️  Suppression des images..."
docker rmi bhf/idempotent-producer:latest 2>/dev/null || true

# Nettoyer les volumes
echo "💾 Nettoyage des volumes..."
docker volume prune -f

# Nettoyer les logs
echo "📚 Nettoyage des logs..."
rm -rf logs/*

echo "✅ Nettoyage terminé"
EOF

chmod +x scripts/cleanup.sh
```

#### ✅ **Checkpoint Lab 02.6**
- [ ] Diagnostic automatique implémenté
- [ ] Solutions aux problèmes courants
- [ ] Scripts de nettoyage créés
- [ ] Support de dépannage disponible

---

## 🎯 **Validation Finale du Lab**

### ✅ **Checklist complète**
- [ ] **Lab 02.1** : Configuration Maven ✓
- [ ] **Lab 02.2** : Docker Configuration ✓
- [ ] **Lab 02.3** : Implémentation Producer ✓
- [ ] **Lab 02.4** : Test d'Idempotence ✓
- [ ] **Lab 02.5** : Monitoring et Métriques ✓
- [ ] **Lab 02.6** : Dépannage et Support ✓

### 🏆 **Compétences acquises**
- ✅ Configuration producer idempotent
- ✅ Déploiement Docker optimisé
- ✅ Code Java structuré et commenté
- ✅ Tests automatisés et validation
- ✅ Monitoring et métriques
- ✅ Dépannage et support

### 📊 **Métriques de performance**
```bash
# Performance finale
./scripts/test-idempotence.sh

# Monitoring final
./scripts/monitor.sh

# Diagnostic complet
./scripts/diagnose.sh
```

---

## 🚀 **Prochain Module**

**Module 03** : Consumer Read-Committed - Stratégies de commit et isolation des transactions.

---

## 🎓 **Ressources Additionnelles**

### 📚 **Documentation**
- **Kafka Producer Documentation** : Guide officiel
- **Docker Best Practices** : Recommandations production
- **Ubuntu Performance Tuning** : Optimisation système

### 🛠️ **Scripts**
- `test-idempotence.sh` : Tests automatisés
- `monitor.sh` : Monitoring système
- `diagnose.sh` : Diagnostic automatique
- `cleanup.sh` : Nettoyage complet

### 🎯 **Support**
- **Logs** : Tous les logs dans `logs/`
- **Health checks** : Monitoring automatique
- **Alertes** : Détection d'anomalies

---

## 🏦 **Conclusion Lab 02**

Le Lab 02 est maintenant **100% complet** avec :

- ✅ **6 labs détaillés** étape par étape
- ✅ **Code production-ready**
- ✅ **Tests automatisés**
- ✅ **Monitoring complet**
- ✅ **Support de dépannage**

**Lab 02 - Producer Idempotent - Complete!** 🧪✅🏦
