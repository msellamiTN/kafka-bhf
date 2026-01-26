# Formation Kafka Enterprise BHF - Ubuntu & Docker Compose

## 🎯 Objectif

Formation Kafka **100% Ubuntu** avec déploiement **Docker/Docker Compose** pour l'équipe DEV-IT BHF ODDO.

---

## 🐧 **Prérequis Ubuntu 22.04 LTS**

### Installation Automatisée

```bash
# Télécharger et exécuter le script d'installation
wget https://raw.githubusercontent.com/bhf/kafka-formation/main/scripts/ubuntu-setup-enterprise.sh
chmod +x ubuntu-setup-enterprise.sh
./ubuntu-setup-enterprise.sh

# Se déconnecter et se reconnecter pour appliquer les changements
exit
ssh user@ubuntu-server
```

### Installation Manuelle

```bash
# 1. Mise à jour système
sudo apt update && sudo apt upgrade -y

# 2. Installation Java 17
sudo apt install -y openjdk-17-jdk openjdk-17-jre

# 3. Installation Maven
sudo apt install -y maven

# 4. Installation Docker
sudo apt install -y docker.io docker-compose-plugin

# 5. Ajout utilisateur au groupe docker
sudo usermod -aG docker $USER

# 6. Installation outils
sudo apt install -y git curl wget vim htop tree jq net-tools

# 7. Optimisation système
echo 'vm.max_map_count=262144' | sudo tee -a /etc/sysctl.conf
echo 'fs.file-max=2097152' | sudo tee -a /etc/sysctl.conf
sudo sysctl -p
```

---

## 🚀 **Démarrage Rapide Ubuntu**

### Script Quick Start

```bash
# Démarrage automatique complet
wget https://raw.githubusercontent.com/bhf/kafka-formation/main/scripts/quick-start-ubuntu.sh
chmod +x quick-start-ubuntu.sh
./quick-start-ubuntu.sh
```

### Démarrage Manuel

```bash
# 1. Créer workspace
mkdir -p ~/kafka-formation-bhf
cd ~/kafka-formation-bhf

# 2. Télécharger docker-compose.enterprise.yml
wget https://raw.githubusercontent.com/bhf/kafka-formation/main/docker-compose.enterprise.yml

# 3. Démarrer cluster
docker-compose -f docker-compose.enterprise.yml up -d

# 4. Vérifier statut
docker ps
```

---

## 🐳 **Docker Compose Enterprise**

### Services Principaux

```yaml
services:
  zookeeper:
    image: confluentinc/cp-zookeeper:7.4.0
    container_name: zookeeper
    ports: ["2181:2181"]
    healthcheck: ["CMD", "nc", "-z", "localhost", "2181"]

  kafka:
    image: confluentinc/cp-kafka:7.4.0
    container_name: kafka
    ports: ["9092:9092", "29092:29092", "9999:9999"]
    environment:
      KAFKA_HEAP_OPTS: "-Xmx4G -Xms2G"
      KAFKA_JMX_PORT: 9999
    healthcheck: ["CMD", "kafka-topics", "--bootstrap-server", "localhost:9092", "--list"]

  kafka-ui:
    image: provectuslabs/kafka-ui:latest
    container_name: kafka-ui
    ports: ["8080:8080"]
    environment:
      KAFKA_CLUSTERS_0_NAME: BHF-Training
      KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS: kafka:29092

  schema-registry:
    image: confluentinc/cp-schema-registry:7.4.0
    container_name: schema-registry
    ports: ["8081:8081"]
    profiles: ["schema-registry"]

  kafka-connect:
    image: confluentinc/cp-kafka-connect:7.4.0
    container_name: kafka-connect
    ports: ["8083:8083"]
    profiles: ["connect"]
```

### Démarrage par Profil

```bash
# Services de base uniquement
docker-compose -f docker-compose.enterprise.yml up -d

# Avec Schema Registry
docker-compose -f docker-compose.enterprise.yml --profile schema-registry up -d

# Avec tous les services
docker-compose -f docker-compose.enterprise.yml --profile schema-registry --profile connect up -d
```

---

## 📁 **Structure Ubuntu Formation**

```
kafka-formation-bhf/
├── docker-compose.enterprise.yml
├── scripts/
│   ├── ubuntu-setup-enterprise.sh
│   ├── quick-start-ubuntu.sh
│   ├── monitor.sh
│   ├── cleanup.sh
│   └── test-cluster.sh
├── jour-01-foundations/
│   ├── module-01-cluster/
│   │   ├── README.md
│   │   ├── docker-compose.yml
│   │   └── validate-module-01.sh
│   ├── module-02-producer/
│   │   ├── README.md
│   │   ├── pom.xml
│   │   ├── src/main/java/...
│   │   └── scripts/test-idempotence.sh
│   └── module-03-consumer/
│       ├── README.md
│       ├── pom.xml
│       ├── src/main/java/...
│       └── scripts/test-read-committed.sh
├── jour-02-transactions/
├── jour-03-streams-production/
└── logs/
```

---

## 🏦 **Modules Ubuntu - Jour 1**

### Module 01 - Cluster Architecture

```bash
# Navigation
cd ~/kafka-formation-bhf/jour-01-foundations/module-01-cluster

# Validation
./validate-module-01.sh

# Test manuel
docker exec kafka kafka-topics --list --bootstrap-server localhost:9092
```

### Module 02 - Producer Idempotent

```bash
# Navigation
cd ~/kafka-formation-bhf/jour-01-foundations/module-02-producer

# Test d'idempotence
./scripts/test-idempotence.sh

# Compilation et exécution
mvn clean compile
mvn exec:java -Dexec.mainClass="com.bhf.kafka.IdempotentProducerApp"
```

### Module 03 - Consumer Read-Committed

```bash
# Navigation
cd ~/kafka-formation-bhf/jour-01-foundations/module-03-consumer

# Test consumer
./scripts/test-read-committed.sh

# Démarrage consumer
mvn spring-boot:run &
```

---

## 🧪 **Scripts Ubuntu Automatisés**

### Installation Complète

```bash
#!/bin/bash
# ubuntu-setup-enterprise.sh
# Installation complète Ubuntu pour Kafka BHF

# Vérification Ubuntu
check_ubuntu() {
    if ! grep -q "Ubuntu" /etc/os-release; then
        echo "❌ Ce script est conçu pour Ubuntu"
        exit 1
    fi
}

# Installation Java 17
install_java() {
    sudo apt install -y openjdk-17-jdk openjdk-17-jre
    echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' >> ~/.bashrc
}

# Installation Docker
install_docker() {
    sudo apt install -y docker.io docker-compose-plugin
    sudo usermod -aG docker $USER
}

# Optimisation système
tune_system() {
    echo 'vm.max_map_count=262144' | sudo tee -a /etc/sysctl.conf
    echo 'fs.file-max=2097152' | sudo tee -a /etc/sysctl.conf
    sudo sysctl -p
}
```

### Test d'Idempotence

```bash
#!/bin/bash
# test-idempotence.sh
# Test producer idempotent BHF

check_kafka() {
    if ! docker exec kafka kafka-topics --list --bootstrap-server localhost:9092 &>/dev/null; then
        echo "❌ Kafka n'est pas en cours d'exécution"
        exit 1
    fi
}

test_idempotence() {
    echo "🔄 Test d'idempotence - 3 exécutions pour 1 seul message"
    
    for i in {1..3}; do
        echo "Exécution $i/3"
        mvn exec:java -Dexec.mainClass="com.bhf.kafka.IdempotentProducerApp" -q
        sleep 1
    done
}

verify_results() {
    message_count=$(docker exec kafka kafka-console-consumer --topic bhf-transactions --bootstrap-server localhost:9092 --from-beginning --timeout-ms 5000 | wc -l)
    
    if [ "$message_count" -eq 1 ]; then
        echo "✅ Test d'idempotence réussi: 1 seul message malgré 3 envois"
    else
        echo "❌ Test d'idempotence échoué: $message_count messages trouvés"
    fi
}
```

### Monitoring Ubuntu

```bash
#!/bin/bash
# monitor.sh
# Monitoring système Kafka sur Ubuntu

echo "🏦 Kafka Performance Monitoring - BHF"
echo "===================================="

# Métriques système
echo "📊 System Metrics:"
echo "CPU Usage: $(top -bn1 | grep "Cpu(s)" | awk '{print $2}')"
echo "Memory Usage: $(free -h | awk 'NR==2{printf "%.2f%%", $3*100/$2}')"
echo "Disk Usage: $(df -h / | awk 'NR==2{print $5}')"

# Conteneurs Docker
echo "🐳 Docker Containers:"
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Topics Kafka
echo "📚 Kafka Topics:"
docker exec kafka kafka-topics --list --bootstrap-server localhost:9092 2>/dev/null
```

---

## 🎯 **Aliases Ubuntu Pratiques**

### Configuration .bashrc

```bash
# Ajouter à ~/.bashrc

# Kafka BHF Environment
export KAFKA_HOME=$HOME/kafka-formation-bhf
export PATH=$PATH:$KAFKA_HOME/scripts

# Kafka Aliases
alias kafka-start='cd $KAFKA_HOME && docker-compose -f docker-compose.enterprise.yml up -d'
alias kafka-stop='cd $KAFKA_HOME && docker-compose -f docker-compose.enterprise.yml down'
alias kafka-logs='cd $KAFKA_HOME && docker-compose -f docker-compose.enterprise.yml logs -f'
alias kafka-topics='docker exec kafka kafka-topics --bootstrap-server localhost:9092'
alias kafka-consumer='docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092'
alias kafka-producer='docker exec kafka kafka-console-producer --bootstrap-server localhost:9092'

# Docker Aliases
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dlogs='docker logs -f'
alias dexec='docker exec -it'

# Maven Aliases
alias mvnc='mvn clean compile'
alias mvnt='mvn clean test'
alias mvnp='mvn clean package'

# Navigation
alias kafka-cd='cd $KAFKA_HOME'
alias kafka-day1='cd $KAFKA_HOME/jour-01-foundations'
alias kafka-day2='cd $KAFKA_HOME/jour-02-transactions'
alias kafka-day3='cd $KAFKA_HOME/jour-03-streams-production'
```

---

## 📊 **Monitoring Ubuntu**

### Commandes de surveillance

```bash
# Monitoring système
~/kafka-formation-bhf/scripts/monitor.sh

# Statut conteneurs
dps

# Logs Kafka
kafka-logs

# Métriques JMX
docker exec kafka jcmd 1 VM.native_memory summary

# Performance réseau
netstat -an | grep :9092 | wc -l
```

### Health Checks

```bash
# Vérifier Kafka
docker exec kafka kafka-topics --list --bootstrap-server localhost:9092

# Vérifier Zookeeper
docker exec zookeeper echo "ruok" | nc localhost 2181

# Vérifier Schema Registry
curl -f http://localhost:8081/subjects

# Vérifier Kafka UI
curl -f http://localhost:8080
```

---

## 🧹 **Nettoyage Ubuntu**

### Script de nettoyage complet

```bash
#!/bin/bash
# cleanup.sh
# Nettoyage complet environnement Kafka

echo "🧹 Nettoyage - Kafka BHF Formation"

# Arrêt conteneurs
cd ~/kafka-formation-bhf
docker-compose -f docker-compose.enterprise.yml down -v

# Suppression images
docker rmi $(docker images "confluentinc/*" -q) 2>/dev/null || true

# Nettoyage volumes
docker volume prune -f

# Nettoyage logs
rm -rf logs/*

echo "✅ Nettoyage terminé"
```

### Nettoyage manuel

```bash
# Arrêter tous les services
kafka-stop

# Supprimer conteneurs
docker rm -f kafka zookeeper kafka-ui schema-registry kafka-connect

# Supprimer images
docker rmi confluentinc/cp-zookeeper:7.4.0 confluentinc/cp-kafka:7.4.0

# Nettoyer volumes
docker volume prune -f
```

---

## 🚀 **Utilisation Formation Ubuntu**

### Démarrage rapide

```bash
# 1. Installation (une seule fois)
./ubuntu-setup-enterprise.sh

# 2. Reconnexion
exit && ssh user@ubuntu-server

# 3. Démarrage formation
./quick-start-ubuntu.sh

# 4. Monitoring
./scripts/monitor.sh
```

### Workflow quotidien

```bash
# Démarrer cluster
kafka-start

# Vérifier statut
dps

# Commencer formation
kafka-day1

# Module 01
cd module-01-cluster && ./validate-module-01.sh

# Module 02
cd ../module-02-producer && ./scripts/test-idempotence.sh

# Module 03
cd ../module-03-consumer && ./scripts/test-read-committed.sh

# Monitoring
~/kafka-formation-bhf/scripts/monitor.sh
```

---

## 🎓 **Formation Continue Ubuntu**

### Support et documentation

```bash
# Documentation locale
ls ~/kafka-formation-bhf/*.md

# Scripts utilitaires
ls ~/kafka-formation-bhf/scripts/

# Logs de formation
ls ~/kafka-formation-bhf/logs/
```

### Prochaines étapes

1. **Jour 1** : Foundations - Cluster, Producer, Consumer
2. **Jour 2** : Transactions - Exactly-Once, Schema Registry
3. **Jour 3** : Streams & Production - Kafka Streams, Monitoring

---

## 🏦 **Conclusion Ubuntu**

La formation Kafka Enterprise BHF est maintenant **100% Ubuntu** avec :

- ✅ **Installation automatisée** Ubuntu 22.04 LTS
- ✅ **Docker Compose** pour déploiement enterprise
- ✅ **Scripts Bash** pour tous les tests
- ✅ **Monitoring** intégré et optimisé
- ✅ **Aliases** pratiques pour productivité
- ✅ **Nettoyage** automatisé

**Formation Kafka Enterprise BHF - Ubuntu Ready!** 🐧🐳🏦✅
