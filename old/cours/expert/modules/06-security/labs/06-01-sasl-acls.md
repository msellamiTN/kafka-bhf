# Lab 06.01 — Sécurité: SASL + ACLs (baseline)

## Objectif

- Démarrer un broker avec SASL
- Exécuter des commandes admin via `--command-config`
- (Option) ajouter des ACLs ciblées

## Pré-requis

- Stack: `docker/security`

## Démarrer

- `docker compose -f docker/security/docker-compose.yml up -d`

## CLI avec authentification

```powershell
docker exec -it kafka kafka-topics --bootstrap-server kafka:9093 --command-config /etc/kafka/client.properties --list
```

## Extension ACL (à faire)

- Ajouter des ACLs pour un principal dédié (ex: `User:app1`)
- Vérifier qu’un accès non autorisé échoue

## Références internes

- Lab CCDAK SASL:
  - `cours/modules/06-securite/labs/06-01-sasl-plain-baseline.md`
- Lab SSO OAuth2 (gateway):
  - `cours/modules/06-securite/labs/06-02-oauth2-sso-gateway.md`
