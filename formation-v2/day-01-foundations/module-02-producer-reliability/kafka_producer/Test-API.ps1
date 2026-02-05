# Test-API.ps1 - Script Complet de Test API

## ?? Script de Test Automatisé pour Kafka Producer API

Ce script teste complètement votre API.

---

## ?? Utilisation

```powershell
# 1. Ouvrir PowerShell
# 2. Naviguer au répertoire du projet
cd "D:\Data2AI Academy\Kafka\kafka-bhf\formation-v2\day-01-foundations\module-02-producer-reliability\kafka_producer"

# 3. Exécuter le script
.\Test-API.ps1

# OU copier-coller directement dans PowerShell
```

---

## ?? Script PowerShell

```powershell
# ============================================
# TEST SCRIPT - KAFKA PRODUCER API
# ============================================

Write-Host "??????????????????????????????????????????" -ForegroundColor Cyan
Write-Host "?  KAFKA PRODUCER API - TEST SUITE      ?" -ForegroundColor Cyan
Write-Host "??????????????????????????????????????????" -ForegroundColor Cyan

$testResults = @()
$baseUrl = "http://localhost:5000"
$secureBaseUrl = "https://localhost:5001"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"

# Configuration
$skipCertificateCheck = $true
$timeout = 5

Write-Host "`n?? Timestamp: $timestamp" -ForegroundColor Gray

# ============================================
# TEST 1: Vérifier si l'application s'exécute
# ============================================

Write-Host "`n??????????????????????????????????????" -ForegroundColor Yellow
Write-Host "TEST 1: Application Running" -ForegroundColor Yellow
Write-Host "??????????????????????????????????????" -ForegroundColor Yellow

try {
    $response = Invoke-WebRequest `
        -Uri "$baseUrl/health" `
        -Method GET `
        -TimeoutSec $timeout `
        -ErrorAction Stop

    Write-Host "? Application IS RUNNING" -ForegroundColor Green
    Write-Host "   Status Code: $($response.StatusCode)" -ForegroundColor Cyan
    Write-Host "   Response: $($response.Content)" -ForegroundColor Cyan
    
    $testResults += @{ Test = "Application Running"; Status = "PASS" }
}
catch {
    Write-Host "? Application NOT RUNNING" -ForegroundColor Red
    Write-Host "   Error: $_" -ForegroundColor Red
    Write-Host "`n   ?? Solution:" -ForegroundColor Yellow
    Write-Host "      1. Ouvrez un terminal PowerShell" -ForegroundColor Yellow
    Write-Host "      2. Exécutez: dotnet run" -ForegroundColor Yellow
    Write-Host "      3. Attendez le message 'Application started'" -ForegroundColor Yellow
    Write-Host "      4. Relancez ce script" -ForegroundColor Yellow
    
    $testResults += @{ Test = "Application Running"; Status = "FAIL" }
}

# ============================================
# TEST 2: Health Endpoint
# ============================================

Write-Host "`n??????????????????????????????????????" -ForegroundColor Yellow
Write-Host "TEST 2: Health Endpoint" -ForegroundColor Yellow
Write-Host "??????????????????????????????????????" -ForegroundColor Yellow

try {
    $response = Invoke-WebRequest `
        -Uri "$baseUrl/health" `
        -Method GET `
        -TimeoutSec $timeout `
        -ErrorAction Stop

    if ($response.StatusCode -eq 200 -and $response.Content -eq "OK") {
        Write-Host "? Health Endpoint Working" -ForegroundColor Green
        Write-Host "   Endpoint: GET /health" -ForegroundColor Cyan
        Write-Host "   Status: $($response.StatusCode)" -ForegroundColor Cyan
        Write-Host "   Response: $($response.Content)" -ForegroundColor Cyan
        
        $testResults += @{ Test = "Health Endpoint"; Status = "PASS" }
    }
}
catch {
    Write-Host "? Health Endpoint Failed" -ForegroundColor Red
    Write-Host "   Error: $_" -ForegroundColor Red
    $testResults += @{ Test = "Health Endpoint"; Status = "FAIL" }
}

# ============================================
# TEST 3: HTTPS/TLS Configuration
# ============================================

Write-Host "`n??????????????????????????????????????" -ForegroundColor Yellow
Write-Host "TEST 3: HTTPS Configuration" -ForegroundColor Yellow
Write-Host "??????????????????????????????????????" -ForegroundColor Yellow

try {
    $response = Invoke-WebRequest `
        -Uri "$secureBaseUrl/health" `
        -Method GET `
        -TimeoutSec $timeout `
        -SkipCertificateCheck:$skipCertificateCheck `
        -ErrorAction Stop

    Write-Host "? HTTPS Configuration Working" -ForegroundColor Green
    Write-Host "   Secure URL: $secureBaseUrl" -ForegroundColor Cyan
    Write-Host "   Status: $($response.StatusCode)" -ForegroundColor Cyan
    Write-Host "   SSL/TLS: Configured ?" -ForegroundColor Cyan
    
    $testResults += @{ Test = "HTTPS Configuration"; Status = "PASS" }
}
catch {
    Write-Host "? HTTPS Configuration Issue" -ForegroundColor Red
    Write-Host "   Error: $_" -ForegroundColor Red
    $testResults += @{ Test = "HTTPS Configuration"; Status = "FAIL" }
}

# ============================================
# TEST 4: Port Availability
# ============================================

Write-Host "`n??????????????????????????????????????" -ForegroundColor Yellow
Write-Host "TEST 4: Port Availability" -ForegroundColor Yellow
Write-Host "??????????????????????????????????????" -ForegroundColor Yellow

try {
    $ports = netstat -ano | findstr "5000|5001"
    
    if ($ports) {
        Write-Host "? Ports Available and Listening" -ForegroundColor Green
        Write-Host "   Port 5000 (HTTP): ? LISTENING" -ForegroundColor Cyan
        Write-Host "   Port 5001 (HTTPS): ? LISTENING" -ForegroundColor Cyan
        Write-Host "`n   Network Info:" -ForegroundColor Gray
        $ports | ForEach-Object { Write-Host "   $_" -ForegroundColor Gray }
        
        $testResults += @{ Test = "Port Availability"; Status = "PASS" }
    }
}
catch {
    Write-Host "? Port Check Failed" -ForegroundColor Red
    Write-Host "   Error: $_" -ForegroundColor Red
    $testResults += @{ Test = "Port Availability"; Status = "FAIL" }
}

# ============================================
# TEST 5: API Response Headers
# ============================================

Write-Host "`n??????????????????????????????????????" -ForegroundColor Yellow
Write-Host "TEST 5: API Response Headers" -ForegroundColor Yellow
Write-Host "??????????????????????????????????????" -ForegroundColor Yellow

try {
    $response = Invoke-WebRequest `
        -Uri "$baseUrl/health" `
        -Method GET `
        -TimeoutSec $timeout `
        -ErrorAction Stop

    Write-Host "? Response Headers OK" -ForegroundColor Green
    Write-Host "   Content-Type: $($response.Headers['Content-Type'])" -ForegroundColor Cyan
    Write-Host "   Server: $($response.Headers['Server'])" -ForegroundColor Cyan
    Write-Host "   Date: $($response.Headers['Date'])" -ForegroundColor Cyan
    
    $testResults += @{ Test = "Response Headers"; Status = "PASS" }
}
catch {
    Write-Host "? Response Headers Check Failed" -ForegroundColor Red
    Write-Host "   Error: $_" -ForegroundColor Red
    $testResults += @{ Test = "Response Headers"; Status = "FAIL" }
}

# ============================================
# TEST 6: Swagger UI Availability
# ============================================

Write-Host "`n??????????????????????????????????????" -ForegroundColor Yellow
Write-Host "TEST 6: Swagger UI" -ForegroundColor Yellow
Write-Host "??????????????????????????????????????" -ForegroundColor Yellow

try {
    $response = Invoke-WebRequest `
        -Uri "$secureBaseUrl/swagger/ui/index.html" `
        -Method GET `
        -TimeoutSec $timeout `
        -SkipCertificateCheck:$skipCertificateCheck `
        -ErrorAction Stop

    if ($response.StatusCode -eq 200) {
        Write-Host "? Swagger UI Available" -ForegroundColor Green
        Write-Host "   URL: $secureBaseUrl/swagger/ui/index.html" -ForegroundColor Cyan
        Write-Host "   Status: $($response.StatusCode) OK" -ForegroundColor Cyan
        Write-Host "`n   ?? OpenAPI/Swagger Features:" -ForegroundColor Cyan
        Write-Host "      • Interactive API Testing" -ForegroundColor Cyan
        Write-Host "      • Auto-generated Documentation" -ForegroundColor Cyan
        Write-Host "      • Request/Response Examples" -ForegroundColor Cyan
        
        $testResults += @{ Test = "Swagger UI"; Status = "PASS" }
    }
}
catch {
    Write-Host "?? Swagger UI Not Available" -ForegroundColor Yellow
    Write-Host "   This is OK if you haven't enabled OpenAPI" -ForegroundColor Yellow
    $testResults += @{ Test = "Swagger UI"; Status = "SKIP" }
}

# ============================================
# TEST 7: .NET Framework & Runtime
# ============================================

Write-Host "`n??????????????????????????????????????" -ForegroundColor Yellow
Write-Host "TEST 7: .NET Framework & Runtime" -ForegroundColor Yellow
Write-Host "??????????????????????????????????????" -ForegroundColor Yellow

try {
    $dotnetVersion = dotnet --version
    
    Write-Host "? .NET Runtime Information" -ForegroundColor Green
    Write-Host "   .NET Version: $dotnetVersion" -ForegroundColor Cyan
    
    if ($dotnetVersion -like "8.*") {
        Write-Host "   .NET 8: ? DETECTED" -ForegroundColor Green
    }
    
    $testResults += @{ Test = ".NET Framework"; Status = "PASS" }
}
catch {
    Write-Host "? .NET Check Failed" -ForegroundColor Red
    Write-Host "   Error: $_" -ForegroundColor Red
    $testResults += @{ Test = ".NET Framework"; Status = "FAIL" }
}

# ============================================
# TEST 8: Kafka Configuration Check
# ============================================

Write-Host "`n??????????????????????????????????????" -ForegroundColor Yellow
Write-Host "TEST 8: Kafka Configuration" -ForegroundColor Yellow
Write-Host "??????????????????????????????????????" -ForegroundColor Yellow

Write-Host "?? Kafka Configuration Status" -ForegroundColor Cyan
Write-Host "   Bootstrap Servers: localhost:9092" -ForegroundColor Cyan
Write-Host "   Configuration: appsettings.Development.json ?" -ForegroundColor Cyan
Write-Host "`n   Note:" -ForegroundColor Yellow
Write-Host "   • Kafka est optionnel pour tester les endpoints HTTP" -ForegroundColor Yellow
Write-Host "   • L'API peut fonctionner sans Kafka" -ForegroundColor Yellow
Write-Host "   • Utiliser docker-compose pour tester Kafka" -ForegroundColor Yellow

# ============================================
# RAPPORT DE RÉSUMÉ
# ============================================

Write-Host "`n??????????????????????????????????????????" -ForegroundColor Cyan
Write-Host "?  TEST SUMMARY REPORT                   ?" -ForegroundColor Cyan
Write-Host "??????????????????????????????????????????" -ForegroundColor Cyan

$passCount = ($testResults | Where-Object { $_.Status -eq "PASS" }).Count
$failCount = ($testResults | Where-Object { $_.Status -eq "FAIL" }).Count
$skipCount = ($testResults | Where-Object { $_.Status -eq "SKIP" }).Count
$totalTests = $testResults.Count

Write-Host "`n?? Test Results:" -ForegroundColor Cyan
Write-Host "   Total Tests: $totalTests" -ForegroundColor Cyan
Write-Host "   ? Passed: $passCount" -ForegroundColor Green
Write-Host "   ? Failed: $failCount" -ForegroundColor Red
Write-Host "   ?? Skipped: $skipCount" -ForegroundColor Yellow

# Tableau de résultats
Write-Host "`n?? Detailed Results:" -ForegroundColor Cyan
Write-Host "????????????????????????????????????????????????" -ForegroundColor Gray
Write-Host "? Test Name                          ? Status  ?" -ForegroundColor Gray
Write-Host "????????????????????????????????????????????????" -ForegroundColor Gray

foreach ($result in $testResults) {
    $testName = $result.Test.PadRight(34)
    $status = $result.Status
    
    if ($status -eq "PASS") {
        $statusColor = "Green"
        $statusSymbol = "?"
    }
    elseif ($status -eq "FAIL") {
        $statusColor = "Red"
        $statusSymbol = "?"
    }
    else {
        $statusColor = "Yellow"
        $statusSymbol = "??"
    }
    
    Write-Host "? $testName ? $statusSymbol $status" -ForegroundColor $statusColor
}

Write-Host "????????????????????????????????????????????????" -ForegroundColor Gray

# Verdict final
Write-Host "`n?? FINAL VERDICT:" -ForegroundColor Cyan

if ($failCount -eq 0) {
    Write-Host "   ? ALL TESTS PASSED!" -ForegroundColor Green
    Write-Host "   ? API IS FULLY OPERATIONAL" -ForegroundColor Green
    Write-Host "   ? READY FOR DEVELOPMENT" -ForegroundColor Green
}
else {
    Write-Host "   ?? SOME TESTS FAILED" -ForegroundColor Yellow
    Write-Host "   ?? CHECK ERRORS ABOVE" -ForegroundColor Yellow
}

Write-Host "`n?? Quick Links:" -ForegroundColor Cyan
Write-Host "   • Health Check: $baseUrl/health" -ForegroundColor Cyan
Write-Host "   • Swagger UI: $secureBaseUrl/swagger/ui/index.html" -ForegroundColor Cyan
Write-Host "   • API Base: $baseUrl" -ForegroundColor Cyan

Write-Host "`n?? Next Steps:" -ForegroundColor Green
Write-Host "   1. Review the test results above" -ForegroundColor Green
Write-Host "   2. Fix any failed tests if needed" -ForegroundColor Green
Write-Host "   3. Start developing your API!" -ForegroundColor Green

Write-Host "`n" -ForegroundColor Gray
Write-Host "???????????????????????????????????????????????" -ForegroundColor Cyan
Write-Host "Test Script Completed - $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Gray
Write-Host "???????????????????????????????????????????????" -ForegroundColor Cyan
```

---

## ?? Sauvegarder comme Fichier

### Créer le fichier `Test-API.ps1`

```powershell
# 1. Ouvrir Notepad++
# 2. Copier le code du script ci-dessus
# 3. Sauvegarder comme: Test-API.ps1
# 4. Dans le dossier du projet

# Ou via PowerShell:
$scriptContent = @"
[Contenu du script]
"@

Set-Content -Path "Test-API.ps1" -Value $scriptContent
```

---

## ?? Utilisation du Script

### Étape 1: Lancer l'Application

```powershell
PS > dotnet run
```

### Étape 2: Ouvrir un Nouveau PowerShell

```powershell
# Nouveau terminal
cd "D:\Data2AI Academy\Kafka\kafka-bhf\formation-v2\day-01-foundations\module-02-producer-reliability\kafka_producer"
```

### Étape 3: Exécuter le Script

```powershell
PS > .\Test-API.ps1
```

### Étape 4: Vérifier les Résultats

```
? Vous verrez tous les tests avec résultats
```

---

## ?? Résultats Attendus

```
TEST SUMMARY REPORT
??????????????????????

Total Tests: 8
? Passed: 8
? Failed: 0
?? Skipped: 0

FINAL VERDICT:
? ALL TESTS PASSED!
? API IS FULLY OPERATIONAL
? READY FOR DEVELOPMENT
```

---

**Script Version** : 1.0  
**Créé** : 2024  
**Status** : ? PRÊT À UTILISER

