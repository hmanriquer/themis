# Frontend Quality, UI Standards & Design System

This standard enforces frontend excellence across all UI tasks in `apps/iris`.

Canonical design: `docs/superpowers/specs/2026-09-21-project-rules-hardening-design.md`.
Stack ADR: `.agents/decisions/ADR-0005-frontend-tanstack-start-ky-zod.md`.

---

## 1. Design & Aesthetic Standards (Impeccable & Web Guidelines)

*   **Aesthetic Guardrails (Impeccable):**
    *   Avoid generic, repetitive "AI slop" (bland white cards with drop-shadows and purple gradient buttons).
    *   Craft intentional visual hierarchies with precise typographic scales, deliberate contrast, and purposeful negative space.
    *   Design for high information density required in enterprise GRC platforms (audit logs, control matrices, risk heatmaps) without cognitive clutter.
    *   Use subtle, polished micro-interactions and transitions that signal system responsiveness and state changes.
*   **Web Design Guidelines Compliance:**
    *   Strict WCAG 2.1 AA accessibility (contrast ratio ≥ 4.5:1, aria attributes, keyboard navigability across all tables, filters, and dialogs).
    *   Responsive layouts optimized for desktop analysts ($1440\text{px}+$) down to tablet/mobile reviewers ($768\text{px}$).
    *   Explicit loading, error, empty, and optimistic states for every data-bound view.

---

## 2. Framework: TanStack Start as a Frontend Host

*   `apps/iris` uses **TanStack Start** (`@tanstack/react-start`) with TanStack Router for routing and SSR.
*   Start is **not** a BFF. Do not use `createServerFn` or Start API routes for GRC business logic.
*   Route loaders may prefetch by calling `olympus` through `ky` / Query `ensureQueryData` only.
*   **View Transitions:** `@vercel/react-view-transitions` driven by TanStack Router. Do not use Next.js `Link`, `useRouter` from `next/navigation`, or `loading.tsx`.

---

## 3. Three-Layer UI (Pages Dumb, Components Smart, Primitives Dumb)

*   **Routes (`app/routes/`):** Structural shells. Validate search params with Zod from `@themis/nomos`. Optionally `queryClient.ensureQueryData`. Mount smart feature components. **Forbidden:** domain `useState`, domain calculations, `ky`, inline `useQuery`/`useMutation` definitions, API calls.
*   **Feature components (`src/features/<pantheon>/components/`):** Smart. Call feature hooks and Zustand stores. Own interaction wiring.
*   **Shared primitives (`src/shared/ui/`):** Dumb. Props in, events out. No Query, no Zustand, no `ky`.

### Hooks isolation
*   **Do not define custom hooks** inside component or route files.
*   Components **may and should use** React hooks and imported feature hooks.
*   Feature hooks: `src/features/<feature>/hooks/*.ts`.
*   Shared hooks: `src/shared/hooks/*.ts`.

### File size
*   Hard cap: `REACT_COMPONENT_MAX_LINES` = **150** Prettier-formatted lines per `*.tsx` file (including imports).
*   Split with compound components, `asChild` slots, or sibling files before crossing the cap.
*   Exempt: tests, generated `routeTree.gen.ts`, Shadcn primitives in `shared/ui/`.
*   No per-component `index.ts` barrels. No `types.d.ts` for component props.

---

## 4. Component Composition Patterns

*   **Compound Components:** Decompose complex UI controls (`<DikeMatrix>`, `<DikeMatrix.Header>`, `<DikeMatrix.Row>`).
*   **Slot Pattern (`asChild`):** Radix / Base UI slots so styling can swap without extra DOM nodes.
*   Feature folder names are Greek; visible labels and routes stay English GRC (`Compliance`, `/compliance`).

---

## 5. State Management Division of Labor

### Server interactions (TanStack Query only)
*   All remote reads: `useQuery` / `queryOptions`.
*   All remote writes: `useMutation`.
*   Components never call `ky` or `fetch`. Only `queryFn` / `mutationFn` in `src/features/<feature>/api/` call the `ky` singleton.
*   Optimistic updates live in Query, not in Zustand.
*   Query key factories in `api/query-keys.ts` built from `nomos` constants — no magic strings.
*   Query owns retries. `ky` retry count is `0`.

### HTTP (`ky`)
*   Singleton: `src/shared/http/client.ts`.
*   `prefixUrl`, auth header injection, timeouts, `nomos` error-envelope parsing.
*   `axios` is forbidden. Raw `fetch` is forbidden in `src/features/**`.

### Client state (Zustand)
*   Transient UI: drawers, modals, column visibility, wizard steps.
*   Explicit state machines: discriminated union + named transition functions in a feature slice. One store per feature. Selectors only.
*   **Never** mirror Query responses.
*   **Themis override of the LobeHub Zustand skill:** do not put optimistic server creates/updates/deletes in Zustand. That pattern is invalid here.

### URL state
*   Filters, pagination, search, and selected view modes MUST be synchronized with URL search params for shareable audit views.
*   Zod `validateSearch` on the route; feature components read validated search.

### Forms & tables
*   **TanStack Form** + Zod schema from `nomos` + `useMutation` for submits.
*   **TanStack Table** inside feature components, fed by Query.

---

## 6. Performance & React Best Practices

*   **Render Optimization:** Selective Zustand subscription, memoization of expensive computations, stable callbacks where the compiler is not in use.
*   **View Transitions:** TanStack Router + `@vercel/react-view-transitions` between dashboards, assessment details, and audit reports.
*   **React Doctor Scoring:** Pass `react-doctor` with a target score ≥ 90/100.
*   **Barrels:** Avoid `export *` barrels. Direct imports from source files.

---

## 7. Tests

Tests live inside the feature. If a test proves one unit, colocate it (`component.test.tsx` beside `component.tsx`). If it proves the feature as a whole, put it in `features/<name>/tests/` (integration, fixtures, MSW). Playwright lives at `apps/iris/e2e/`. See `.agents/rules/04-testing-tdd.md`.
