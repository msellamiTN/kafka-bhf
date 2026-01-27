# Scripts PowerShell pour le Module 02

# Script 1 : Test de l'idempotence
Write-Host "🔄 Test de l'idempotence - 3 exécutions pour 1 seul message" -ForegroundColor Green

for ($i=1; $i -le 3; $i++) {
    Write-Host "🔄 Exécution $i/3" -ForegroundColor Yellow
    mvn exec:java -Dexec.mainClass="com.bhf.kafka.IdempotentProducerApp"
    Start-Sleep 1
}

Write-Host "✅ Test terminé - Vérifiez les résultats avec le consumer" -ForegroundColor Green

# Script 2 : Vérification des résultats
Write-Host "🔍 Vérification des messages dans Kafka" -ForegroundColor Blue
docker exec kafka kafka-console-consumer --topic bhf-transactions --bootstrap-server localhost:9092 --from-beginning --property print.key=true --timeout-ms 10000
