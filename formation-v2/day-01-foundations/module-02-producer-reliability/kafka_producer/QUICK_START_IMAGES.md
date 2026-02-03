# ?? QUICK START - Ajouter les Images au Projet

## ? Résumé des Changements

Le README a été amélioré avec :

? **Table des matières** - Navigation facile  
? **Section "Créer un Nouveau Projet"** - Guide complet ASP.NET Core  
? **Placeholders pour 6 images** - Prêts à recevoir les screenshots  
? **Dossier `assets/`** - Créé et organisé  
? **Guides d'ajout d'images** - `IMAGES_GUIDE.md` et `README_IMAGES.md`  

## ?? Prochaines Étapes

### Étape 1 : Capturer les Screenshots

Capturez les 6 images suivantes depuis Visual Studio 2022 :

| # | Nom du Fichier | Contenu |
|---|---|---|
| 1 | `01-visual-studio-launch.png` | Écran d'accueil VS 2022 |
| 2 | `02-create-new-project.png` | Dialog "Create a new project" |
| 3 | `03-select-api-template.png` | Recherche "ASP.NET Core Web API" |
| 4 | `04-configure-project.png` | Formulaire de config (nom, chemin) |
| 5 | `05-select-dotnet-version.png` | Sélection .NET 10 et options |
| 6 | `06-project-created.png` | Solution Explorer - projet créé |

### Étape 2 : Placer les Images

1. Naviguez vers le dossier `assets/` du projet
2. Placez les 6 fichiers PNG capturés
3. Vérifiez que les noms correspondent exactement

```
assets/
??? 01-visual-studio-launch.png
??? 02-create-new-project.png
??? 03-select-api-template.png
??? 04-configure-project.png
??? 05-select-dotnet-version.png
??? 06-project-created.png
```

### Étape 3 : Vérifier

```bash
# Vérifier que les fichiers sont présents
dir assets/

# Vérifier le README affiche correctement les images
# Ouvrez README.md dans un lecteur Markdown
```

### Étape 4 : Commit et Push

```bash
# Ajouter les fichiers
git add README.md assets/

# Commit
git commit -m "docs: add visual guide with screenshots for project creation"

# Push
git push origin main
```

## ?? Conseils pour les Screenshots

- **Résolution** : 1200x900 px ou plus
- **Format** : PNG (meilleure qualité)
- **Taille** : < 500 KB par image (compresser si nécessaire)
- **Qualité** : Texte lisible, UI claire

### Outils Recommandés

- **Windows Snipping Tool** : `Win + Shift + S`
- **Greenshot** : [https://getgreenshot.org/](https://getgreenshot.org/)
- **ShareX** : [https://getsharex.com/](https://getsharex.com/)

## ?? Notes Important

- Les images sont **optionnelles** - Le README fonctionne sans elles
- Les liens Markdown affichent "Image manquante" jusqu'à ce que vous ajoutiez les fichiers
- Une fois ajoutées, GitHub les affichera automatiquement

## ?? Résultat Final

Une fois les images ajoutées, les utilisateurs verront :

```markdown
![Lancer Visual Studio 2022](assets/01-visual-studio-launch.png)
```

Remplacé par une **image visuelle complète** du processus de création du projet.

---

**Pour plus de détails** : Consultez `assets/IMAGES_GUIDE.md`
