# ?? Guide Complet - Producteur Kafka ASP.NET Core (.NET 8)

## ?? Bienvenue !

Ce guide complet vous aidera à **configurer, développer et déployer** un producteur Kafka haute performance en utilisant **ASP.NET Core 8** et la bibliothèque **Confluent.Kafka**. 

**Pour qui ?** Développeurs débutants à intermédiaires souhaitant intégrer Kafka dans leur architecture microservices.

**Durée estimée :** 30-45 minutes  
**Niveau de difficulté :** ?? Intermédiaire

---

## ?? Table des Matières

| # | Section | ?? Temps |
|---|---------|---------|
| 1 | [Prérequis](#prérequis) | 5 min |
| 2 | [Créer un Nouveau Projet](#créer-un-nouveau-projet-aspnet-core-api) | 10 min |
| 3 | [Configuration Kafka](#configuration-kafka) | 15 min |
| 4 | [Étapes Rapides](#étapes-rapides) | 5 min |
| 5 | [Utilisation Docker](#utilisation-docker) | 10 min |
| 6 | [Structure du Projet](#structure-du-projet) | 5 min |
| 7 | [Troubleshooting](#troubleshooting) | Besoin |
| 8 | [Ressources](#ressources) | Ref. |

---

## ?? Prérequis

### ??? Requis Absolus

- **? .NET 8 SDK** ? : [Télécharger](https://dotnet.microsoft.com/download/dotnet/8.0)
  - Vérifiez : `dotnet --version` (doit être ? 8.0)
  
- **Git** : Pour versionner et cloner
  - Vérifiez : `git --version`

- **Un éditeur de code** :
  - **Visual Studio 2022** (recommandé) : [Télécharger](https://visualstudio.microsoft.com/)
  - **Visual Studio Code** : [Télécharger](https://code.visualstudio.com/)

### ?? Optionnel mais Recommandé

- **Docker Desktop** : Pour conteneuriser
  - Vérifiez : `docker --version`
  - [Télécharger](https://www.docker.com/products/docker-desktop)

---

## ?? Créer un Nouveau Projet ASP.NET Core API

### ?? Méthode 1 : Interface Graphique (Visual Studio 2022)

1. **Lancer Visual Studio 2022**
2. **Cliquer** : "Create a new project" ou **File ? New ? Project**
3. **Rechercher** : `api` ? Sélectionner **"ASP.NET Core Web API"** ? **Next**
4. **Configurer** :
   - Project name: `kafka_producer`
   - Location: `D:\Data2AI Academy\Kafka\kafka-bhf\formation-v2\day-01-foundations\module-02-producer-reliability\`
   - ? **Next**
5. **Sélectionner .NET** : `.NET 8.0` ? **Create**

? **Fait !** Le projet est créé.

### ?? Méthode 2 : Ligne de Commande

```powershell
# Créer le projet
dotnet new webapi -n kafka_producer -minimal false

# Naviguer dedans
cd kafka_producer

# Modifier .csproj : Remplacer net10.0 par net8.0
# Puis build
dotnet build
```

---

## ?? Configuration Kafka

### 1?? Ajouter le Package

```powershell
dotnet add package Confluent.Kafka
```

### 2?? Créer le Service `Services/KafkaProducerService.cs`

```csharp
using Confluent.Kafka;

namespace kafka_producer.Services
{
    public interface IKafkaProducerService
    {
        Task<DeliveryResult<string, string>> SendMessageAsync(
            string topic, string key, string value);
    }

    public class KafkaProducerService : IKafkaProducerService, IAsyncDisposable
    {
        private readonly IProducer<string, string> _producer;
        private readonly ILogger<KafkaProducerService> _logger;

        public KafkaProducerService(IConfiguration config, ILogger<KafkaProducerService> logger)
        {
            _logger = logger;
            var bootstrapServers = config["Kafka:BootstrapServers"] ?? "localhost:9092";
            
            var producerConfig = new ProducerConfig
            {
                BootstrapServers = bootstrapServers,
                ClientId = "kafka_producer_app",
                Acks = Acks.All,
                Retries = 3,
                EnableIdempotence = true,
                CompressionType = CompressionType.Snappy
            };

            _producer = new ProducerBuilder<string, string>(producerConfig)
                .SetErrorHandler((_, error) => _logger.LogError($"Erreur: {error.Reason}"))
                .Build();

            _logger.LogInformation($"Producer initialisé sur {bootstrapServers}");
        }

        public async Task<DeliveryResult<string, string>> SendMessageAsync(
            string topic, string key, string value)
        {
            var message = new Message<string, string> { Key = key, Value = value };
            return await _producer.ProduceAsync(topic, message);
        }

        async ValueTask IAsyncDisposable.DisposeAsync()
        {
            _producer?.Dispose();
            await Task.CompletedTask;
        }
    }
}
```

### 3?? Mettre à Jour `Program.cs`

```csharp
using kafka_producer.Services;

var builder = WebApplication.CreateBuilder(args);

builder.Services.AddControllers();
builder.Services.AddOpenApi();
builder.Services.AddSingleton<IKafkaProducerService, KafkaProducerService>();

var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseHttpsRedirection();
app.MapControllers();
app.Run();
```

### 4?? Créer l'API `Controllers/KafkaController.cs`

```csharp
using kafka_producer.Services;
using Microsoft.AspNetCore.Mvc;

namespace kafka_producer.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class KafkaController : ControllerBase
    {
        private readonly IKafkaProducerService _producer;
        private readonly ILogger<KafkaController> _logger;

        public KafkaController(IKafkaProducerService producer, ILogger<KafkaController> logger)
        {
            _producer = producer;
            _logger = logger;
        }

        [HttpPost("send")]
        public async Task<IActionResult> SendMessage([FromBody] SendMessageRequest request)
        {
            if (string.IsNullOrWhiteSpace(request.Topic) || string.IsNullOrWhiteSpace(request.Value))
                return BadRequest("Topic et Value sont requis");

            try
            {
                var result = await _producer.SendMessageAsync(
                    request.Topic, request.Key ?? "default", request.Value);

                return Ok(new
                {
                    status = "Success",
                    topic = result.Topic,
                    partition = result.Partition.Value,
                    offset = result.Offset.Value
                });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Erreur: {ex.Message}");
                return StatusCode(500, new { error = ex.Message });
            }
        }

        [HttpGet("health")]
        public IActionResult Health() => Ok(new { status = "healthy" });
    }

    public class SendMessageRequest
    {
        public string Topic { get; set; } = string.Empty;
        public string? Key { get; set; }
        public string Value { get; set; } = string.Empty;
    }
}
```

### 5?? Configurer `appsettings.json`

```json
{
  "Kafka": {
    "BootstrapServers": "localhost:9092"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information"
    }
  }
}
```

---

## ? Étapes Rapides

```powershell
# 1. Restaurer
dotnet restore

# 2. Construire
dotnet build

# 3. Exécuter
dotnet run

# 4. Tester - Ouvrir navigateur
# https://localhost:5001/swagger
```

---

## ?? Utilisation Docker

### Créer `docker-compose.yml`

```yaml
version: '3.8'
services:
  zookeeper:
    image: confluentinc/cp-zookeeper:7.5.0
    ports:
      - "2181:2181"
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181

  kafka:
    image: confluentinc/cp-kafka:7.5.0
    ports:
      - "9092:9092"
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka:29092,PLAINTEXT_HOST://kafka:9092
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT
      KAFKA_INTER_BROKER_LISTENER_NAME: PLAINTEXT
    depends_on:
      - zookeeper

  producer:
    build: .
    ports:
      - "5000:5000"
    environment:
      Kafka__BootstrapServers: kafka:29092
    depends_on:
      - kafka
```

### Lancer

```powershell
docker-compose up -d
```

---

## ?? Structure du Projet

```
kafka-producer/
??? Program.cs
??? Dockerfile
??? docker-compose.yml
??? appsettings.json
??? nuget.config
??? Controllers/
?   ??? KafkaController.cs
??? Services/
?   ??? KafkaProducerService.cs
??? Properties/
?   ??? launchSettings.json
??? README.md
```

---

## ?? Troubleshooting

### ? Erreur : "Port 5000 déjà utilisé"

```powershell
netstat -ano | findstr :5000
taskkill /PID <PID> /F
```

### ? Erreur : "Kafka connection refused"

- Assurez-vous que Kafka s'exécute : `docker-compose up -d`
- Vérifiez `appsettings.json` : `Kafka:BootstrapServers` correct

### ? Erreur : ".NET 8 SDK not found"

```powershell
dotnet --version
# Téléchargez .NET 8 si absent
```

---

## ?? Ressources

- ?? [Confluent.Kafka Docs](https://docs.confluent.io/kafka-clients/dotnet/current/overview.html)
- ?? [ASP.NET Core Docs](https://learn.microsoft.com/en-us/aspnet/core/)
- ?? [Kafka Docs](https://kafka.apache.org/documentation/)

---

**Version** : 1.0  
**Date** : 2024  
**Auteur** : Data2AI Academy  

? **Prêt à démarrer !**

