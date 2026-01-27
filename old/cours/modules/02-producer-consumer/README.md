# Module 02 — Producer & Consumer (Java)

## Objectifs

- Écrire un **producer** fiable (acks, retries, idempotence)
- Écrire un **consumer** robuste (poll loop, commits, rebalancing)
- Comprendre les garanties: at-most-once / at-least-once / (aperçu) exactly-once

## Temps estimé

- 4 à 6 heures

## Pré-requis

- Avoir validé le Module 01
- Stack Docker recommandée: `docker/single-broker`

## Labs

- `labs/02-01-producer-cli-vs-java.md`
- `labs/02-02-consumer-commit-strategies.md`

## Livrables

- Un producer qui:
  - envoie avec `acks=all`,
  - est idempotent,
  - respecte `max.in.flight.requests.per.connection<=5`,
  - journalise `partition/offset`.

- Un consumer qui:
  - commit **après** traitement,
  - gère une erreur non-retriable via une “dead-letter” (topic).

## Exam tips

- Attends-toi à des questions sur:
  - `enable.idempotence`
  - contraintes: `acks=all` + `max.in.flight.requests.per.connection<=5`
  - `acks` vs `min.insync.replicas`
  - auto-commit vs manual commit
  - `auto.offset.reset`
