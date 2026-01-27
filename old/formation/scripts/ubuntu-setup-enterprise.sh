#!/bin/bash

# Ubuntu Enterprise Setup - Formation Kafka BHF
# Script d'installation pour environnement de formation Ubuntu 22.04 LTS

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

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   log_error "Ce script ne doit pas être exécuté en tant que root"
   exit 1
fi

# Check Ubuntu version
check_ubuntu() {
    log_step "Vérification de la version Ubuntu"
    
    if ! grep -q "Ubuntu" /etc/os-release; then
        log_error "Ce script est conçu pour Ubuntu"
        exit 1
    fi
    
    UBUNTU_VERSION=$(grep VERSION_ID /etc/os-release | cut -d'"' -f2)
    log_info "Version Ubuntu détectée: $UBUNTU_VERSION"
    
    if [[ "$UBUNTU_VERSION" < "22.04" ]]; then
        log_warning "Ubuntu 22.04 LTS ou supérieur recommandé"
    fi
}

# System Update
update_system() {
    log_step "Mise à jour du système"
    
    log_info "Mise à jour des paquets..."
    sudo apt update
    
    log_info "Mise à niveau des paquets installés..."
    sudo apt upgrade -y
    
    log_success "Système mis à jour"
}

# Install Java 17
install_java() {
    log_step "Installation de Java 17"
    
    if command -v java &> /dev/null; then
        JAVA_VERSION=$(java -version 2>&1 | head -n 1 | cut -d'"' -f2)
        log_info "Java déjà installé: $JAVA_VERSION"
        
        if [[ "$JAVA_VERSION" < "17" ]]; then
            log_warning "Java 17 ou supérieur recommandé"
        fi
    else
        log_info "Installation de OpenJDK 17..."
        sudo apt install -y openjdk-17-jdk openjdk-17-jre
        
        log_success "Java 17 installé"
    fi
    
    # Set JAVA_HOME
    JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))
    echo "export JAVA_HOME=$JAVA_HOME" >> ~/.bashrc
    echo 'export PATH=$PATH:$JAVA_HOME/bin' >> ~/.bashrc
}

# Install Maven
install_maven() {
    log_step "Installation de Maven"
    
    if command -v mvn &> /dev/null; then
        MVN_VERSION=$(mvn -version | head -n 1 | cut -d' ' -f3)
        log_info "Maven déjà installé: $MVN_VERSION"
    else
        log_info "Installation de Maven..."
        sudo apt install -y maven
        
        log_success "Maven installé"
    fi
}

# Install Docker
install_docker() {
    log_step "Installation de Docker et Docker Compose"
    
    if command -v docker &> /dev/null; then
        DOCKER_VERSION=$(docker --version | cut -d' ' -f3 | sed 's/,//')
        log_info "Docker déjà installé: $DOCKER_VERSION"
    else
        log_info "Installation de Docker..."
        
        # Install prerequisites
        sudo apt install -y apt-transport-https ca-certificates curl gnupg lsb-release
        
        # Add Docker's official GPG key
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
        
        # Set up the repository
        echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        
        # Install Docker Engine
        sudo apt update
        sudo apt install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
        
        log_success "Docker installé"
    fi
    
    # Add user to docker group
    if ! groups $USER | grep -q docker; then
        log_info "Ajout de l'utilisateur au groupe docker..."
        sudo usermod -aG docker $USER
        log_warning "Vous devrez vous déconnecter et vous reconnecter pour appliquer les changements"
    fi
}

# Install additional tools
install_tools() {
    log_step "Installation des outils de développement"
    
    # Install Git
    if ! command -v git &> /dev/null; then
        log_info "Installation de Git..."
        sudo apt install -y git
    fi
    
    # Install curl and wget
    sudo apt install -y curl wget
    
    # Install vim and nano
    sudo apt install -y vim nano
    
    # Install htop for monitoring
    sudo apt install -y htop
    
    # Install tree for directory visualization
    sudo apt install -y tree
    
    # Install jq for JSON processing
    sudo apt install -y jq
    
    # Install net-tools for network utilities
    sudo apt install -y net-tools
    
    log_success "Outils de développement installés"
}

# Performance tuning for Kafka
tune_system() {
    log_step "Optimisation des paramètres système pour Kafka"
    
    # Create sysctl configuration
    sudo tee -a /etc/sysctl.conf > /dev/null << EOF
# Kafka Performance Tuning
vm.max_map_count=262144
fs.file-max=2097152
net.ipv4.tcp_keepalive_time=600
net.ipv4.tcp_keepalive_intvl=60
net.ipv4.tcp_keepalive_probes=20
net.core.rmem_max=16777216
net.core.wmem_max=16777216
net.ipv4.tcp_rmem=4096 87380 16777216
net.ipv4.tcp_wmem=4096 65536 16777216
EOF
    
    # Apply sysctl settings
    sudo sysctl -p
    
    # Create limits configuration
    sudo tee -a /etc/security/limits.conf > /dev/null << EOF
# Kafka Limits
* soft nofile 100000
* hard nofile 100000
* soft nproc 32768
* hard nproc 32768
EOF
    
    log_success "Paramètres système optimisés pour Kafka"
}

# Create workspace directory
create_workspace() {
    log_step "Création de l'espace de travail"
    
    WORKSPACE_DIR="$HOME/kafka-formation-bhf"
    
    if [ -d "$WORKSPACE_DIR" ]; then
        log_warning "Le répertoire $WORKSPACE_DIR existe déjà"
        read -p "Voulez-vous le nettoyer? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$WORKSPACE_DIR"
            log_info "Ancien répertoire supprimé"
        fi
    fi
    
    mkdir -p "$WORKSPACE_DIR"
    mkdir -p "$WORKSPACE_DIR/logs"
    mkdir -p "$WORKSPACE_DIR/scripts"
    mkdir -p "$WORKSPACE_DIR/jour-01-foundations"
    mkdir -p "$WORKSPACE_DIR/jour-02-transactions"
    mkdir -p "$WORKSPACE_DIR/jour-03-streams-production"
    
    log_success "Espace de travail créé: $WORKSPACE_DIR"
}

# Set environment variables
setup_environment() {
    log_step "Configuration des variables d'environnement"
    
    # Add environment variables to .bashrc
    cat >> ~/.bashrc << 'EOF'

# Kafka BHF Formation Environment Variables
export KAFKA_HOME=$HOME/kafka-formation-bhf
export PATH=$PATH:$KAFKA_HOME/scripts
export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64

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

# Quick Navigation
alias kafka-cd='cd $KAFKA_HOME'
alias kafka-day1='cd $KAFKA_HOME/jour-01-foundations'
alias kafka-day2='cd $KAFKA_HOME/jour-02-transactions'
alias kafka-day3='cd $KAFKA_HOME/jour-03-streams-production'
EOF
    
    # Reload .bashrc
    source ~/.bashrc
    
    log_success "Variables d'environnement configurées"
}

# Create performance monitoring script
create_monitoring_script() {
    log_step "Création du script de monitoring"
    
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
    
    chmod +x "$WORKSPACE_DIR/scripts/monitor.sh"
    log_success "Script de monitoring créé"
}

# Create quick start script
create_quickstart_script() {
    log_step "Création du script de démarrage rapide"
    
    cat > "$WORKSPACE_DIR/scripts/quick-start.sh" << 'EOF'
#!/bin/bash

# Quick Start Script - Kafka BHF Formation
echo "🚀 Quick Start - Kafka BHF Formation"
echo "=================================="

# Start Kafka cluster
echo "📦 Démarrage du cluster Kafka..."
cd $KAFKA_HOME
docker-compose -f docker-compose.enterprise.yml up -d

# Wait for Kafka to be ready
echo "⏳ Attente du démarrage de Kafka..."
sleep 30

# Create test topics
echo "📚 Création des topics de test..."
docker exec kafka kafka-topics --create --topic bhf-transactions --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1 2>/dev/null
docker exec kafka kafka-topics --create --topic bhf-audit --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1 2>/dev/null

# Show cluster status
echo "📊 Statut du cluster:"
docker exec kafka kafka-topics --list --bootstrap-server localhost:9092

echo ""
echo "✅ Kafka est prêt pour la formation!"
echo ""
echo "📖 Prochaine étape:"
echo "cd $KAFKA_HOME/jour-01-foundations/module-01-cluster"
echo "./validate-module-01.sh"
EOF
    
    chmod +x "$WORKSPACE_DIR/scripts/quick-start.sh"
    log_success "Script de démarrage rapide créé"
}

# Create cleanup script
create_cleanup_script() {
    log_step "Création du script de nettoyage"
    
    cat > "$WORKSPACE_DIR/scripts/cleanup.sh" << 'EOF'
#!/bin/bash

# Cleanup Script - Kafka BHF Formation
echo "🧹 Nettoyage - Kafka BHF Formation"
echo "================================="

# Stop and remove containers
echo "🛑 Arrêt des conteneurs..."
cd $KAFKA_HOME
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
    
    chmod +x "$WORKSPACE_DIR/scripts/cleanup.sh"
    log_success "Script de nettoyage créé"
}

# Display success message
display_success() {
    echo ""
    log_success "🎉 Installation terminée avec succès!"
    echo ""
    echo "📋 Résumé de l'installation:"
    echo "   ✅ Ubuntu $UBUNTU_VERSION optimisé pour Kafka"
    echo "   ✅ Java 17 installé"
    echo "   ✅ Maven installé"
    echo "   ✅ Docker et Docker Compose installés"
    echo "   ✅ Outils de développement installés"
    echo "   ✅ Paramètres système optimisés"
    echo "   ✅ Espace de travail créé: $WORKSPACE_DIR"
    echo "   ✅ Scripts utilitaires créés"
    echo ""
    echo "🚀 Prochaines étapes:"
    echo ""
    echo "1. 🔄 Déconnectez-vous et reconnectez-vous (pour appliquer le groupe docker):"
    echo "   exit"
    echo "   ssh user@hostname"
    echo ""
    echo "2. 🚀 Démarrez Kafka avec:"
    echo "   ~/kafka-formation-bhf/scripts/quick-start.sh"
    echo ""
    echo "3. 📊 Vérifiez le statut avec:"
    echo "   ~/kafka-formation-bhf/scripts/monitor.sh"
    echo ""
    echo "4. 📚 Commencez la formation:"
    echo "   cd ~/kafka-formation-bhf/jour-01-foundations"
    echo ""
    echo "🎯 Aliases disponibles:"
    echo "   kafka-start, kafka-stop, kafka-logs"
    echo "   kafka-topics, kafka-consumer, kafka-producer"
    echo "   dps, dlogs, dexec"
    echo "   mvnc, mvnt, mvnp"
    echo "   kafka-cd, kafka-day1, kafka-day2, kafka-day3"
    echo ""
    echo "🏦 Formation Kafka Enterprise BHF - Ready for Ubuntu!"
}

# Main execution
main() {
    echo "🏦 Installation Ubuntu Enterprise - Formation Kafka BHF"
    echo "=================================================="
    echo ""
    
    check_ubuntu
    update_system
    install_java
    install_maven
    install_docker
    install_tools
    tune_system
    create_workspace
    setup_environment
    create_monitoring_script
    create_quickstart_script
    create_cleanup_script
    display_success
}

# Run main function
main "$@"
