# ?? Tutoriel Complet : De Visual Studio à une API Containerisée

## ?? Guide Didactique Pas à Pas

**Objectif** : Créer une API ASP.NET Core complète avec support Docker  
**Durée** : 45-60 minutes  
**Niveau** : Débutant à Intermédiaire  
**Résultat** : Une API Kafka Producer prête pour la production

---

## ?? Table des Matières

| Étape | Titre | Temps | Niveau |
|-------|-------|-------|--------|
| 1 | Lancer Visual Studio | 5 min | ? |
| 2 | Créer un Nouveau Projet | 10 min | ? |
| 3 | Explorer la Structure | 5 min | ? |
| 4 | Ajouter Dépendances | 5 min | ?? |
| 5 | Créer le Service Kafka | 10 min | ?? |
| 6 | Créer le Contrôleur API | 10 min | ?? |
| 7 | Configurer les Paramètres | 5 min | ?? |
| 8 | Tester Localement | 5 min | ? |
| 9 | Créer le Dockerfile | 10 min | ?? |
| 10 | Containeriser l'App | 10 min | ??? |

**Temps Total** : ~65 minutes

---

# ?? PARTIE 1 : LANCER VISUAL STUDIO

## Étape 1.1 : Ouvrir Visual Studio 2022

### ?? Image Référence
```
assets/01-launch-visual-studio.png
```

### ?? Instructions

1. **Cliquez** sur le bouton Windows (en bas à gauche)
2. **Tapez** : `Visual Studio 2022`
3. **Sélectionnez** : "Visual Studio 2022"
4. **Cliquez** pour ouvrir

### ?? Temps d'Attente
- Premier lancement : 60-90 secondes
- Lancements suivants : 30-45 secondes

### ? Vous Saurez Que C'est Prêt Quand
- L'écran d'accueil complet s'affiche
- Vous voyez les options "Create a new project"

---

# ?? PARTIE 2 : CRÉER UN NOUVEAU PROJET

## Étape 2.1 : Cliquer sur "Create a new project"

### ?? Image Référence
```
assets/02-create-new-project-button.png
```

### ?? Instructions

Sur l'écran d'accueil, vous verrez plusieurs options :
- **"Create a new project"** ? Cliquez ici
- "Clone a repository"
- "Open a project or solution"

**Cliquez sur "Create a new project"**

---

## Étape 2.2 : Rechercher le Modèle "Web API"

### ?? Image Référence
```
assets/03-search-web-api.png
```

### ?? Instructions

1. Dans la barre de recherche en haut, **tapez** : `api`
2. **Attendez** que les résultats s'affichent
3. **Cherchez** le modèle "ASP.NET Core Web API"
4. **Sélectionnez-le**

### ?? Identifiez le Bon Modèle

```
Bon ? :
?? Logo : .NET
?? Nom : "ASP.NET Core Web API"
?? Langage : C#
?? Description : "A project for creating a REST API..."

Mauvais ? :
?? "ASP.NET Core App" (Application web, pas API)
?? "Console App" (Application console)
?? "Class Library" (Bibliothèque de classes)
```

---

## Étape 2.3 : Cliquer sur "Next"

### ?? Image Référence
```
assets/04-web-api-template-selected.png
```

### ?? Instructions

1. Vous voyez les détails du modèle sélectionné
2. **Cliquez** sur le bouton **"Next"** (en bas à droite)

### ?? À Savoir
- À ce stade, le modèle est juste "sélectionné"
- Nous allons configurer les détails à l'étape suivante

---

## Étape 2.4 : Configurer les Paramètres du Projet

### ?? Image Référence
```
assets/05-configure-project.png
```

### ?? Instructions Détaillées

#### Champ 1?? : Project Name
- **Cherchez** le champ "Project name"
- **Effacez** le texte actuel
- **Tapez** : `kafka_producer`

#### Champ 2?? : Location
- **Cliquez** sur le champ "Location"
- **Naviguez** vers : 
  ```
  D:\Data2AI Academy\Kafka\kafka-bhf\formation-v2\day-01-foundations\module-02-producer-reliability\
  ```
- **Sélectionnez** ce dossier

#### Champ 3?? : Solution Name
- **Doit être automatiquement** : `kafka_producer`
- Si non, changez-le manuellement

#### Case à Cocher 4??
- **Cochez** : "Place solution and project in the same directory"
- Cela simplifie la structure

### ? Vérification
Avant de continuer, vérifiez :
```
? Project name       : kafka_producer
? Location           : D:\Data2AI...\module-02-producer-reliability\
? Solution name      : kafka_producer
? Same directory     : COCHÉ
```

### ?? Cliquez sur "Next"

---

## Étape 2.5 : Sélectionner la Version .NET et Options

### ?? Image Référence
```
assets/06-additional-information.png
```

### ?? Instructions Détaillées

#### Option 1?? : Framework
```
Cherchez : "Framework"
Sélectionnez : ".NET 8.0"
(La version LTS la plus récente)
```

#### Option 2?? : Authentication Type
```
Cherchez : "Authentication type"
Sélectionnez : "None"
(Nous configurerons l'auth plus tard si nécessaire)
```

#### Option 3?? : HTTPS Configuration
```
Cherchez : "Configure for HTTPS"
Cochez : ? (coché)
(Important pour la sécurité en développement)
```

#### Option 4?? : OpenAPI Support
```
Cherchez : "Enable OpenAPI support"
Cochez : ? (coché)
(Cela ajoute Swagger UI automatiquement)
```

#### Option 5?? : Use Top-Level Statements
```
Cherchez : "Use top-level statements"
Cochez : ? (coché)
(Code Program.cs plus moderne)
```

### ? Configuration Finale
```
? Framework              : .NET 8.0
? Authentication Type    : None
? Configure for HTTPS    : COCHÉ
? Enable OpenAPI Support : COCHÉ
? Top-Level Statements   : COCHÉ
```

### ?? Cliquez sur "Create"

---

## Étape 2.6 : Attendre la Création du Projet

### ?? Image Référence
```
assets/07-creating-project.png
```

### ?? Ce Qui se Passe
1. Visual Studio **télécharge** les templates
2. **Crée** la structure du projet
3. **Restaure** les dépendances NuGet
4. **Construit** le projet initial

### ?? Temps d'Attente
- Premier projet : 30-60 secondes
- Affiche une barre de progression

### ? Vous Saurez Que C'est Fini Quand
- La barre de progression disparaît
- Vous voyez l'explorateur de projet dans la gauche
- Le fichier "Program.cs" s'ouvre automatiquement

---

# ??? PARTIE 3 : EXPLORER LA STRUCTURE

## Étape 3.1 : Comprendre les Fichiers Créés

### ?? Image Référence
```
assets/08-project-structure.png
```

### ?? Structure du Projet

```
kafka_producer/
?
??? ?? Program.cs                      ? Point d'entrée
?   (Configuration de l'application)
?
??? ?? Controllers/
?   ??? ?? WeatherForecastController.cs
?       (Exemple de contrôleur à supprimer)
?
??? ?? Properties/
?   ??? ?? launchSettings.json
?       (Configuration de lancement)
?
??? ?? kafka_producer.csproj
?   (Configuration du projet)
?
??? ?? appsettings.json
?   (Paramètres de l'application)
?
??? ?? appsettings.Development.json
    (Paramètres développement)
```

## Étape 3.2 : Explorer les Fichiers Clés

### Fichier 1?? : Program.cs

**Ce qu'il contient :**
```csharp
var builder = WebApplication.CreateBuilder(args);

// Configuration des services
builder.Services.AddControllers();
builder.Services.AddOpenApi();

var app = builder.Build();

// Configuration du pipeline HTTP
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
}

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

app.Run();
```

**Qu'est-ce que c'est ?**
- Le **fichier principal** de l'application
- Configure les services (dépendances)
- Configure le pipeline HTTP (requêtes/réponses)

### Fichier 2?? : appsettings.json

**Ce qu'il contient :**
```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

**Qu'est-ce que c'est ?**
- Fichier de **configuration** de l'application
- Paramètres d'environnement
- Nous allons ajouter nos paramètres Kafka ici

### Fichier 3?? : kafka_producer.csproj

**Ce qu'il contient :**
```xml
<Project Sdk="Microsoft.NET.Sdk.Web">

  <PropertyGroup>
    <TargetFramework>net8.0</TargetFramework>
    <Nullable>enable</Nullable>
    <ImplicitUsings>enable</ImplicitUsings>
  </PropertyGroup>

  <ItemGroup>
    <PackageReference Include="Microsoft.AspNetCore.OpenApi" Version="8.0.0" />
  </ItemGroup>

</Project>
```

**Qu'est-ce que c'est ?**
- Fichier de **configuration du projet**
- Définit le framework (.NET 8.0)
- Référence les dépendances NuGet

---

# ?? PARTIE 4 : AJOUTER LES DÉPENDANCES

## Étape 4.1 : Ajouter Confluent.Kafka

### ?? Image Référence
```
assets/09-nuget-package-manager.png
```

### ?? Méthode 1?? : Via Interface Graphique

1. **Cliquez** sur le menu : **Tools ? NuGet Package Manager ? Manage NuGet Packages for Solution**

2. **Cherchez** le package
   - Tapez dans la barre de recherche : `Confluent.Kafka`
   - Attendez les résultats

3. **Sélectionnez** le package
   - "Confluent.Kafka" (par Confluent Inc.)
   
4. **Installez**
   - Cliquez sur le bouton "Install"
   - Acceptez la licence

5. **Attendez**
   - La barre de progression indique l'installation
   - Cela peut prendre 30-60 secondes

### ?? Méthode 2?? : Via Package Manager Console

1. **Ouvrez** : **Tools ? NuGet Package Manager ? Package Manager Console**

2. **Tapez** la commande :
   ```powershell
   Install-Package Confluent.Kafka
   ```

3. **Appuyez** sur Entrée

4. **Attendez** l'installation

### ? Vérification

Pour vérifier que le package a été installé :

1. **Ouvrez** : **Tools ? NuGet Package Manager ? Package Manager Console**

2. **Tapez** :
   ```powershell
   Get-Package
   ```

3. **Cherchez** dans la liste : `Confluent.Kafka`

---

# ??? PARTIE 5 : CRÉER LE SERVICE KAFKA

## Étape 5.1 : Créer le Dossier "Services"

### ?? Image Référence
```
assets/10-create-folder.png
```

### ?? Instructions

1. **Cliquez droit** sur le nom du projet : `kafka_producer`
2. **Sélectionnez** : **Add ? New Folder**
3. **Tapez** : `Services`
4. **Appuyez** sur Entrée

### ? Résultat

Vous devriez maintenant avoir une structure comme :
```
kafka_producer/
??? Controllers/
??? Properties/
??? Services/           ? Nouveau dossier
??? ...
```

---

## Étape 5.2 : Créer la Classe "KafkaProducerService.cs"

### ?? Image Référence
```
assets/11-create-class.png
```

### ?? Instructions

1. **Cliquez droit** sur le dossier : `Services`
2. **Sélectionnez** : **Add ? Class**
3. **Tapez** : `KafkaProducerService.cs`
4. **Cliquez** sur **Add**

---

## Étape 5.3 : Coder le Service

### ?? Image Référence
```
assets/12-kafka-service-code.png
```

### ?? Code Complet

**Remplacez** le contenu du fichier par :

```csharp
using Confluent.Kafka;

namespace kafka_producer.Services
{
    /// <summary>
    /// Interface pour le service Kafka Producer
    /// </summary>
    public interface IKafkaProducerService
    {
        Task<DeliveryResult<string, string>> SendMessageAsync(
            string topic,
            string key,
            string value);

        Task FlushAsync();
    }

    /// <summary>
    /// Implémentation du service Kafka Producer
    /// </summary>
    public class KafkaProducerService : IKafkaProducerService, IAsyncDisposable
    {
        private readonly IProducer<string, string> _producer;
        private readonly ILogger<KafkaProducerService> _logger;

        /// <summary>
        /// Constructeur - Initialise le producer Kafka
        /// </summary>
        public KafkaProducerService(
            IConfiguration config,
            ILogger<KafkaProducerService> logger)
        {
            _logger = logger;

            // Récupérer l'adresse du serveur Kafka
            var bootstrapServers = config["Kafka:BootstrapServers"] 
                ?? "localhost:9092";

            // Configuration du Producer
            var producerConfig = new ProducerConfig
            {
                BootstrapServers = bootstrapServers,
                ClientId = "kafka_producer_app",
                
                // Fiabilité
                Acks = Acks.All,                // Attendre tous les ACKs
                Retries = 3,                     // 3 tentatives
                EnableIdempotence = true,        // Éviter les doublons
                
                // Performance
                CompressionType = CompressionType.Snappy,
                Linger = 100,                    // Batcher après 100ms
            };

            // Créer le producer avec gestion des erreurs
            _producer = new ProducerBuilder<string, string>(producerConfig)
                .SetErrorHandler((_, error) =>
                {
                    _logger.LogError($"? Erreur Producer: {error.Reason}");
                })
                .Build();

            _logger.LogInformation(
                $"? Producer Kafka initialisé sur {bootstrapServers}");
        }

        /// <summary>
        /// Envoyer un message à Kafka
        /// </summary>
        public async Task<DeliveryResult<string, string>> SendMessageAsync(
            string topic,
            string key,
            string value)
        {
            try
            {
                var message = new Message<string, string>
                {
                    Key = key,
                    Value = value
                };

                _logger.LogInformation(
                    $"?? Envoi: Topic={topic}, Key={key}");

                var deliveryReport = await _producer.ProduceAsync(
                    topic, message);

                if (deliveryReport.Status == PersistenceStatus.Persisted)
                {
                    _logger.LogInformation(
                        $"? Message livré - " +
                        $"Topic: {deliveryReport.Topic}, " +
                        $"Partition: {deliveryReport.Partition}, " +
                        $"Offset: {deliveryReport.Offset}");
                }

                return deliveryReport;
            }
            catch (Exception ex)
            {
                _logger.LogError(
                    $"? Erreur lors de l'envoi: {ex.Message}");
                throw;
            }
        }

        /// <summary>
        /// Vider le buffer (envoyer les messages en attente)
        /// </summary>
        public async Task FlushAsync()
        {
            _logger.LogInformation("?? Flushing producer...");
            _producer.Flush(TimeSpan.FromSeconds(10));
            await Task.CompletedTask;
        }

        /// <summary>
        /// Nettoyer les ressources
        /// </summary>
        async ValueTask IAsyncDisposable.DisposeAsync()
        {
            _logger.LogInformation("?? Arrêt du Producer Kafka");
            _producer?.Dispose();
            await Task.CompletedTask;
        }
    }
}
```

### ?? Explication du Code

#### Interfaces
- **`IKafkaProducerService`** : Contrat du service
  - Définit les méthodes que le service doit implémenter
  - Permet l'injection de dépendances

#### Configuration du Producer
```csharp
var producerConfig = new ProducerConfig
{
    BootstrapServers = "localhost:9092",  // Serveur Kafka
    Acks = Acks.All,                      // Fiabilité max
    EnableIdempotence = true,             // Pas de doublons
    CompressionType = CompressionType.Snappy // Compression
};
```

#### Envoi d'un Message
```csharp
var message = new Message<string, string>
{
    Key = key,      // Clé (pour partitioning)
    Value = value   // Valeur (données)
};

var result = await _producer.ProduceAsync(topic, message);
```

---

# ?? PARTIE 6 : CRÉER LE CONTRÔLEUR API

## Étape 6.1 : Créer la Classe "KafkaController.cs"

### ?? Image Référence
```
assets/13-create-controller.png
```

### ?? Instructions

1. **Cliquez droit** sur le dossier : `Controllers`
2. **Sélectionnez** : **Add ? Class**
3. **Tapez** : `KafkaController.cs`
4. **Cliquez** sur **Add**

---

## Étape 6.2 : Coder le Contrôleur

### ?? Image Référence
```
assets/14-kafka-controller-code.png
```

### ?? Code Complet

**Remplacez** le contenu du fichier par :

```csharp
using kafka_producer.Services;
using Microsoft.AspNetCore.Mvc;

namespace kafka_producer.Controllers
{
    /// <summary>
    /// Contrôleur API pour Kafka
    /// </summary>
    [ApiController]
    [Route("api/[controller]")]
    public class KafkaController : ControllerBase
    {
        private readonly IKafkaProducerService _kafkaProducer;
        private readonly ILogger<KafkaController> _logger;

        /// <summary>
        /// Constructeur - Injection de dépendances
        /// </summary>
        public KafkaController(
            IKafkaProducerService kafkaProducer,
            ILogger<KafkaController> logger)
        {
            _kafkaProducer = kafkaProducer;
            _logger = logger;
        }

        /// <summary>
        /// Envoyer un message à Kafka
        /// GET: /api/kafka/send?topic=test&key=key1&value=value1
        /// POST: /api/kafka/send
        /// </summary>
        [HttpPost("send")]
        [ProducesResponseType(StatusCodes.Status200OK)]
        [ProducesResponseType(StatusCodes.Status400BadRequest)]
        [ProducesResponseType(StatusCodes.Status500InternalServerError)]
        public async Task<ActionResult<SendMessageResponse>> SendMessage(
            [FromBody] SendMessageRequest request)
        {
            // Validation
            if (string.IsNullOrWhiteSpace(request.Topic) ||
                string.IsNullOrWhiteSpace(request.Value))
            {
                return BadRequest(
                    new { error = "Topic et Value sont requis" });
            }

            try
            {
                // Envoyer le message
                var result = await _kafkaProducer.SendMessageAsync(
                    request.Topic,
                    request.Key ?? "default",
                    request.Value);

                // Retourner le résultat
                return Ok(new SendMessageResponse
                {
                    Status = "Success",
                    Topic = result.Topic,
                    Partition = result.Partition.Value,
                    Offset = result.Offset.Value,
                    Timestamp = DateTime.UtcNow
                });
            }
            catch (Exception ex)
            {
                _logger.LogError($"Erreur: {ex.Message}");
                return StatusCode(500,
                    new { error = ex.Message });
            }
        }

        /// <summary>
        /// Envoyer plusieurs messages (batch)
        /// POST: /api/kafka/send-batch
        /// </summary>
        [HttpPost("send-batch")]
        public async Task<ActionResult<List<SendMessageResponse>>> SendBatchMessages(
            [FromBody] List<SendMessageRequest> requests)
        {
            var results = new List<SendMessageResponse>();

            foreach (var request in requests)
            {
                try
                {
                    var result = await _kafkaProducer.SendMessageAsync(
                        request.Topic,
                        request.Key ?? "default",
                        request.Value);

                    results.Add(new SendMessageResponse
                    {
                        Status = "Success",
                        Topic = result.Topic,
                        Partition = result.Partition.Value,
                        Offset = result.Offset.Value,
                        Timestamp = DateTime.UtcNow
                    });
                }
                catch (Exception ex)
                {
                    results.Add(new SendMessageResponse
                    {
                        Status = "Failed",
                        Error = ex.Message,
                        Timestamp = DateTime.UtcNow
                    });
                }
            }

            // Flush tous les messages
            await _kafkaProducer.FlushAsync();
            return Ok(results);
        }

        /// <summary>
        /// Vérifier la santé du service
        /// GET: /api/kafka/health
        /// </summary>
        [HttpGet("health")]
        public IActionResult Health()
        {
            return Ok(new
            {
                status = "healthy",
                timestamp = DateTime.UtcNow,
                version = "1.0"
            });
        }
    }

    /// <summary>
    /// DTO - Requête pour envoyer un message
    /// </summary>
    public class SendMessageRequest
    {
        /// <summary>Topic Kafka cible</summary>
        public string Topic { get; set; } = string.Empty;

        /// <summary>Clé du message (optionnel)</summary>
        public string? Key { get; set; }

        /// <summary>Valeur du message</summary>
        public string Value { get; set; } = string.Empty;
    }

    /// <summary>
    /// DTO - Réponse après envoi d'un message
    /// </summary>
    public class SendMessageResponse
    {
        /// <summary>Statut de l'envoi</summary>
        public string Status { get; set; } = "Unknown";

        /// <summary>Topic où le message a été envoyé</summary>
        public string? Topic { get; set; }

        /// <summary>Partition du message</summary>
        public int Partition { get; set; }

        /// <summary>Offset du message</summary>
        public long Offset { get; set; }

        /// <summary>Timestamp de la réponse</summary>
        public DateTime Timestamp { get; set; }

        /// <summary>Message d'erreur (si erreur)</summary>
        public string? Error { get; set; }
    }
}
```

### ?? Explication du Code

#### Décorateurs
```csharp
[ApiController]          // Indique que c'est un contrôleur API
[Route("api/[controller]")]  // Route de base: /api/kafka
```

#### Actions HTTP
```csharp
[HttpPost("send")]       // POST /api/kafka/send
[HttpGet("health")]      // GET /api/kafka/health
```

#### DTOs (Data Transfer Objects)
- **SendMessageRequest** : Données reçues du client
- **SendMessageResponse** : Données envoyées au client

---

# ?? PARTIE 7 : CONFIGURER LES PARAMÈTRES

## Étape 7.1 : Mettre à Jour Program.cs

### ?? Image Référence
```
assets/15-program-cs-updated.png
```

### ?? Instructions

1. **Ouvrez** le fichier : `Program.cs`
2. **Remplacez** le contenu complet par :

```csharp
using kafka_producer.Services;

var builder = WebApplication.CreateBuilder(args);

// Configuration depuis appsettings.json
builder.Configuration
    .AddJsonFile("appsettings.json", optional: false, reloadOnChange: true)
    .AddEnvironmentVariables();

// Ajouter les services
builder.Services.AddControllers();
builder.Services.AddOpenApi();

// Ajouter notre service Kafka
builder.Services.AddSingleton<IKafkaProducerService, KafkaProducerService>();

// Ajouter les logs
builder.Services.AddLogging();

// Ajouter CORS si nécessaire
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", builder =>
    {
        builder.AllowAnyOrigin()
               .AllowAnyMethod()
               .AllowAnyHeader();
    });
});

var app = builder.Build();

// Pipeline HTTP
if (app.Environment.IsDevelopment())
{
    app.MapOpenApi();
    app.MapScalarApiReference();
}

app.UseHttpsRedirection();
app.UseAuthorization();
app.UseCors("AllowAll");

app.MapControllers();

app.Run();
```

### ?? Explication

#### Enregistrement des Services
```csharp
builder.Services.AddSingleton<IKafkaProducerService, KafkaProducerService>();
```
- **Singleton** : Une seule instance pour toute l'application
- **IKafkaProducerService** : Interface (ce qui est injecté)
- **KafkaProducerService** : Implémentation

#### CORS
```csharp
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", ...);
});
```
- Permet aux requêtes cross-origin (utile pour les tests)

---

## Étape 7.2 : Mettre à Jour appsettings.json

### ?? Image Référence
```
assets/16-appsettings-json.png
```

### ?? Instructions

1. **Ouvrez** le fichier : `appsettings.json`
2. **Remplacez** le contenu par :

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft": "Warning",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "Kafka": {
    "BootstrapServers": "localhost:9092",
    "Topic": "my-topic",
    "GroupId": "kafka_producer_group",
    "SecurityProtocol": "plaintext"
  }
}
```

### Étape 7.3 : Créer appsettings.Development.json

### ?? Image Référence
```
assets/17-appsettings-development.png
```

### ?? Instructions

1. **Cliquez droit** sur la racine du projet
2. **Sélectionnez** : **Add ? New Item ? appsettings.Development.json**
3. **Remplacez** le contenu par :

```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Debug",
      "Microsoft": "Debug",
      "Microsoft.AspNetCore": "Debug"
    }
  },
  "Kafka": {
    "BootstrapServers": "localhost:9092"
  }
}
```

---

# ? PARTIE 8 : TESTER LOCALEMENT

## Étape 8.1 : Supprimer le Contrôleur d'Exemple

### ?? Image Référence
```
assets/18-delete-weather-controller.png
```

### ?? Instructions

1. **Cherchez** le fichier : `WeatherForecastController.cs` dans `Controllers/`
2. **Cliquez droit** dessus
3. **Sélectionnez** : **Delete**
4. **Confirmez** la suppression

---

## Étape 8.2 : Compiler le Projet

### ?? Image Référence
```
assets/19-build-project.png
```

### ?? Instructions

1. **Cliquez** sur le menu : **Build ? Build Solution**
   - Ou appuyez sur : **Ctrl+Shift+B**

2. **Observez** la barre de compilation
   - Vous verrez "Building kafka_producer"

3. **Attendez** la fin
   - Devrait afficher : "Build succeeded" dans la fenêtre de sortie

### ? Résultat Attendu

```
Build started...
------ Build started: Project: kafka_producer, Configuration: Debug Any CPU ------
kafka_producer -> D:\...\kafka_producer\bin\Debug\net8.0\kafka_producer.dll

========== Build: 1 succeeded, 0 failed, 0 up-to-date, 0 skipped ==========
```

---

## Étape 8.3 : Lancer l'Application

### ?? Image Référence
```
assets/20-run-application.png
```

### ?? Instructions

1. **Cliquez** sur le bouton **Play** (triangle vert) en haut
   - Ou appuyez sur : **F5**

2. **Attendez** le démarrage
   - La première fois : 10-15 secondes

3. **Observez** la fenêtre de sortie
   - Devrait voir : "Application started"

### ?? Résultat

Une fenêtre du navigateur devrait s'ouvrir sur :
```
https://localhost:5001/swagger/ui/index.html
```

Ou si elle ne s'ouvre pas, naviguez manuellement.

---

## Étape 8.4 : Tester l'API avec Swagger

### ?? Image Référence
```
assets/21-swagger-interface.png
```

### ?? Test de Health Check

1. **Cherchez** dans Swagger : `GET /api/kafka/health`
2. **Cliquez** sur cette endpoint
3. **Cliquez** sur **"Try it out"**
4. **Cliquez** sur **"Execute"**

### ? Résultat Attendu
```json
{
  "status": "healthy",
  "timestamp": "2024-01-15T10:30:00.000Z",
  "version": "1.0"
}
```

### ?? Test d'Envoi de Message

1. **Cherchez** dans Swagger : `POST /api/kafka/send`
2. **Cliquez** sur cette endpoint
3. **Cliquez** sur **"Try it out"**
4. **Modifiez** le JSON d'exemple :

```json
{
  "topic": "test-topic",
  "key": "test-key",
  "value": "Hello Kafka from ASP.NET Core!"
}
```

5. **Cliquez** sur **"Execute"**

### ? Résultat Attendu
```json
{
  "status": "Success",
  "topic": "test-topic",
  "partition": 0,
  "offset": 0,
  "timestamp": "2024-01-15T10:30:15.000Z"
}
```

---

## Étape 8.5 : Vérifier les Logs

### ?? Image Référence
```
assets/22-debug-output.png
```

### ?? Où Voir les Logs

1. **Ouvrez** : **View ? Output** (ou Ctrl+Alt+O)

2. **Changez** la source vers : **"Show output from: Application"**

3. **Observez** les messages

### ? Messages Attendus
```
? Producer Kafka initialisé sur localhost:9092
?? Envoi: Topic=test-topic, Key=test-key
? Message livré - Topic: test-topic, Partition: 0, Offset: 0
```

---

# ?? PARTIE 9 : CRÉER LE DOCKERFILE

## Étape 9.1 : Créer le Fichier Dockerfile

### ?? Image Référence
```
assets/23-create-dockerfile.png
```

### ?? Instructions

1. **Cliquez droit** sur la racine du projet
2. **Sélectionnez** : **Add ? New Item**
3. **Cherchez** : "Docker"
4. **Sélectionnez** : **Dockerfile**
5. **Cliquez** sur **Add**

---

## Étape 9.2 : Configurer le Dockerfile

### ?? Image Référence
```
assets/24-dockerfile-code.png
```

### ?? Code Complet

**Remplacez** le contenu du Dockerfile par :

```dockerfile
# Stage 1: Build
# Utilise SDK .NET pour compiler l'application
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build

WORKDIR /src

# Copier le fichier projet
COPY ["kafka_producer.csproj", "./"]

# Restaurer les dépendances NuGet
RUN dotnet restore "kafka_producer.csproj"

# Copier tout le code source
COPY . .

# Compiler l'application
RUN dotnet build "kafka_producer.csproj" -c Release -o /app/build

# Stage 2: Publish
# Continue depuis le stage build
FROM build AS publish

# Publier l'application
RUN dotnet publish "kafka_producer.csproj" \
    -c Release \
    -o /app/publish

# Stage 3: Runtime
# Image minimale pour exécution
FROM mcr.microsoft.com/dotnet/aspnet:8.0

WORKDIR /app

# Copier les fichiers publiés depuis le stage publish
COPY --from=publish /app/publish .

# Exposer les ports
EXPOSE 80
EXPOSE 443

# Variables d'environnement
ENV ASPNETCORE_ENVIRONMENT=Production
ENV ASPNETCORE_HTTP_PORT=80
ENV ASPNETCORE_HTTPS_PORT=443

# Commande de démarrage
ENTRYPOINT ["dotnet", "kafka_producer.dll"]
```

### ?? Explication du Dockerfile

#### Stage 1: Build
```dockerfile
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
```
- **FROM** : Image de base (SDK .NET 8.0)
- **AS build** : Étiquette pour référencer plus tard

```dockerfile
RUN dotnet restore
RUN dotnet build
```
- **Restaure** les dépendances
- **Compile** l'application

#### Stage 2: Publish
```dockerfile
FROM build AS publish
RUN dotnet publish
```
- **Publie** l'application en mode Release
- Réduit la taille de l'image

#### Stage 3: Runtime
```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0
```
- Image **minimale** (sans SDK)
- Pour exécuter l'application en production

#### Avantages du Multi-Stage Build
- ? Image finale plus petite
- ? SDK n'est pas inclus en production
- ? Plus sécurisé

---

## Étape 9.3 : Créer docker-compose.yml

### ?? Image Référence
```
assets/25-create-docker-compose.png
```

### ?? Instructions

1. **Cliquez droit** sur la racine du projet
2. **Sélectionnez** : **Add ? New Item ? docker-compose.yml**
3. **Remplacez** le contenu par le code suivant

### ?? Code Complet

```yaml
version: '3.8'

services:
  # Zookeeper (coordinateur Kafka)
  zookeeper:
    image: confluentinc/cp-zookeeper:7.5.0
    ports:
      - "2181:2181"
    environment:
      ZOOKEEPER_CLIENT_PORT: 2181
      ZOOKEEPER_SYNC_LIMIT: 2
      ZOOKEEPER_INIT_LIMIT: 5
    networks:
      - kafka-network
    healthcheck:
      test: ["CMD", "echo", "stat", "|", "nc", "localhost", "2181"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Kafka Broker
  kafka:
    image: confluentinc/cp-kafka:7.5.0
    ports:
      - "9092:9092"
      - "29092:29092"
    depends_on:
      zookeeper:
        condition: service_healthy
    environment:
      KAFKA_BROKER_ID: 1
      KAFKA_ZOOKEEPER_CONNECT: zookeeper:2181
      KAFKA_ADVERTISED_LISTENERS: PLAINTEXT://kafka:29092,PLAINTEXT_HOST://kafka:9092
      KAFKA_LISTENER_SECURITY_PROTOCOL_MAP: PLAINTEXT:PLAINTEXT,PLAINTEXT_HOST:PLAINTEXT
      KAFKA_INTER_BROKER_LISTENER_NAME: PLAINTEXT
      KAFKA_OFFSETS_TOPIC_REPLICATION_FACTOR: 1
      KAFKA_AUTO_CREATE_TOPICS_ENABLE: "true"
    networks:
      - kafka-network
    healthcheck:
      test: ["CMD", "kafka-broker-api-versions", "--bootstrap-server", "localhost:9092"]
      interval: 10s
      timeout: 5s
      retries: 5

  # Notre API Producer
  api:
    build:
      context: .
      dockerfile: Dockerfile
    ports:
      - "5000:80"
      - "5001:443"
    depends_on:
      kafka:
        condition: service_healthy
    environment:
      Kafka__BootstrapServers: kafka:29092
      ASPNETCORE_ENVIRONMENT: Development
    networks:
      - kafka-network

networks:
  kafka-network:
    driver: bridge
```

### ?? Explication du docker-compose.yml

#### Services
```yaml
services:
  zookeeper:   # Coordinateur Kafka
  kafka:       # Broker Kafka
  api:         # Notre API
```

#### Dépendances
```yaml
depends_on:
  kafka:
    condition: service_healthy
```
- Attend que Kafka soit prêt avant de démarrer l'API

#### Réseau
```yaml
networks:
  kafka-network:
```
- Permet aux services de communiquer entre eux

#### Variables d'Environnement
```yaml
environment:
  Kafka__BootstrapServers: kafka:29092
```
- Configure l'application pour se connecter à Kafka

---

# ?? PARTIE 10 : CONTAINERISER L'APPLICATION

## Étape 10.1 : Installer Docker Desktop

### ?? Image Référence
```
assets/26-docker-desktop-download.png
```

### ?? Instructions

Si vous n'avez pas Docker :

1. **Téléchargez** : [Docker Desktop](https://www.docker.com/products/docker-desktop)
2. **Installez** : Suivez l'assistant d'installation
3. **Redémarrez** votre ordinateur
4. **Lancez** Docker Desktop

### ? Vérification

Ouvrez PowerShell et tapez :
```powershell
docker --version
```

Devrait afficher : `Docker version 24.x.x, build ...`

---

## Étape 10.2 : Arrêter l'Application Visual Studio

### ?? Image Référence
```
assets/27-stop-debugger.png
```

### ?? Instructions

1. **Appuyez** sur : **Shift+F5**
   - Ou cliquez le bouton d'arrêt (carré rouge)

2. **Attendez** que l'application s'arrête

### ? Résultat

- Swagger UI disparaît
- La fenêtre du navigateur se ferme

---

## Étape 10.3 : Ouvrir un Terminal PowerShell

### ?? Image Référence
```
assets/28-open-powershell.png
```

### ?? Instructions

1. **Cliquez droit** sur la racine du projet dans l'Explorateur
2. **Sélectionnez** : **Open in Terminal**

Ou manuellement :

1. **Ouvrez** PowerShell
2. **Naviguez** vers le dossier du projet :
   ```powershell
   cd "D:\Data2AI Academy\Kafka\kafka-bhf\formation-v2\day-01-foundations\module-02-producer-reliability\kafka_producer"
   ```

---

## Étape 10.4 : Lancer Docker Compose

### ?? Image Référence
```
assets/29-docker-compose-up.png
```

### ?? Instructions

Dans le terminal PowerShell, tapez :

```powershell
docker-compose up -d
```

### ?? Explication de la Commande
- `docker-compose up` : Lance les services
- `-d` : Mode "detached" (en arrière-plan)

### ?? Temps d'Attente
- **Premier lancement** : 2-5 minutes
  - Télécharge les images Docker
  - Compile l'API
  
- **Lancements suivants** : 30-60 secondes

### ? Résultat

Vous devriez voir :
```
Creating zookeeper ... done
Creating kafka ... done
Creating api ... done
```

---

## Étape 10.5 : Vérifier les Conteneurs

### ?? Image Référence
```
assets/30-docker-containers-running.png
```

### ?? Instructions

**Commande 1?? : Voir les conteneurs actifs**

```powershell
docker-compose ps
```

### ? Résultat Attendu
```
NAME       STATUS           PORTS
zookeeper  Up 2 minutes     2181/tcp
kafka      Up 2 minutes     9092/tcp, 29092/tcp
api        Up 1 minute      80/tcp, 443/tcp
```

---

## Étape 10.6 : Voir les Logs

### ?? Image Référence
```
assets/31-docker-logs.png
```

### ?? Commandes

**Voir tous les logs :**
```powershell
docker-compose logs -f
```

**Voir les logs de l'API seulement :**
```powershell
docker-compose logs -f api
```

**Voir les logs de Kafka :**
```powershell
docker-compose logs -f kafka
```

### ?? Interprétation des Logs

#### ? Logs Correctes pour Kafka
```
kafka      | broker 1 started
kafka      | Successfully connected to Zookeeper
```

#### ? Logs Correctes pour API
```
api | Now listening on: http://[::]:80
api | Now listening on: https://[::]:443
```

#### ? Logs d'Erreur Courantes
```
kafka      | Connection refused
  ? Zookeeper n'est pas encore prêt

api        | Unable to connect to Kafka
  ? Vérifiez Kafka__BootstrapServers
```

---

## Étape 10.7 : Tester l'API Containerisée

### ?? Image Référence
```
assets/32-test-containerized-api.png
```

### ?? Accéder à Swagger

**Dans votre navigateur, allez à :**
```
http://localhost:5000/swagger/ui/index.html
```

### ?? Test de Health Check

1. **Cherchez** : `GET /api/kafka/health`
2. **Cliquez** sur **"Try it out"**
3. **Cliquez** sur **"Execute"**

### ? Résultat Attendu
```json
{
  "status": "healthy",
  "timestamp": "2024-01-15T10:30:00.000Z",
  "version": "1.0"
}
```

### ?? Test d'Envoi de Message

1. **Cherchez** : `POST /api/kafka/send`
2. **Cliquez** sur **"Try it out"**
3. **Entrez** le JSON :

```json
{
  "topic": "docker-test",
  "key": "test-key",
  "value": "Message from containerized API!"
}
```

4. **Cliquez** sur **"Execute"**

### ? Résultat Attendu
```json
{
  "status": "Success",
  "topic": "docker-test",
  "partition": 0,
  "offset": 0,
  "timestamp": "2024-01-15T10:30:15.000Z"
}
```

---

## Étape 10.8 : Tester via cURL

### ?? Image Référence
```
assets/33-curl-test.png
```

### ?? Commandes

**Test Health Check :**
```powershell
curl -X GET "http://localhost:5000/api/kafka/health" `
  -H "Content-Type: application/json"
```

**Envoyer un Message :**
```powershell
curl -X POST "http://localhost:5000/api/kafka/send" `
  -H "Content-Type: application/json" `
  -d '{
    "topic": "my-topic",
    "key": "my-key",
    "value": "Hello from cURL!"
  }'
```

---

## Étape 10.9 : Arrêter les Conteneurs

### ?? Image Référence
```
assets/34-docker-compose-down.png
```

### ?? Instructions

**Pour arrêter les conteneurs :**
```powershell
docker-compose down
```

**Pour arrêter ET supprimer les données :**
```powershell
docker-compose down -v
```

### ?? Paramètres
- `-v` : Supprime aussi les volumes (données persistantes)
- Sans `-v` : Les données sont conservées

---

# ?? RÉSUMÉ FINAL

## ? Qu'Avez-Vous Créé ?

### ??? Architecture
```
Visual Studio Project
??? Controllers/
?   ??? KafkaController.cs      (API Endpoints)
??? Services/
?   ??? KafkaProducerService.cs (Logique Kafka)
??? Program.cs                  (Configuration)
??? appsettings.json            (Paramètres)
??? Dockerfile                  (Image Docker)
??? docker-compose.yml          (Orchestration)
```

### ?? API Endpoints Disponibles

| Méthode | Endpoint | Description |
|---------|----------|-------------|
| GET | `/api/kafka/health` | Vérifier la santé |
| POST | `/api/kafka/send` | Envoyer 1 message |
| POST | `/api/kafka/send-batch` | Envoyer plusieurs |

### ?? Services Dockerisés

| Service | Port | Rôle |
|---------|------|------|
| Zookeeper | 2181 | Coordinateur Kafka |
| Kafka | 9092 | Broker de messages |
| API | 5000/5001 | Application ASP.NET |

### ?? Compétences Acquises

? Créer un projet ASP.NET Core Web API  
? Configurer les services et le pipeline HTTP  
? Implémenter un client Kafka Producer  
? Créer des endpoints REST avec validation  
? Écrire un Dockerfile multi-stage  
? Orchestrer plusieurs conteneurs avec Docker Compose  
? Tester une API via Swagger et cURL  

---

## ?? Prochaines Étapes

### Amélioration 1?? : Ajouter la Persistance
- Connecter à une base de données
- Stocker l'historique des messages

### Amélioration 2?? : Ajouter l'Authentification
- Implémenter JWT tokens
- Sécuriser les endpoints

### Amélioration 3?? : Ajouter Consumer
- Lire les messages Kafka
- Traiter les données

### Amélioration 4?? : Déployer en Production
- Kubernetes
- Cloud Azure/AWS

---

## ?? Ressources Utiles

### Documentation Officielle
- [ASP.NET Core Docs](https://learn.microsoft.com/en-us/aspnet/core/)
- [Confluent.Kafka Client](https://docs.confluent.io/kafka-clients/dotnet/current/overview.html)
- [Docker Docs](https://docs.docker.com/)
- [Apache Kafka](https://kafka.apache.org/documentation/)

### Tutoriels Additionnels
- Ajouter des tests unitaires
- Implémenter Dependency Injection avancée
- Configurer des healthchecks personnalisés

---

## ?? Conclusion

Vous avez maintenant une **API ASP.NET Core complète** avec :
- ? Communication Kafka fonctionnelle
- ? Containerisation Docker
- ? Orchestration via Docker Compose
- ? Documentation via Swagger
- ? Code prêt pour production

**Bravo ! Vous êtes maintenant un développeur Kafka avec ASP.NET Core ! ??**

---

**Version** : 1.0  
**Créé** : 2024  
**Auteur** : GitHub Copilot + Data2AI Academy  
**Grade** : Tutoriel Complet ?????

