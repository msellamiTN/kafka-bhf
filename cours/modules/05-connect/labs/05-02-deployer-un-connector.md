# Lab 05.02 — Déployer un connector (REST) + diagnostiquer

## Objectif

- Déployer un `FileStreamSourceConnector`
- Vérifier `status` et comprendre la notion de tâche

## Déployer

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

## Vérifier

```powershell
curl http://localhost:8083/connectors
curl http://localhost:8083/connectors/file-source-demo/status
```

## Checkpoint (exam style)

1. Différence entre worker et task?
2. Où sont stockées les configs/offsets/status?
3. Pourquoi Connect est utile vs écrire un consumer “à la main”?
