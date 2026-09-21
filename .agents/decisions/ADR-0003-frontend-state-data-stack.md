# ADR-0003: Frontend State, Data Fetching & UI System

## Status
Accepted

## Date
2026-09-21

## Context
A GRC dashboard requires displaying high-density data (risk heatmaps, framework control grids, audit timelines, compliance scorecards) with rapid filtering, real-time status toggles, and seamless page transitions without sluggish renders or state synchronisation bugs.

## Decision
1. **Component Library & Design Tokens:** Shadcn UI + Tailwind CSS v4 + Radix/Base UI primitives. Strict adherence to Impeccable guidelines to prevent generic AI UI output.
2. **Server State & Data Fetching:** TanStack Query (`@tanstack/react-query`) handles all asynchronous caching, polling, background synchronization, and optimistic UI mutations.
3. **Client State:** Zustand (`zustand`) with atomic slice architecture for transient interface state (modal visibility, table column ordering, drawer toggles, active filter presets).
4. **Transitions:** `@vercel/react-view-transitions` for native-feeling, smooth screen transitions between compliance frameworks, control assessments, and audit logs.
5. **Component Patterns:** Compound components and slot patterns (`asChild`) for extensible and maintainable UI elements.

## Consequences
### Positive
- Strict separation between server state (cached API responses) and client state (interactive UI controls).
- Zero re-render storms due to Zustand's selector pattern.
- High-quality, polished look that elevates the portfolio above generic templates.

### Negative
- Developers must maintain clear discipline not to copy server query results into Zustand stores.
