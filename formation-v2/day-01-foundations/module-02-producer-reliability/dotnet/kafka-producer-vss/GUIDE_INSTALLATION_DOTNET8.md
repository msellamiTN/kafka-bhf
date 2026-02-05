# ?? Guide Complet - Installation .NET 8 pour le Projet Kafka Producer

## ?? Table des Matières

1. [Vérification de l'Installation Existante](#vérification-existante)
2. [Installation .NET 8.0](#installation-net-80)
3. [Vérification Post-Installation](#vérification-post)
4. [Configuration du Projet](#configuration-projet)
5. [Première Exécution](#première-exécution)
6. [Troubleshooting](#troubleshooting)

---

## ? Vérification de l'Installation Existante

### Étape 1: Ouvrir PowerShell

```powershell
# Windows: Win + X ? PowerShell
# Ou: Win + R ? powershell
```

### Étape 2: Vérifier la Version .NET Actuelle

```powershell
PS > dotnet --version
```

#### Résultats Attendus

```
? 8.0.x        ? Déjà installé, parfait!
? 7.0.x        ? Peut être mis à niveau
? 6.0.x        ? Peut être mis à niveau
? Version < 6  ? À installer .NET 8
? Erreur       ? .NET non installé
```

### Étape 3: Lister les SDKs Installés

```powershell
PS > dotnet --list-sdks
```

#### Exemple de Sortie

```
8.0.100 [C:\Program Files\dotnet\sdk]
7.0.300 [C:\Program Files\dotnet\sdk]
6.0.400 [C:\Program Files\dotnet\sdk]
```

---

## ?? Installation .NET 8.0

### Option 1: Windows (Recommandée - Installez)

#### Étape 1: Télécharger

1. Allez sur: [https://dotnet.microsoft.com/download/dotnet/8.0](https://dotnet.microsoft.com/download/dotnet/8.0)

2. Sélectionnez:
   ```
   Windows ? x64 (ou ARM64 si vous avez un Mac M1/M2)
   ```

3. Téléchargez le fichier `.exe`

#### Étape 2: Installer

```
1. Double-cliquez sur le fichier .exe
2. Suivez l'assistant d'installation
3. Acceptez les termes
4. Cliquez sur "Install"
5. Redémarrez votre ordinateur (recommandé)
```

#### Étape 3: Vérifier l'Installation

```powershell
# Ouvrez un nouveau PowerShell
PS > dotnet --version

# Résultat attendu:
# 8.0.x
```

---

### Option 2: Installer via Chocolatey

#### Prérequis: Installer Chocolatey

```powershell
# Ouvrez PowerShell en administrateur

# Copier/coller:
Set-ExecutionPolicy Bypass -Scope Process -Force; `
[System.Net.ServicePointManager]::SecurityProtocol = `
[System.Net.ServicePointManager]::SecurityProtocol -bor 3072; `
iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))
```

#### Installer .NET 8

```powershell
# Redémarrez PowerShell

choco install dotnet-sdk-8.0 -y
```

---

### Option 3: Installer via Windows Package Manager (WinGet)

```powershell
winget install Microsoft.DotNet.SDK.8
```

---

## ?? Vérification Post-Installation

### Étape 1: Vérifier la Version

```powershell
PS > dotnet --version

# Résultat attendu:
# 8.0.x (ex: 8.0.100, 8.0.101, etc.)
```

### Étape 2: Vérifier Tous les SDKs

```powershell
PS > dotnet --list-sdks

# Résultat attendu:
# 8.0.100 [C:\Program Files\dotnet\sdk]
# 7.0.300 [C:\Program Files\dotnet\sdk]
```

### Étape 3: Afficher les Runtimes

```powershell
PS > dotnet --list-runtimes

# Résultat attendu:
# Microsoft.AspNetCore.App 8.0.x [C:\Program Files\dotnet\shared\Microsoft.AspNetCore.App]
# Microsoft.NETCore.App 8.0.x [C:\Program Files\dotnet\shared\Microsoft.NETCore.App]
```

### Étape 4: Information Complète

```powershell
PS > dotnet --info

# Affiche une information détaillée:
# - Version du SDK
# - Version du runtime
# - Chemins d'installation
# - Variables d'environnement
```

---

## ?? Configuration du Projet

### Étape 1: Naviguer vers le Projet

```powershell
cd "D:\Data2AI Academy\Kafka\kafka-bhf\formation-v2\day-01-foundations\module-02-producer-reliability\kafka_producer"

# Vérifier que vous êtes au bon endroit:
PS > dir

# Vous devez voir:
# - kafka_producer.csproj
# - Program.cs
# - appsettings.json
# - Controllers/
# - Services/
```

### Étape 2: Restaurer les Dépendances

```powershell
PS > dotnet restore

# Résultat attendu:
# - Downloading packages...
# - Restoring NuGet packages...
# - Determining projects to restore...
# - Restoration completed
```

**Cela peut prendre 1-2 minutes la première fois**

### Étape 3: Vérifier les Packages Installés

```powershell
PS > dotnet list package

# Résultat attendu:
# Project 'kafka_producer' has the following package references
# [net8.0]:
#   Confluent.Kafka -> 2.13.0
#   Microsoft.AspNetCore.OpenApi -> 8.0.11
#   Microsoft.VisualStudio.Azure.Containers.Tools.Targets -> 1.23.0
```

### Étape 4: Compiler le Projet

```powershell
PS > dotnet build

# Résultat attendu:
# Build succeeded
# 0 Warning(s)
# 0 Error(s)
```

**Cela peut prendre 30-60 secondes la première fois**

---

## ?? Première Exécution

### Étape 1: Lancer l'Application

```powershell
PS > dotnet run

# Résultat attendu:
# info: Microsoft.Hosting.Lifetime[14]
#   Now listening on: https://localhost:5001
#   Now listening on: http://localhost:5000
#   Application started.
```

### Étape 2: Accéder à l'API

Ouvrez votre navigateur et allez à:

```
http://localhost:5000/health
```

#### Résultat Attendu

```
OK
```

### Étape 3: Accéder à Swagger (OpenAPI)

```
https://localhost:5001/swagger/ui/index.html
```

#### Résultat Attendu

```
Interface Swagger avec les endpoints disponibles
```

### Étape 4: Arrêter l'Application

```powershell
# Dans le terminal:
Ctrl + C

# Résultat:
# Application terminated
```

---

## ?? Commandes Utiles

### Développement

```powershell
# Lancer en mode "watch" (auto-reload)
PS > dotnet watch

# Exécuter les tests
PS > dotnet test

# Lancer avec configuration Release
PS > dotnet run -c Release

# Build en mode Release
PS > dotnet build -c Release
```

### Packages

```powershell
# Lister tous les packages
PS > dotnet list package

# Lister les mises à jour disponibles
PS > dotnet list package --outdated

# Mettre à jour un package
PS > dotnet add package Confluent.Kafka --version 2.14.0

# Supprimer un package
PS > dotnet remove package NomDuPackage
```

### Publication

```powershell
# Publier pour production
PS > dotnet publish -c Release -o ./publish

# Publier en tant que conteneur
PS > dotnet publish --os linux --arch x64 -c Release -p:PublishProfile=DefaultContainer
```

---

## ?? Troubleshooting

### ? Problème 1: "dotnet: command not found"

**Cause**: .NET n'est pas installé ou pas dans le PATH

**Solution**:
```powershell
# Option 1: Installer .NET 8 (voir section Installation)

# Option 2: Ajouter au PATH manuellement
# Le chemin est généralement: C:\Program Files\dotnet
# Ajouter au PATH:
# 1. Win + Pause/Break
# 2. Variables d'environnement avancées
# 3. Ajouter C:\Program Files\dotnet au PATH

# Option 3: Redémarrer PowerShell/VS
```

---

### ? Problème 2: "Build failed"

**Cause**: Erreur de compilation

**Solution**:
```powershell
# 1. Vérifier les erreurs
dotnet build

# 2. Supprimer le cache de build
dotnet clean
dotnet build

# 3. Restaurer les packages
dotnet restore
dotnet build

# 4. Vérifier la version de .NET
dotnet --version
# Doit être 8.0.x

# 5. Lire les erreurs détaillées
# Les messages d'erreur indiquent le problème exact
```

---

### ? Problème 3: "NuGet restore failed"

**Cause**: Problème avec les packages

**Solution**:
```powershell
# 1. Vider le cache NuGet
dotnet nuget locals all --clear

# 2. Restaurer à nouveau
dotnet restore

# 3. Vérifier la connexion internet
# Assurez-vous que votre connexion fonctionne

# 4. Vérifier le fichier nuget.config
# Vérifier que les sources sont correctes
```

---

### ? Problème 4: "Port 5000/5001 déjà utilisé"

**Cause**: Un autre processus utilise le port

**Solution**:
```powershell
# 1. Trouver le processus utilisant le port
netstat -ano | findstr :5000

# 2. Tuer le processus
taskkill /PID <PID> /F

# 3. Relancer l'application
dotnet run

# Alternative: Utiliser un autre port
dotnet run --urls="https://localhost:5002"
```

---

### ? Problème 5: "Cannot connect to Kafka"

**Cause**: Kafka ne s'exécute pas

**Solution**:
```powershell
# 1. Vérifier que Kafka s'exécute
docker ps
# Doit voir "kafka" et "zookeeper" en cours d'exécution

# 2. Lancer Kafka avec Docker Compose
cd kafka_producer
docker-compose up -d

# 3. Attendre que Kafka soit prêt (30-60 secondes)

# 4. Relancer l'application
dotnet run
```

---

### ? Problème 6: "Certificate error"

**Cause**: Certificat HTTPS auto-signé non approuvé

**Solution (Développement Only)**:
```powershell
# Accepter le certificat auto-signé (développement)
$env:ASPNETCORE_ENVIRONMENT = "Development"
dotnet run

# OU: Désactiver HTTPS en développement
# Dans appsettings.Development.json, ajouter:
# "Kestrel": {
#   "Endpoints": {
#     "Http": {
#       "Url": "http://localhost:5000"
#     }
#   }
# }
```

---

## ?? Vérification Complète

### Checklist Finale

```powershell
PS > Write-Host "=== Vérification Complète ===" 
PS > Write-Host "1. Version .NET:"
PS > dotnet --version

PS > Write-Host "2. SDKs installés:"
PS > dotnet --list-sdks

PS > Write-Host "3. Runtimes installés:"
PS > dotnet --list-runtimes

PS > Write-Host "4. Packages du projet:"
PS > dotnet list package

PS > Write-Host "5. Test de build:"
PS > dotnet build

PS > Write-Host "6. ? Tout est OK!"
```

---

## ?? Résumé Installation

### ? Étapes Complètes

```
1. ? Télécharger .NET 8.0
2. ? Installer .NET 8.0
3. ? Redémarrer l'ordinateur
4. ? Vérifier l'installation (dotnet --version)
5. ? Naviguer vers le projet
6. ? Restaurer les dépendances (dotnet restore)
7. ? Compiler (dotnet build)
8. ? Lancer (dotnet run)
9. ? Accéder à http://localhost:5000/health
10. ? Vérifier Swagger sur https://localhost:5001/swagger
```

### ? Configuration Finale

```
.NET 8.0 SDK              : ? Installé
Visual Studio 2022        : ? (optionnel)
Confluent.Kafka 2.13.0    : ? Téléchargé
Docker Desktop            : ? (optionnel)
Kafka Cluster             : ? (via Docker Compose)
```

---

## ?? Vous Êtes Prêt!

Votre environnement .NET 8 est maintenant complètement configuré.

### Prochaines Étapes

```
1. Lancer: dotnet run
2. Accéder: http://localhost:5000/health
3. Tester: Swagger UI
4. Développer: Votre API Kafka
5. Déployer: Via Docker
```

---

**Version** : 1.0  
**Date** : 2024  
**Statut** : ? GUIDE COMPLET  
**Grade** : ????? 

Bon développement ! ??

