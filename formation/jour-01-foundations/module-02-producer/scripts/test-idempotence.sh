#!/bin/bash

# Test Idempotent Producer - Ubuntu Enterprise
# Script de test pour le Lab 02.1 - Producer Idempotent BHF

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
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

# Check if Kafka is running
check_kafka() {
    if ! docker exec kafka kafka-topics --list --bootstrap-server localhost:9092 &>/dev/null; then
        log_error "Kafka n'est pas en cours d'exécution"
        log_info "Démarrez Kafka avec: docker-compose -f docker-compose.enterprise.yml up -d"
        exit 1
    fi
}

# Create test topic
create_topic() {
    log_info "Création du topic BHF: bhf-transactions"
    docker exec kafka kafka-topics --create --topic bhf-transactions --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1 2>/dev/null || log_warning "Le topic existe déjà"
}

# Test idempotent producer
test_idempotent_producer() {
    log_info "🔄 Test de l'idempotence - 3 exécutions pour 1 seul message"
    
    cd ~/kafka-formation-bhf/jour-01-foundations/module-02-producer
    
    for i in {1..3}; do
        log_info "Exécution $i/3"
        mvn exec:java -Dexec.mainClass="com.bhf.kafka.IdempotentProducerApp" -q
        sleep 1
    done
}

# Verify results
verify_results() {
    log_info "🔍 Vérification des messages dans Kafka"
    
    # Count messages
    message_count=$(docker exec kafka kafka-console-consumer --topic bhf-transactions --bootstrap-server localhost:9092 --from-beginning --timeout-ms 5000 2>/dev/null | wc -l)
    
    if [ "$message_count" -eq 1 ]; then
        log_success "✅ Test d'idempotence réussi: 1 seul message malgré 3 envois"
    else
        log_error "❌ Test d'idempotence échoué: $message_count messages trouvés"
        return 1
    fi
}

# Show message details
show_message() {
    log_info "📄 Message unique reçu:"
    docker exec kafka kafka-console-consumer --topic bhf-transactions --bootstrap-server localhost:9092 --from-beginning --property print.key=true --timeout-ms 5000 2>/dev/null
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
    duration=$((($end_time - $start_time) / 1000000)) # Convert to milliseconds
    
    log_info "📊 Performance: 100 envois en ${duration}ms"
    log_info "📈 Moyenne: $(($duration / 100))ms par envoi"
}

# Cleanup
cleanup() {
    log_info "🧹 Nettoyage du topic de test"
    docker exec kafka kafka-topics --delete --topic bhf-transactions --bootstrap-server localhost:9092 2>/dev/null || true
}

# Main execution
main() {
    echo "🏦 Test Idempotent Producer - BHF Formation"
    echo "=========================================="
    
    check_kafka
    create_topic
    test_idempotent_producer
    verify_results
    show_message
    
    # Ask for performance test
    read -p "⚡ Voulez-vous exécuter le test de performance (100 envois)? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        performance_test
    fi
    
    read -p "🧹 Voulez-vous nettoyer le topic de test? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cleanup
    fi
    
    log_success "✅ Test d'idempotence terminé avec succès!"
}

# Run main function
main "$@"

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Kafka is running
check_kafka() {
    if ! docker exec kafka kafka-topics --list --bootstrap-server localhost:9092 &>/dev/null; then
        log_error "Kafka n'est pas en cours d'exécution"
        log_info "Démarrez Kafka avec: docker-compose up -d"
        exit 1
    fi
}

# Create test topic
create_topic() {
    log_info "Création du topic BHF: bhf-transactions"
    docker exec kafka kafka-topics --create --topic bhf-transactions --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1 2>/dev/null || log_warning "Le topic existe déjà"
}

# Test idempotent producer
test_idempotent_producer() {
    log_info "🔄 Test de l'idempotence - 3 exécutions pour 1 seul message"
    
    cd ~/kafka-formation-bhf/jour-01-foundations/module-02-producer
    
    for i in {1..3}; do
        log_info "Exécution $i/3"
        mvn exec:java -Dexec.mainClass="com.bhf.kafka.IdempotentProducerApp" -q
        sleep 1
    done
}

# Verify results
verify_results() {
    log_info "🔍 Vérification des messages dans Kafka"
    
    # Count messages
    message_count=$(docker exec kafka kafka-console-consumer --topic bhf-transactions --bootstrap-server localhost:9092 --from-beginning --timeout-ms 5000 2>/dev/null | wc -l)
    
    if [ "$message_count" -eq 1 ]; then
        log_success "✅ Test d'idempotence réussi: 1 seul message malgré 3 envois"
    else
        log_error "❌ Test d'idempotence échoué: $message_count messages trouvés"
        return 1
    fi
}

# Show message details
show_message() {
    log_info "📄 Message unique reçu:"
    docker exec kafka kafka-console-consumer --topic bhf-transactions --bootstrap-server localhost:9092 --from-beginning --property print.key=true --timeout-ms 5000 2>/dev/null
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
    duration=$((($end_time - $start_time) / 1000000)) # Convert to milliseconds
    
    log_info "📊 Performance: 100 envois en ${duration}ms"
    log_info "📈 Moyenne: $(($duration / 100))ms par envoi"
}

# Cleanup
cleanup() {
    log_info "🧹 Nettoyage du topic de test"
    docker exec kafka kafka-topics --delete --topic bhf-transactions --bootstrap-server localhost:9092 2>/dev/null || true
}

# Main execution
main() {
    echo "🏦 Test Idempotent Producer - BHF Formation"
    echo "=========================================="
    
    check_kafka
    create_topic
    test_idempotent_producer
    verify_results
    show_message
    
    # Ask for performance test
    read -p "⚡ Voulez-vous exécuter le test de performance (100 envois)? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        performance_test
    fi
    
    read -p "🧹 Voulez-vous nettoyer le topic de test? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        cleanup
    fi
    
    log_success "✅ Test d'idempotence terminé avec succès!"
}

# Run main function
main "$@"
