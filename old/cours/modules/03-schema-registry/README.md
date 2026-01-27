# Module 03 — Schema Registry & Avro

## Objectifs

- Comprendre le **problème de schéma** (contrat producer/consumer)
- Déployer **Schema Registry** localement
- Pratiquer la **compatibilité** (BACKWARD/FORWARD/FULL)

## Temps estimé

- 3 à 5 heures

## Pré-requis

- Avoir validé Modules 01–02
- Stack Docker: `docker/schema-registry`

## Labs

- `labs/03-01-schema-registry-deploiement.md`
- `labs/03-02-compatibilite-et-evolution.md`

## Livrables

- Tu sais:
  - lister les subjects,
  - enregistrer un schéma,
  - expliquer une erreur 409 d’incompatibilité.

## Exam tips

- Les questions tournent souvent autour de:
  - “qu’est-ce qu’un breaking change?”
  - différence backward vs forward
  - pourquoi Avro est plus compact que JSON
