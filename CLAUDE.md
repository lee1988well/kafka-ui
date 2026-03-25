# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

UI for Apache Kafka is a web-based management interface for Apache Kafka clusters. It's a multi-module Maven project with a Spring Boot WebFlux backend and React frontend.

## Build & Development Commands

### Backend (Java/Maven)
```bash
# Build entire project (includes frontend)
./mvnw clean install

# Run backend only (requires pre-built frontend)
cd kafka-ui-api
../mvnw spring-boot:run

# Run tests
./mvnw test

# Run specific module tests
cd kafka-ui-api && ../mvnw test
```

### Frontend (React/TypeScript)
```bash
cd kafka-ui-react-app

# Install dependencies
pnpm install

# Development server (with hot reload)
pnpm start

# Build for production
pnpm build

# Run tests
pnpm test

# Run tests with coverage
pnpm test:coverage

# Lint
pnpm lint
pnpm lint:fix

# Type check
pnpm tsc

# Generate API client from OpenAPI spec
pnpm gen:sources
```

### Docker
```bash
# Quick demo run
docker run -it -p 8080:8080 -e DYNAMIC_CONFIG_ENABLED=true provectuslabs/kafka-ui

# With configuration file
docker run -d -p 8080:8080 \
  -v /path/to/config.yml:/etc/kafkaui/dynamic_config.yaml \
  provectuslabs/kafka-ui:latest
```

## Architecture

### Module Structure
- **kafka-ui-contract**: OpenAPI specifications and generated API contracts
- **kafka-ui-api**: Spring Boot backend (main application)
- **kafka-ui-serde-api**: Serialization/deserialization plugin API
- **kafka-ui-react-app**: React frontend
- **kafka-ui-e2e-checks**: End-to-end tests

### Backend Architecture (kafka-ui-api)

**Technology Stack**: Spring Boot 3.1.3, Java 17, Spring WebFlux (reactive), Kafka clients 3.5.0

**Key Packages**:
- `controller/`: REST API endpoints (reactive controllers)
- `service/`: Business logic layer
  - `service/rbac/`: Role-based access control implementation
- `config/`: Spring configuration
  - `config/auth/`: Authentication configurations (LDAP, OAuth2, Basic)
- `model/`: Domain models and DTOs
  - `model/rbac/`: RBAC data structures (Role, Subject, Permission)
- `serdes/`: Message serialization/deserialization
- `emitter/`: Server-sent events (SSE) for real-time updates
- `mapper/`: MapStruct mappers for DTO conversions
- `client/`: Kafka client wrappers
- `util/`: Utility classes

**Configuration System**:
- Static config: `application.yml` or via `SPRING_CONFIG_ADDITIONAL_LOCATION`
- Dynamic config: `/etc/kafkaui/dynamic_config.yaml` (enabled via `DYNAMIC_CONFIG_ENABLED`)
- Config priority: Dynamic config > SPRING_CONFIG_ADDITIONAL_LOCATION > application.yml > environment variables

**Authentication & Authorization**:
- Auth types: `DISABLED`, `LOGIN_FORM` (single user), `LDAP`, `OAUTH2`
- RBAC system: Role-based access control with fine-grained permissions
  - Roles defined in config with subjects (users/groups) and permissions
  - Permissions: resource (topic, consumer, schema, etc.) + actions (VIEW, EDIT, DELETE, etc.)
  - Provider types: `ldap`, `oauth_google`, `oauth_github`, `oauth_cognito`
  - Subject types: `user`, `group`, `domain`, `organization`
- Key classes:
  - [AccessControlService.java](kafka-ui-api/src/main/java/com/provectus/kafka/ui/service/rbac/AccessControlService.java): Permission checking
  - [RbacLdapAuthoritiesExtractor.java](kafka-ui-api/src/main/java/com/provectus/kafka/ui/service/rbac/extractor/RbacLdapAuthoritiesExtractor.java): LDAP group extraction
  - [Subject.java](kafka-ui-api/src/main/java/com/provectus/kafka/ui/model/rbac/Subject.java): Auto-converts provider to uppercase

### Frontend Architecture (kafka-ui-react-app)

**Technology Stack**: React 18, TypeScript, Vite, Redux Toolkit, React Router 6

**Key Directories**:
- `src/components/`: Reusable UI components
- `src/redux/`: Redux store and slices
- `src/generated-sources/`: Auto-generated API client (from OpenAPI spec)

**API Client Generation**: Frontend API client is generated from OpenAPI specs in kafka-ui-contract module. Run `pnpm gen:sources` after backend API changes.

## Code Style & Conventions

- **Java**: Checkstyle rules in `etc/checkstyle.xml` (import into IDE)
- **REST API**: lowercase, plural nouns, hyphen-separated (e.g., `/api/consumer-groups`)
- **Query params**: camelCase
- **Model names**: camelCase, plural nouns
- **Branch naming**: `issues/123`, `feature/feature_name`, `bugfix/fix_thing`

## Important Configuration Notes

### LDAP Authentication
- For multi-user support, LDAP is the simplest option (LOGIN_FORM only supports single user)
- RBAC with `type: user` (user-based) is simpler than `type: group` (group-based)
- User-based RBAC avoids LDAP group query complexity
- Provider field: use lowercase `ldap` (auto-converted to uppercase internally)

### Dynamic Configuration
- Default path: `/etc/kafkaui/dynamic_config.yaml`
- Highest priority in config hierarchy
- Supports runtime cluster addition via UI when enabled

## Health & Monitoring

- Health endpoint: `/actuator/health`
- Info endpoint: `/actuator/info`
- Metrics: `/actuator/prometheus`

## Testing

- Backend: JUnit 5 + Testcontainers for integration tests
- Frontend: Jest + React Testing Library
- E2E: Selenium-based tests in kafka-ui-e2e-checks module
