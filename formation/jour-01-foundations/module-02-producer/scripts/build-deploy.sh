#!/bin/bash

# Build and Deploy Script - Producer Idempotent Ubuntu
# Script pour construire et déployer le producer idempotent BHF

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

# Check if we're in the right directory
check_directory() {
    if [ ! -f "pom.xml" ]; then
        log_error "pom.xml non trouvé. Veuillez exécuter ce script depuis le répertoire racine du module."
        exit 1
    fi
    
    if [ ! -f "Dockerfile" ]; then
        log_error "Dockerfile non trouvé. Veuillez vous assurer que le Dockerfile est présent."
        exit 1
    fi
}

# Clean previous build
clean_build() {
    log_step "Nettoyage des builds précédents"
    
    # Stop existing containers
    if docker ps -q | grep -q bhf-idempotent-producer; then
        log_info "Arrêt du conteneur bhf-idempotent-producer existant..."
        docker stop bhf-idempotent-producer || true
        docker rm bhf-idempotent-producer || true
    fi
    
    # Remove previous image
    if docker images -q bhf/idempotent-producer | grep -q .; then
        log_info "Suppression de l'image Docker précédente..."
        docker rmi bhf/idempotent-producer || true
    fi
    
    # Clean Maven
    log_info "Nettoyage Maven..."
    mvn clean
    
    log_success "Nettoyage terminé"
}

# Build Maven project
build_maven() {
    log_step "Compilation du projet Maven"
    
    log_info "Compilation Maven en cours..."
    mvn clean package -DskipTests
    
    if [ $? -eq 0 ]; then
        log_success "Compilation Maven réussie"
    else
        log_error "Échec de la compilation Maven"
        exit 1
    fi
}

# Build Docker image
build_docker() {
    log_step "Construction de l'image Docker"
    
    log_info "Construction de l'image Docker bhf/idempotent-producer..."
    docker build -t bhf/idempotent-producer:latest .
    
    if [ $? -eq 0 ]; then
        log_success "Image Docker construite avec succès"
    else
        log_error "Échec de la construction de l'image Docker"
        exit 1
    fi
}

# Deploy with Docker Compose
deploy_services() {
    log_step "Déploiement des services avec Docker Compose"
    
    # Check if docker-compose.yml exists
    if [ ! -f "docker-compose.yml" ]; then
        log_error "docker-compose.yml non trouvé"
        exit 1
    fi
    
    # Stop existing services
    log_info "Arrêt des services existants..."
    docker-compose -f docker-compose.yml down
    
    # Start services
    log_info "Démarrage des services..."
    docker-compose -f docker-compose.yml up -d
    
    # Wait for services to be ready
    log_info "Attente du démarrage des services..."
    sleep 30
    
    # Check if services are running
    if docker-compose -f docker-compose.yml ps | grep -q "Up"; then
        log_success "Services déployés avec succès"
    else
        log_error "Échec du déploiement des services"
        docker-compose -f docker-compose.yml logs
        exit 1
    fi
}

# Verify deployment
verify_deployment() {
    log_step "Vérification du déploiement"
    
    # Check Kafka
    log_info "Vérification de Kafka..."
    if docker exec kafka kafka-topics --list --bootstrap-server localhost:9092 &>/dev/null; then
        log_success "Kafka est opérationnel"
    else
        log_error "Kafka n'est pas opérationnel"
        return 1
    fi
    
    # Check producer service
    log_info "Vérification du service producer..."
    if curl -f http://localhost:8080/actuator/health &>/dev/null; then
        log_success "Service producer est opérationnel"
    else
        log_warning "Service producer peut encore être en démarrage..."
        sleep 10
        if curl -f http://localhost:8080/actuator/health &>/dev/null; then
            log_success "Service producer est maintenant opérationnel"
        else
            log_error "Service producer n'est pas opérationnel"
            docker-compose -f docker-compose.yml logs bhf-producer
            return 1
        fi
    fi
    
    # Create test topic
    log_info "Création du topic de test bhf-transactions..."
    docker exec kafka kafka-topics --create --topic bhf-transactions --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1 2>/dev/null || log_warning "Topic bhf-transactions existe déjà"
    
    log_success "Vérification terminée"
}

# Show deployment status
show_status() {
    log_step "Statut du déploiement"
    
    echo ""
    echo "🐳 Conteneurs Docker:"
    docker-compose -f docker-compose.yml ps
    
    echo ""
    echo "🌐 URLs d'accès:"
    echo "   Producer Health: http://localhost:8080/actuator/health"
    echo "   Kafka UI: http://localhost:8081"
    echo "   Kafka Broker: localhost:9092"
    
    echo ""
    echo "📚 Topics Kafka:"
    docker exec kafka kafka-topics --list --bootstrap-server localhost:9092 2>/dev/null || echo "Kafka non disponible"
    
    echo ""
    echo "📊 Logs récents:"
    docker-compose -f docker-compose.yml logs --tail=10 bhf-producer
}

# Test the deployment
test_deployment() {
    log_step "Test du déploiement"
    
    # Test producer endpoint
    log_info "Test du producer endpoint..."
    response=$(curl -s -o /dev/null -w "%{http_code}" http://localhost:8080/actuator/health)
    
    if [ "$response" = "200" ]; then
        log_success "Test du producer endpoint réussi"
    else
        log_error "Test du producer endpoint échoué (HTTP $response)"
        return 1
    fi
    
    # Test Kafka connectivity
    log_info "Test de la connectivité Kafka..."
    if docker exec kafka kafka-topics --list --bootstrap-server localhost:9092 &>/dev/null; then
        log_success "Connectivité Kafka vérifiée"
    else
        log_error "Connectivité Kafka échouée"
        return 1
    fi
    
    log_success "Tests de déploiement réussis"
}

# Main execution
main() {
    echo "🏦 Build and Deploy - Producer Idempotent Ubuntu"
    echo "==============================================="
    echo ""
    
    check_directory
    
    # Parse command line arguments
    case "${1:-all}" in
        "clean")
            clean_build
            ;;
        "maven")
            build_maven
            ;;
        "docker")
            build_docker
            ;;
        "deploy")
            deploy_services
            ;;
        "verify")
            verify_deployment
            ;;
        "status")
            show_status
            ;;
        "test")
            test_deployment
            ;;
        "all")
            clean_build
            build_maven
            build_docker
            deploy_services
            verify_deployment
            show_status
            test_deployment
            ;;
        *)
            echo "Usage: $0 {clean|maven|docker|deploy|verify|status|test|all}"
            echo ""
            echo "Options:"
            echo "  clean   - Nettoyer les builds précédents"
            echo "  maven   - Compiler le projet Maven"
            echo "  docker  - Construire l'image Docker"
            echo "  deploy  - Déployer les services"
            echo "  verify  - Vérifier le déploiement"
            echo "  status  - Afficher le statut"
            echo "  test    - Tester le déploiement"
            echo "  all     - Exécuter toutes les étapes (défaut)"
            exit 1
            ;;
    esac
    
    echo ""
    log_success "✅ Opération terminée avec succès!"
}

# Run main function with all arguments
main "$@"
