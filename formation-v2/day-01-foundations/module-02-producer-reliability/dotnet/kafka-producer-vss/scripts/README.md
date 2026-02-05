# 🛠️ Scripts Kafka Producer

> Scripts utilitaires pour le développement et les tests du projet Kafka Producer

---

## 📋 Vue d'ensemble

Ce répertoire contient les scripts PowerShell pour automatiser les tâches de développement, de build et de test du projet Kafka Producer.

---

## 📁 Scripts Disponibles

### 🔧 **Scripts de Build et Test**
- **`Run-Final-Test.ps1`** - Exécution des tests finaux
- **`Test-API.ps1`** - Tests complets de l'API Kafka
- **`Full-Docker-Check.ps1`** - Vérification complète Docker

### 🛠️ **Scripts de Maintenance**
- **`Cleanup-and-Retry.ps1`** - Nettoyage et retry
- **`Diagnose-HTTPS-Issue.ps1`** - Diagnostic des problèmes HTTPS
- **`Quick-Fix-HTTP-Only.ps1`** - Correction rapide HTTP only

### 🚀 **Scripts de Déploiement**
- **`Final-Fix-And-Test.ps1`** - Fix final et tests

---

## 🎯 Utilisation

### Exécution des Tests
```powershell
# Tests complets de l'API
.\Test-API.ps1

# Tests finaux
.\Run-Final-Test.ps1
```

### Maintenance Docker
```powershell
# Vérification Docker complète
.\Full-Docker-Check.ps1

# Nettoyage et retry
.\Cleanup-and-Retry.ps1
```

### Résolution de Problèmes
```powershell
# Diagnostic HTTPS
.\Diagnose-HTTPS-Issue.ps1

# Fix rapide HTTP only
.\Quick-Fix-HTTP-Only.ps1
```

---

## ⚠️ Notes

- Les scripts sont conçus pour PowerShell sur Windows
- Certains scripts nécessitent des droits d'administrateur
- Exécuter dans le contexte du projet kafka_producer

---

## 🔍 Recherche par Catégorie

### Tests
- `Run-Final-Test.ps1`
- `Test-API.ps1`

### Docker
- `Full-Docker-Check.ps1`
- `Cleanup-and-Retry.ps1`

### Maintenance
- `Diagnose-HTTPS-Issue.ps1`
- `Quick-Fix-HTTP-Only.ps1`
- `Final-Fix-And-Test.ps1`

---

*Scripts maintenus par Data2AI Academy - BHF Kafka Training*
