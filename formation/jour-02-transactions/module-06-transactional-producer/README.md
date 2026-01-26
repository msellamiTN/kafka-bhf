# Module 06 - Transactional Producer

## 📚 Théorie (30%) - Transactions Kafka

### 6.1 Transactional Producer - Cycle de vie

```
┌─────────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│   Begin      │───▶│   Send       │───▶│   Commit     │───▶│   Visible   │
│ Transaction │    │   Records    │    │ Transaction │    │ to Consumers│
└─────────────┘    └─────────────┘    └─────────────┘    └─────────────┘
       │                   │                   │                   │
       ▼                   ▼                   ▼                   ▼
   ┌─────────────┐   ┌─────────────┐   ┌─────────────┐   ┌─────────────┐
   │   Abort      │   │   Retry      │   │   Atomic     │   │   Isolated  │
   │ Transaction │   │ on Error     │   │ Guarantees   │   │ Visibility  │
   └─────────────┘   └─────────────┘   └─────────────┘   └─────────────┘
```

### 6.2 Transactional ID - Unicité et Recovery

#### 🔑 **Transactional ID**
- **Unicité** : 1 producer = 1 transactional.id
- **Persistence** : Stocké dans Kafka (__transaction_state topic)
- **Recovery** : Reprise après crash avec même ID
- **Fencing** : Empêche 2 producers avec même ID

#### 🏦 **Cas d'usage BHF**
```
transactional.id=bhf-payment-service-01
# Service de paiement BHF, instance 01
```

### 6.3 Garanties Transactionnelles

| Garantie | Description | Impact BHF |
|----------|-------------|------------|
| **Atomicité** | Tout ou rien | Pas de transactions partielles |
| **Durabilité** | Persistance avant commit | Pas de perte de transactions |
| **Isolation** | read_committed | Transactions abortées invisibles |
| **Consistency** | Ordre garanti | Chronologie des paiements respectée |

---

## 🛠️ Pratique (70%) - Producer Transactionnel BHF

### Lab 06.1 - Producer Transactionnel pour Paiements BHF

#### Étape 1 : Configuration Transactionnelle

```java
Properties props = new Properties();
props.put(ProducerConfig.BOOTSTRAP_SERVERS_CONFIG, "localhost:9092");
props.put(ProducerConfig.KEY_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());
props.put(ProducerConfig.VALUE_SERIALIZER_CLASS_CONFIG, StringSerializer.class.getName());

// 🔥 Configuration transactionnelle BHF
props.put(ProducerConfig.TRANSACTIONAL_ID_CONFIG, "bhf-payment-service-01");
props.put(ProducerConfig.ENABLE_IDEMPOTENCE_CONFIG, true);
props.put(ProducerConfig.ACKS_CONFIG, "all");
props.put(ProducerConfig.RETRIES_CONFIG, Integer.MAX_VALUE);
props.put(ProducerConfig.DELIVERY_TIMEOUT_MS_CONFIG, 30000);
props.put(ProducerConfig.TRANSACTION_TIMEOUT_MS_CONFIG, 60000); // 1 minute timeout
```

#### Étape 2 : Pattern Transactionnel BHF

```java
public class TransactionalProducerApp {
    private static final Logger log = LoggerFactory.getLogger(TransactionalProducerApp.class);

    public static void main(String[] args) {
        Properties props = createProducerConfig();
        
        try (KafkaProducer<String, String> producer = new KafkaProducer<>(props)) {
            // 🔥 Initialisation transactionnelle
            producer.initTransactions();
            log.info("🏦 Producer transactionnel BHF initialisé");
            
            String topic = "bhf-transactions";
            
            // Scénario 1 : Transaction validée
            processValidTransaction(producer, topic);
            
            // Scénario 2 : Transaction abortée (simulation erreur)
            processAbortedTransaction(producer, topic);
        }
    }
    
    private static void processValidTransaction(KafkaProducer<String, String> producer, String topic) {
        try {
            producer.beginTransaction();
            log.info("🔥 Début transaction BHF - Paiement validé");
            
            // Étape 1 : Créer la transaction
            String transactionId = "TXN-" + System.currentTimeMillis();
            String key = "account-" + (int)(Math.random() * 1000);
            String paymentJson = String.format(
                "{\"transactionId\":\"%s\",\"amount\":1500.00,\"currency\":\"EUR\",\"type\":\"DEBIT\",\"status\":\"PENDING\",\"timestamp\":%d}",
                transactionId, System.currentTimeMillis()
            );
            
            // Étape 2 : Envoyer la transaction principale
            ProducerRecord<String, String> paymentRecord = new ProducerRecord<>(topic, key, paymentJson);
            producer.send(paymentRecord);
            log.info("📤 Transaction principale envoyée : {}", transactionId);
            
            // Étape 3 : Envoyer l'événement d'audit
            String auditJson = String.format(
                "{\"transactionId\":\"%s\",\"eventType\":\"PAYMENT_INITIATED\",\"service\":\"payment-service\",\"timestamp\":%d}",
                transactionId, System.currentTimeMillis()
            );
            ProducerRecord<String, String> auditRecord = new ProducerRecord<>("bhf-audit", transactionId, auditJson);
            producer.send(auditRecord);
            log.info("📤 Événement d'audit envoyé");
            
            // Étape 4 : Validation métier (simulation)
            boolean isValid = validatePayment(paymentJson);
            
            if (isValid) {
                producer.commitTransaction();
                log.info("✅ Transaction BHF commitée - {} messages visibles", 2);
            } else {
                producer.abortTransaction();
                log.info("❌ Transaction BHF abortée - validation échouée");
            }
            
        } catch (Exception e) {
            log.error("💥 Erreur transaction BHF - abort", e);
            producer.abortTransaction();
        }
    }
    
    private static void processAbortedTransaction(KafkaProducer<String, String> producer, String topic) {
        try {
            producer.beginTransaction();
            log.info("🔥 Début transaction BHF - Paiement aborté (simulation)");
            
            // Transaction invalide (montant négatif)
            String transactionId = "TXN-INVALID-" + System.currentTimeMillis();
            String key = "account-" + (int)(Math.random() * 1000);
            String paymentJson = String.format(
                "{\"transactionId\":\"%s\",\"amount\":-500.00,\"currency\":\"EUR\",\"type\":\"DEBIT\",\"status\":\"PENDING\"}",
                transactionId
            );
            
            ProducerRecord<String, String> record = new ProducerRecord<>(topic, key, paymentJson);
            producer.send(record);
            
            // Simulation d'erreur métier
            throw new RuntimeException("Montant invalide : paiement négatif");
            
        } catch (Exception e) {
            producer.abortTransaction();
            log.info("❌ Transaction BHF abortée comme attendu");
        }
    }
    
    private static boolean validatePayment(String paymentJson) {
        // Simulation validation BHF
        return paymentJson.contains("\"amount\":") && !paymentJson.contains("\"amount\":-");
    }
}
```

#### Étape 3 : Test des Transactions

```powershell
# 1. Compiler le projet
mvn clean compile

# 2. Créer les topics BHF
docker exec kafka kafka-topics --create --topic bhf-transactions --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1
docker exec kafka kafka-topics --create --topic bhf-audit --bootstrap-server localhost:9092 --partitions 3 --replication-factor 1

# 3. Exécuter le producer transactionnel
mvn exec:java -Dexec.mainClass="com.bhf.kafka.TransactionalProducerApp"
```

#### Étape 4 : Vérification des Résultats

```powershell
# Consumer read_committed pour voir seulement les transactions validées
docker exec kafka kafka-console-consumer --topic bhf-transactions --bootstrap-server localhost:9092 --from-beginning --isolation-level read_committed --property print.key=true

# Consumer d'audit pour tracer les événements
docker exec kafka kafka-console-consumer --topic bhf-audit --bootstrap-server localhost:9092 --from-beginning --property print.key=true
```

**Résultat attendu :**
```
# bhf-transactions (seulement les transactions validées)
account-456	{"transactionId":"TXN-1643723400123","amount":1500.00,"currency":"EUR","type":"DEBIT","status":"PENDING"}

# bhf-audit (tous les événements de transaction)
TXN-1643723400123	{"transactionId":"TXN-1643723400123","eventType":"PAYMENT_INITIATED","service":"payment-service"}
```

#### Étape 5 : Test de Recovery

```powershell
# Simuler un crash pendant une transaction
# 1. Démarrer le producer
# 2. Tuer le processus (Ctrl+C)
# 3. Redémarrer avec le même transactional.id
# 4. Observer que Kafka empêche la double écriture
```

**Observation des logs de recovery :**
```
2024-01-01 10:00:00 INFO  TransactionalProducerApp - 🏦 Producer transactionnel BHF initialisé
2024-01-01 10:00:01 ERROR ProducerConfig - Fatal error on existing producer with transactional.id=bhf-payment-service-01: This producer is being fenced off due to an active transaction with the same transactional.id
```

---

## 🎯 Checkpoint Module 06

### ✅ Validation des compétences

- [ ] Producer transactionnel configuré
- [ ] Transactions commitées visibles
- [ ] Transactions abortées invisibles
- [ ] Recovery et fencing fonctionnels
- [ ] Audit trail cohérent

### 📝 Questions de checkpoint

1. **Pourquoi le fencing est-il important chez BHF ?**
   - Empêche les doubles écritures après crash
   - Garantit l'unicité des transactions financières

2. **Quel est l'impact du timeout transactionnel ?**
   - 60 secondes par défaut chez BHF
   - Doit être > latence maximale de traitement

3. **Comment gérer les transactions longues ?**
   - Augmenter `transaction.timeout.ms`
   - Découper en transactions plus petites

---

## 🚀 Prochain module

**Module 07** : Consumer Read-Committed - Isolation des transactions et stratégies de commit.
