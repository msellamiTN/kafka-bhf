# Capstone — Plateforme event-driven “de bout en bout”

## Objectif

Livrer un mini-système complet:

- 1 API Gateway (Spring Cloud Gateway, WebFlux)
- 3 microservices (Order/Payment/Inventory)
- Kafka comme backbone event-driven
- Observabilité (Prometheus/Grafana)
- Sécurité (OAuth2/SSO) + (option) SASL/TLS côté Kafka

## Contraintes (qualité / fiabilité)

- Producer idempotent partout où il y a retry:
  - `enable.idempotence=true`
  - `acks=all`
  - `max.in.flight.requests.per.connection<=5`
- Flux read-process-write:
  - démontrer `read_committed` et les transactions
- Streams:
  - 1 topology en `exactly_once_v2`

## Livrables attendus

- README d’architecture
- Scripts de démo (PowerShell)
- Runbook (start/stop, diagnostics, métriques, incident "duplicates")
