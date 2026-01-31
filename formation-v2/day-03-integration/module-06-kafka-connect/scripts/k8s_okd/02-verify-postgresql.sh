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

# Récupérer les mots de passe PostgreSQL
echo "🔑 Récupération des mots de passe PostgreSQL..."
POSTGRES_PASSWORD=$(kubectl get secret --namespace kafka postgres-banking-postgresql -o jsonpath="{.data.password}" | base64 -d)
POSTGRES_ADMIN_PASSWORD=$(kubectl get secret --namespace kafka postgres-banking-postgresql -o jsonpath="{.data.postgres-password}" | base64 -d)
echo "Mot de passe banking: ${POSTGRES_PASSWORD:0:3}***"
echo "Mot de passe postgres: ${POSTGRES_ADMIN_PASSWORD:0:3}***"

# Créer les tables et données initiales
echo "📋 Création du schéma bancaire PostgreSQL..."
kubectl exec -n kafka postgres-banking-postgresql-0 -- bash -c "PGPASSWORD='${POSTGRES_ADMIN_PASSWORD}' psql -U postgres -d core_banking -c \"
-- Créer l'utilisateur banking s'il n'existe pas
DO \\\$\\$
BEGIN
   IF NOT EXISTS (SELECT FROM pg_catalog.pg_roles WHERE rolname = 'banking') THEN
      CREATE ROLE banking LOGIN PASSWORD '${POSTGRES_PASSWORD}';
   END IF;
END
\\\$;

-- Donner les permissions
GRANT ALL PRIVILEGES ON DATABASE core_banking TO banking;
GRANT ALL ON SCHEMA public TO banking;

-- Créer les tables
CREATE TABLE IF NOT EXISTS customers (
    customer_number SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone VARCHAR(20),
    customer_type VARCHAR(20) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS accounts (
    account_number SERIAL PRIMARY KEY,
    customer_number INTEGER NOT NULL REFERENCES customers(customer_number),
    account_type VARCHAR(20) NOT NULL,
    balance DECIMAL(15,2) NOT NULL DEFAULT 0.00,
    currency VARCHAR(3) NOT NULL DEFAULT 'EUR',
    status VARCHAR(20) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS transactions (
    transaction_id SERIAL PRIMARY KEY,
    account_number INTEGER NOT NULL REFERENCES accounts(account_number),
    transaction_type VARCHAR(20) NOT NULL,
    amount DECIMAL(15,2) NOT NULL,
    description TEXT,
    transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    balance_after DECIMAL(15,2) NOT NULL
);

CREATE TABLE IF NOT EXISTS transfers (
    transfer_id SERIAL PRIMARY KEY,
    from_account_number INTEGER NOT NULL REFERENCES accounts(account_number),
    to_account_number INTEGER NOT NULL REFERENCES accounts(account_number),
    amount DECIMAL(15,2) NOT NULL,
    transfer_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(20) NOT NULL DEFAULT 'PENDING'
);

-- Insérer des données de test
INSERT INTO customers (first_name, last_name, email, phone, customer_type) VALUES
('Jean', 'Dupont', 'jean.dupont@email.com', '+33-1-23456789', 'INDIVIDUAL'),
('Marie', 'Martin', 'marie.martin@email.com', '+33-1-23456788', 'INDIVIDUAL'),
('Entreprise', 'TechCorp', 'contact@techcorp.com', '+33-1-23456787', 'BUSINESS')
ON CONFLICT (email) DO NOTHING;

INSERT INTO accounts (customer_number, account_type, balance, currency, status) VALUES
(1, 'CHECKING', 5000.00, 'EUR', 'ACTIVE'),
(2, 'SAVINGS', 10000.00, 'EUR', 'ACTIVE'),
(3, 'BUSINESS', 50000.00, 'EUR', 'ACTIVE')
ON CONFLICT DO NOTHING;
\""

# Activer la réplication logique et créer la publication
echo "📡 Configuration de la réplication logique..."
kubectl exec -n kafka postgres-banking-postgresql-0 -- bash -c "PGPASSWORD='${POSTGRES_ADMIN_PASSWORD}' psql -U postgres -d core_banking -c \"
-- Activer la réplication logique
ALTER SYSTEM SET wal_level = logical;
ALTER SYSTEM SET max_replication_slots = 4;
ALTER SYSTEM SET max_wal_senders = 4;

-- Créer la publication CDC
DROP PUBLICATION IF EXISTS dbz_publication;
CREATE PUBLICATION dbz_publication FOR TABLE customers, accounts, transactions, transfers;
\""

# Redémarrer PostgreSQL pour appliquer les changements
echo "🔄 Redémarrage de PostgreSQL pour appliquer la configuration..."
kubectl delete pod postgres-banking-postgresql-0 -n kafka
kubectl wait --for=condition=Ready pod -l app.kubernetes.io/instance=postgres-banking -n kafka --timeout=120s

# Vérification finale
echo "📋 Vérification des tables PostgreSQL:"
kubectl exec -n kafka postgres-banking-postgresql-0 -- bash -c "PGPASSWORD='${POSTGRES_PASSWORD}' psql -U banking -d core_banking -c \"\\dt\""

echo ""
echo "👥 Vérification des données clients:"
kubectl exec -n kafka postgres-banking-postgresql-0 -- bash -c "PGPASSWORD='${POSTGRES_PASSWORD}' psql -U banking -d core_banking -c \"SELECT customer_number, first_name, last_name, customer_type FROM customers;\""

echo ""
echo "📡 Vérification de la publication CDC:"
kubectl exec -n kafka postgres-banking-postgresql-0 -- bash -c "PGPASSWORD='${POSTGRES_PASSWORD}' psql -U banking -d core_banking -c \"SELECT * FROM pg_publication_tables WHERE pubname = 'dbz_publication';\""

echo ""
echo "✅ PostgreSQL vérifié avec succès!"
echo ""
echo "Prochaine étape:"
echo "  ./03-verify-sqlserver.sh"
