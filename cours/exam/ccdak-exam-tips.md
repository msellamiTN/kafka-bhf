# CCDAK — Exam Tips (stratégie + pièges)

## Ce que l’examen teste vraiment

- Ta capacité à **raisonner** sur:
  - partitions, ordering, consumer groups
  - offset commits
  - configs producer/consumer
  - erreurs et garanties

## Stratégie de préparation (simple et efficace)

- **Semaine 1**: Modules 1–2 (CLI + clients)
- **Semaine 2**: Module 3 (schemas) + Module 7 (exactly-once)
- **Semaine 3**: Streams ou Connect (selon ton profil) + Observabilité
- **Semaine 4**: drills + questions + relecture ciblée

## Pièges classiques

- **Ordering**: garanti uniquement **dans une partition**.
- **Clé**: même clé → même partition (mais seulement si partitioner standard + même nombre de partitions).
- **Auto-commit**: facile à activer, mais source majeure de duplication/perte.
- **`acks=all`**: inutile si `min.insync.replicas` est mal réglé.
- **Idempotence**: `enable.idempotence=true` implique un mode “safe” (ordering + retries):
  - `acks=all`
  - `max.in.flight.requests.per.connection<=5`
- **Rebalance**: les pauses de processing sont normales; ce n’est pas “un bug” par défaut.

## Checklist configs à connaître

- Producer:
  - `acks`
  - `enable.idempotence`
  - `retries`
  - `max.in.flight.requests.per.connection`
  - `linger.ms`, `batch.size`, `compression.type`

- Streams:
  - `processing.guarantee=exactly_once_v2` (EOS recommandé, brokers 2.5+)

- Consumer:
  - `enable.auto.commit`
  - `auto.offset.reset`
  - `max.poll.records`
  - `max.poll.interval.ms`
  - `session.timeout.ms` / `heartbeat.interval.ms`

## Drills recommandés (quotidiens)

- `ressources/drills-cli.md`

## Mini banque de questions (format CCDAK)

### Q1

Tu veux éviter les doublons côté producer lors des retries.

- A) `acks=all`
- B) `enable.idempotence=true`
- C) `retries=0`
- D) `linger.ms=0`

Réponse attendue: **B**.

### Q2

Pourquoi le consumer group lag peut augmenter même si ton app est « healthy »?

- **Indice**: rebalancing, backpressure, processing plus lent que l’ingestion.
