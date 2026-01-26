# Lab 11.01 — Kafka on Kubernetes (plan de déploiement)

## Objectif

Produire un plan de déploiement Kafka sur Kubernetes:

- Stateful
- storage
- upgrades
- observabilité

## Livrable

- Un document (markdown) avec:
  - stratégie de stockage (PVC/StorageClass)
  - stratégie d’upgrade (rolling)
  - sécurité (TLS/SASL)
  - monitoring (Prometheus/Grafana)
  - opérations (rebalancing, partitions, quotas)

## Option recommandée

- Utiliser un operator (ex: Strimzi) ou Helm.

## Checkpoint

- Citer 3 risques spécifiques à Kafka sur K8s (ex: storage, network, rescheduling).
