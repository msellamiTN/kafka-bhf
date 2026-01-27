# Lab 04.01 — Kafka Streams: WordCount (intro)

## Objectif

- Écrire une topology WordCount
- Démarrer l’app localement
- (Option) activer EOS v2

## Pré-requis

- Stack Kafka locale (ex: `docker/single-broker`)

## Démarrer Kafka

- `docker compose -f docker/single-broker/docker-compose.yml up -d`

## Exercice (à faire)

Dans le mini-projet Java:

- Lire `input-topic`
- Transformer en mots
- Agréger en comptage
- Écrire dans `output-topic`

## Config EOS v2 (option)

- `processing.guarantee=exactly_once_v2`

## Checkpoint

1. STREAM vs TABLE?
2. Pourquoi EOS a un coût?
