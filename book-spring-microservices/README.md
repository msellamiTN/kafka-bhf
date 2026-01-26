# Mini-livre — Microservices Java/Spring Boot & Kafka (event-driven)

Ce mini-livre accompagne le parcours CCDAK et te fait construire une plateforme **microservices événementiels** (Order/Payment/Inventory) avec Kafka.

## Objectif pédagogique

- Passer de “je sais utiliser Kafka” à “je sais **concevoir** un système event-driven robuste”
- Appliquer:
  - contrats (Schema Registry / Avro)
  - idempotence + exactly-once (quand possible)
  - observabilité
  - tests d’intégration avec Kafka

## Chapitres

- `chapitres/00-introduction.md`
- `chapitres/01-architecture-event-driven.md`
- `chapitres/02-modelisation-evenements.md`
- `chapitres/03-order-service.md`
- `chapitres/04-payment-service.md`
- `chapitres/05-inventory-service.md`
- `chapitres/06-observabilite.md`
- `chapitres/07-tests.md`

## Code

Le squelette de code est dans `code/` (Maven multi-modules).

- `code/pom.xml` (parent)
- `code/order-service/`
- `code/payment-service/`
- `code/inventory-service/`
- `code/common/`

## Pré-requis

- Java 17 recommandé (Java 11 possible, mais Spring Boot 3.x préfère Java 17)
- Docker Desktop

## Note

On reste volontairement “cours”: le but est la compréhension + la pratique, pas l’exhaustivité framework.
