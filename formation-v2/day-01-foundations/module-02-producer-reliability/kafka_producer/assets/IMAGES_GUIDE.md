# ?? Guide des Images pour le README

Ce fichier explique comment organiser les images pour le guide visuel du projet.

## ?? Structure des Répertoires

```
assets/
??? IMAGES_GUIDE.md                  # Ce fichier
??? 01-visual-studio-launch.png      # Visual Studio 2022 lancé
??? 02-create-new-project.png        # Écran "Create a new project"
??? 03-select-api-template.png       # Sélection du modèle ASP.NET Core Web API
??? 04-configure-project.png         # Remplissage du nom et chemin du projet
??? 05-select-dotnet-version.png     # Sélection de .NET 10.0
??? 06-project-created.png           # Projet créé avec succès
??? [autres images futures]
```

## ?? Spécifications des Images

### 01 - Visual Studio Launch
- **Contenu** : Fenêtre d'accueil de Visual Studio 2022
- **Dimension recommandée** : 1200x900 px
- **Description** : Montre l'écran initial avec les options "Create a new project"

### 02 - Create New Project
- **Contenu** : Dialog ou page "Create a new project"
- **Dimension recommandée** : 1200x900 px
- **Description** : Écran pour sélectionner le type de projet

### 03 - Select API Template
- **Contenu** : Résultats de recherche "ASP.NET Core Web API"
- **Dimension recommandée** : 1200x900 px
- **Description** : Sélection du modèle de projet

### 04 - Configure Project
- **Contenu** : Formulaire de configuration avec les champs remplis
- **Dimension recommandée** : 1200x900 px
- **Description** : Remplissage du nom, chemin, et options du projet

### 05 - Select .NET Version
- **Contenu** : Page de sélection de framework et options supplémentaires
- **Dimension recommandée** : 1200x900 px
- **Description** : Choix de .NET 10.0, authentication, HTTPS

### 06 - Project Created
- **Contenu** : Solution Explorer avec le projet créé
- **Dimension recommandée** : 1200x900 px
- **Description** : Structure complète du projet prête à utiliser

## ?? Format des Images

- **Format** : PNG ou JPEG (PNG recommandé pour meilleure qualité)
- **Compression** : Optimisez pour le web (< 500 KB par image)
- **Ratio d'aspect** : 4:3 ou 16:10

## ?? Comment Capturer les Screenshots

### Sous Windows
```powershell
# Méthode 1 : Utiliser l'outil Capture
# Pressez: Win + Shift + S

# Méthode 2 : Utiliser un outil tiers
# Utilisez Snagit, Greenshot, ou ShareX
```

### Sous macOS
```bash
# Capture de fenêtre active
Cmd + Shift + 4 + Spacebar
```

### Outils Recommandés
1. **Greenshot** - Gratuit et puissant
2. **Snagit** - Professionnel avec édition
3. **ShareX** - Open source et complet
4. **FastStone Capture** - Léger et rapide

## ?? Checklist de Capture

Pour chaque screenshot :
- [ ] L'image est claire et lisible
- [ ] Le texte est visible
- [ ] Les éléments UI importants sont mis en évidence
- [ ] Pas d'informations sensibles (mots de passe, tokens, etc.)
- [ ] La taille est optimisée (< 500 KB)
- [ ] Le format est PNG ou JPEG
- [ ] Le nom suit la convention `XX-description.png`

## ?? Vérification

Pour vérifier que les images s'affichent correctement dans le README :

```bash
# Clonez le repo
git clone https://github.com/msellamiTN/kafka-bhf

# Ouvrez le README dans un éditeur markdown
# Vérifiez que les images sont visibles

# Ou rendez-vous sur GitHub
# https://github.com/msellamiTN/kafka-bhf
```

## ?? Ressources

- [Markdown Image Syntax](https://www.markdownguide.org/basic-syntax/#images)
- [GitHub Flavored Markdown](https://github.github.com/gfm/)
- [Image Optimization](https://tinypng.com/)

---

**Note** : Ajoutez les images PNG dans ce dossier `assets/` et elles s'afficheront automatiquement dans le README via les liens Markdown.
