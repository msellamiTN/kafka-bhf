# 📋 Guide Complet - Producteur Kafka ASP.NET Core (.NET 8)

## 🎯 Bienvenue !

Ce guide complet vous aidera à **configurer, développer et déployer** un producteur Kafka haute performance en utilisant **ASP.NET Core 8** et la bibliothèque **Confluent.Kafka**.

**Pour qui ?** Développeurs débutants à intermédiaires souhaitant intégrer Kafka dans leur architecture microservices.
**Durée estimée :** 30-45 minutes
**Niveau de difficulté :** 🟡 Intermédiaire

---

## 📋 Table des Matières

| # | Section | ⏱️ Temps |
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

## 📋 Prérequis

### 🔧 Requis Absolus

- **📦 .NET 8 SDK** 📥 : [Télécharger](https://dotnet.microsoft.com/download/dotnet/8.0)
  - Vérifiez : `dotnet --version` (doit être ≥ 8.0)
- **Git** : Pour versionner et cloner
  - Vérifiez : `git --version`
- **Un éditeur de code** :
  - **Visual Studio 2022** (recommandé) : [Télécharger](https://visualstudio.microsoft.com/)
  - **Visual Studio Code** : [Télécharger](https://code.visualstudio.com/)

### 🐧 Optionnel mais Recommandé

- **Docker Desktop** : Pour conteneuriser
  - Vérifiez : `docker --version`
  - [Télécharger](https://www.docker.com/products/docker-desktop)

---

## 🚀 Créer un Nouveau Projet ASP.NET Core API

### 🖱️ Méthode 1 : Interface Graphique (Visual Studio 2022)

#### Étape 1 : Lancer Visual Studio 2022

![Lancer Visual Studio 2022](assets/01-visual-studio-launch.png)

Ouvrez Visual Studio 2022 depuis le menu Démarrer ou le raccourci bureau.

#### Étape 2 : Créer un Nouveau Projet

![Créer un nouveau projet](assets/02-create-new-project.png)

- Cliquez sur **"Create a new project"** ou allez à **File → New → Project**

#### Étape 3 : Sélectionner le Modèle API

![Sélectionner le modèle ASP.NET Core Web API](assets/03-select-api-template.png)

- Recherchez **"ASP.NET Core Web API"**
- Sélectionnez le modèle
- Cliquez sur **"Next"**

#### Étape 4 : Configurer le Projet

![Configurer le projet](assets/04-configure-project.png)

Remplissez les informations suivantes :

- **Project name** : `kafka_producer`
- **Location** : Choisissez le chemin `D:\Data2AI Academy\Kafka\kafka-bhf\formation-v2\day-01-foundations\module-02-producer-reliability\`
- **Solution name** : `kafka_producer`
- Cochez **"Place solution and project in the same directory"** (optionnel)
- Cliquez sur **"Next"**

#### Étape 5 : Informations Supplémentaires

![Sélectionner .NET 8 et options](assets/05-infos-dotnet-container.png)

Configurez les options suivantes :

- **Framework** : Sélectionnez **".NET 8.0"**
- **Authentication type** : Laissez à **"None"**
- **Configure for HTTPS** : Cochez cette option
- **Use controllers (uncheck to use minimal APIs)** : Décochez pour utiliser les APIs minimales
- **Enable OpenAPI support** : Cochez pour Swagger/OpenAPI
- Cliquez sur **"Create"**

#### Étape 6 : Projet Créé

![Projet créé avec succès](assets/06-project-created.png)

Votre nouveau projet ASP.NET Core API est maintenant créé avec :
- ✅ Structure de base avec `Program.cs`, `Controllers/`, etc.
- ✅ Le fichier `.csproj` configuré
- ✅ Le dossier `Properties/` avec configurations de lancement
- ✅ Swagger/OpenAPI activé pour la documentation API

### 💻 Méthode 2 : Ligne de Commande (CLI)

Si vous préférez créer le projet via PowerShell/Terminal :

```powershell
# Naviguer vers le répertoire souhaité
cd "D:\Data2AI Academy\Kafka\kafka-bhf\formation-v2\day-01-foundations\module-02-producer-reliability\"

# Créer un nouveau projet ASP.NET Core API
dotnet new webapi -n kafka_producer

# Naviguer dans le projet
cd kafka_producer

# Mettre à jour le fichier .csproj pour .NET 8
# Ouvrez kafka_producer.csproj et changez <TargetFramework>net10.0</TargetFramework> en <TargetFramework>net8.0</TargetFramework>

# Restaurer les dépendances
dotnet restore

# Ajouter le package Confluent.Kafka
dotnet add package Confluent.Kafka

# Lancer l'application
dotnet run
```

**Options CLI expliquées** :
- `-n kafka_producer` : Nom du projet
- Le template par défaut crée un projet .NET 10.0 (doit être modifié manuellement pour .NET 8)
- Les contrôleurs sont utilisés par défaut (peut être modifié pour APIs minimales)
- HTTPS est activé par défaut
- OpenAPI (Swagger) est activé par défaut

**Modification manuelle requise** :
Après la création, ouvrez `kafka_producer.csproj` et modifiez :
```xml
<!-- Avant -->
<TargetFramework>net10.0</TargetFramework>

<!-- Après -->
<TargetFramework>net8.0</TargetFramework>
```

**Résultat** : L'application démarre sur `https://localhost:5001` ou `http://localhost:5000`

---

## ⚙️ Configuration Kafka

### Étape 1 : Ajouter Confluent.Kafka

```powershell
# Ajouter le package Confluent.Kafka
dotnet add package Confluent.Kafka

# Vérifier l'installation
dotnet list package
```

### Étape 2 : Configurer le Producer

Créez un fichier `KafkaProducerService.cs` :

```csharp
using Confluent.Kafka;

public class KafkaProducerService
{
    private readonly IProducer<string, string> _producer;
    private readonly string _bootstrapServers;

    public KafkaProducerService(IConfiguration configuration)
    {
        _bootstrapServers = configuration["Kafka:BootstrapServers"] 
            ?? "localhost:9092";
        
        var config = new ProducerConfig
        {
            BootstrapServers = _bootstrapServers,
            EnableIdempotence = true,
            Acks = Acks.All,
            MessageSendMaxRetries = 3,
            RetryBackoffMs = 1000,
            MessageTimeoutMs = 5000
        };

        _producer = new ProducerBuilder<string, string>(config).Build();
    }

    public async Task<DeliveryResult<string, string>> SendMessageAsync(
        string topic, 
        string key, 
        string message)
    {
        try
        {
            var msg = new Message<string, string>
            {
                Key = key,
                Value = message
            };

            return await _producer.ProduceAsync(topic, msg);
        }
        catch (ProduceException<string, string> ex)
        {
            Console.WriteLine($"Error producing message: {ex.Error.Reason}");
            throw;
        }
    }

    public void Dispose()
    {
        _producer?.Dispose();
    }
}
```

### Étape 3 : Mettre à jour Program.cs

```csharp
var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Ajouter le service Kafka
builder.Services.AddSingleton<KafkaProducerService>();

// Configuration Kafka
builder.Services.Configure<KafkaOptions>(
    builder.Configuration.GetSection("Kafka"));

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

// Endpoint Kafka
app.MapPost("/api/kafka/send", async (KafkaProducerService producer, 
    string topic, string key, string message) =>
{
    try
    {
        var result = await producer.SendMessageAsync(topic, key, message);
        return Results.Ok($"Message sent to offset {result.Offset}");
    }
    catch (Exception ex)
    {
        return Results.Problem($"Error sending message: {ex.Message}");
    }
});

app.Run();
```

### Étape 4 : Configuration appsettings.json

```json
{
  "Kafka": {
    "BootstrapServers": "localhost:9092"
  },
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*"
}
```

---

## ⚡ Étapes Rapides

### 1️⃣ Créer le Projet
```bash
dotnet new webapi -n kafka_producer
cd kafka_producer
```

### 2️⃣ Ajouter Kafka
```bash
dotnet add package Confluent.Kafka
```

### 3️⃣ Configurer Service
- Créer `KafkaProducerService.cs`
- Mettre à jour `Program.cs`
- Configurer `appsettings.json`

### 4️⃣ Tester
```bash
dotnet run
```

---

## 🐳 Utilisation Docker

### Créer Dockerfile

```dockerfile
FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
WORKDIR /app
EXPOSE 80
EXPOSE 443

FROM mcr.microsoft.com/dotnet/sdk:8.0 AS build
WORKDIR /src
COPY ["kafka_producer.csproj", "./"]
RUN dotnet restore "./kafka_producer.csproj"
COPY . .
WORKDIR "/src/."
RUN dotnet build "kafka_producer.csproj" -c Release -o /app/build

FROM build AS publish
RUN dotnet publish "kafka_producer.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "kafka_producer.dll"]
```

### Construire et Exécuter

```bash
# Construire l'image
docker build -t kafka-producer .

# Exécuter le conteneur
docker run -p 8080:80 kafka-producer
```

---

## 📁 Structure du Projet

```
kafka_producer/
├── Controllers/
│   └── WeatherForecastController.cs
├── Services/
│   └── KafkaProducerService.cs
├── Properties/
│   └── launchSettings.json
├── appsettings.Development.json
├── appsettings.json
├── kafka_producer.csproj
├── Program.cs
└── Dockerfile
```

---

## 🛠️ Résolution des Erreurs

### Erreurs Communes

#### 1. **Kafka Connection Failed**
```bash
# Vérifier que Kafka tourne
docker ps | grep kafka

# Vérifier les ports
netstat -an | findstr 9092
```

#### 2. **Package Restore Failed**
```bash
# Nettoyer et restaurer
dotnet clean
dotnet restore
```

#### 3. **Port Already in Use**
```bash
# Tuer le processus sur le port
netstat -ano | findstr :5001
taskkill /PID <PID> /F
```

---

## ⚡ Commandes Utiles

```bash
# Lancer l'application
dotnet run

# Build en mode Release
dotnet build -c Release

# Publier pour production
dotnet publish -c Release -o ./publish

# Tester avec curl
curl -X POST "https://localhost:5001/api/kafka/send" 
     -H "Content-Type: application/json" 
     -d '{"topic":"test","key":"key1","message":"Hello Kafka"}'
```

---

## 🔐 Secrets Utilisateur

```bash
# Gérer les secrets
dotnet user-secrets init
dotnet user-secrets set "Kafka:BootstrapServers" "localhost:9092"
```

---

## 📚 Ressources Utiles

- **[Confluent.Kafka Documentation](https://docs.confluent.io/kafka-clients/dotnet/current/overview.html)**
- **[.NET 8 Documentation](https://docs.microsoft.com/dotnet/)**
- **[Apache Kafka Documentation](https://kafka.apache.org/documentation/)**
- **[Docker .NET Guide](https://docs.docker.com/language/dotnet/)**

---

## ✅ Checklist de Vérification

- [ ] .NET 8 SDK installé
- [ ] Kafka cluster disponible
- [ ] Projet créé avec .NET 8
- [ ] Package Confluent.Kafka ajouté
- [ ] KafkaProducerService implémenté
- [ ] Program.cs configuré
- [ ] appsettings.json mis à jour
- [ ] Application démarre sans erreur
- [ ] Endpoint Kafka répond correctement

---

## 💡 Conseils de Développement

1. **Utilisez l'idempotence** : `EnableIdempotence = true`
2. **Configurez les retries** : `MessageSendMaxRetries = 3`
3. **Gérez les exceptions** : Try-catch autour des appels Kafka
4. **Monitor les performances** : Utilisez des métriques
5. **Testez en local** : Avant déploiement en production

---

## 📞 Support

Pour toute question ou problème :
- 📧 Email : support@example.com
- 💬 Discord : [Join our community](https://discord.gg/example)
- 📖 Documentation : [Wiki](https://github.com/example/wiki)

---

## 📂 Structure des Fichiers

### Fichiers Principaux

| Fichier | Description |
|---------|-------------|
| `Program.cs` | Point d'entrée et configuration |
| `KafkaProducerService.cs` | Service Kafka personnalisé |
| `appsettings.json` | Configuration de l'application |
| `Dockerfile` | Configuration Docker |
| `kafka_producer.csproj` | Fichier de projet .NET |

### Dossiers Importants

| Dossier | Contenu |
|---------|---------|
| `Controllers/` | Contrôleurs API |
| `Services/` | Services métier |
| `Properties/` | Configuration de lancement |

---

**🎉 Félicitations !** Vous avez maintenant un producteur Kafka ASP.NET Core 8 fonctionnel !

Pour aller plus loin, explorez les fonctionnalités avancées de Kafka :
- Transactions
- Partitions
- Consumer Groups
- Monitoring et Métriques

*Bonne programmation ! 🚀*
