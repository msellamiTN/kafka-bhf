# 01 — Architecture event-driven (pratique)

## 1) Command vs Event

- **Command**: intention (souvent synchrone), ex: “CréerCommande”
- **Event**: fait accompli (asynchrone), ex: “CommandeCréée”

Dans Kafka, on publie principalement des **events**.

## 2) Topics: comment les choisir

- Un topic par “flux métier” (ex: `orders`, `payments`)
- La clé doit porter l’ordering nécessaire:
  - ex: `orderId` ou `customerId`

## 3) Partitioning et ordering

- Ordering garanti seulement **dans une partition**
- Conséquence: ta **clé** est un choix d’architecture, pas un détail

## 4) Patterns indispensables

- **Idempotent consumer**: accepter la redelivery
- **Outbox pattern** (plus tard): garantir cohérence DB → Kafka
- **DLQ**: isoler les messages “poison”

## 5) Anti-patterns

- “Je mets tout dans un topic `events`”
- “Je change le format JSON sans versionner”
- “Je laisse auto-commit en prod”
