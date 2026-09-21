# NestJS Architecture for Olympus

`apps/olympus` is a standard NestJS application. Follow Nest's own module system, dependency injection, pipes, guards, interceptors, and exception filters. Do not introduce a second DI container or a parallel hexagonal runtime that fights Nest.

Canonical design: `docs/superpowers/specs/2026-09-21-project-rules-hardening-design.md`.

---

## 1. Native Dependency Injection

*   Every collaborator is an `@Injectable()` provider registered in a Nest module.
*   Constructor injection only. No service locators, no manual `new` of adapters inside services.
*   Controllers receive services; services receive ports (implemented by infrastructure providers).
*   `ZodValidationPipe` is global or module-scoped and consumes schemas from `@themis/nomos`.
*   Exception filters map `ThemisError` subclasses onto the `nomos` HTTP error envelope.
*   Guards and interceptors stay Nest constructs. Authorization is enforced at the service/use-case boundary, not only in the controller.

---

## 2. Pantheon Module Template

One Nest module per Greek module name. English GRC names for entities and methods.

```
apps/olympus/src/dike/
  dike.module.ts
  dike.controller.ts          # HTTP only
  dike.service.ts             # application / use case
  domain/                     # Nest-free TypeScript
    control.ts
    control.test.ts
  infrastructure/
    control.repository.ts
    control.repository.spec.ts
  dike.controller.spec.ts
  dike.service.spec.ts
```

| Nest construct | Role |
| :--- | :--- |
| `*Module` | Composition root for this pantheon area |
| `*Controller` | Presentation / transport. Params, status codes, no formulas |
| `*Service` | Application workflow. Injectable use case |
| `domain/` | Entities, value objects, domain functions. Zero Nest/Prisma/HTTP imports |
| `infrastructure/` | Repository adapters, crypto, external clients |

Registered modules: `DikeModule`, `PrometheusModule`, `AstraeaModule`, `ArgusModule`, `HermesModule`, `MnemosyneModule`.

Shared domain needed by two modules stays in `olympus` (or a later package). It does **not** belong in `nomos`. `nomos` is IO contracts only.

---

## 3. HTTP Surface

*   Version all public routes under `/v1`.
*   Path strings come from `@themis/nomos` constants — no magic strings.
*   Controllers return DTOs that match `nomos` Zod response schemas.
*   Persistence is **PostgreSQL + Prisma** (ADR-0006), registered as Nest providers in `infrastructure/`. Domain folders stay Prisma-free.
*   Authorization libraries (Oso, OpenFGA) are **out of scope**. Use Nest Guards plus a policy function (ADR-0007). Identity provider (Better Auth vs Nest JWT) is still undecided.

---

## 4. Testing

*   Colocate `*.spec.ts` / `*.test.ts` with the unit under test.
*   Use `@nestjs/testing` to compile a module with mocked ports for controller and service tests.
*   Domain tests stay framework-free.

---

## 5. What Not To Do

*   Do not put GRC business logic in `iris` Start server functions.
*   Do not import React or `ky` into `olympus`.
*   Do not name entities after gods (`Dike`, `Prometheus`). Name modules after gods; name entities `Control`, `Risk`, `Evidence`.
