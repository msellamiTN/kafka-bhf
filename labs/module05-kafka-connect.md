# Module 5: Kafka Connect (Docker)

## Goal

- Start a Kafka Connect worker
- Deploy a simple connector via the Connect REST API

## Start stack

- Base (Kafka + Connect + UI):
  - `docker compose -f docker/connect/docker-compose.yml up -d`

Optional services:

- Add Postgres (for JDBC labs):
  - `docker compose -f docker/connect/docker-compose.yml --profile jdbc up -d`
- Add Elasticsearch (for sink labs):
  - `docker compose -f docker/connect/docker-compose.yml --profile es up -d`

Endpoints:

- Kafka (host): `localhost:9092`
- Connect REST: `http://localhost:8083`
- Kafka UI: `http://localhost:8080`

## Verify Connect

- `curl http://localhost:8083/`
- `curl http://localhost:8083/connectors`

## Deploy a FileStreamSource connector (built-in)

```powershell
curl -X POST http://localhost:8083/connectors `
  -H "Content-Type: application/json" `
  -d '{
    "name": "file-source-demo",
    "config": {
      "connector.class": "org.apache.kafka.connect.file.FileStreamSourceConnector",
      "tasks.max": "1",
      "topic": "file-source-topic",
      "file": "/tmp/input.txt"
    }
  }'
```

- Check status:
  - `curl http://localhost:8083/connectors/file-source-demo/status`

## Tear down

- `docker compose -f docker/connect/docker-compose.yml down -v`
