# Lab 06.02 — OAuth2 / SSO (Keycloak) + Gateway (WebFlux)

## Objectif

- Démarrer un IdP local (Keycloak) pour simuler un SSO
- Obtenir un **access token** (OAuth2)
- Appeler une API via le **Gateway** avec `Authorization: Bearer <token>`

## Contexte bancaire (ODDO / finance)

Dans une banque, on veut:

- **Authentifier** l’appelant (SSO)
- **Autoriser** selon des scopes/roles (principe du moindre privilège)
- **Tracer** (audit): qui a appelé quoi, quand, avec quel contexte
- Avoir une posture “defense in depth”:
  - gateway + service + Kafka (segmentation)

## Pré-requis

- Docker Desktop
- Module `api-gateway` présent dans `book-spring-microservices/code/`

## Étape 1 — Démarrer Keycloak

- Lancer:

```powershell
docker compose -f docker/iam-keycloak/docker-compose.yml up -d
```

- Console Keycloak:
  - `http://localhost:18080`
  - Admin: `admin` / `admin`

Le realm importé:

- Realm: `oddo-labs`
- Client: `api-gateway` (public)
- User: `demo` / `demo`

## Étape 2 — Obtenir un token (Resource Owner Password)

> Cette méthode est pratique pour un lab. En entreprise on préfère Authorization Code + PKCE (front) ou Client Credentials (machine-to-machine).

```powershell
$body = "grant_type=password&client_id=api-gateway&username=demo&password=demo"

curl -X POST "http://localhost:18080/realms/oddo-labs/protocol/openid-connect/token" `
  -H "Content-Type: application/x-www-form-urlencoded" `
  -d $body
```

- Récupère `access_token` dans la réponse JSON.

## Étape 3 — Démarrer le Gateway

Depuis `book-spring-microservices/code`:

- `mvn -pl api-gateway spring-boot:run`

Le gateway écoute:

- `http://localhost:8081`

## Étape 4 — Appel d’une route protégée (à brancher ensuite)

Exemple d’appel (une fois le security config en place):

```powershell
$token = "<COLLER_ACCESS_TOKEN>"

curl -H "Authorization: Bearer $token" http://localhost:8081/actuator/health
```

## Bonnes pratiques (exam / prod)

- **Ne pas** faire confiance au gateway seul: les microservices doivent aussi vérifier le token (ou s’appuyer sur un service mesh/ingress policy).
- Journaliser:
  - `sub`, `client_id`, `scope`, `jti`, `correlationId`
- Éviter de propager des secrets en clair (utiliser secrets OpenShift).

## Reset

- `docker compose -f docker/iam-keycloak/docker-compose.yml down -v`
