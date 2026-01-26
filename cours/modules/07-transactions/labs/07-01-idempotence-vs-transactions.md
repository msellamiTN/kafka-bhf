# Lab 07.01 — Idempotence vs Transactions (guidé)

## Objectif

- Distinguer précisément:
  - idempotence (anti-doublons sur retries)
  - transactions (exactly-once read-process-write)

## Rappel (idempotence)

- `enable.idempotence=true`
- contraintes:
  - `acks=all`
  - `max.in.flight.requests.per.connection<=5`

## Rappel (transactions)

- `transactional.id=...`
- consumer:
  - `isolation.level=read_committed`

## Exercice (à faire)

- Implémenter un pipeline:
  - consume `input`
  - process
  - produce `output`
  - commit offsets dans la transaction

## Checkpoint

1. Dans quel cas l’idempotence ne suffit pas?
2. Pourquoi `read_committed` côté consumer?
