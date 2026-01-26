#!/bin/bash

# Ubuntu Enterprise Setup - Formation Kafka BHF
# Script d'installation pour environnement de formation Ubuntu 22.04 LTS

set -e

echo "🏦 Installation Kafka Enterprise - BHF Formation"
echo "============================================="

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

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   log_error "Ce script ne doit pas être exécuté en tant que root"
   exit 1
fi

# System Update
log_info "Mise à jour du système..."
sudo apt update && sudo apt upgrade -y

# Install Java 17
log_info "Installation de Java 17..."
sudo apt install -y openjdk-17-jdk openjdk-17-jre

# Install Maven
log_info "Installation de Maven..."
sudo apt install -y maven

# Install Docker
log_info "Installation de Docker..."
sudo apt install -y docker.io docker-compose-plugin

# Add user to docker group
log_info "Ajout de l'utilisateur au groupe docker..."
sudo usermod -aG docker $USER

# Install Git
log_info "Installation de Git..."
sudo apt install -y git

# Install useful tools
log_info "Installation des outils de développement..."
sudo apt install -y curl wget vim htop tree jq

# Performance tuning for Kafka
log_info "Configuration des paramètres système pour Kafka..."
echo 'vm.max_map_count=262144' | sudo tee -a /etc/sysctl.conf
echo 'fs.file-max=2097152' | sudo tee -a /etc/sysctl.conf
echo 'net.ipv4.tcp_keepalive_time=600' | sudo tee -a /etc/sysctl.conf
echo 'net.ipv4.tcp_keepalive_intvl=60' | sudo tee -a /etc/sysctl.conf
echo 'net.ipv4.tcp_keepalive_probes=20' | sudo tee -a /etc/sysctl.conf

# Apply sysctl settings
sudo sysctl -p

# Create workspace directory
log_info "Création du workspace de formation..."
mkdir -p ~/kafka-formation-bhf
cd ~/kafka-formation-bhf

# Clone the repository (replace with actual repo)
log_info "Clonage du repository de formation..."
git clone https://github.com/bhf/kafka-formation.git .

# Create logs directory
mkdir -p logs

# Set environment variables
log_info "Configuration des variables d'environnement..."
echo 'export JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64' >> ~/.bashrc
echo 'export MAVEN_HOME=/usr/share/maven' >> ~/.bashrc
echo 'export PATH=$PATH:$JAVA_HOME/bin:$MAVEN_HOME/bin' >> ~/.bashrc
echo 'export KAFKA_HOME=~/kafka-formation-bhf' >> ~/.bashrc

# Create aliases for convenience
log_info "Création des aliases..."
cat >> ~/.bashrc << 'EOF'

# Kafka BHF Formation aliases
alias kafka-start='cd ~/kafka-formation-bhf && docker-compose up -d'
alias kafka-stop='cd ~/kafka-formation-bhf && docker-compose down'
alias kafka-logs='cd ~/kafka-formation-bhf && docker-compose logs -f'
alias kafka-topics='docker exec kafka kafka-topics --bootstrap-server localhost:9092'
alias kafka-consumer='docker exec kafka kafka-console-consumer --bootstrap-server localhost:9092'
alias kafka-producer='docker exec kafka kafka-console-producer --bootstrap-server localhost:9092'

# Docker aliases
alias dps='docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"'
alias dlogs='docker logs -f'
alias dexec='docker exec -it'

# Maven aliases
alias mvnc='mvn clean compile'
alias mvnt='mvn clean test'
alias mvnp='mvn clean package'
EOF

# Reload bashrc
source ~/.bashrc

# Verify installations
log_info "Vérification des installations..."

# Check Java
java_version=$(java -version 2>&1 | head -n 1)
log_success "Java installé: $java_version"

# Check Maven
maven_version=$(mvn -version | head -n 1)
log_success "Maven installé: $maven_version"

# Check Docker
if command -v docker &> /dev/null; then
    docker_version=$(docker --version)
    log_success "Docker installé: $docker_version"
else
    log_warning "Docker n'est pas dans le PATH. Veuillez vous déconnecter et vous reconnecter."
fi

# Create performance monitoring script
log_info "Création du script de monitoring..."
cat > ~/kafka-formation-bhf/scripts/monitor.sh << 'EOF'
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

chmod +x ~/kafka-formation-bhf/scripts/monitor.sh

# Create quick start script
log_info "Création du script de démarrage rapide..."
cat > ~/kafka-formation-bhf/scripts/quick-start.sh << 'EOF'
#!/bin/bash

# Quick Start Script - Kafka BHF Formation
echo "🚀 Quick Start - Kafka BHF Formation"
echo "=================================="

# Start Kafka cluster
echo "📦 Démarrage du cluster Kafka..."
cd ~/kafka-formation-bhf
docker-compose up -d

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
echo "cd ~/kafka-formation-bhf/jour-01-foundations/module-02-producer"
echo "./scripts/test-idempotence.sh"
EOF

chmod +x ~/kafka-formation-bhf/scripts/quick-start.sh

# Create cleanup script
log_info "Création du script de nettoyage..."
cat > ~/kafka-formation-bhf/scripts/cleanup.sh << 'EOF'
#!/bin/bash

# Cleanup Script - Kafka BHF Formation
echo "🧹 Nettoyage - Kafka BHF Formation"
echo "================================="

# Stop and remove containers
echo "🛑 Arrêt des conteneurs..."
cd ~/kafka-formation-bhf
docker-compose down -v

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

chmod +x ~/kafka-formation-bhf/scripts/cleanup.sh

# Success message
log_success "Installation terminée avec succès!"
echo ""
echo "🎯 Prochaines étapes:"
echo "1. Déconnectez-vous et reconnectez-vous pour appliquer les changements de groupe"
echo "2. Exécutez: ~/kafka-formation-bhf/scripts/quick-start.sh"
echo "3. Commencez la formation avec le Module 01"
echo ""
echo "📚 Documentation: ~/kafka-formation-bhf/README.md"
echo "🔧 Scripts: ~/kafka-formation-bhf/scripts/"
echo "📊 Monitoring: ~/kafka-formation-bhf/scripts/monitor.sh"
echo ""
echo "🏦 BHF Kafka Formation - Ready for Enterprise Training!"
