# Lab 03.02 — Compatibilité & évolution de schéma (exercice guidé)

## Objectif

- Enregistrer une v1
- Faire une v2 compatible
- Provoquer une erreur d’incompatibilité (409)

## Pré-requis

- Stack `docker/schema-registry` démarrée

## Étape 1 — Enregistrer v1

```powershell
curl -X POST http://localhost:8081/subjects/orders-value/versions `
  -H "Content-Type: application/vnd.schemaregistry.v1+json" `
  -d '{"schema":"{\"type\":\"record\",\"name\":\"Order\",\"namespace\":\"com.data2ai\",\"fields\":[{\"name\":\"orderId\",\"type\":\"string\"},{\"name\":\"total\",\"type\":\"double\"}]}"}'
```

## Étape 2 — Lister subjects + récupérer la version

```powershell
curl http://localhost:8081/subjects
curl http://localhost:8081/subjects/orders-value/versions
```

## Étape 3 — Enregistrer v2 (compatible)

Ajouter un champ **optionnel** avec valeur par défaut.

```powershell
curl -X POST http://localhost:8081/subjects/orders-value/versions `
  -H "Content-Type: application/vnd.schemaregistry.v1+json" `
  -d '{"schema":"{\"type\":\"record\",\"name\":\"Order\",\"namespace\":\"com.data2ai\",\"fields\":[{\"name\":\"orderId\",\"type\":\"string\"},{\"name\":\"total\",\"type\":\"double\"},{\"name\":\"currency\",\"type\":\"string\",\"default\":\"EUR\"}]}"}'
```

## Étape 4 — Provoquer un 409 (exemple)

Supprimer un champ requis (breaking change).

```powershell
curl -X POST http://localhost:8081/subjects/orders-value/versions `
  -H "Content-Type: application/vnd.schemaregistry.v1+json" `
  -d '{"schema":"{\"type\":\"record\",\"name\":\"Order\",\"namespace\":\"com.data2ai\",\"fields\":[{\"name\":\"orderId\",\"type\":\"string\"}]}"}'
```

Attendu:

- `error_code: 409`

## Checkpoint (exam style)

1. Pourquoi ajouter un champ avec `default` est souvent BACKWARD compatible?
2. Quelle est la différence entre BACKWARD et FORWARD?
3. Pourquoi Schema Registry évite des incidents prod?
