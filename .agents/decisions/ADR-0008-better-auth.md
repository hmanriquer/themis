# ADR-0008: Authentication with Better Auth

## Status
Accepted

## Date
2026-09-21

## Context
ADR-0007 defined authorization (`CompanyMembership` + `ProcessAssignment`) and left the identity provider unset (Better Auth vs Nest JWT). Themis needs sessions for `iris` (TanStack Start) talking to `olympus` (NestJS) without a second DIY auth stack.

## Decision
Use **[Better Auth](https://www.better-auth.com/)** as the only authentication system.

1. **Host:** `olympus` owns Better Auth (Prisma adapter on the same PostgreSQL database). `iris` uses the Better Auth client only — no NextAuth, no Passport, no hand-rolled JWT issuer.
2. **`User`:** Better Auth’s user row **is** the Themis user. Extra GRC fields (`fullName`, `isActive`) live on the same user (or a 1:1 profile) keyed by that id. Still **no** `User.role` and **no** `User.companyId` (ADR-0007).
3. **v1 methods:** email + password. Magic-link / OAuth are out of scope until a second consumer needs them.
4. **Session:** HTTP-only cookie. `ky` sends credentials (`credentials: 'include'`). CSRF follows Better Auth defaults.
5. **Guards:** Nest authenticates the session, then the existing policy function evaluates membership + process assignment. Authentication ≠ authorization.
6. **Env:** `BETTER_AUTH_SECRET` and `BETTER_AUTH_URL` are Zod-parsed at Olympus startup (rule 05). Never commit secrets.

This closes the identity-provider gap in ADR-0007.

## Consequences
### Positive
- One maintained auth library, Prisma-native, works with a separate Start frontend.
- Authorization stays application-owned (not Oso).

### Negative
- Better Auth’s catch-all HTTP surface must be mounted on Nest without putting GRC logic in `iris` `createServerFn`.
- Cookie CORS (`iris` origin ↔ `olympus` origin) must be configured explicitly in local and deployed environments.

### Neutral
- Identity provider is now decided. Authorization tables in ADR-0007 are unchanged.
