# Dockerfile
# Optimisé pour Ubuntu Enterprise - Producer Idempotent BHF

FROM openjdk:17-jdk-slim

# Metadata
LABEL maintainer="BHF Kafka Formation"
LABEL version="1.0.0"
LABEL description="Producer Idempotent BHF pour Ubuntu Enterprise"

# Variables d'environnement
ENV APP_HOME=/app
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV KAFKA_BOOTSTRAP_SERVERS=localhost:9092

# Créer le répertoire de l'application
WORKDIR $APP_HOME

# Installer les dépendances système nécessaires
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        curl \
        jq \
        netcat-traditional \
        && rm -rf /var/lib/apt/lists/*

# Copier le pom.xml et télécharger les dépendances Maven
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copier le code source
COPY src ./src

# Compiler l'application
RUN mvn clean package -DskipTests

# Créer l'utilisateur non-root pour sécurité
RUN groupadd -r bhf && useradd -r -g bhf bhf
RUN chown -R bhf:bhf $APP_HOME
USER bhf

# Exposer le port (si nécessaire pour monitoring)
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:8080/actuator/health || exit 1

# Commande de démarrage
CMD ["java", "-jar", "target/idempotent-producer-1.0.0.jar"]
