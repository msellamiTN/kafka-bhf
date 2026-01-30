#!/bin/bash

echo "☸️  Mode OKD/K3s: Création du connecteur PostgreSQL CDC"
echo "===================================================="

# Créer le connecteur PostgreSQL
echo "🔧 Création du connecteur PostgreSQL..."
curl -i -X POST -H "Accept:application/json" -H "Content-Type:application/json" \
  localhost:31083/connectors \
  -d @day-03-integration/module-06-kafka-connect/connectors/postgres-cdc-connector.json

echo ""
echo "⏳ Attente du démarrage du connecteur..."
sleep 10

# Vérifier le statut du connecteur
echo "🔍 Statut du connecteur PostgreSQL:"
curl -s http://localhost:31083/connectors/postgres-banking-cdc/status | jq

echo ""
echo "📋 Vérification des topics créés:"
kubectl run kafka-topics --rm -it --restart=Never \
  --image=quay.io/strimzi/kafka:latest-kafka-4.0.0 \
  -n kafka -- bin/kafka-topics.sh \
  --bootstrap-server bhf-kafka-kafka-bootstrap:9092 --list | grep banking.postgres

echo ""
echo "✅ Connecteur PostgreSQL créé avec succès!"
echo ""
echo "Prochaine étape:"
echo "  ./05-create-sqlserver-connector.sh"
