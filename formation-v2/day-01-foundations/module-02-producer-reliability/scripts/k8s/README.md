# Module 02 - K8s Deployment Scripts

Scripts for deploying and managing Module 02 (Producer Reliability) on Kubernetes/K3s.

## Prerequisites

- K3s cluster running with Strimzi Kafka operator
- Docker installed for building images
- `kubectl` configured to access the cluster
- Kafka cluster `bhf-kafka` deployed in `kafka` namespace

## Scripts

| Script | Description |
|--------|-------------|
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
./00-full-deploy.sh
```

### Option 2: Step by Step

```bash
cd scripts/k8s
chmod +x *.sh

# 1. Build images
./01-build-images.sh

# 2. Import into K3s
./02-import-images.sh

# 3. Deploy
./03-deploy.sh

# 4. Validate
./04-validate.sh

# 5. Test
./05-test-apis.sh
```

## Service Endpoints

| Service | NodePort | URL |
|---------|----------|-----|
| Java API | 31080 | http://localhost:31080 |
| .NET API | 31081 | http://localhost:31081 |
| Toxiproxy API | 31474 | http://localhost:31474 |
| Toxiproxy Proxy | 32093 | http://localhost:32093 |

## Cleanup

```bash
./06-cleanup.sh
```

## Troubleshooting

### ImagePullBackOff

If pods show `ImagePullBackOff`:
1. Ensure images are built: `docker images | grep m02`
2. Re-run import: `./02-import-images.sh`
3. Verify in K3s: `sudo k3s ctr images list | grep m02`

### Pods not starting

Check pod logs:
```bash
kubectl logs -n kafka -l app=m02-java-api
kubectl logs -n kafka -l app=m02-dotnet-api
kubectl describe pod -n kafka -l app=m02-java-api
```

### API not responding

1. Check pod is running: `kubectl get pods -n kafka`
2. Check service: `kubectl get svc -n kafka | grep m02`
3. Test from inside cluster:
   ```bash
   kubectl run curl --rm -it --image=curlimages/curl:8.5.0 -- curl http://m02-java-api:8080/health
   ```
