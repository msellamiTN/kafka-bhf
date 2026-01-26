# Lab 02.02 — Consumer: stratégies de commit (auto vs manuel)

## Objectif

- Comprendre les risques de l’auto-commit
- Mettre en place un commit manuel “après traitement”

## Pré-requis

- Stack: `docker/single-broker`
- Un topic avec des messages: `lab02-events` (cf. Lab 02.01)

## Partie A — Observer auto-commit

But: constater que l’auto-commit peut committer *avant* la fin du traitement.

- (À implémenter en Java)
  - `enable.auto.commit=true`
  - simuler un traitement lent + crash

## Partie B — Commit manuel

- (À implémenter en Java)
  - `enable.auto.commit=false`
  - `commitSync()` après traitement

## Drill CLI — lire le lag

- Créer un groupe via console consumer:
  - `docker exec -it kafka kafka-console-consumer --topic lab02-events --bootstrap-server localhost:9093 --group lab02-group --from-beginning`

- Dans un autre terminal:
  - `docker exec -it kafka kafka-consumer-groups --bootstrap-server localhost:9093 --group lab02-group --describe`

## Checkpoint

1. Auto-commit = at-most-once ou at-least-once?
2. Quand préférer `commitAsync()`?
3. Quel lien entre rebalancing et commits?
