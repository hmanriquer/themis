# ADR-0005: TanStack Start, ky, Zod, Query, and Zustand

## Status
Accepted

## Date
2026-09-21

## Context
DESIGN.md originally listed "Next.js / Vite" as the UI framework. Themis needs SSR-capable routing without adopting Next.js, a single HTTP client, shared runtime validation, and a strict split between server cache and client machines. TanStack Start includes `createServerFn` and API routes, which would duplicate NestJS if used for GRC business logic.

## Decision
1. **`apps/iris` uses TanStack Start** (`@tanstack/react-start`) with TanStack Router and Vite. Start is a frontend host: routing, SSR, and loaders only.
2. **No Start server functions or Start API routes for GRC business logic.** Loaders may call `olympus` through `ky` / Query `ensureQueryData`.
3. **`ky`** is the only HTTP client in `iris`. Singleton in `src/shared/http/client.ts`. Auth headers, timeouts, `nomos` error parsing. Retry count `0`.
4. **Zod** in `@themis/nomos` is the validator for backend pipes, frontend search params, forms, and DTOs. Types are inferred from schemas.
5. **TanStack Query** is the only server-interaction API (`useQuery` / `useMutation`). Optimistic updates live here. Query owns retries.
6. **Zustand** is the only client state library for complex UI and explicit state machines. It does not cache server records and does not perform optimistic API writes.
7. **TanStack Form** and **TanStack Table** are the form and grid libraries.
8. **View transitions** use `@vercel/react-view-transitions` with TanStack Router. Next.js `Link` / `loading.tsx` patterns are invalid in this repo.
9. **Env** objects in both apps are Zod-parsed at startup.

## Consequences
### Positive
- One backend (`olympus`), one contract package (`nomos`), one interaction path (Query + `ky`).
- NestJS remains the DI/composition root for domain work.
- Shared schemas prevent frontend/backend drift.

### Negative
- Two servers to run in development.
- Agents must ignore Start's full-stack examples when they put business rules on the server.
