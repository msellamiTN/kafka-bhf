# Module 01 - Architecture Kafka & Cluster Local

## 📚 Théorie (30%) - Architecture Kafka

### 1.1 Vue d'ensemble de l'architecture

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Producer   │───▶│   Broker     │◀───│   Consumer   │
└─────────────┘    │  (Leader)    │    └─────────────┘
                   └─────────────┘
                          │
                   ┌─────────────┐
                   │  Zookeeper   │
                   │  (Metadata)  │
                   └─────────────┘
```

### 1.2 Concepts fondamentaux

#### 🎯 **Topic**
- Flux de données catégorisé
- Exemple BHF : `transactions-paiements`, `comptes-clients`, `audit-traces`

#### 📦 **Partition**
- Unité de parallélisme et d'ordonnancement
- 1 partition = 1 thread de consommation maximum
- Distribution basée sur la clé du message

#### 📍 **Offset**
- Position unique dans une partition
- Permet reprise après crash
- Gestion manuelle pour exactly-once

#### 🔄 **Replica**
- Redondance des données
- 1 leader + N followers
- Failover automatique

### 1.3 Pourquoi Kafka chez BHF ?

- **Fiabilité** : Garanties exactly-once pour transactions financières
- **Scalabilité** : Millions d'événements/secondes
- **Durabilité** : Données persistées, rejeu possible
- **Réglementation** : Audit trails immuables

---

## 🛠️ Pratique (70%) - Cluster Local Docker

### Lab 01.1 - Déploiement Cluster Kafka

#### Étape 1 : Préparation de l'environnement

```powershell
# 1. Vérifier Docker Desktop
docker --version
docker-compose --version

# 2. Créer workspace de formation
mkdir C:\kafka-formation-bhf
cd C:\kafka-formation-bhf

# 3. Créer structure des dossiers
mkdir jour-01, logs, scripts
```

#### Étape 2 : Configuration Docker Compose

Créer le fichier `docker-compose.yml` :

```yaml
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
    networks:
      - kafka-network

  kafka:
    image: confluentinc/cp-kafka:7.4.0
    hostname: kafka
    container_name: kafka
    depends_on:
      - zookeeper
    ports:
      - "9092:9092"
      - "29092:29092"
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: 'zookeeper:2181'
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka:29092,PLAINTEXT_HOST://localhost:9092
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
      KAFKA_TRANSACTION_STATE_LOG_MIN_ISR: 1
      KAFKA_TRANSACTION_STATE_LOG_REPLICATION_FACTOR: 1
    networks:
      - kafka-network

networks:
  kafka-network:
    driver: bridge
```

#### Étape 3 : Démarrage du cluster

```powershell
# Démarrer les services
docker-compose up -d

# Vérifier que les containers sont up
docker ps

# Attendre 30 secondes pour le démarrage complet
Start-Sleep 30
```

**Résultat attendu :**
```
CONTAINER ID   IMAGE                              COMMAND                  CREATED         STATUS         PORTS
a1b2c3d4e5f6   confluentinc/cp-kafka:7.4.0      "/etc/confluent/dock…"   2 minutes ago   Up 2 minutes   0.0.0.0:9092->9092/tcp
f6e5d4c3b2a1   confluentinc/cp-zookeeper:7.4.0   "/etc/confluent/dock…"   2 minutes ago   Up 2 minutes   2181/tcp
```

#### Étape 4 : Validation du cluster

```powershell
# 1. Créer un topic de test BHF
docker exec kafka kafka-topics --create --topic bhf-transactions --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1

# 2. Lister les topics
docker exec kafka kafka-topics --list --bootstrap-server localhost:9092

# 3. Décrire le topic
docker exec kafka kafka-topics --describe --topic bhf-transactions --bootstrap-server localhost:9092
```

**Résultat attendu :**
```
Topic: bhf-transactions
PartitionCount: 3
ReplicationFactor: 1
Configs:
    Topic: bhf-transactions
    Partition: 0  Leader: 1  Replicas: 1  Isr: 1
    Partition: 1  Leader: 1  Replicas: 1  Isr: 1
    Partition: 2  Leader: 1  Replicas: 1  Isr: 1
```

#### Étape 5 : Test de production/consommation

```powershell
# Terminal 1 : Consumer
docker exec -it kafka kafka-console-consumer --topic bhf-transactions --bootstrap-server localhost:9092 --from-beginning

# Terminal 2 : Producer
docker exec -it kafka kafka-console-producer --topic bhf-transactions --bootstrap-server localhost:9092

# Envoyer des messages de test BHF
> transaction-001:{"id":"txn001","montant":1500.00,"devise":"EUR","statut":"EN_COURS"}
> transaction-002:{"id":"txn002","montant":250.50,"devise":"EUR","statut":"VALIDE"}
```

**Vérification dans le consumer :**
```
transaction-001	{"id":"txn001","montant":1500.00,"devise":"EUR","statut":"EN_COURS"}
transaction-002	{"id":"txn002","montant":250.50,"devise":"EUR","statut":"VALIDE"}
```

---

## 🎯 Checkpoint Module 01

### ✅ Validation des compétences

- [ ] Cluster Kafka démarré avec Docker Compose
- [ ] Topic BHF créé avec 3 partitions
- [ ] Messages produits et consommés avec succès
- [ ] Architecture comprise (Producer/Broker/Consumer/Zookeeper)

### 📝 Questions de checkpoint

1. **Pourquoi 3 partitions pour le topic `bhf-transactions` ?**
   - Parallélisme : 3 consumers peuvent traiter en parallèle
   - Scalabilité horizontale

2. **Que se passe-t-il si le container Kafka crash ?**
   - Données persistées dans volumes Docker
   - Redémarrage automatique avec `docker-compose up -d`

3. **Comment BHF utilise-t-il Kafka en production ?**
   - Transactions financières en temps réel
   - Audit trails immuables
   - Intégration entre systèmes hétérogènes

---

## 🚀 Prochain module

**Module 02** : Producer Idempotent - Configuration avancée pour garantir l'unicité des messages dans un contexte bancaire.
