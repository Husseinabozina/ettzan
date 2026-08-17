# Etzan Architecture

Etzan uses a feature-first, layered architecture.

## Layers

- **Presentation:** Flutter widgets and Cubits. Depends on domain use cases only.
- **Domain:** Entities, repository contracts, and use cases. No Flutter UI or JSON knowledge.
- **Data:** DTOs, mappers, data sources, and repository implementations.
- **Core:** Design system, dependency injection, navigation, localization, network abstractions, and shared errors.

## Implemented vertical slices

- Dashboard
- Notifications

Both slices are wired to a mock API through GetIt and exposed to the UI through Cubits.

## Dependency rule

Dependencies point inward:

```text
Presentation -> Domain <- Data
                   ^
                   |
                  Core
```

Data implements domain contracts. Domain never imports data or presentation.

## Mapper boundary

API vocabulary stays in DTOs. Business vocabulary stays in domain entities. For example:

```text
API: support_hours
DTO: supportHours
Domain: DashboardSummary.supportHours
```

The UI never parses JSON.
