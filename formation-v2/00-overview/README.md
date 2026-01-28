# 🎓 Formation Kafka Enterprise - BHF

> **Version 2.0** | Formation auto-rythmée pour développeurs Java & .NET

---

## 📋 Executive Summary

Cette formation **Kafka pour développeurs** est conçue pour les équipes IT de **BHF** souhaitant maîtriser Apache Kafka dans un contexte enterprise. Elle couvre les fondamentaux jusqu'aux patterns avancés, avec une approche **hands-on** via des labs pratiques.

```mermaid
mindmap
  root((Kafka BHF))
    Fondamentaux
      Producers
      Consumers
      Transactions
    Développement
      Patterns DLT
      Kafka Streams
    Intégration
      Connect
      Testing
      Observability
```

---

## 🎯 Objectifs de la formation

À l'issue de cette formation, les participants seront capables de :

| Compétence | Description |
|------------|-------------|
| **Producer Reliability** | Configurer des producers idempotents avec gestion des retries |
| **Consumer Transactions** | Implémenter des consumers avec isolation `read_committed` |
| **Error Handling** | Mettre en place des Dead Letter Topics et stratégies de retry |
| **Stream Processing** | Développer des applications Kafka Streams temps réel |
| **Data Integration** | Déployer et configurer des connecteurs Kafka Connect |
| **Quality Assurance** | Tester les applications Kafka (unit + integration) |
| **Production Readiness** | Monitorer Kafka avec Prometheus et Grafana |

---

## 🗓️ Structure de la formation

```mermaid
gantt
    title Programme de formation (3 jours)
    dateFormat X
    axisFormat %s
    
    section Day 1 - Fondamentaux
    Module 02 - Producer Reliability    :m02, 0, 2
    Module 03 - Consumer Transactions   :m03, 2, 4
    
    section Day 2 - Développement
    Module 04 - Advanced Patterns       :m04, 4, 6
    Module 05 - Kafka Streams           :m05, 6, 8
    
    section Day 3 - Intégration
    Module 06 - Kafka Connect           :m06, 8, 10
    Module 07 - Testing                 :m07, 10, 11
    Module 08 - Observability           :m08, 11, 12
```

### Parcours d'apprentissage

```mermaid
flowchart LR
    subgraph "📅 Day 1: Foundations"
        M02["🔒 M02<br/>Producer<br/>Idempotence"]
        M03["📖 M03<br/>Consumer<br/>Read Committed"]
    end
    
    subgraph "📅 Day 2: Development"
        M04["💀 M04<br/>DLT & Retry<br/>Patterns"]
        M05["🌊 M05<br/>Kafka<br/>Streams"]
    end
    
    subgraph "📅 Day 3: Integration"
        M06["🔌 M06<br/>Kafka<br/>Connect"]
        M07["🧪 M07<br/>Testing"]
        M08["📊 M08<br/>Observability"]
    end
    
    M02 --> M03 --> M04 --> M05 --> M06 --> M07 --> M08
    
    style M02 fill:#e3f2fd
    style M03 fill:#e3f2fd
    style M04 fill:#fff3e0
    style M05 fill:#fff3e0
    style M06 fill:#e8f5e9
    style M07 fill:#e8f5e9
    style M08 fill:#e8f5e9
```

---

## 📚 Détail des modules

### Day 1 - Fondamentaux Kafka

| Module | Titre | Durée | Technologies |
|--------|-------|-------|--------------|
| **M02** | Producer Reliability (Idempotence) | 60-90 min | Java, .NET, Toxiproxy |
| **M03** | Consumer Read Committed | 60-90 min | Java, .NET |

**Compétences acquises :**
- Configuration `enable.idempotence=true`
- Gestion des retries et timeouts
- Transactions Kafka et isolation level
- Callbacks et gestion asynchrone

### Day 2 - Développement avancé

| Module | Titre | Durée | Technologies |
|--------|-------|-------|--------------|
| **M04** | Advanced Patterns (DLT, Retry) | 90-120 min | Spring Kafka, .NET |
| **M05** | Kafka Streams | 90-120 min | Kafka Streams API |

**Compétences acquises :**
- Dead Letter Topic pattern
- Backoff exponentiel
- KStream / KTable
- Windowing et agrégations
- Interactive Queries

### Day 3 - Intégration & Production

| Module | Titre | Durée | Technologies |
|--------|-------|-------|--------------|
| **M06** | Kafka Connect | 60-90 min | Connect REST API |
| **M07** | Testing Kafka Applications | 60 min | JUnit, Testcontainers |
| **M08** | Observability | 60-90 min | Prometheus, Grafana |

**Compétences acquises :**
- Source & Sink Connectors
- MockProducer / MockConsumer
- Tests d'intégration avec Testcontainers
- Métriques JMX et alerting

---

## 🏗️ Architecture technique

```mermaid
flowchart TB
    subgraph "🖥️ Poste développeur"
        VS["VS Code"]
        DC["Docker Desktop"]
    end
    
    subgraph "🐳 Docker Network: bhf-kafka-network"
        subgraph "Infrastructure (infra/)"
            K["📦 Kafka<br/>:9092 / :29092"]
            UI["🖥️ Kafka UI<br/>:8080"]
        end
        
        subgraph "Module APIs"
            JAVA["☕ Java APIs<br/>:18080-18090"]
            DOTNET["🔷 .NET APIs<br/>:18081-18091"]
        end
        
        subgraph "Observability"
            PROM["📊 Prometheus<br/>:9090"]
            GRAF["📈 Grafana<br/>:3000"]
        end
    end
    
    VS --> DC
    DC --> K
    JAVA --> K
    DOTNET --> K
    UI --> K
    PROM --> K
    GRAF --> PROM
```

### Stack technologique

```mermaid
flowchart LR
    subgraph "Backend Java"
        J[Java 17+]
        SB[Spring Boot 3.x]
        SK[Spring Kafka]
        KS[Kafka Streams]
    end
    
    subgraph "Backend .NET"
        N[.NET 8]
        MA[Minimal API]
        CK[Confluent.Kafka]
    end
    
    subgraph "Infrastructure"
        KF[Apache Kafka 3.x]
        KR[KRaft Mode]
        KC[Kafka Connect]
    end
    
    subgraph "DevOps"
        D[Docker]
        DC[Docker Compose]
        P[Prometheus]
        G[Grafana]
    end
```

---

## 💻 Prérequis techniques

### Logiciels requis

| Outil | Version | Installation |
|-------|---------|--------------|
| **VS Code** | Latest | [code.visualstudio.com](https://code.visualstudio.com) |
| **Docker Desktop** | 4.x+ | [docker.com](https://docker.com) |
| **Java JDK** | 17+ | `winget install Microsoft.OpenJDK.17` |
| **Maven** | 3.8+ | `winget install Apache.Maven` |
| **.NET SDK** | 8.0+ | `winget install Microsoft.DotNet.SDK.8` |
| **Git** | Latest | `winget install Git.Git` |

### Extensions VS Code recommandées

```bash
# Java
code --install-extension vscjava.vscode-java-pack
code --install-extension vmware.vscode-boot-dev-pack

# .NET
code --install-extension ms-dotnettools.csharp
code --install-extension ms-dotnettools.csdevkit

# Docker & REST
code --install-extension ms-azuretools.vscode-docker
code --install-extension humao.rest-client
```

### Connaissances préalables

- ✅ Programmation Java ou C#/.NET
- ✅ Concepts REST API
- ✅ Bases Docker (containers, images, compose)
- ✅ Notions de messaging asynchrone

---

## 📂 Structure du repository

```
formation-v2/
├── 00-overview/              # Vue d'ensemble (ce document)
├── infra/                    # Infrastructure Docker partagée
│   └── docker-compose.single-node.yml
│
├── day-01-foundations/       # Jour 1 - Fondamentaux
│   ├── module-02-producer-reliability/
│   │   ├── README.md         # Théorie
│   │   ├── TUTORIAL-JAVA.md  # Lab Java pas-à-pas
│   │   ├── TUTORIAL-DOTNET.md
│   │   ├── java/             # Code source Java
│   │   ├── dotnet/           # Code source .NET
│   │   └── docker-compose.module.yml
│   └── module-03-consumer-read-committed/
│
├── day-02-development/       # Jour 2 - Développement
│   ├── module-04-advanced-patterns/
│   └── module-05-kafka-streams/
│
└── day-03-integration/       # Jour 3 - Intégration
    ├── module-06-kafka-connect/
    ├── module-07-testing/
    └── module-08-observability/
```

---

## 🚀 Quick Start

### 1. Cloner le repository

```powershell
git clone https://github.com/msellamiTN/kafka-bhf.git
cd kafka-bhf/formation-v2
```

### 2. Démarrer l'infrastructure Kafka

```powershell
cd infra
docker-compose -f docker-compose.single-node.yml up -d
```

### 3. Vérifier l'installation

```powershell
# Kafka UI disponible sur http://localhost:8080
curl http://localhost:8080
```

### 4. Commencer le premier module

```powershell
cd ../day-01-foundations/module-02-producer-reliability
# Ouvrir TUTORIAL-JAVA.md ou TUTORIAL-DOTNET.md
```

---

## 📊 Ports de référence

| Service | Port | Description |
|---------|------|-------------|
| Kafka (externe) | 9092 | Bootstrap servers (localhost) |
| Kafka (Docker) | 29092 | Bootstrap servers (containers) |
| Kafka UI | 8080 | Interface web |
| M02 Java API | 18080 | Producer Reliability |
| M02 .NET API | 18081 | Producer Reliability |
| M03 Java API | 18090 | Consumer Read Committed |
| M03 .NET API | 18091 | Consumer Read Committed |
| M04 Java API | 18082 | Advanced Patterns |
| M04 .NET Consumer | 18083 | Advanced Patterns |
| M05 Streams App | 18084 | Kafka Streams |
| Kafka Connect | 8083 | REST API |
| Prometheus | 9090 | Metrics |
| Grafana | 3000 | Dashboards |
| JMX Exporter | 9404 | Kafka JMX Metrics |

---

## 📞 Support

| Contact | Rôle |
|---------|------|
| **Data2AI Academy** | Organisme de formation |
| **Équipe BHF** | Client |

---

## 📜 Licence

© 2024-2026 Data2AI Academy - Formation Kafka Enterprise BHF

---

*Dernière mise à jour : Janvier 2026*
