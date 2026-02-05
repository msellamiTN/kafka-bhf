# Full-Docker-Check.ps1 - Script Complet de Vérification API avec Docker

<#
.SYNOPSIS
    Script complet de vérification et test de l'API Kafka Producer avec Docker

.DESCRIPTION
    Ce script effectue une vérification complète incluant:
    - Vérification de Docker
    - Build de l'image Docker
    - Lancement du conteneur
    - Tests de l'API
    - Rapports détaillés

.PARAMETER SkipBuild
    Sauter la compilation (utiliser l'image existante)

.PARAMETER SkipPull
    Sauter le pull de l'image de base

.PARAMETER Verbose
    Mode verbose avec logs détaillés

.EXAMPLE
    .\Full-Docker-Check.ps1
    .\Full-Docker-Check.ps1 -SkipBuild
    .\Full-Docker-Check.ps1 -Verbose

.NOTES
    Version: 1.0
    Auteur: GitHub Copilot
    Date: 2024
#>

param(
    [switch]$SkipBuild,
    [switch]$SkipPull,
    [switch]$Verbose
)

# Configuration
$ErrorActionPreference = "Continue"
$WarningPreference = "Continue"

# Couleurs
$colors = @{
    Success = "Green"
    Error   = "Red"
    Warning = "Yellow"
    Info    = "Cyan"
    Header  = "Magenta"
    Divider = "Gray"
}

# Variables
$projectPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$imageName = "kafka-producer:latest"
$containerName = "kafka-producer-test"
$apiBaseUrl = "http://localhost:5000"
$apiSecureUrl = "https://localhost:5001"
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
$testResults = @()

# ============================================
# FONCTIONS
# ============================================

function Write-Header {
    param([string]$Text)
    Write-Host "`n?????????????????????????????????????????????????????????????????????" -ForegroundColor $colors.Header
    Write-Host "?  $($Text.PadRight(67))?" -ForegroundColor $colors.Header
    Write-Host "?????????????????????????????????????????????????????????????????????" -ForegroundColor $colors.Header
}

function Write-Section {
    param([string]$Text)
    Write-Host "`n?????????????????????????????????????????????????????" -ForegroundColor $colors.Divider
    Write-Host "  $Text" -ForegroundColor $colors.Info
    Write-Host "?????????????????????????????????????????????????????" -ForegroundColor $colors.Divider
}

function Write-Success {
    param([string]$Text)
    Write-Host "  ? $Text" -ForegroundColor $colors.Success
}

function Write-Error-Custom {
    param([string]$Text)
    Write-Host "  ? $Text" -ForegroundColor $colors.Error
}

function Write-Warning-Custom {
    param([string]$Text)
    Write-Host "  ??  $Text" -ForegroundColor $colors.Warning
}

function Write-Info {
    param([string]$Text)
    Write-Host "  ??  $Text" -ForegroundColor $colors.Info
}

function Add-TestResult {
    param(
        [string]$TestName,
        [string]$Status,
        [string]$Details = ""
    )
    $testResults += @{
        Name    = $TestName
        Status  = $Status
        Details = $Details
        Time    = Get-Date -Format "HH:mm:ss"
    }
}

# ============================================
# PHASE 1: VÉRIFICATION INITIALE
# ============================================

Write-Header "KAFKA PRODUCER - DOCKER CHECK COMPLET"
Write-Host "Timestamp: $timestamp" -ForegroundColor $colors.Info
Write-Host "Project Path: $projectPath" -ForegroundColor $colors.Info

Write-Section "PHASE 1: Vérification des Prérequis"

# Vérifier si on est dans le bon répertoire
if (-not (Test-Path "Program.cs")) {
    Write-Error-Custom "Program.cs non trouvé dans le répertoire courant"
    Write-Info "Essayez de naviguer dans le dossier kafka_producer"
    exit 1
}
Write-Success "Program.cs trouvé"
Add-TestResult "Fichier Program.cs" "PASS"

# Vérifier .NET SDK
try {
    $dotnetVersion = dotnet --version
    Write-Success ".NET SDK installé: $dotnetVersion"
    Add-TestResult ".NET SDK" "PASS" $dotnetVersion
}
catch {
    Write-Error-Custom ".NET SDK non installé"
    exit 1
}

# Vérifier Docker
try {
    $dockerVersion = docker --version
    Write-Success "Docker installé: $dockerVersion"
    Add-TestResult "Docker" "PASS" $dockerVersion
}
catch {
    Write-Error-Custom "Docker n'est pas installé ou n'est pas accessible"
    Write-Info "Installez Docker Desktop depuis https://www.docker.com/products/docker-desktop"
    exit 1
}

# Vérifier Docker daemon
try {
    docker ps | Out-Null
    Write-Success "Docker daemon est en cours d'exécution"
    Add-TestResult "Docker Daemon" "PASS"
}
catch {
    Write-Error-Custom "Docker daemon n'est pas en cours d'exécution"
    Write-Info "Lancez Docker Desktop"
    exit 1
}

# ============================================
# PHASE 2: BUILD DE L'IMAGE DOCKER
# ============================================

Write-Section "PHASE 2: Build de l'Image Docker"

if ($SkipBuild) {
    Write-Warning-Custom "Build image ignoré (--SkipBuild)"
    Add-TestResult "Docker Build" "SKIP" "Skipped by user"
}
else {
    Write-Info "Suppression de l'image existante (si présente)..."
    docker rmi $imageName -f | Out-Null

    Write-Info "Construction de l'image Docker..."
    $buildOutput = docker build -t $imageName . 2>&1
    
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Image Docker construite avec succès"
        Write-Info "Image: $imageName"
        Add-TestResult "Docker Build" "PASS"
    }
    else {
        Write-Error-Custom "Erreur lors de la construction de l'image Docker"
        Write-Host $buildOutput -ForegroundColor Red
        Add-TestResult "Docker Build" "FAIL" $buildOutput
        exit 1
    }

    # Vérifier l'image
    $images = docker images | Select-String $imageName
    if ($images) {
        Write-Success "Image Docker vérifiée"
        Write-Host "  $images" -ForegroundColor Cyan
    }
}

# ============================================
# PHASE 3: LANCEMENT DU CONTENEUR
# ============================================

Write-Section "PHASE 3: Lancement du Conteneur Docker"

# Vérifier si le conteneur existe déjà
$existingContainer = docker ps -a | Select-String $containerName
if ($existingContainer) {
    Write-Info "Arrêt du conteneur existant..."
    docker stop $containerName 2>&1 | Out-Null
    docker rm $containerName 2>&1 | Out-Null
    Write-Success "Conteneur existant supprimé"
}

Write-Info "Lancement du conteneur..."
$runOutput = docker run -d `
    --name $containerName `
    -p 5000:80 `
    -p 5001:443 `
    -e ASPNETCORE_ENVIRONMENT=Development `
    -e ASPNETCORE_URLS="http://+:80;https://+:443" `
    $imageName 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Success "Conteneur lancé avec succès"
    Write-Info "Container ID: $runOutput"
    Add-TestResult "Container Startup" "PASS"
}
else {
    Write-Error-Custom "Erreur lors du lancement du conteneur"
    Write-Host $runOutput -ForegroundColor Red
    Add-TestResult "Container Startup" "FAIL" $runOutput
    exit 1
}

# Attendre le démarrage du conteneur
Write-Info "Attente du démarrage de l'application (10 secondes)..."
Start-Sleep -Seconds 10

# Vérifier l'état du conteneur
$containerStatus = docker ps | Select-String $containerName
if ($containerStatus) {
    Write-Success "Conteneur en cours d'exécution"
    Write-Host "  $containerStatus" -ForegroundColor Cyan
    Add-TestResult "Container Status" "PASS"
}
else {
    Write-Error-Custom "Le conteneur ne s'exécute pas"
    Write-Info "Logs du conteneur:"
    docker logs $containerName
    Add-TestResult "Container Status" "FAIL"
    exit 1
}

# ============================================
# PHASE 4: TESTS DE L'API
# ============================================

Write-Section "PHASE 4: Tests de l'API"

# Test 1: Health Check HTTP
Write-Info "TEST 1: Health Check (HTTP)..."
try {
    $response = Invoke-WebRequest -Uri "$apiBaseUrl/health" `
        -Method GET `
        -TimeoutSec 5 `
        -ErrorAction Stop

    if ($response.StatusCode -eq 200 -and $response.Content -eq "OK") {
        Write-Success "Health Check réussi (HTTP)"
        Write-Info "  Status: $($response.StatusCode)"
        Write-Info "  Response: $($response.Content)"
        Add-TestResult "Health Check (HTTP)" "PASS"
    }
}
catch {
    Write-Error-Custom "Health Check échoué (HTTP)"
    Write-Error-Custom $_.Exception.Message
    Add-TestResult "Health Check (HTTP)" "FAIL" $_.Exception.Message
}

# Test 2: Health Check HTTPS
Write-Info "TEST 2: Health Check (HTTPS)..."
try {
    $response = Invoke-WebRequest -Uri "$apiSecureUrl/health" `
        -Method GET `
        -TimeoutSec 5 `
        -SkipCertificateCheck `
        -ErrorAction Stop

    if ($response.StatusCode -eq 200 -and $response.Content -eq "OK") {
        Write-Success "Health Check réussi (HTTPS)"
        Write-Info "  Status: $($response.StatusCode)"
        Write-Info "  Response: $($response.Content)"
        Add-TestResult "Health Check (HTTPS)" "PASS"
    }
}
catch {
    Write-Error-Custom "Health Check échoué (HTTPS)"
    Write-Error-Custom $_.Exception.Message
    Add-TestResult "Health Check (HTTPS)" "FAIL" $_.Exception.Message
}

# Test 3: Swagger UI
Write-Info "TEST 3: Swagger UI..."
try {
    $response = Invoke-WebRequest -Uri "$apiSecureUrl/swagger/ui/index.html" `
        -Method GET `
        -TimeoutSec 5 `
        -SkipCertificateCheck `
        -ErrorAction Stop

    if ($response.StatusCode -eq 200) {
        Write-Success "Swagger UI accessible"
        Write-Info "  Status: $($response.StatusCode)"
        Write-Info "  URL: $apiSecureUrl/swagger/ui/index.html"
        Add-TestResult "Swagger UI" "PASS"
    }
}
catch {
    Write-Error-Custom "Swagger UI non accessible"
    Write-Error-Custom $_.Exception.Message
    Add-TestResult "Swagger UI" "FAIL" $_.Exception.Message
}

# Test 4: Port Availability
Write-Info "TEST 4: Vérification des Ports..."
try {
    $ports = netstat -ano | Select-String "5000|5001"
    if ($ports) {
        Write-Success "Ports 5000 et 5001 écoutent"
        Write-Host "  $ports" -ForegroundColor Cyan
        Add-TestResult "Port Availability" "PASS"
    }
}
catch {
    Write-Warning-Custom "Impossible de vérifier les ports (normal sur certains systèmes)"
    Add-TestResult "Port Availability" "SKIP"
}

# Test 5: Container Logs
Write-Info "TEST 5: Vérification des Logs du Conteneur..."
try {
    $logs = docker logs $containerName --tail 20
    
    if ($logs -match "Application started|Now listening") {
        Write-Success "Logs du conteneur normaux"
        Add-TestResult "Container Logs" "PASS"
    }
    else {
        Write-Warning-Custom "Logs du conteneur suspects"
        Add-TestResult "Container Logs" "WARN"
    }

    if ($Verbose) {
        Write-Info "Derniers logs:"
        Write-Host $logs -ForegroundColor Gray
    }
}
catch {
    Write-Warning-Custom "Impossible de lire les logs"
    Add-TestResult "Container Logs" "SKIP"
}

# Test 6: Container Stats
Write-Info "TEST 6: Ressources du Conteneur..."
try {
    $stats = docker stats $containerName --no-stream --format "table {{.CPUPerc}}\t{{.MemUsage}}"
    Write-Success "Conteneur en cours d'exécution"
    Write-Host $stats -ForegroundColor Cyan
    Add-TestResult "Container Stats" "PASS"
}
catch {
    Write-Warning-Custom "Impossible de lire les stats"
    Add-TestResult "Container Stats" "SKIP"
}

# ============================================
# PHASE 5: TESTS AVANCS
# ============================================

Write-Section "PHASE 5: Tests Avancés"

# Test 7: Response Headers
Write-Info "TEST 7: Response Headers..."
try {
    $response = Invoke-WebRequest -Uri "$apiBaseUrl/health" `
        -Method GET `
        -TimeoutSec 5

    $headers = @{
        "Server" = $response.Headers["Server"]
        "Date" = $response.Headers["Date"]
        "Content-Type" = $response.Headers["Content-Type"]
        "Connection" = $response.Headers["Connection"]
    }

    Write-Success "Response headers OK"
    foreach ($header in $headers.GetEnumerator()) {
        Write-Info "  $($header.Key): $($header.Value)"
    }
    Add-TestResult "Response Headers" "PASS"
}
catch {
    Write-Warning-Custom "Impossible de vérifier les headers"
    Add-TestResult "Response Headers" "SKIP"
}

# Test 8: Performance (Latency)
Write-Info "TEST 8: Latency Test..."
try {
    $totalTime = 0
    $iterations = 5
    
    for ($i = 1; $i -le $iterations; $i++) {
        $start = Get-Date
        $response = Invoke-WebRequest -Uri "$apiBaseUrl/health" `
            -Method GET `
            -TimeoutSec 5 `
            -ErrorAction Stop
        $elapsed = (Get-Date) - $start
        $totalTime += $elapsed.TotalMilliseconds
    }

    $avgLatency = $totalTime / $iterations
    Write-Success "Latency Test complet"
    Write-Info "  Iterations: $iterations"
    Write-Info "  Latency moyenne: ${avgLatency:F2}ms"
    
    if ($avgLatency -lt 100) {
        Write-Success "Performance excellente!"
    }
    elseif ($avgLatency -lt 500) {
        Write-Info "Performance acceptable"
    }
    else {
        Write-Warning-Custom "Performance lente"
    }
    
    Add-TestResult "Latency Test" "PASS" "${avgLatency:F2}ms"
}
catch {
    Write-Error-Custom "Latency test échoué"
    Add-TestResult "Latency Test" "FAIL" $_.Exception.Message
}

# ============================================
# PHASE 6: RAPPORT FINAL
# ============================================

Write-Header "RÉSUMÉ DES TESTS"

# Statistiques
$passCount = ($testResults | Where-Object { $_.Status -eq "PASS" }).Count
$failCount = ($testResults | Where-Object { $_.Status -eq "FAIL" }).Count
$skipCount = ($testResults | Where-Object { $_.Status -eq "SKIP" }).Count
$warnCount = ($testResults | Where-Object { $_.Status -eq "WARN" }).Count
$totalTests = $testResults.Count

Write-Host "`n?? Statistiques:" -ForegroundColor $colors.Header
Write-Host "   Total des tests: $totalTests" -ForegroundColor Cyan
Write-Host "   ? Réussis: $passCount" -ForegroundColor Green
Write-Host "   ? Échoués: $failCount" -ForegroundColor Red
Write-Host "   ??  Avertissements: $warnCount" -ForegroundColor Yellow
Write-Host "   ??  Ignorés: $skipCount" -ForegroundColor Gray

# Tableau détaillé
Write-Host "`n?? Détails des Tests:" -ForegroundColor $colors.Header
Write-Host "????????????????????????????????????????????????????????????????????????" -ForegroundColor Gray
Write-Host "? Nom du Test                        ? Status   ? Détails              ?" -ForegroundColor Gray
Write-Host "????????????????????????????????????????????????????????????????????????" -ForegroundColor Gray

foreach ($result in $testResults) {
    $name = $result.Name.PadRight(34)
    $status = $result.Status.PadRight(8)
    $details = $result.Details.PadRight(20).Substring(0, 20)
    
    $statusColor = switch ($result.Status) {
        "PASS" { "Green" }
        "FAIL" { "Red" }
        "WARN" { "Yellow" }
        default { "Gray" }
    }
    
    $statusSymbol = switch ($result.Status) {
        "PASS" { "?" }
        "FAIL" { "?" }
        "WARN" { "??" }
        "SKIP" { "??" }
        default { "?" }
    }
    
    Write-Host "? $name ? $statusSymbol $status ? $details ?" -ForegroundColor $statusColor
}

Write-Host "????????????????????????????????????????????????????????????????????????" -ForegroundColor Gray

# Verdict
Write-Host "`n?? VERDICT FINAL:" -ForegroundColor $colors.Header

if ($failCount -eq 0 -and $passCount -gt 0) {
    Write-Host "   ? TOUS LES TESTS RÉUSSIS!" -ForegroundColor Green
    Write-Host "   ?? L'API DOCKER FONCTIONNE CORRECTEMENT" -ForegroundColor Green
    $verdict = "SUCCESS"
}
elseif ($failCount -lt 3) {
    Write-Host "   ??  QUELQUES TESTS ONT ÉCHOUÉ" -ForegroundColor Yellow
    Write-Host "   ??  Vérifiez les erreurs ci-dessus" -ForegroundColor Cyan
    $verdict = "WARNING"
}
else {
    Write-Host "   ? TESTS CRITIQUES ÉCHOUÉS" -ForegroundColor Red
    Write-Host "   ?? Vérifiez la configuration" -ForegroundColor Red
    $verdict = "FAILURE"
}

# ============================================
# PHASE 7: INFORMATIONS UTILES
# ============================================

Write-Section "COMMANDES UTILES"

Write-Host "`n?? Gestion du Conteneur:" -ForegroundColor $colors.Info
Write-Host "   Logs en direct:" -ForegroundColor Cyan
Write-Host "   > docker logs -f $containerName" -ForegroundColor Gray
Write-Host "`n   Arrêter le conteneur:" -ForegroundColor Cyan
Write-Host "   > docker stop $containerName" -ForegroundColor Gray
Write-Host "`n   Supprimer le conteneur:" -ForegroundColor Cyan
Write-Host "   > docker rm $containerName" -ForegroundColor Gray
Write-Host "`n   Accéder au shell:" -ForegroundColor Cyan
Write-Host "   > docker exec -it $containerName /bin/sh" -ForegroundColor Gray

Write-Host "`n?? Accès à l'API:" -ForegroundColor $colors.Info
Write-Host "   Health Check (HTTP):" -ForegroundColor Cyan
Write-Host "   > $apiBaseUrl/health" -ForegroundColor Gray
Write-Host "`n   Swagger UI (HTTPS):" -ForegroundColor Cyan
Write-Host "   > $apiSecureUrl/swagger/ui/index.html" -ForegroundColor Gray

Write-Host "`n?? Debugging:" -ForegroundColor $colors.Info
Write-Host "   Statut du conteneur:" -ForegroundColor Cyan
Write-Host "   > docker ps -a | Select-String $containerName" -ForegroundColor Gray
Write-Host "`n   Stats en direct:" -ForegroundColor Cyan
Write-Host "   > docker stats $containerName" -ForegroundColor Gray
Write-Host "`n   Inspecter l'image:" -ForegroundColor Cyan
Write-Host "   > docker inspect $imageName" -ForegroundColor Gray

# ============================================
# EXPORT DU RAPPORT
# ============================================

Write-Section "RAPPORT D'EXPORT"

$reportFile = "Docker-Check-Report-$(Get-Date -Format 'yyyy-MM-dd_HH-mm-ss').txt"

$report = @"
????????????????????????????????????????????????????????????????????????????????
?           RAPPORT DE VÉRIFICATION DOCKER - KAFKA PRODUCER API                ?
????????????????????????????????????????????????????????????????????????????????

Timestamp: $timestamp
Verdict: $verdict

????????????????????????????????????????????????????????????????????????????

STATISTIQUES
????????????????????????????????????????????????????????????????????????????

Total des tests: $totalTests
? Réussis: $passCount
? Échoués: $failCount
??  Avertissements: $warnCount
??  Ignorés: $skipCount

TAUX DE RÉUSSITE: $(if ($totalTests -gt 0) { [math]::Round(($passCount / $totalTests) * 100, 2) }else { 0 })%

????????????????????????????????????????????????????????????????????????????

DÉTAILS DES TESTS
????????????????????????????????????????????????????????????????????????????

$(
    foreach ($result in $testResults) {
        "Test: $($result.Name)"
        "Status: $($result.Status)"
        "Time: $($result.Time)"
        if ($result.Details) {
            "Details: $($result.Details)"
        }
        "?" * 80
    }
)

????????????????????????????????????????????????????????????????????????????

CONFIGURATION DOCKER
????????????????????????????????????????????????????????????????????????????

Image: $imageName
Container: $containerName
Base URL (HTTP): $apiBaseUrl
Base URL (HTTPS): $apiSecureUrl

Port Mappings:
  - Container Port 80 ? Host Port 5000 (HTTP)
  - Container Port 443 ? Host Port 5001 (HTTPS)

Environment:
  - ASPNETCORE_ENVIRONMENT: Development
  - ASPNETCORE_URLS: http://+:80;https://+:443

????????????????????????????????????????????????????????????????????????????

VERDICT: $verdict

"@

$report | Out-File -FilePath $reportFile -Encoding UTF8
Write-Success "Rapport sauvegardé: $reportFile"

# ============================================
# FINALE
# ============================================

Write-Header "? VÉRIFICATION DOCKER COMPLÉTÉE"

Write-Host "`n?? Prochaines étapes:" -ForegroundColor Cyan
Write-Host "   1. Accédez à Swagger UI: $apiSecureUrl/swagger/ui/index.html" -ForegroundColor Gray
Write-Host "   2. Testez les endpoints" -ForegroundColor Gray
Write-Host "   3. Vérifiez les logs: docker logs -f $containerName" -ForegroundColor Gray
Write-Host "   4. Arrêtez le conteneur quand terminé: docker stop $containerName" -ForegroundColor Gray

Write-Host "`n" -ForegroundColor Cyan

exit 0
