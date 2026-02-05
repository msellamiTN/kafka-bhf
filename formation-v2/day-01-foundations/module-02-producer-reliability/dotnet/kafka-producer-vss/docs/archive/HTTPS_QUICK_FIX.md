# ?? SOLUTION RAPIDE - HTTPS Docker ne fonctionne pas

## ? Problème

```
https://localhost:5001/swagger/ui/index.html ? Non accessible
http://localhost:5000/health ? Fonctionne ?
```

---

## ? Solution Immédiate (2 minutes)

### Option 1: Utiliser HTTP (Recommandé pour Dev)

```powershell
# Pas besoin de modifier le code!
# Utilisez simplement HTTP:

# Health Check
curl http://localhost:5000/health

# Swagger UI
Start-Process http://localhost:5000/swagger/ui/index.html
```

**Avantages:**
- ? Fonctionne immédiatement
- ? Pas de problèmes de certificats
- ? Plus rapide en développement

**Quand utiliser:**
- Développement local
- Tests en développement
- Environnement de dev

---

### Option 2: Désactiver HTTPS dans Program.cs

Modifiez `Program.cs` :

```csharp
var app = builder.Build();

// Commentez cette ligne:
// app.UseHttpsRedirection();  // ? Commenté

app.UseHttpsRedirection();  // ? Cette ligne cause le problème en Docker

app.UseAuthorization();
app.MapControllers();
app.MapGet("/health", () => Results.Ok("OK"));
app.Run();
```

**Changement:**
```csharp
// AVANT:
app.UseHttpsRedirection();

// APRÈS:
// app.UseHttpsRedirection();  // Commenté pour Docker
```

---

### Option 3: Recréer le Conteneur (HTTP uniquement)

Utilisez le script de diagnostic :

```powershell
.\Diagnose-HTTPS-Issue.ps1

# Puis choisir option 2
# Le script va créer un Dockerfile HTTP-only
# Et relancer le conteneur
```

---

## ?? Recommandation

### Pour la Développement

```
? Utilisez HTTP sur port 5000
? API fonctionne correctement
? Pas de problèmes HTTPS
```

### Pour la Production

```
? Configurez HTTPS correctement
? Utilisez des certificats valides
? Mettez HTTPS Redirect
```

---

## ?? Résumé

| Situation | Solution |
|-----------|----------|
| Dev Local | HTTP sur 5000 ? |
| Tests | HTTP sur 5000 ? |
| Production | HTTPS avec certificats valides |
| Docker Dev | HTTP sans HTTPS ? |

---

## ?? Commandes Rapides

### Tester HTTP

```powershell
# Health Check
curl http://localhost:5000/health

# Réponse attendue:
# OK
```

### Tester Swagger UI

```powershell
# Ouvrir dans le navigateur
Start-Process http://localhost:5000/swagger/ui/index.html
```

### Voir les logs

```powershell
docker logs -f kafka-producer-test
```

### Arrêter et redémarrer

```powershell
docker stop kafka-producer-test
docker start kafka-producer-test
```

---

## ?? Diagnostic Avancé

```powershell
# Exécuter le script complet
.\Diagnose-HTTPS-Issue.ps1

# Ce script va:
# 1. Vérifier l'état du conteneur
# 2. Tester HTTP
# 3. Tester HTTPS
# 4. Afficher les logs
# 5. Proposer des solutions
```

---

## ? Vérification Finale

```powershell
# 1. Vérifier que l'API répond
curl http://localhost:5000/health
# Résultat: OK ?

# 2. Vérifier que le conteneur est en cours d'exécution
docker ps
# Doit montrer kafka-producer-test ?

# 3. Vérifier que les ports écoutent
netstat -ano | findstr "5000"
# Doit montrer port 5000 LISTENING ?
```

---

## ?? Explication Technique

### Pourquoi HTTPS ne fonctionne pas dans Docker?

```
1. Le certificat HTTPS auto-signé est généré en Docker
2. Le client PowerShell/curl rejette les certificats auto-signés
3. Sans -SkipCertificateCheck, la connexion HTTPS échoue
4. Solution: Utiliser HTTP en développement
```

### Comment l'API démarre?

```
1. ASPNETCORE_URLS=http://+:80;https://+:443
2. L'app essaie de démarrer sur les 2 protocoles
3. Si le certificat n'est pas bon ? Erreur HTTPS
4. HTTP fonctionne toujours (port 80 = 5000)
```

---

## ?? Solution Recommandée

```powershell
# 1. Arrêter l'API actuelle
docker stop kafka-producer-test

# 2. Exécuter le diagnostic
.\Diagnose-HTTPS-Issue.ps1

# 3. Choisir option 2 (HTTP-only)

# 4. Tester
curl http://localhost:5000/health

# 5. Accéder à Swagger
Start-Process http://localhost:5000/swagger/ui/index.html
```

**Résultat:** ? API opérationnelle en HTTP

---

**Status:** ? **SOLUTION FOURNIE**

**Action:** ?? **Exécutez `.\Diagnose-HTTPS-Issue.ps1`**

**Durée:** ?? **2-5 minutes**

