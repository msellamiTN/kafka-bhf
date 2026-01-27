# Programme Expert Developer (Apache Kafka) — 13 modules (80–100h)

Ce parcours complète le dossier `cours/` (orienté CCDAK) avec un **programme Expert Developer** structuré en 4 phases.

## Principes clés (non négociables)

- Le producer **idempotent** est un socle de fiabilité:
  - `enable.idempotence=true`
  - contraintes associées (ordering + sécurité sur retries):
    - `acks=all`
    - `max.in.flight.requests.per.connection<=5`
- Kafka Streams EOS recommandé: `processing.guarantee=exactly_once_v2` (brokers 2.5+)

## Organisation

- **Phase 1 — Foundations (Modules 1–3)**
- **Phase 2 — Core Development (Modules 4–6)**
- **Phase 3 — Advanced Processing (Modules 7–10)**
- **Phase 4 — Production Operations (Modules 11–13)**

## Table des modules

- **01 — Kafka architecture & core concepts (6–8h)**
  - `modules/01-architecture/`
- **02 — Producers in depth (6–8h)**
  - `modules/02-producers/`
- **03 — Consumers & consumer groups (8–10h)**
  - `modules/03-consumers/`
- **04 — Advanced partitioning & reliability patterns (6–8h)**
  - `modules/04-partitioning-reliability/`
- **05 — Kafka Connect (integration) (8–10h)**
  - `modules/05-connect/`
- **06 — Security & authentication (10–12h)**
  - `modules/06-security/`
- **07 — Transactions & exactly-once (EOS) (8–10h)**
  - `modules/07-transactions-eos/`
- **08 — Kafka Streams (stream processing) (12–14h)**
  - `modules/08-streams/`
- **09 — Performance tuning (10–12h)**
  - `modules/09-performance/`
- **10 — Monitoring & observability (8–10h)**
  - `modules/10-monitoring/`
- **11 — Kubernetes & cloud deployment (12–14h)**
  - `modules/11-kubernetes/`
- **12 — Disaster recovery & high availability (10–12h)**
  - `modules/12-disaster-recovery/`
- **13 — Enterprise patterns & architecture (14–16h)**
  - `modules/13-enterprise-patterns/`

## Capstone

- `capstone/README.md`
