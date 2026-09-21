# ADR-0003: Frontend State, Data Fetching & UI System

## Status
Accepted (amended 2026-09-21)

## Date
2026-09-21

## Context
A GRC dashboard requires displaying high-density data (risk heatmaps, framework control grids, audit timelines, compliance scorecards) with rapid filtering, real-time status toggles, and seamless page transitions without sluggish renders or state synchronisation bugs.

The first draft did not name the HTTP client, the form/table libraries, or the ban on duplicating server state. The LobeHub Zustand skill documents optimistic updates inside stores; that pattern conflicts with Query-owned interactions.

## Decision
1. **Component Library & Design Tokens:** Shadcn UI + Tailwind CSS v4 + Radix/Base UI primitives. Impeccable guidelines. WCAG 2.1 AA.
2. **Framework:** TanStack Start as the `iris` host. See ADR-0005. View transitions use TanStack Router + `@vercel/react-view-transitions`, not Next.js APIs.
3. **Server Interactions:** TanStack Query owns **all** remote reads (`useQuery`) and writes (`useMutation`), including optimistic UI. Components never call `ky`.
4. **HTTP Client:** `ky` singleton (`src/shared/http/client.ts`). Retry count `0` — Query retries. `axios` and feature-level `fetch` are forbidden.
5. **Client State:** Zustand feature slices for transient UI and explicit state machines (discriminated union + named transitions). **Never** mirror Query data. **Never** optimistic API writes in Zustand (Themis override of the LobeHub Zustand skill).
6. **URL State:** Filters, pagination, search, and view mode live in search params, validated with Zod from `nomos`.
7. **Forms & Tables:** TanStack Form + `nomos` Zod schemas + `useMutation`. TanStack Table inside feature components, fed by Query.
8. **Component Patterns:** Compound components and `asChild` slots. React files ≤ 150 Prettier lines. Custom hooks only in `hooks/` folders.
9. **Three-layer UI:** Dumb routes, smart feature components, dumb `shared/ui` primitives.

## Consequences
### Positive
- One interaction path (Query) and one HTTP adapter (`ky`).
- No re-render storms from over-broad Zustand subscriptions.
- Shareable audit URLs.

### Negative
- Discipline required: no `ky` in click handlers, no Start `createServerFn` for GRC writes, no copying lists into Zustand.
