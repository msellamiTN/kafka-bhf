# Lab 13.01 — Enterprise patterns: architecture review (atelier)

## Objectif

Faire une revue d’architecture d’une plateforme event-driven:

- event sourcing / CQRS
- sagas
- multi-tenancy
- gouvernance

## Livrable

- Un schéma + 1 page de décisions:
  - conventions de topics
  - stratégie de clés (ordering)
  - schema governance (compatibilité)
  - sécurité (ACLs / quotas)
  - DLQ/retry standards

## Checkpoint

1. Dans quel cas choisir event sourcing?
2. Pourquoi la gouvernance des schémas est critique en entreprise?
