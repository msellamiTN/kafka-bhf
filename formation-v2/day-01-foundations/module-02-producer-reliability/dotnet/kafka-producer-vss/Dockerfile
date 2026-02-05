# Multi-stage Dockerfile - Kafka Producer API (HTTP Development Mode)

# ============================================
# Stage 1: Build
# ============================================
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS builder

WORKDIR /source

# Copy project files
COPY ["kafka_producer.csproj", ""]
COPY ["Program.cs", ""]
COPY ["appsettings.json", ""]
COPY ["appsettings.Development.json", ""]
COPY ["Services/", "Services/"]
COPY ["Controllers/", "Controllers/"]
COPY ["Properties/", "Properties/"]

# Restore dependencies
RUN dotnet restore "kafka_producer.csproj"

# Build application
RUN dotnet build "kafka_producer.csproj" -c Release -o /app/build

# Publish application
RUN dotnet publish "kafka_producer.csproj" -c Release -o /app/publish /p:UseAppHost=false

# ============================================
# Stage 2: Runtime (HTTP Only)
# ============================================
FROM mcr.microsoft.com/dotnet/aspnet:8.0

WORKDIR /app

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Copy published application
COPY --from=builder /app/publish .

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:80/health || exit 1

# Expose port (HTTP only - 80)
EXPOSE 80

# Set environment variables for HTTP only
ENV ASPNETCORE_ENVIRONMENT=Development
ENV ASPNETCORE_URLS=http://+:80

# Run application
ENTRYPOINT ["dotnet", "kafka_producer.dll"]
