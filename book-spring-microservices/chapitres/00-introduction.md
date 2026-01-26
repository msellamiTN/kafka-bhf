# 00 — Introduction

## Pourquoi Kafka dans une architecture microservices?

- Découplage temporel (producer et consumer n’ont pas besoin d’être “up” en même temps)
- Scalabilité via partitions + consumer groups
- Rejouabilité (reprocess) si la rétention le permet

## Ce que tu vas construire

- **Order Service**: produit des événements de commande
- **Payment Service**: consomme les commandes, produit des paiements
- **Inventory Service**: consomme commandes/paiements, maintient l’état stock

## Principes non négociables

- Contrat d’événement (schema) + versioning
- Idempotence côté consumers
- Observabilité (au minimum: logs structurés + métriques)

## Liens avec le CCDAK

- Producer/Consumer configs
- Ordering + partitions
- Offset commits
- (Optionnel) transactions
