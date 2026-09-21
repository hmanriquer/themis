# Frontend Quality, UI Standards & Design System

This standard enforces frontend excellence across all UI tasks developed by Codex, OpenCode, Cursor, and Antigravity.

---

## 1. Design & Aesthetic Standards (Impeccable & Web Guidelines)

*   **Aesthetic Guardrails (Impeccable):**
    *   Avoid generic, repetitive "AI slop" (bland white cards with drop-shadows and purple gradient buttons).
    *   Craft intentional visual hierarchies with precise typographic scales, deliberate contrast, and purposeful negative space.
    *   Design for high information density required in enterprise GRC platforms (audit logs, control matrices, risk heatmaps) without cognitive clutter.
    *   Use subtle, polished micro-interactions and transitions that signal system responsiveness and state changes.
*   **Web Design Guidelines Compliance:**
    *   Strict WCAG 2.1 AA accessibility (contrast ratio $\ge 4.5:1$, aria attributes, keyboard navigability across all tables, filters, and dialogs).
    *   Responsive layouts optimized for desktop analysts ($1440\text{px}+$) down to tablet/mobile reviewers ($768\text{px}$).
    *   Explicit loading, error, empty, and optimistic states for every data-bound view.

---

## 2. Component Composition Patterns

*   **Compound Components:** Decompose complex UI controls into composable parts (e.g., `<RiskMatrix>`, `<RiskMatrix.Grid>`, `<RiskMatrix.Cell>`, `<RiskMatrix.Legend>`).
*   **Slot Pattern (`asChild`):** Leverage Radix / Base UI slot patterns so component styling can be swapped without wrapping extra unstyled DOM nodes.
*   **Decoupled State & Presentation:**
    *   *Headless Logic:* Hooks manage interaction mechanics (e.g., `useRiskScoreCalculator`, `useAuditFilter`).
    *   *Pure Presentational View:* Stateless components render visuals based on props.

---

## 3. State Management Division of Labor

*   **Server State (TanStack Query):**
    *   All remote data fetching, caching, polling, deduplication, and invalidation belong in TanStack Query (`useQuery`, `useMutation`).
    *   Never mirror server state inside Zustand or `useState`.
    *   Use optimistic updates for high-frequency actions (e.g., toggling control compliance status).
*   **Client / UI State (Zustand):**
    *   Used solely for client-side state: active navigation tabs, drawer/modal state, column visibility in tables, multi-step assessment wizards.
    *   Organize stores into cohesive slices using Zustand's slice pattern.
    *   Use selectors (`useStore(state => state.selectedFramework)`) to prevent unnecessary re-renders.
*   **URL State:**
    *   Filters, pagination, search queries, and selected view modes MUST be synchronized with URL query params for shareable and bookmarkable audit views.

---

## 4. Performance & React Best Practices

*   **Render Optimization:** Avoid unnecessary renders through selective subscription, memoization of expensive computations (`useMemo`), and stable callbacks (`useCallback`).
*   **View Transitions:** Use `@vercel/react-view-transitions` for fluid state transitions between compliance dashboards, assessment details, and audit reports.
*   **React Doctor Scoring:** Code must pass `react-doctor` audits with a target score $\ge 90/100$, free of diagnostic warnings, unhandled promises, and memory leaks.
