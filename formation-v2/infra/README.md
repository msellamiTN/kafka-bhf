# Options de Déploiement Kafka KRaft

Ce répertoire contient deux modes de déploiement KRaft (Kafka Raft) utilisant l'image officielle Apache Kafka.

## Mode Nœud Unique (Défaut)

- **Fichier** : `docker-compose.single-node.yml`
- **Image** : `apache/kafka:latest`
- **Cas d'usage** : Développement, tests, labs de formation
- **Ressources** : 1 broker Kafka (agit comme broker et contrôleur)
- **Ports** : Kafka 9092, Kafka UI 8080, Portainer 9443
- **Démarrage** : `./scripts/up.sh single-node`
- **Arrêt** : `./scripts/down.sh single-node`

## Mode Cluster

- **Fichier** : `docker-compose.cluster.yml`
- **Image** : `apache/kafka:latest`
- **Cas d'usage** : Tests de production, tests de tolérance de panne
- **Ressources** : 3 brokers Kafka (chaque broker agit comme broker et contrôleur)
- **Ports** :
  - kafka1 : 9092
  - kafka2 : 9093
  - kafka3 : 9094
  - Kafka UI : 8080
  - Portainer : 9443
- **Démarrage** : `./scripts/up.sh cluster`
- **Arrêt** : `./scripts/down.sh cluster`

## Démarrage Rapide

```bash
# Nœud unique (défaut)
./scripts/up.sh

# Ou explicitement
./scripts/up.sh single-node

# Mode cluster
./scripts/up.sh cluster

# Arrêter
./scripts/down.sh
./scripts/down.sh cluster
```

## Avantages KRaft

- **Pas de ZooKeeper** : Architecture simplifiée, moins de composants
- **Démarrage plus rapide** : Pas de service de coordination externe nécessaire
- **Meilleures performances** : Gestion des métadonnées directe dans Kafka
- **Opérations simplifiées** : Un seul processus à gérer par nœud
- **Image officielle** : Utilise `apache/kafka:latest` pour une expérience Kafka vanilla

## Différences de Configuration

### Nœud Unique

- `KAFKA_NODE_ID: 1`
- `KAFKA_CONTROLLER_QUORUM_VOTERS: 1@kafka:29093`
- Facteur de réplication : 1
- Min ISR : 1
- Mémoire : 2GB heap, 1GB start

### Cluster

- `KAFKA_NODE_ID: 1/2/3` (par broker)
- `KAFKA_CONTROLLER_QUORUM_VOTERS: 1@kafka1:29093,2@kafka2:29093,3@kafka3:29093`
- Facteur de réplication : 3
- Min ISR : 2
- Mémoire : 1GB heap, 512MB start par broker

## Labs de Formation

Tous les modules de formation fonctionnent avec les deux modes. Utilisez le mode nœud unique pour la simplicité et la rapidité, ou le mode cluster pour des scénarios distribués réalistes.

## Migration depuis ZooKeeper

Ces configurations remplacent la configuration traditionnelle basée sur ZooKeeper par le mode KRaft :

- Pas de conteneur ZooKeeper nécessaire
- Métadonnées stockées en interne dans Kafka
- Même compatibilité client
- Meilleure utilisation des ressources
