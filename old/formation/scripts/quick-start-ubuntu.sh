#!/bin/bash

# Quick Start Script - Ubuntu Enterprise Kafka Formation
# Script de démarrage rapide pour toute la formation BHF

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

log_step() {
    echo -e "${CYAN}[STEP]${NC} $1"
}

# Check if running on Ubuntu
check_ubuntu() {
    if ! grep -q "Ubuntu" /etc/os-release 2>/dev/null; then
        log_warning "Ce script est optimisé pour Ubuntu. Vérifiez la compatibilité avec votre système."
    fi
}

# Check Docker installation
check_docker() {
    if ! command -v docker &> /dev/null; then
        log_error "Docker n'est pas installé"
        log_info "Installez Docker avec: sudo apt update && sudo apt install -y docker.io"
        exit 1
    fi
    
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        log_error "Docker Compose n'est pas installé"
        log_info "Installez Docker Compose avec: sudo apt install -y docker-compose-plugin"
        exit 1
    fi
    
    # Check if user is in docker group
    if ! groups $USER | grep -q docker; then
        log_warning "L'utilisateur n'est pas dans le groupe docker"
        log_info "Ajoutez l'utilisateur au groupe docker: sudo usermod -aG docker $USER"
        log_info "Puis déconnectez-vous et reconnectez-vous"
    fi
}

# Create workspace directory
create_workspace() {
    log_step "Création de l'espace de travail BHF"
    
    WORKSPACE_DIR="$HOME/kafka-formation-bhf"
    
    if [ -d "$WORKSPACE_DIR" ]; then
        log_warning "Le répertoire $WORKSPACE_DIR existe déjà"
        read -p "Voulez-vous le nettoyer et recréer? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$WORKSPACE_DIR"
            log_info "Ancien répertoire supprimé"
        else
            log_info "Utilisation du répertoire existant"
        fi
    fi
    
    mkdir -p "$WORKSPACE_DIR"
    mkdir -p "$WORKSPACE_DIR/logs"
    mkdir -p "$WORKSPACE_DIR/scripts"
    
    log_success "Espace de travail créé: $WORKSPACE_DIR"
}

# Download enterprise docker-compose
download_docker_compose() {
    log_step "Téléchargement de la configuration Docker Enterprise"
    
    DOCKER_COMPOSE_FILE="$WORKSPACE_DIR/docker-compose.enterprise.yml"
    
    cat > "$DOCKER_COMPOSE_FILE" << 'EOF'
version: '3.8'

services:
  zookeeper:
    image: confluentinc/cp-zookeeper:7.4.0
    hostname: zookeeper
    container_name: zookeeper
    ports:
      - "2181:2181"
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
      ZOOKEEPER_TICK_TIME: 2000
      ZOOKEEPER_SYNC_LIMIT: 5
      ZOOKEEPER_MAX_CLIENT_CNXNS: 60
    volumes:
      - zookeeper-data:/var/lib/zookeeper/data
      - zookeeper-logs:/var/lib/zookeeper/log
    networks:
      - bhf-kafka-network
    healthcheck:
      test: ["CMD", "nc", "-z", "localhost", "2181"]
      interval: 10s
      timeout: 5s
      retries: 5
    restart: unless-stopped

  kafka:
    image: confluentinc/cp-kafka:7.4.0
    hostname: kafka
    container_name: kafka
    depends_on:
      zookeeper:
        condition: service_healthy
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
      KAFKA_GROUP_INITIAL_REBALANCE_DELAY_MS: 0
      KAFKA_AUTO_CREATE_TOPICS_ENABLE: "true"
      KAFKA_DELETE_TOPIC_ENABLE: "true"
      KAFKA_LOG_RETENTION_HOURS: 24
      KAFKA_LOG_SEGMENT_BYTES: 1073741824
      KAFKA_LOG_RETENTION_CHECK_INTERVAL_MS: 300000
      KAFKA_HEAP_OPTS: "-Xmx4G -Xms2G"
      KAFKA_JMX_PORT: 9999
      KAFKA_JMX_HOSTNAME: localhost
      KAFKA_METRICS_REPORTER_INTERVAL_MS: 30000
      KAFKA_METRICS_NUM_SAMPLES: 2
      KAFKA_AUTO_LEADER_REBALANCE_ENABLE: "true"
    volumes:
      - kafka-data:/var/lib/kafka/data
      - kafka-logs:/var/log/kafka
    networks:
      - bhf-kafka-network
    healthcheck:
      test: ["CMD", "kafka-topics", "--bootstrap-server", "localhost:9092", "--list"]
      interval: 30s
      timeout: 10s
      retries: 3
    restart: unless-stopped

  kafka-ui:
    image: provectuslabs/kafka-ui:latest
    hostname: kafka-ui
    container_name: kafka-ui
    depends_on:
      kafka:
        condition: service_healthy
    ports:
      - "8080:8080"
    environment:
      KAFKA_CLUSTERS_0_NAME: BHF-Training
      KAFKA_CLUSTERS_0_BOOTSTRAPSERVERS: kafka:29092
      KAFKA_CLUSTERS_0_ZOOKEEPERCONNECT: zookeeper:2181
      KAFKA_CLUSTERS_0_READONLY: "false"
      KAFKA_CLUSTERS_0_KAFKACONFIGCLIENTID: kafka-ui
      KAFKA_CLUSTERS_0_KAFKACONFIGCLIENTSECRET: kafka-ui-secret
    networks:
      - bhf-kafka-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080"]
      interval: 30s
      timeout: 10s
      retries: 3
    restart: unless-stopped

  schema-registry:
    image: confluentinc/cp-schema-registry:7.4.0
    hostname: schema-registry
    container_name: schema-registry
    depends_on:
      kafka:
        condition: service_healthy
    ports:
      - "8081:8081"
    environment:
      SCHEMA_REGISTRY_HOST_NAME: schema-registry
      SCHEMA_REGISTRY_KAFKASTORE_BOOTSTRAP_SERVERS: kafka:29092
      SCHEMA_REGISTRY_LISTENERS: http://0.0.0.0:8081
      SCHEMA_REGISTRY_KAFKASTORE_TOPIC: _schemas
      SCHEMA_REGISTRY_DEBUG: "true"
    networks:
      - bhf-kafka-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8081/subjects"]
      interval: 30s
      timeout: 10s
      retries: 3
    profiles:
      - schema-registry
    restart: unless-stopped

  kafka-connect:
    image: confluentinc/cp-kafka-connect:7.4.0
    hostname: kafka-connect
    container_name: kafka-connect
    depends_on:
      kafka:
        condition: service_healthy
      schema-registry:
        condition: service_healthy
    ports:
      - "8083:8083"
    environment:
      CONNECT_BOOTSTRAP_SERVERS: kafka:29092
      CONNECT_REST_ADVERTISED_HOST_NAME: kafka-connect
      CONNECT_REST_PORT: 8083
      CONNECT_GROUP_ID: bhf-connect-cluster
      CONNECT_CONFIG_STORAGE_TOPIC: bhf-connect-configs
      CONNECT_OFFSET_STORAGE_TOPIC: bhf-connect-offsets
      CONNECT_STATUS_STORAGE_TOPIC: bhf-connect-statuses
      CONNECT_KEY_CONVERTER: org.apache.kafka.connect.json.JsonConverter
      CONNECT_VALUE_CONVERTER: org.apache.kafka.connect.json.JsonConverter
      CONNECT_INTERNAL_KEY_CONVERTER: org.apache.kafka.connect.json.JsonConverter
      CONNECT_INTERNAL_VALUE_CONVERTER: org.apache.kafka.connect.json.JsonConverter
      CONNECT_PLUGIN_PATH: "/usr/share/java,/usr/share/confluent-hub-components"
      CONNECT_LOG4J_LOGGERS: org.apache.kafka.connect.runtime.rest.RestLogger,org.reflections.Reflections
      CONNECT_LOG4J_LOGGERS_ROOT: ERROR,org.reflections.Reflections,WARN
      CONNECT_LOG4J_LOGGERS_CONNECT_ROOT: ERROR,org.reflections.Reflections,WARN
    volumes:
      - kafka-connect-data:/var/lib/kafka/connect
    networks:
      - bhf-kafka-network
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8083/connectors"]
      interval: 30s
      timeout: 10s
      retries: 3
    profiles:
      - connect
    restart: unless-stopped

volumes:
  zookeeper-data:
    driver: local
  zookeeper-logs:
    driver: local
  kafka-data:
    driver: local
  kafka-logs:
    driver: local
  kafka-connect-data:
    driver: local

networks:
  bhf-kafka-network:
    driver: bridge
    ipam:
      config:
        - subnet: 172.20.0.0/16
EOF
    
    log_success "Configuration Docker Enterprise créée"
}

# Start Kafka cluster
start_kafka_cluster() {
    log_step "Démarrage du cluster Kafka Enterprise"
    
    cd "$WORKSPACE_DIR"
    
    # Stop existing containers if any
    log_info "Arrêt des conteneurs existants..."
    docker-compose -f docker-compose.enterprise.yml down -v 2>/dev/null || true
    
    # Start core services
    log_info "Démarrage des services de base (Zookeeper, Kafka, Kafka UI)..."
    docker-compose -f docker-compose.enterprise.yml up -d zookeeper kafka kafka-ui
    
    # Wait for Kafka to be ready
    log_info "Attente du démarrage de Kafka..."
    for i in {1..30}; do
        if docker exec kafka kafka-topics --list --bootstrap-server localhost:9092 &>/dev/null; then
            log_success "Kafka est prêt!"
            break
        fi
        echo -n "."
        sleep 2
        if [ $i -eq 30 ]; then
            echo
            log_error "Kafka n'a pas démarré dans le temps imparti"
            exit 1
        fi
    done
    
    # Create BHF topics
    log_info "Création des topics BHF..."
    docker exec kafka kafka-topics --create --topic bhf-transactions --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1 2>/dev/null || log_warning "Topic bhf-transactions existe déjà"
    docker exec kafka kafka-topics --create --topic bhf-audit --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1 2>/dev/null || log_warning "Topic bhf-audit existe déjà"
    docker exec kafka kafka-topics --create --topic bhf-wordcount-input --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1 2>/dev/null || log_warning "Topic bhf-wordcount-input existe déjà"
    docker exec kafka kafka-topics --create --topic bhf-wordcount-output --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1 2>/dev/null || log_warning "Topic bhf-wordcount-output existe déjà"
    
    log_success "Cluster Kafka Enterprise démarré avec succès!"
}

# Create utility scripts
create_utility_scripts() {
    log_step "Création des scripts utilitaires"
    
    # Monitoring script
    cat > "$WORKSPACE_DIR/scripts/monitor.sh" << 'EOF'
#!/bin/bash

# Kafka Performance Monitoring Script
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
    
    # Cleanup script
    cat > "$WORKSPACE_DIR/scripts/cleanup.sh" << 'EOF'
#!/bin/bash

# Cleanup Script - Kafka BHF Formation
echo "🧹 Nettoyage - Kafka BHF Formation"
echo "================================="

# Stop and remove containers
echo "🛑 Arrêt des conteneurs..."
cd ~/kafka-formation-bhf
docker-compose -f docker-compose.enterprise.yml down -v

# Remove Docker images
echo "🗑️  Suppression des images Docker..."
docker rmi $(docker images "confluentinc/*" -q) 2>/dev/null || true

# Clean up logs
echo "📚 Nettoyage des logs..."
rm -rf logs/*

# Clean up Docker volumes
echo "💾 Nettoyage des volumes Docker..."
docker volume prune -f

echo "✅ Nettoyage terminé"
EOF
    
    # Test script
    cat > "$WORKSPACE_DIR/scripts/test-cluster.sh" << 'EOF'
#!/bin/bash

# Test Cluster Functionality
echo "🧪 Test Cluster Kafka - BHF"
echo "=========================="

# Test 1: List topics
echo "📚 Test 1: List topics"
docker exec kafka kafka-topics --list --bootstrap-server localhost:9092

# Test 2: Produce message
echo ""
echo "📤 Test 2: Production message"
echo "test-message-$(date +%s)" | docker exec -i kafka kafka-console-producer --topic bhf-transactions --bootstrap-server localhost:9092

# Test 3: Consume message
echo ""
echo "📥 Test 3: Consommation message"
docker exec kafka kafka-console-consumer --topic bhf-transactions --bootstrap-server localhost:9092 --from-beginning --timeout-ms 2000

echo ""
echo "✅ Tests terminés"
EOF
    
    # Make scripts executable
    chmod +x "$WORKSPACE_DIR/scripts"/*.sh
    
    log_success "Scripts utilitaires créés"
}

# Display cluster status
display_status() {
    log_step "Statut du cluster Kafka Enterprise"
    
    echo ""
    echo "🐳 Conteneurs Docker:"
    docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | grep -E "(zookeeper|kafka|kafka-ui)"
    
    echo ""
    echo "📚 Topics Kafka:"
    docker exec kafka kafka-topics --list --bootstrap-server localhost:9092 2>/dev/null || echo "Kafka non disponible"
    
    echo ""
    echo "🌐 URLs d'accès:"
    echo "   Kafka UI: http://localhost:8080"
    echo "   JMX Metrics: localhost:9999"
    
    if docker ps | grep -q schema-registry; then
        echo "   Schema Registry: http://localhost:8081"
    fi
    
    if docker ps | grep -q kafka-connect; then
        echo "   Kafka Connect: http://localhost:8083"
    fi
}

# Display next steps
display_next_steps() {
    echo ""
    echo "🚀 Prochaines étapes:"
    echo ""
    echo "1. 📚 Formation - Jour 1 Foundations:"
    echo "   cd ~/kafka-formation-bhf/jour-01-foundations"
    echo ""
    echo "2. 🏦 Module 01 - Cluster Architecture:"
    echo "   cd module-01-cluster && ./validate-module-01.sh"
    echo ""
    echo "3. 🔄 Module 02 - Producer Idempotent:"
    echo "   cd module-02-producer && ./scripts/test-idempotence.sh"
    echo ""
    echo "4. 📥 Module 03 - Consumer Read-Committed:"
    echo "   cd module-03-consumer && ./scripts/test-read-committed.sh"
    echo ""
    echo "5. 📊 Monitoring:"
    echo "   ~/kafka-formation-bhf/scripts/monitor.sh"
    echo ""
    echo "6. 🧹 Nettoyage:"
    echo "   ~/kafka-formation-bhf/scripts/cleanup.sh"
    echo ""
    echo "📖 Documentation complète: ~/kafka-formation-bhf/README.md"
    echo "🎯 Workshop guide: ~/kafka-formation-bhf/workshop-guide.md"
}

# Main execution
main() {
    echo "🏦 Quick Start - Formation Kafka Enterprise BHF"
    echo "============================================="
    echo ""
    
    check_ubuntu
    check_docker
    create_workspace
    download_docker_compose
    start_kafka_cluster
    create_utility_scripts
    display_status
    display_next_steps
    
    echo ""
    log_success "✅ Quick Start terminé avec succès!"
    echo ""
    echo "🎉 Votre environnement Kafka Enterprise BHF est prêt!"
    echo "📚 Commencez la formation avec le Module 01 - Cluster Architecture"
}

# Run main function
main "$@"
