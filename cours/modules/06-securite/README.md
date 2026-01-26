# Module 06 — Sécurité (SASL/TLS/ACL)

## Objectifs

- Authentification: **SASL/PLAIN** puis (optionnel) **SCRAM**
- Autorisation: **ACLs** (topics, groups)
- Chiffrement: (optionnel) **TLS**

## Temps estimé

- 4 à 6 heures

## Pré-requis

- Modules 01–02
- Stack Docker: `docker/security`

## Labs

- `labs/06-01-sasl-plain-baseline.md`
- `labs/06-02-oauth2-sso-gateway.md`

## Livrables

- Tu sais exécuter des commandes admin Kafka avec `--command-config`.
- Tu sais expliquer la différence entre:
  - authentification (qui es-tu?)
  - autorisation (as-tu le droit?)

## Exam tips

- Sois à l’aise avec:
  - `security.protocol`
  - `sasl.mechanism`
  - JAAS config
