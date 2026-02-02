# 🐳🚀 Self-Paced Training Labs: Docker Build & Kubernetes Deployment

## 📋 Overview

This self-paced training program focuses on **Docker image building** and **Kubernetes deployment** for .NET Kafka Producer applications. You'll progress through hands-on labs from basic concepts to advanced production scenarios.

### 🎯 Learning Objectives

- **Lab 1**: Master Docker multi-stage builds for .NET applications
- **Lab 2**: Deploy applications to Kubernetes with manifests
- **Lab 3**: Implement production-ready configurations
- **Lab 4**: Advanced K8s patterns and troubleshooting
- **Lab 5**: CI/CD pipeline integration

### 📚 Prerequisites

| Tool | Version | Purpose |
|------|---------|---------|
| **Docker Desktop** | Latest | Build and run containers |
| **kubectl** | Latest | Kubernetes CLI |
| **.NET SDK** | 8.0+ | Build applications |
| **K3s/minikube** | Latest | Local K8s cluster |

---

## 🏗️ Lab 1: Docker Image Building Fundamentals

### 🎯 Objective
Build optimized Docker images for .NET Kafka Producer applications.

### 📋 Lab Steps

#### Step 1.1: Create Base Dockerfile

```bash
# Navigate to your project directory
cd formation-v2/day-01-foundations/module-02-producer-reliability/dotnet/M02ProducerReliability
```

**Exercise**: Create a basic Dockerfile

```dockerfile
# TODO: Create your first Dockerfile
# Hint: Use mcr.microsoft.com/dotnet/sdk:8.0 as base
# Hint: Set WORKDIR to /src
# Hint: Copy .csproj and restore
# Hint: Copy source code and publish
# Hint: Use runtime image for final stage
```

**Validation**: 
```bash
docker build -t m02-dotnet-basic:1.0 .
docker run --rm m02-dotnet-basic:1.0 --version
```

#### Step 1.2: Optimize Multi-Stage Build

**Exercise**: Enhance your Dockerfile with multi-stage optimization

```dockerfile
# TODO: Optimize your Dockerfile
# Requirements:
# - Use separate build and runtime stages
# - Minimize image size (< 100MB)
# - Include health checks
# - Use non-root user
# - Add proper labels
```

**Validation**:
```bash
# Check image size
docker images m02-dotnet-basic:1.0

# Test health check
docker run --rm -p 8080:8080 m02-dotnet-basic:1.0
curl http://localhost:8080/health
```

#### Step 1.3: Production Dockerfile

**Exercise**: Create production-ready Dockerfile

```dockerfile
# TODO: Production Dockerfile with:
# - Security best practices
# - Environment variable configuration
# - Health checks
# - Proper signal handling
# - Optimized layers
```

**Validation**:
```bash
# Security scan
docker run --rm -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy:latest image m02-dotnet-producer:latest

# Performance test
docker run --rm -p 8080:8080 m02-dotnet-producer:latest
ab -n 1000 -c 10 http://localhost:8080/health
```

### ✅ Lab 1 Completion Checklist

- [ ] Basic Dockerfile created and tested
- [ ] Multi-stage build implemented
- [ ] Image size optimized (< 100MB)
- [ ] Health checks functional
- [ ] Security scan passed
- [ ] Performance benchmarked

---

## ☸️ Lab 2: Kubernetes Deployment Fundamentals

### 🎯 Objective
Deploy .NET Kafka Producer to Kubernetes with proper manifests.

### 📋 Lab Steps

#### Step 2.1: Create Basic Kubernetes Manifests

**Exercise**: Create deployment manifest

```yaml
# TODO: Create m02-dotnet-deployment.yaml
# Requirements:
# - Use m02-dotnet-producer:latest image
# - Set replicas to 1
# - Configure port 8080
# - Add environment variables
# - Include resource limits
```

**Validation**:
```bash
kubectl apply -f m02-dotnet-deployment.yaml
kubectl get pods -l app=m02-dotnet
kubectl logs -f deployment/m02-dotnet
```

#### Step 2.2: Create Service Manifest

**Exercise**: Create service for your deployment

```yaml
# TODO: Create m02-dotnet-service.yaml
# Requirements:
# - Type: NodePort (for local access)
# - Target port: 8080
# - NodePort: 31081
# - Select app: m02-dotnet
```

**Validation**:
```bash
kubectl apply -f m02-dotnet-service.yaml
kubectl get svc m02-dotnet
# Test access
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[0].address}')
curl http://$NODE_IP:31081/health
```

#### Step 2.3: ConfigMap and Secrets

**Exercise**: Externalize configuration

```yaml
# TODO: Create m02-dotnet-config.yaml
# Requirements:
# - ConfigMap for Kafka bootstrap servers
# - Secret for sensitive data
# - Mount configuration as environment variables
```

**Validation**:
```bash
kubectl apply -f m02-dotnet-config.yaml
kubectl describe configmap m02-dotnet-config
kubectl describe secret m02-dotnet-secrets
```

### ✅ Lab 2 Completion Checklist

- [ ] Deployment manifest created
- [ ] Service configured and accessible
- [ ] ConfigMap for configuration
- [ ] Secrets for sensitive data
- [ ] Application running successfully
- [ ] Health endpoint accessible

---

## 🚀 Lab 3: Production-Ready Kubernetes

### 🎯 Objective
Implement production-grade Kubernetes configurations.

### 📋 Lab Steps

#### Step 3.1: Resource Management

**Exercise**: Add resource requests and limits

```yaml
# TODO: Update deployment with resources
# Requirements:
# - CPU request: 100m
# - CPU limit: 500m
# - Memory request: 128Mi
# - Memory limit: 512Mi
# - Add HPA (Horizontal Pod Autoscaler)
```

**Validation**:
```bash
kubectl apply -f m02-dotnet-hpa.yaml
kubectl get hpa
kubectl top pods
```

#### Step 3.2: Health Probes

**Exercise**: Add liveness and readiness probes

```yaml
# TODO: Add probes to deployment
# Requirements:
# - Liveness probe: /health, 30s interval
# - Readiness probe: /health, 10s interval
# - Startup probe: /health, 60s timeout
# - Proper failure thresholds
```

**Validation**:
```bash
kubectl describe pod m02-dotnet-xxx
kubectl get events --field-selector involvedObject.name=m02-dotnet-xxx
```

#### Step 3.3: Network Policies

**Exercise**: Implement network security

```yaml
# TODO: Create network policy
# Requirements:
# - Allow ingress from namespace
# - Allow egress to Kafka
# - Deny all other traffic
# - Apply proper labels
```

**Validation**:
```bash
kubectl apply -f m02-dotnet-networkpolicy.yaml
kubectl get networkpolicy
# Test connectivity
```

### ✅ Lab 3 Completion Checklist

- [ ] Resource limits configured
- [ ] HPA implemented
- [ ] Health probes configured
- [ ] Network policies applied
- [ ] Security hardening complete
- [ ] Monitoring metrics available

---

## 🔧 Lab 4: Advanced Kubernetes Patterns

### 🎯 Objective
Master advanced K8s patterns for Kafka applications.

### 📋 Lab Steps

#### Step 4.1: Init Containers

**Exercise**: Add init container for Kafka connectivity

```yaml
# TODO: Add init container
# Requirements:
# - Wait for Kafka to be ready
# - Test Kafka connectivity
# - Use busybox or alpine image
# - Proper retry logic
```

**Validation**:
```bash
kubectl apply -f m02-dotnet-with-init.yaml
kubectl logs m02-dotnet-xxx -c init-kafka
```

#### Step 4.2: Sidecar Pattern

**Exercise**: Add logging sidecar

```yaml
# TODO: Add sidecar container
# Requirements:
# - Fluentd or filebeat sidecar
# - Share volume with main container
# - Forward logs to output
# - Proper resource limits
```

**Validation**:
```bash
kubectl logs m02-dotnet-xxx -c logger
kubectl exec m02-dotnet-xxx -c main -- ls /var/log/app
```

#### Step 4.3: Rolling Updates

**Exercise**: Implement zero-downtime deployment

```bash
# TODO: Test rolling update
# Requirements:
# - Update image to new version
# - Configure rolling update strategy
# - Set maxUnavailable and maxSurge
# - Monitor update progress
```

**Validation**:
```bash
kubectl set image deployment/m02-dotnet m02-dotnet=m02-dotnet:2.0
kubectl rollout status deployment/m02-dotnet
kubectl rollout history deployment/m02-dotnet
```

### ✅ Lab 4 Completion Checklist

- [ ] Init containers implemented
- [ ] Sidecar pattern working
- [ ] Rolling updates tested
- [ ] Zero-downtime deployment
- [ ] Backup and restore procedures
- [ ] Disaster recovery tested

---

## 🔄 Lab 5: CI/CD Integration

### 🎯 Objective
Build complete CI/CD pipeline for Docker and K8s.

### 📋 Lab Steps

#### Step 5.1: GitHub Actions Workflow

**Exercise**: Create CI/CD pipeline

```yaml
# TODO: Create .github/workflows/docker-k8s.yml
# Requirements:
# - Build Docker image on push
# - Run security scans
# - Deploy to staging environment
# - Run integration tests
# - Deploy to production on tag
```

**Validation**:
```bash
# Push to trigger workflow
git push origin feature/ci-cd
# Check Actions tab in GitHub
```

#### Step 5.2: Helm Charts

**Exercise**: Create Helm chart for application

```bash
# TODO: Create Helm chart structure
# Requirements:
# - Chart.yaml with metadata
# - Values.yaml with configuration
# - Templates for deployment, service, configmap
# - Helper functions
```

**Validation**:
```bash
helm install m02-dotnet ./helm/m02-dotnet
helm test m02-dotnet
helm upgrade m02-dotnet ./helm/m02-dotnet --set image.tag=2.0
```

#### Step 5.3: ArgoCD Integration

**Exercise**: GitOps with ArgoCD

```yaml
# TODO: Create ArgoCD application
# Requirements:
# - Git repository source
# - Sync policy
# - Health checks
# - Auto-sync configuration
```

**Validation**:
```bash
kubectl apply -f argocd-application.yaml
argocd app get m02-dotnet
argocd app sync m02-dotnet
```

### ✅ Lab 5 Completion Checklist

- [ ] CI/CD pipeline working
- [ ] Automated security scans
- [ ] Helm charts created
- [ ] GitOps implemented
- [ ] Automated deployments
- [ ] Rollback procedures tested

---

## 📊 Final Assessment

### 🎯 Capstone Project

**Objective**: Deploy complete production-ready Kafka Producer system

**Requirements**:
1. Multi-stage Docker build with security scanning
2. Production K8s deployment with monitoring
3. CI/CD pipeline with automated testing
4. GitOps deployment with ArgoCD
5. Documentation and runbooks

**Validation**:
```bash
# Complete deployment test
./scripts/deploy-production.sh
./scripts/validate-production.sh
./scripts/load-test.sh
```

### 🏆 Certification Criteria

| Skill | Required | Evidence |
|-------|-----------|----------|
| **Docker** | Image optimization | Size < 100MB, security scan pass |
| **Kubernetes** | Production deployment | HA, monitoring, security |
| **CI/CD** | Automated pipeline | GitHub Actions working |
| **GitOps** | Infrastructure as code | ArgoCD sync successful |
| **Monitoring** | Observability | Metrics, logs, alerts |

---

## 🛠️ Troubleshooting Guide

### Common Docker Issues

| Issue | Solution | Command |
|-------|----------|---------|
| **Build fails** | Check Dockerfile syntax | `docker build --no-cache` |
| **Image too large** | Optimize layers | `docker history` |
| **Port conflicts** | Use different ports | `docker ps` |

### Common Kubernetes Issues

| Issue | Solution | Command |
|-------|----------|---------|
| **Pod pending** | Check resources | `kubectl describe pod` |
| **Service not accessible** | Check endpoints | `kubectl get endpoints` |
| **Image pull error** | Check image name | `kubectl get events` |

---

## 📚 Additional Resources

### Documentation
- [Docker Best Practices](https://docs.docker.com/develop/dev-best-practices/)
- [Kubernetes Documentation](https://kubernetes.io/docs/)
- [.NET Containerization](https://docs.microsoft.com/dotnet/core/docker/)

### Tools
- [Docker Desktop](https://www.docker.com/products/docker-desktop/)
- [Lens K8s IDE](https://k8slens.dev/)
- [Octant](https://github.com/vmware-tanzu/octant)

### Communities
- [Docker Community](https://www.docker.com/community)
- [Kubernetes Community](https://kubernetes.io/community/)
- [.NET K8s SIG](https://github.com/dotnet/dotnet-docker)

---

## 🎓 Next Steps

After completing these labs, you'll be ready for:

1. **Advanced Kafka Patterns**: Transactions, exactly-once
2. **Service Mesh**: Istio, Linkerd integration
3. **Monitoring**: Prometheus, Grafana, OpenTelemetry
4. **Security**: RBAC, Network Policies, Secrets Management
5. **Multi-Cluster**: Federation, disaster recovery

**🚀 Congratulations on completing the Docker & Kubernetes training labs!**