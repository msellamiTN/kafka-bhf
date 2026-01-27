# Lab 04.01 — Poison-pill handling + DLQ pattern

## Objectif

- Identifier un message « poison » (non traitable)
- Appliquer un pattern de fiabilité:
  - retry contrôlé
  - puis **DLQ** (dead-letter topic)

## Pré-requis

- Stack: `docker/single-broker`

## Démarrer

- `docker compose -f docker/single-broker/docker-compose.yml up -d`

## Étape 1 — Créer les topics

```powershell
docker exec -it kafka kafka-topics --bootstrap-server localhost:9093 --create --topic payments-in --partitions 3 --replication-factor 1

docker exec -it kafka kafka-topics --bootstrap-server localhost:9093 --create --topic payments-dlq --partitions 3 --replication-factor 1
```

## Étape 2 — Produire un poison message

Exemple (payload invalide):

```powershell
docker exec -it kafka kafka-console-producer --bootstrap-server localhost:9093 --topic payments-in
```

Envoie:

- `{"paymentId":"p-1","amount":100}`
- `INVALID_JSON`

## Étape 3 — Implémentation (à faire)

Dans un consumer Java:

- parser JSON
- si parsing KO:
  - produire dans `payments-dlq`
  - inclure des headers:
    - `error.type`, `error.message`
    - `original.topic`, `original.partition`, `original.offset`
  - commit l’offset uniquement après la mise en DLQ

## Drill CLI

- Lire la DLQ:

```powershell
docker exec -it kafka kafka-console-consumer --bootstrap-server localhost:9093 --topic payments-dlq --from-beginning
```

## Checkpoint (exam style)

1. Pourquoi une DLQ est préférable à un crash en boucle?
2. Quelle stratégie de commit éviter pour ne pas « perdre » un message poison?
