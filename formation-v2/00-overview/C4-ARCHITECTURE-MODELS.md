# 🏗️ C4 Models : Architecture Kafka Microservices

> Documentation d'architecture avec **C4 Model** pour les microservices .NET avec Apache Kafka

---

## 📋 Contexte

Les **C4 Models** (Context, Containers, Components, Code) fournissent une approche structurée pour documenter l'architecture logicielle. Ce guide applique C4 aux architectures **microservices .NET + Kafka**.

---

## 🌍 Level 1 : Context Diagram

```mermaid
flowchart TB
    subgraph External["External Systems"]
        WEB["Web Application"]
        MOBILE["Mobile App"]
        PARTNER["Partner Systems"]
        LEGACY["Legacy Systems"]
    end
    
    subgraph Banking["Banking System"]
        KAFKA["Apache Kafka"]
        SERVICES[".NET Microservices"]
        DB["SQL Server"]
    end
    
    WEB -->|HTTP/REST| SERVICES
    MOBILE -->|HTTP/REST| SERVICES
    PARTNER -->|HTTP/REST| SERVICES
    LEGACY -->|CDC| KAFKA
    
    SERVICES -->|Events| KAFKA
    SERVICES -->|Query/Write| DB
    KAFKA -->|Events| SERVICES
    
    style KAFKA fill:#ff6b6b
    style SERVICES fill:#4ecdc4
    style DB fill:#45b7d1
```

### Description

Le **Banking System** est une architecture **event-driven** composée de :
- **Apache Kafka** : Bus d'événements central
- **.NET Microservices** : Services métier
- **SQL Server** : Base de données principale
- **External Systems** : Applications clientes et partenaires

---

## 📦 Level 2 : Container Diagram

```mermaid
flowchart TB
    subgraph Kubernetes["☸️ Kubernetes Cluster"]
        subgraph Ingress["🌐 Ingress Layer"]
            INGRESS["Nginx Ingress"]
        end
        
        subgraph Services["☁️ Microservices"]
            ORDER["🛒 Order Service<br/>.NET 8<br/>Port: 8080"]
            PAYMENT["💳 Payment Service<br/>.NET 8<br/>Port: 8081"]
            NOTIFICATION["📧 Notification Service<br/>.NET 8<br/>Port: 8082"]
            ANALYTICS["📊 Analytics Service<br/>.NET 8<br/>Port: 8083"]
        end
        
        subgraph Data["🗄️ Data Layer"]
            KAFKA["📦 Apache Kafka<br/>3 brokers<br/>Port: 9092"]
            SQLSERVER["🗄️ SQL Server<br/>Port: 1433"]
            REDIS["🔴 Redis Cache<br/>Port: 6379"]
        end
        
        subgraph Infrastructure["🔧 Infrastructure"]
            MONITOR["📊 Prometheus + Grafana"]
            LOGGING["📝 ELK Stack"]
        end
    end
    
    subgraph External["🌍 External"]
        WEB["🌐 Web App"]
        MOBILE["📱 Mobile App"]
        PARTNER["🤝 Partner API"]
    end
    
    WEB -->|HTTPS| INGRESS
    MOBILE -->|HTTPS| INGRESS
    PARTNER -->|HTTPS| INGRESS
    
    INGRESS -->|HTTP| ORDER
    INGRESS -->|HTTP| PAYMENT
    INGRESS -->|HTTP| NOTIFICATION
    INGRESS -->|HTTP| ANALYTICS
    
    ORDER -->|Events| KAFKA
    PAYMENT -->|Events| KAFKA
    NOTIFICATION -->|Events| KAFKA
    ANALYTICS -->|Events| KAFKA
    
    ORDER -->|Query/Write| SQLSERVER
    PAYMENT -->|Query/Write| SQLSERVER
    ANALYTICS -->|Read| SQLSERVER
    
    ORDER -->|Cache| REDIS
    PAYMENT -->|Cache| REDIS
    
    ORDER -->|Metrics| MONITOR
    PAYMENT -->|Metrics| MONITOR
    KAFKA -->|Metrics| MONITOR
    
    ORDER -->|Logs| LOGGING
    PAYMENT -->|Logs| LOGGING
    KAFKA -->|Logs| LOGGING
    
    style KAFKA fill:#ff6b6b
    style SQLSERVER fill:#45b7d1
    style REDIS fill:#dc382d
    style ORDER fill:#4ecdc4
    style PAYMENT fill:#4ecdc4
    style NOTIFICATION fill:#4ecdc4
    style ANALYTICS fill:#4ecdc4
```

### Description des Containers

| Container | Technologie | Responsabilité | Interfaces |
|-----------|-------------|----------------|------------|
| **Order Service** | .NET 8 Web API | Gestion des commandes | REST API, Kafka Producer/Consumer |
| **Payment Service** | .NET 8 Web API | Traitement des paiements | REST API, Kafka Producer/Consumer |
| **Notification Service** | .NET 8 Web API | Envoi de notifications | REST API, Kafka Consumer |
| **Analytics Service** | .NET 8 Web API | Analyse de données | REST API, Kafka Consumer |
| **Apache Kafka** | Kafka 3.x | Bus d'événements | TCP:9092 |
| **SQL Server** | SQL Server 2022 | Persistance des données | TCP:1433 |
| **Redis** | Redis 7.x | Cache distribué | TCP:6379 |

---

## 🧩 Level 3 : Component Diagram - Order Service

```mermaid
flowchart TB
    subgraph OrderService["🛒 Order Service (.NET 8)"]
        subgraph API["🌐 API Layer"]
            CONTROLLER["OrderController<br/>REST Endpoints"]
        end
        
        subgraph Business["⚙️ Business Layer"]
            ORDER_SERVICE["OrderService<br/>Business Logic"]
            VALIDATOR["OrderValidator<br/>Validation Rules"]
        end
        
        subgraph Data["🗄️ Data Layer"]
            REPOSITORY["OrderRepository<br/>EF Core"]
            OUTBOX["OutboxProcessor<br/>Event Sourcing"]
        end
        
        subgraph Messaging["📦 Messaging Layer"]
            KAFKA_PRODUCER["KafkaProducer<br/>Event Publishing"]
            KAFKA_CONSUMER["KafkaConsumer<br/>Event Consumption"]
        end
        
        subgraph Infrastructure["🔧 Infrastructure"]
            LOGGER["ILogger"]
            METRICS["IMetrics"]
            CACHE["IDistributedCache"]
        end
    end
    
    subgraph External["🌍 External Systems"]
        KAFKA["📦 Apache Kafka"]
        SQLSERVER["🗄️ SQL Server"]
        REDIS["🔴 Redis Cache"]
    end
    
    CONTROLLER --> ORDER_SERVICE
    ORDER_SERVICE --> VALIDATOR
    ORDER_SERVICE --> REPOSITORY
    ORDER_SERVICE --> OUTBOX
    ORDER_SERVICE --> KAFKA_PRODUCER
    KAFKA_CONSUMER --> ORDER_SERVICE
    
    REPOSITORY --> SQLSERVER
    OUTBOX --> KAFKA_PRODUCER
    KAFKA_PRODUCER --> KAFKA
    KAFKA_CONSUMER --> KAFKA
    CACHE --> REDIS
    
    ORDER_SERVICE --> LOGGER
    ORDER_SERVICE --> METRICS
    ORDER_SERVICE --> CACHE
    
    style CONTROLLER fill:#e1f5fe
    style ORDER_SERVICE fill:#f3e5f5
    style REPOSITORY fill:#e8f5e8
    style KAFKA_PRODUCER fill:#fff3e0
    style KAFKA_CONSUMER fill:#fff3e0
```

### Description des Components

| Component | Type | Responsabilité | Technologies |
|-----------|------|----------------|--------------|
| **OrderController** | API | Expose REST endpoints | ASP.NET Core, Swagger |
| **OrderService** | Business | Logique métier des commandes | C#, Dependency Injection |
| **OrderValidator** | Business | Validation des règles métier | FluentValidation |
| **OrderRepository** | Data | Accès aux données | Entity Framework Core |
| **OutboxProcessor** | Data | Pattern Outbox pour cohérence | EF Core, BackgroundService |
| **KafkaProducer** | Messaging | Publication d'événements | Confluent.Kafka |
| **KafkaConsumer** | Messaging | Consommation d'événements | Confluent.Kafka |

---

## 💻 Level 4 : Code Diagram - Order Processing Flow

```mermaid
sequenceDiagram
    participant Client as Client App
    participant API as OrderController
    participant Service as OrderService
    participant Validator as OrderValidator
    participant Repo as OrderRepository
    participant Outbox as OutboxProcessor
    participant Kafka as KafkaProducer
    participant DB as SQL Server
    participant Cache as Redis
    
    Client->>API: POST /api/orders
    API->>Service: CreateOrderAsync(request)
    Service->>Validator: Validate(order)
    Validator-->>Service: ValidationResult
    
    alt Validation OK
        Service->>Repo: AddAsync(order)
        Repo->>DB: INSERT INTO Orders
        DB-->>Repo: OrderId
        Repo-->>Service: order with Id
        
        Service->>Outbox: SaveEvent(OrderCreated)
        Outbox->>DB: INSERT INTO Outbox
        DB-->>Outbox: EventId
        
        Service->>Cache: SetAsync($"order:{orderId}", order)
        Cache-->>Service: OK
        
        Service-->>API: OrderResponse
        API-->>Client: 201 Created + OrderId
        
        Note over Outbox: Background processing
        Outbox->>Kafka: Publish event
        Kafka->>Kafka: banking.orders.created
    else Validation Failed
        Service-->>API: ValidationException
        API-->>Client: 400 Bad Request
    end
```

### Code Structure

```csharp
// Controllers/OrderController.cs
[ApiController]
[Route("api/[controller]")]
public class OrderController : ControllerBase
{
    private readonly IOrderService _orderService;
    
    [HttpPost]
    public async Task<ActionResult<OrderResponse>> CreateOrder(CreateOrderRequest request)
    {
        var order = await _orderService.CreateOrderAsync(request);
        return CreatedAtAction(nameof(GetOrder), new { id = order.Id }, order);
    }
}

// Services/OrderService.cs
public class OrderService : IOrderService
{
    private readonly IOrderRepository _repository;
    private readonly IOrderValidator _validator;
    private readonly IKafkaProducer _kafkaProducer;
    private readonly IDistributedCache _cache;
    
    public async Task<Order> CreateOrderAsync(CreateOrderRequest request)
    {
        var order = new Order(request);
        await _validator.ValidateAsync(order);
        
        var savedOrder = await _repository.AddAsync(order);
        
        // Outbox pattern
        var orderCreatedEvent = new OrderCreatedEvent(savedOrder);
        await _kafkaProducer.PublishAsync("banking.orders.created", orderCreatedEvent);
        
        // Cache
        await _cache.SetAsync($"order:{savedOrder.Id}", savedOrder);
        
        return savedOrder;
    }
}
```

---

## 🔄 Architecture Patterns

### 1. Event-Driven Architecture

```mermaid
flowchart LR
    subgraph Command["Command Side"]
        ORDER["Order Service"]
        PAYMENT["Payment Service"]
    end
    
    subgraph Events["📦 Event Bus (Kafka)"]
        CREATED["order.created"]
        PAID["order.paid"]
        FAILED["payment.failed"]
    end
    
    subgraph Query["Query Side"]
        NOTIFICATION["Notification Service"]
        ANALYTICS["Analytics Service"]
    end
    
    ORDER -->|publish| CREATED
    PAYMENT -->|publish| PAID
    PAYMENT -->|publish| FAILED
    
    CREATED -->|subscribe| PAYMENT
    CREATED -->|subscribe| NOTIFICATION
    PAID -->|subscribe| NOTIFICATION
    PAID -->|subscribe| ANALYTICS
    FAILED -->|subscribe| NOTIFICATION
```

### 2. Outbox Pattern

```mermaid
sequenceDiagram
    participant Service as Order Service
    participant DB as SQL Server
    participant Outbox as Outbox Processor
    participant Kafka as Apache Kafka
    
    Service->>DB: BEGIN TRANSACTION
    Service->>DB: INSERT INTO Orders
    Service->>DB: INSERT INTO OutboxEvents
    Service->>DB: COMMIT
    
    Note over Outbox: Background thread
    Outbox->>DB: SELECT * FROM OutboxEvents WHERE ProcessedAt IS NULL
    Outbox->>Kafka: PUBLISH events
    Outbox->>DB: UPDATE OutboxEvents SET ProcessedAt = NOW()
```

### 3. Saga Pattern

```mermaid
flowchart TB
    subgraph Saga["Order Saga"]
        CREATE["Create Order"]
        RESERVE["Reserve Inventory"]
        PROCESS["Process Payment"]
        CONFIRM["Confirm Order"]
        COMPENSATE["Compensate Actions"]
    end
    
    CREATE --> RESERVE
    RESERVE --> PROCESS
    PROCESS --> CONFIRM
    
    CREATE -.->|failure| COMPENSATE
    RESERVE -.->|failure| COMPENSATE
    PROCESS -.->|failure| COMPENSATE
    
    style CONFIRM fill:#4caf50
    style COMPENSATE fill:#f44336
```

---

## 📊 Architecture Decision Records (ADRs)

### ADR-001: Choix de Kafka comme Event Bus

**Status**: Accepted  
**Date**: 2024-02-05

**Context**
- Besoin d'un bus d'événements scalable
- Support du replay des événements
- Intégration avec .NET ecosystem

**Decision**
- Apache Kafka comme bus d'événements principal
- Confluent.Kafka comme client .NET
- Topics par type d'événement

**Consequences**
- ✅ Scalabilité horizontale
- ✅ Persistance des événements
- ✅ Multiple consumers
- ❌ Complexité opérationnelle

### ADR-002: Architecture Microservices avec .NET 8

**Status**: Accepted  
**Date**: 2024-02-05

**Context**
- Migration d'une architecture monolithique
- Besoin d'évolutivité et de résilience
- Équipe .NET expérimentée

**Decision**
- .NET 8 comme framework principal
- Conteneurs Docker + Kubernetes
- Communication via REST + Events

**Consequences**
- ✅ Performance et modernité
- ✅ Écosystème .NET riche
- ❌ Courbe d'apprentissage Kubernetes

---

## 🔍 Architecture Views

### 1. Deployment View

```mermaid
flowchart TB
    subgraph Prod["Production Environment"]
        subgraph K8s["Kubernetes Cluster"]
            subgraph NS1["banking-prod"]
                SVC1["Order Service"]
                SVC2["Payment Service"]
            end
            subgraph NS2["kafka-prod"]
                KAFKA["Kafka Cluster"]
            end
            subgraph NS3["data-prod"]
                DB["SQL Server"]
            end
        end
    end
    
    subgraph Staging["Staging Environment"]
        subgraph K8s2["Kubernetes Cluster"]
            subgraph NS4["banking-staging"]
                SVC1_STG["Order Service"]
                SVC2_STG["Payment Service"]
            end
        end
    end
    
    style KAFKA fill:#ff6b6b
    style DB fill:#45b7d1
```

### 2. Data Flow View

```mermaid
flowchart LR
    subgraph Input["Data Input"]
        USER["User Actions"]
        SYSTEM["System Events"]
    end
    
    subgraph Process["Processing"]
        API["API Gateway"]
        SERVICES["Microservices"]
        KAFKA["Event Bus"]
    end
    
    subgraph Storage["Data Storage"]
        SQL["SQL Server"]
        CACHE["Redis"]
        SEARCH["Elasticsearch"]
    end
    
    subgraph Output["Data Output"]
        NOTIFICATIONS["Notifications"]
        ANALYTICS["Analytics"]
        REPORTS["Reports"]
    end
    
    USER --> API
    SYSTEM --> KAFKA
    API --> SERVICES
    KAFKA --> SERVICES
    
    SERVICES --> SQL
    SERVICES --> CACHE
    SERVICES --> SEARCH
    
    SERVICES --> NOTIFICATIONS
    SERVICES --> ANALYTICS
    SERVICES --> REPORTS
```

---

## 📋 Architecture Checklist

### ✅ Microservices Design
- [ ] Single Responsibility Principle
- [ ] Loose Coupling
- [ ] High Cohesion
- [ ] API First Design
- [ ] Event-Driven Communication

### ✅ Data Management
- [ ] Database per Service
- [ ] Outbox Pattern
- [ ] Event Sourcing (si nécessaire)
- [ ] Data Consistency Strategy
- [ ] Backup & Recovery

### ✅ Kafka Integration
- [ ] Topic Naming Convention
- [ ] Schema Registry
- [ ] Error Handling
- [ ] Dead Letter Topics
- [ ] Monitoring

### ✅ Infrastructure
- [ ] Container Strategy
- [ ] Orchestration (K8s)
- [ ] Service Discovery
- [ ] Load Balancing
- [ ] Auto-scaling

### ✅ Observability
- [ ] Structured Logging
- [ ] Metrics Collection
- [ ] Distributed Tracing
- [ ] Health Checks
- [ ] Alerting

---

## 🎯 Conclusion

Les **C4 Models** fournissent une documentation claire et structurée de l'architecture **microservices .NET + Kafka**. Cette approche facilite la communication entre les équipes techniques et métier, et sert de référence pour l'évolution du système.

L'architecture **event-driven** avec Kafka permet de construire des systèmes **scalables**, **résilients** et **maintenables**, tout en respectant les principes modernes de développement logiciel.
