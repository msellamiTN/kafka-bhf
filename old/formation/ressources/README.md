# Scripts et Ressources - Formation BHF Kafka

## 📁 Scripts PowerShell

### Scripts de déploiement
- `deploy-cluster.ps1` - Déploiement cluster Kafka
- `test-idempotence.ps1` - Test producer idempotent
- `test-transactions.ps1` - Test producer transactionnel
- `test-streams.ps1` - Test Kafka Streams

## 📋 Checklists

### Module 01 - Cluster
- [ ] Docker Desktop installé
- [ ] Cluster Kafka démarré
- [ ] Topics créés
- [ ] CLI fonctionnelle

### Module 02 - Producer Idempotent
- [ ] Configuration idempotent appliquée
- [ ] Messages uniques malgré retries
- [ ] Logs de retry observés

### Module 06 - Transactional Producer
- [ ] Transactional ID configuré
- [ ] Transactions commitées/abortées
- [ ] Audit trail cohérent
- [ ] Recovery testé

## 🏦 Cas d'usage BHF

### Transactions bancaires
- **Paiements** : Exactly-once obligatoire
- **Comptes** : Mises à jour atomiques
- **Audit** : Trails immuables

### Monitoring
- **SLA** : Latence < 50ms
- **Disponibilité** : 99.9%
- **Alertes** : Seuils critiques

## 🚀 Quick Start

```powershell
# 1. Cloner le repo
git clone https://github.com/bhf/kafka-formation.git
cd kafka-formation

# 2. Démarrer le cluster
cd formation/jour-01-foundations/module-01-cluster
docker-compose up -d

# 3. Lancer le premier lab
cd ../module-02-producer
./scripts/test-idempotence.ps1
```

## 📚 Références BHF

- **Documentation interne** : Conformité réglementaire
- **Playbooks** : Procédures d'urgence
- **Architecture** : Patterns BHF Kafka
