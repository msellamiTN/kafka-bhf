# Lab 12.01 — Failure drills + RPO/RTO checklist

## Objectif

- Exécuter des drills de panne
- Documenter un playbook
- Mesurer RPO/RTO (qualitativement)

## Pré-requis

- Stack multi-broker: `docker/multi-broker`
- Stack multi-cluster (option): `docker/multi-cluster`

## Drills (suggestions)

1. Stopper un broker et vérifier:
   - ISR
   - leadership
   - impact producer/consumer

2. Redémarrer et vérifier:
   - rattrapage
   - stabilité des consumers groups

3. (Option) Multi-cluster:
   - produire dans cluster A
   - vérifier réplication vers cluster B

## Checkpoint

- Définir RPO vs RTO.
- Quels indicateurs regarder pendant le drill?
