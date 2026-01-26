# Module 3: Schema Registry & Avro (Docker)

## Goal

- Run Schema Registry alongside Kafka
- Verify Schema Registry API and register schemas

## Start stack

- `docker compose -f docker/schema-registry/docker-compose.yml up -d`

Endpoints:

- Kafka (host): `localhost:9092`
- Schema Registry: `http://localhost:8081`
- Kafka UI: `http://localhost:8080`

## Verify Schema Registry

- Subjects (should be empty initially):
  - `curl http://localhost:8081/subjects`
- Mode:
  - `curl http://localhost:8081/mode`

## Register a demo schema

- Register (example subject: `users-value`):

```powershell
curl -X POST http://localhost:8081/subjects/users-value/versions `
  -H "Content-Type: application/vnd.schemaregistry.v1+json" `
  -d '{"schema":"{\"type\":\"record\",\"name\":\"User\",\"namespace\":\"com.kafkalabs.avro\",\"fields\":[{\"name\":\"userId\",\"type\":\"string\"},{\"name\":\"email\",\"type\":\"string\"}]}"}'
```

- List subjects:
  - `curl http://localhost:8081/subjects`

## Next

- Use your Java/Scala labs from the curriculum with:
  - `bootstrap.servers=localhost:9092`
  - `schema.registry.url=http://localhost:8081`

## Tear down

- `docker compose -f docker/schema-registry/docker-compose.yml down -v`
