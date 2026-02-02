# Module 02 - K8s Deployment Scripts

Scripts for deploying and managing Module 02 (Producer Reliability) on Kubernetes/K3s.

## Overview

This module deploys:

- **Java API** - Spring Boot Kafka producer with idempotent mode support
- **.NET API** - ASP.NET Minimal API Kafka producer with idempotent mode support
- **Toxiproxy** - Network proxy for simulating latency and failures

## Prerequisites

- K3s cluster running with Strimzi Kafka operator
- Docker installed for building images
- `kubectl` configured to access the cluster
- Kafka cluster `bhf-kafka` deployed in `kafka` namespace

## Architecture

```text
┌─────────────────────────────────────────────────────────────┐
│                     Kubernetes Cluster                       │
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────┐  │
│  │   Java API      │  │   .NET API      │  │  Toxiproxy  │  │
│  │   NodePort:     │  │   NodePort:     │  │  NodePort:  │  │
│  │   31080         │  │   31081         │  │  31474      │  │
│  └────────┬────────┘  └────────┬────────┘  └──────┬──────┘  │
│           │                    │                   │         │
│           └────────────────────┼───────────────────┘         │
│                                │                             │
│                    ┌───────────▼───────────┐                 │
│                    │   Kafka Bootstrap     │                 │
│                    │   bhf-kafka:9092      │                 │
│                    └───────────────────────┘                 │
└─────────────────────────────────────────────────────────────┘
```

## Scripts

| Script | Description |
| ------ | ----------- |
| `00-full-deploy.sh` | Run complete deployment pipeline (all steps) |
| `01-build-images.sh` | Build Docker images for Java and .NET APIs |
| `02-import-images.sh` | Export and import images into K3s containerd |
| `03-deploy.sh` | Deploy all services to Kubernetes |
| `04-validate.sh` | Validate pods and services are running |
| `05-test-apis.sh` | Test API health and message sending |
| `06-cleanup.sh` | Remove all module resources from cluster |

## Quick Start

### Option 1: Full Pipeline (Recommended)

```bash
cd scripts/k8s
chmod +x *.sh
sudo ./00-full-deploy.sh
```

### Option 2: Step by Step

```bash
cd scripts/k8s
chmod +x *.sh

# 1. Build images
./01-build-images.sh

# 2. Import into K3s (requires sudo)
sudo ./02-import-images.sh

# 3. Deploy
./03-deploy.sh

# 4. Validate
./04-validate.sh

# 5. Test
./05-test-apis.sh
```

## Service Endpoints

| Service | NodePort | Internal Service | Description |
| ------- | -------- | ---------------- | ----------- |
| Java API | 31080 | m02-java-api:8080 | Spring Boot Kafka producer |
| .NET API | 31081 | m02-dotnet-api:8080 | ASP.NET Kafka producer |
| Toxiproxy API | 31474 | toxiproxy:8474 | Toxiproxy management API |
| Toxiproxy Proxy | 32093 | toxiproxy:29093 | Kafka proxy with latency injection |

### API Endpoints

**Health Check:**

```bash
# Java API
curl http://<NODE_IP>:31080/health

# .NET API
curl http://<NODE_IP>:31081/health
```

**Send Message:**

```bash
# Java API - Idempotent mode
curl -X POST "http://<NODE_IP>:31080/api/v1/send?mode=idempotent&sendMode=sync&eventId=TEST-001"

# .NET API - Idempotent mode
curl -X POST "http://<NODE_IP>:31081/api/v1/send?mode=idempotent&sendMode=sync&eventId=TEST-002"

# Plain mode (may duplicate on retry)
curl -X POST "http://<NODE_IP>:31080/api/v1/send?mode=plain&sendMode=sync&eventId=TEST-003"
```

**Expected Response:**

```json
{
  "eventId": "TEST-001",
  "mode": "idempotent",
  "sendMode": "sync",
  "topic": "bhf-transactions",
  "partition": 2,
  "offset": 0
}
```

## Cleanup

```bash
./06-cleanup.sh
```

## Technical Details

### K3s Image Import

K3s uses **containerd** as its container runtime, not Docker. Images built with Docker must be exported and imported into containerd:

```bash
# Export from Docker
sudo docker save m02-java-api:latest -o /tmp/m02-java-api.tar

# Import into K3s containerd
sudo k3s ctr images import /tmp/m02-java-api.tar
```

The `02-import-images.sh` script handles this automatically.

### Image Pull Policy

Manifests use `imagePullPolicy: Never` to prevent Kubernetes from trying to pull images from a registry:

```yaml
containers:
- name: java-api
  image: m02-java-api:latest
  imagePullPolicy: Never
```

### Toxiproxy Health Probes

Toxiproxy uses `/version` endpoint for liveness and readiness probes:

```yaml
livenessProbe:
  httpGet:
    path: /version
    port: 8474
  initialDelaySeconds: 10
  periodSeconds: 10
  failureThreshold: 3
```

## Troubleshooting

### ImagePullBackOff

**Symptom:** Pods show `ImagePullBackOff` or `ErrImagePull` status.

**Cause:** K3s cannot find the image in containerd.

**Solution:**

1. Verify images exist in Docker:

   ```bash
   docker images | grep m02
   ```

2. Re-import into K3s:

   ```bash
   sudo ./02-import-images.sh
   ```

3. Verify in K3s containerd:

   ```bash
   sudo k3s ctr images list | grep m02
   ```

4. Delete and redeploy:

   ```bash
   kubectl delete deployment m02-java-api -n kafka
   kubectl apply -f ../../k8s/m02-java-api.yaml
   ```

### Toxiproxy CrashLoopBackOff

**Symptom:** Toxiproxy pod keeps restarting.

**Cause:** Liveness probe failing (wrong endpoint or timing).

**Solution:**

1. Check logs:

   ```bash
   kubectl logs -n kafka -l app=toxiproxy
   ```

2. Ensure manifest uses `/version` endpoint (not `/list`):

   ```yaml
   livenessProbe:
     httpGet:
       path: /version
       port: 8474
   ```

3. Redeploy:

   ```bash
   kubectl delete deployment toxiproxy -n kafka
   kubectl apply -f ../../k8s/toxiproxy.yaml
   ```

### API Health Check Fails

**Symptom:** `curl http://<IP>:31080/health` returns error.

**Cause:** Pod not ready or service misconfigured.

**Solution:**

1. Check pod status:

   ```bash
   kubectl get pods -n kafka -l app=m02-java-api
   ```

2. Check pod logs:

   ```bash
   kubectl logs -n kafka -l app=m02-java-api
   ```

3. Test from inside cluster:

   ```bash
   kubectl run curl --rm -it --image=curlimages/curl:8.5.0 -n kafka -- \
     curl http://m02-java-api:8080/health
   ```

### IPv6 Address Issues

**Symptom:** Test script shows malformed URLs with IPv6 addresses.

**Cause:** Node has both IPv4 and IPv6 addresses.

**Solution:** The test script automatically extracts only the IPv4 address. If issues persist:

```bash
# Get IPv4 manually
NODE_IP=$(hostname -I | awk '{print $1}')
echo $NODE_IP

# Test directly
curl http://${NODE_IP}:31080/health
```

### Message Send Fails

**Symptom:** API returns error when sending messages.

**Cause:** Kafka cluster not accessible or topic doesn't exist.

**Solution:**

1. Check Kafka cluster:

   ```bash
   kubectl get kafka -n kafka
   ```

2. Check topic exists:

   ```bash
   kubectl get kafkatopic -n kafka | grep bhf-transactions
   ```

3. Create topic if missing:

   ```bash
   kubectl apply -f - <<EOF
   apiVersion: kafka.strimzi.io/v1beta2
   kind: KafkaTopic
   metadata:
     name: bhf-transactions
     namespace: kafka
     labels:
       strimzi.io/cluster: bhf-kafka
   spec:
     partitions: 6
     replicas: 1
   EOF
   ```

## Validation Checklist

After deployment, verify:

- [ ] All pods running: `kubectl get pods -n kafka | grep m02`
- [ ] Services created: `kubectl get svc -n kafka | grep m02`
- [ ] Java API health: `curl http://<NODE_IP>:31080/health`
- [ ] .NET API health: `curl http://<NODE_IP>:31081/health`
- [ ] Toxiproxy version: `curl http://<NODE_IP>:31474/version`
- [ ] Message send works: `./05-test-apis.sh`

## Files Reference

```text
module-02-producer-reliability/
├── k8s/
│   ├── m02-java-api.yaml      # Java API deployment + service
│   ├── m02-dotnet-api.yaml    # .NET API deployment + service
│   ├── toxiproxy.yaml         # Toxiproxy deployment + service
│   └── toxiproxy-init.yaml    # Toxiproxy init job
├── scripts/
│   └── k8s/
│       ├── 00-full-deploy.sh  # Complete pipeline
│       ├── 01-build-images.sh # Build Docker images
│       ├── 02-import-images.sh# Import to K3s
│       ├── 03-deploy.sh       # Deploy to K8s
│       ├── 04-validate.sh     # Validate deployment
│       ├── 05-test-apis.sh    # Test APIs
│       ├── 06-cleanup.sh      # Cleanup resources
│       └── README.md          # This file
├── java/                      # Java API source
└── dotnet/                    # .NET API source
```
