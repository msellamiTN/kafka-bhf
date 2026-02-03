# ?? Guide des Images pour le Tutoriel

## Structure des Images Requises

Tous les fichiers images doivent être placés dans le dossier `assets/`

```
assets/
??? 01-launch-visual-studio.png
??? 02-create-new-project-button.png
??? 03-search-web-api.png
??? 04-web-api-template-selected.png
??? 05-configure-project.png
??? 06-additional-information.png
??? 07-creating-project.png
??? 08-project-structure.png
??? 09-nuget-package-manager.png
??? 10-create-folder.png
??? 11-create-class.png
??? 12-kafka-service-code.png
??? 13-create-controller.png
??? 14-kafka-controller-code.png
??? 15-program-cs-updated.png
??? 16-appsettings-json.png
??? 17-appsettings-development.png
??? 18-delete-weather-controller.png
??? 19-build-project.png
??? 20-run-application.png
??? 21-swagger-interface.png
??? 22-debug-output.png
??? 23-create-dockerfile.png
??? 24-dockerfile-code.png
??? 25-create-docker-compose.png
??? 26-docker-desktop-download.png
??? 27-stop-debugger.png
??? 28-open-powershell.png
??? 29-docker-compose-up.png
??? 30-docker-containers-running.png
??? 31-docker-logs.png
??? 32-test-containerized-api.png
??? 33-curl-test.png
??? 34-docker-compose-down.png
```

## Spécifications des Images

### Format Général
- **Format** : PNG ou JPEG
- **Résolution** : 1920x1080 ou 1280x720 minimum
- **Compression** : Optimisée pour web (< 500 KB par image)
- **Ratio** : 16:9 ou 4:3

---

## Détails de Chaque Image

### 01-launch-visual-studio.png
- **Contenu** : Écran Windows avec menu Démarrer
- **Étape** : Recherche de Visual Studio 2022
- **Légende** : "Cliquez sur le bouton Windows et tapez Visual Studio 2022"

### 02-create-new-project-button.png
- **Contenu** : Écran d'accueil de Visual Studio 2022
- **Étape** : Avant de cliquer sur "Create a new project"
- **Légende** : "Cliquez sur Create a new project"

### 03-search-web-api.png
- **Contenu** : Dialogue de recherche de template
- **Étape** : Barre de recherche avec "api" tapé
- **Légende** : "Tapez 'api' dans la barre de recherche"

### 04-web-api-template-selected.png
- **Contenu** : Template "ASP.NET Core Web API" en évidence
- **Étape** : Template sélectionné
- **Légende** : "Sélectionnez ASP.NET Core Web API"

### 05-configure-project.png
- **Contenu** : Formulaire de configuration avec champs remplis
- **Étape** : Avant de cliquer "Next"
- **Légende** : "Remplissez les paramètres du projet"
- **Points clés** :
  - Project name: kafka_producer
  - Location: ...module-02-producer-reliability\

### 06-additional-information.png
- **Contenu** : Dialogue "Additional Information"
- **Étape** : Sélection de .NET 8.0 et options
- **Légende** : "Configurez les options additionnelles"
- **Points clés** :
  - Framework: .NET 8.0
  - Authentication: None
  - HTTPS: Coché

### 07-creating-project.png
- **Contenu** : Barre de progression de création
- **Étape** : VS en train de créer le projet
- **Légende** : "Attendez la création du projet"

### 08-project-structure.png
- **Contenu** : Solution Explorer avec la structure du projet
- **Étape** : Après création du projet
- **Légende** : "Structure initiale du projet"
- **Points clés** :
  - Controllers/
  - Program.cs
  - appsettings.json

### 09-nuget-package-manager.png
- **Contenu** : NuGet Package Manager interface
- **Étape** : Avant d'installer Confluent.Kafka
- **Légende** : "Ouvrez NuGet Package Manager"

### 10-create-folder.png
- **Contenu** : Menu contextuel pour créer un dossier
- **Étape** : Clic droit sur le projet
- **Légende** : "Add ? New Folder"

### 11-create-class.png
- **Contenu** : Menu "Add ? Class"
- **Étape** : Clic droit sur le dossier Services
- **Légende** : "Créez une nouvelle classe"

### 12-kafka-service-code.png
- **Contenu** : Code du KafkaProducerService.cs
- **Étape** : Après avoir copié le code
- **Légende** : "Implémentation du service Kafka"

### 13-create-controller.png
- **Contenu** : Menu pour créer un contrôleur
- **Étape** : Dans le dossier Controllers
- **Légende** : "Créez KafkaController.cs"

### 14-kafka-controller-code.png
- **Contenu** : Code du KafkaController.cs
- **Étape** : API endpoints visibles
- **Légende** : "Endpoints REST de l'API"

### 15-program-cs-updated.png
- **Contenu** : Contenu mis à jour de Program.cs
- **Étape** : Avec enregistrement des services
- **Légende** : "Configuration mise à jour"

### 16-appsettings-json.png
- **Contenu** : Configuration JSON avec paramètres Kafka
- **Étape** : appsettings.json complété
- **Légende** : "Paramètres de configuration"

### 17-appsettings-development.png
- **Contenu** : appsettings.Development.json
- **Étape** : Configuration de développement
- **Légende** : "Paramètres de développement"

### 18-delete-weather-controller.png
- **Contenu** : Menu contextuel supprimer
- **Étape** : Sur WeatherForecastController.cs
- **Légende** : "Supprimez le contrôleur d'exemple"

### 19-build-project.png
- **Contenu** : Menu Build Solution
- **Étape** : Build en cours
- **Légende** : "Compilez le projet"

### 20-run-application.png
- **Contenu** : Bouton Play (démarrage)
- **Étape** : Avant de cliquer pour lancer
- **Légende** : "Cliquez sur Play ou F5"

### 21-swagger-interface.png
- **Contenu** : Interface Swagger UI
- **Étape** : Application en cours d'exécution
- **Légende** : "Interface Swagger pour tester l'API"

### 22-debug-output.png
- **Contenu** : Fenêtre Output avec logs
- **Étape** : Logs d'application affichés
- **Légende** : "Observez les logs de l'application"

### 23-create-dockerfile.png
- **Contenu** : Menu pour créer Dockerfile
- **Étape** : Add ? New Item
- **Légende** : "Créez le Dockerfile"

### 24-dockerfile-code.png
- **Contenu** : Contenu du Dockerfile
- **Étape** : Code multi-stage build
- **Légende** : "Configuration Docker multi-stage"

### 25-create-docker-compose.png
- **Contenu** : Menu pour créer docker-compose.yml
- **Étape** : Add ? New Item
- **Légende** : "Créez docker-compose.yml"

### 26-docker-desktop-download.png
- **Contenu** : Écran de téléchargement Docker Desktop
- **Étape** : Page d'installation
- **Légende** : "Téléchargez Docker Desktop"

### 27-stop-debugger.png
- **Contenu** : Bouton d'arrêt (carré rouge)
- **Étape** : Application en cours d'exécution
- **Légende** : "Cliquez sur le bouton d'arrêt"

### 28-open-powershell.png
- **Contenu** : PowerShell ouvert
- **Étape** : Terminal dans le dossier projet
- **Légende** : "Ouvrez PowerShell dans le projet"

### 29-docker-compose-up.png
- **Contenu** : Terminal avec commande docker-compose up
- **Étape** : Conteneurs en cours de démarrage
- **Légende** : "Lancez docker-compose up -d"

### 30-docker-containers-running.png
- **Contenu** : Output de docker-compose ps
- **Étape** : Tous les conteneurs actifs
- **Légende** : "Vérifiez que les conteneurs tournent"

### 31-docker-logs.png
- **Contenu** : Logs Docker affichés
- **Étape** : Output de docker-compose logs
- **Légende** : "Observez les logs des conteneurs"

### 32-test-containerized-api.png
- **Contenu** : Swagger UI de l'API containerisée
- **Étape** : http://localhost:5000/swagger
- **Légende** : "Testez l'API containerisée"

### 33-curl-test.png
- **Contenu** : PowerShell avec commande curl
- **Étape** : Réponse du serveur
- **Légende** : "Testez avec cURL"

### 34-docker-compose-down.png
- **Contenu** : Terminal avec docker-compose down
- **Étape** : Arrêt des conteneurs
- **Légende** : "Arrêtez les conteneurs avec docker-compose down"

---

## ?? Guide de Capture des Images

### Résolution Recommandée
- **Primaire** : 1920x1080 (Full HD)
- **Alternative** : 1280x720 (HD)
- **Minimum** : 1024x768 (VGA)

### Outils de Capture
1. **Windows Snipping Tool** (intégré)
   - Win + Shift + S
   - Gratuit et simple

2. **Greenshot** (recommandé)
   - https://getgreenshot.org/
   - Édition intégrée

3. **ShareX** (complet)
   - https://getsharex.com/
   - Riche en options

4. **FastStone Capture**
   - Léger et rapide

### Optimisation des Images
1. **Format** : Exporter en PNG
2. **Compression** : Utiliser TinyPNG
3. **Taille** : Cible < 500 KB par image

### Annotation des Images
1. **Utiliser** : Paint ou Photoshop
2. **Ajouter** : Flèches, cercles, numéros
3. **Mettre en évidence** : Les éléments clés

---

## ?? Checklist de Couverture

- [ ] 01 - Launch Visual Studio
- [ ] 02 - Create New Project Button
- [ ] 03 - Search Web API
- [ ] 04 - Web API Template Selected
- [ ] 05 - Configure Project
- [ ] 06 - Additional Information
- [ ] 07 - Creating Project
- [ ] 08 - Project Structure
- [ ] 09 - NuGet Package Manager
- [ ] 10 - Create Folder
- [ ] 11 - Create Class
- [ ] 12 - Kafka Service Code
- [ ] 13 - Create Controller
- [ ] 14 - Kafka Controller Code
- [ ] 15 - Program CS Updated
- [ ] 16 - AppSettings JSON
- [ ] 17 - AppSettings Development
- [ ] 18 - Delete Weather Controller
- [ ] 19 - Build Project
- [ ] 20 - Run Application
- [ ] 21 - Swagger Interface
- [ ] 22 - Debug Output
- [ ] 23 - Create Dockerfile
- [ ] 24 - Dockerfile Code
- [ ] 25 - Create Docker Compose
- [ ] 26 - Docker Desktop Download
- [ ] 27 - Stop Debugger
- [ ] 28 - Open PowerShell
- [ ] 29 - Docker Compose Up
- [ ] 30 - Docker Containers Running
- [ ] 31 - Docker Logs
- [ ] 32 - Test Containerized API
- [ ] 33 - cURL Test
- [ ] 34 - Docker Compose Down

---

## ? Processus de Placement

1. **Capturer** chaque image suivant le tutoriel
2. **Nommer** exactement comme spécifié
3. **Optimiser** la taille et la compression
4. **Placer** dans le dossier `assets/`
5. **Vérifier** que les liens Markdown fonctionnent

---

## ?? Vérification des Liens

Dans le tutoriel, les images sont référencées ainsi :

```markdown
### ?? Image Référence
```
assets/01-launch-visual-studio.png
```
```

Pour vérifier que ça fonctionne :
- Ouvrez le fichier markdown
- Les images doivent s'afficher

---

**Version** : 1.0  
**Créé** : 2024  
**Total d'Images** : 34  
**Taille Totale Estimée** : ~15-17 MB

