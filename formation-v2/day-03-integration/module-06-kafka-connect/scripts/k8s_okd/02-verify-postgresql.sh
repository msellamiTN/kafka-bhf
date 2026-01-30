#!/bin/bash

echo "☸️  Mode OKD/K3s: Vérification PostgreSQL"
echo "======================================="

# Vérifier que Kafka Connect est déployé
echo "🔍 Vérification de Kafka Connect..."
kubectl get kafkaconnect -n kafka
kubectl get pods -n kafka -l strimzi.io/kind=KafkaConnect

# Vérifier que PostgreSQL est prêt
echo "⏳ Vérification de PostgreSQL..."
kubectl wait --for=condition=Ready pod -l app.kubernetes.io/instance=postgres-banking -n kafka --timeout=60s
kubectl get pods -n kafka -l app.kubernetes.io/instance=postgres-banking

# Connexion et vérification du schéma
echo "📋 Vérification des tables PostgreSQL:"
kubectl exec -it -n kafka postgres-banking-postgresql-0 -- psql -U banking -d core_banking -c "\dt"

echo ""
echo "👥 Vérification des données clients:"
kubectl exec -it -n kafka postgres-banking-postgresql-0 -- psql -U banking -d core_banking -c "SELECT customer_number, first_name, last_name, customer_type FROM customers;"

echo ""
echo "📡 Vérification de la publication CDC:"
kubectl exec -it -n kafka postgres-banking-postgresql-0 -- psql -U banking -d core_banking -c "SELECT * FROM pg_publication_tables WHERE pubname = 'dbz_publication';"

echo ""
echo "✅ PostgreSQL vérifié avec succès!"
echo ""
echo "Prochaine étape:"
echo "  ./03-verify-sqlserver.sh"
