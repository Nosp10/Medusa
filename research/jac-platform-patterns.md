# Jac Platform Patterns: Primary-Source Research for MEDUSA

Research date: 2026-07-26

## Scope and coverage

This note uses only first-party Jac sources:

- [Jac product site](https://jaclang.org/)
- [Current Jac documentation](https://docs.jaseci.org/) (the documentation destination linked by `jaclang.org` and the repository)
- [jaseci-labs/jac](https://github.com/jaseci-labs/jac)

The phrase “all code examples” cannot responsibly be treated as every code fence and every test fixture in a repository with thousands of commits. The inspected scope was:

1. The complete official “Build an AI Day Planner” tutorial, including its single-file, authenticated multi-file, and walker-based variants.
2. The official reference sections for HTTP/walkers, authentication, permissions, persistence/schema migration, full-stack client behavior, testing, code organization, and Kubernetes operations.
3. The top-level inventory of all nine example families in [`jac/examples/`](https://github.com/jaseci-labs/jac/tree/main/jac/examples), with deeper inspection of the platform-oriented [`day_planner`](https://github.com/jaseci-labs/jac/tree/main/jac/examples/day_planner) and [`littleX`](https://github.com/jaseci-labs/jac/tree/main/jac/examples/littleX) layouts.

The nine repository example families visible at inspection time were `chess`, `day_planner`, `littleX`, `mini_todo`, `mobui`, `notes-app`, `ownbench`, `raylib_shooter`, and `todo_app`. This is an inventory of the official example directory, not a claim that every source file in every family was line-reviewed.

## Platform construction model

Jac’s platform model is a single checked program divided into codespaces:

- `sv` declarations execute on the server.
- `cl` declarations compile to browser JavaScript and JSX/React.
- `na` declarations target native code or WebAssembly.
- A normal `main.jac` can mix these codespaces, while `.cl.jac` files can pin an entire file to the client.

The compiler/runtime generates the ordinary glue: HTTP routes, request parsing, serialization, typed client stubs, persistence mapping, OpenAPI documentation, and client bundling. The canonical lifecycle is:

1. Scaffold with `jac create <name> --kind web-static`.
2. Put graph archetypes and protected operations in the server codespace.
3. Put JSX-returning functions and reactive `has` state in the client codespace.
4. Import server declarations into client code with `sv import`.
5. Run locally with `jac start` or HMR via `jac start --dev`.
6. Type-check and test with `jac check` and `jac test`.
7. Preview deployment manifests with `jac start --scale --dry-run`, then deploy with `jac start --scale`.

Sources: [repository overview](https://github.com/jaseci-labs/jac#the-jac-programming-language), [full-stack reference](https://docs.jaseci.org/reference/plugins/jac-client/), [HTTP reference](https://docs.jaseci.org/reference/plugins/jac-scale-http/), [Kubernetes reference](https://docs.jaseci.org/reference/plugins/jac-scale-kubernetes/).

## Graph data modeling, nodes, edges, and identity

Application records that need graph identity are declared as `node`; relationship types that need their own fields are declared as `edge`. Plain structured values that do not need persistence or topology use `obj`.

Key documented mechanics:

- Every program has an ambient `root`.
- A node reachable from `root` persists; an unreachable node is transient and can be collected.
- `root ++> SomeNode(...)` creates and connects.
- `[root-->][?:SomeNode]` reads connected nodes and filters by type.
- Typed edges use the `+>: EdgeType(...) :+>` form and can be filtered during traversal.
- `jid(node)` supplies runtime-managed identity; application code should not invent another identifier unless the domain needs one.
- `del node` removes graph data.

For authenticated endpoints, `root` is the current user’s isolated root. Public endpoints operate on the shared guest graph. This makes root ownership a crucial domain decision: connect only data that should inherit the caller’s persistence and isolation semantics.

MEDUSA implication: model operational entities and meaningful relationships as nodes/typed edges, but keep computed summaries, request payloads, and LLM output containers as `obj`. Do not turn every record into a node; the topology should encode operational meaning.

Sources: [AI Day Planner, Parts 2 and 6](https://docs.jaseci.org/tutorials/first-app/build-ai-day-planner/), [Object-Spatial Programming reference](https://docs.jaseci.org/reference/language/osp/), [`jac/examples/day_planner`](https://github.com/jaseci-labs/jac/tree/main/jac/examples/day_planner).

## Walkers and operational behavior

A walker is mobile computation that enters graph locations and triggers abilities. The core concepts used in official examples are:

- `root spawn WalkerName(...)` starts traversal.
- `visit [-->]` queues connected nodes.
- `here` is the current node; `self` is walker state; `visitor` is the walker from a node-side ability.
- `report` returns values; an explicit typed `reports` field prevents `any` from leaking to the client.
- `disengage` stops after a decisive match.
- Abilities can live on the walker (traversal-centric behavior) or node (data-centric response).
- `walker:priv` exposes an authenticated, per-user operation; `walker:pub` is intentionally anonymous/public.

The official day-planner comparison is especially useful: `def:priv` functions and `walker:priv` can implement identical user behavior. Walkers earn their keep when behavior naturally traverses or coordinates graph locations. A single-record calculation is usually clearer as a function.

MEDUSA implication: use walkers for multi-entity mission flows, dependency propagation, readiness/risk traversal, provenance walks, and graph-scoped commands. Keep deterministic calculations behind small function interfaces. This creates deeper modules instead of turning every operation into a shallow walker.

Sources: [AI Day Planner, Part 7](https://docs.jaseci.org/tutorials/first-app/build-ai-day-planner/), [walker patterns](https://docs.jaseci.org/reference/language/walker-patterns/), [HTTP/walker generation](https://docs.jaseci.org/reference/plugins/jac-scale-http/), [`day_planner/walkers`](https://github.com/jaseci-labs/jac/tree/main/jac/examples/day_planner/walkers).

## Authentication, permissions, and isolation

Jac’s built-in client runtime exposes signup, login, logout, and session-state helpers. Standard server authentication uses JWT-backed endpoints; client code can use `jacSignup`, `jacLogin`, `jacLogout`, and `jacIsLoggedIn`.

Important access facts:

- Walker and function endpoints are protected by default.
- `:priv` is the explicit protected spelling; `:pub` opts out of authentication.
- Protected calls execute against the caller’s isolated root.
- Public anonymous calls execute against `root.shared`.
- Roles documented by the admin subsystem are `ADMIN`, `SYSTEM`, and `USER`.
- Object access levels are `NO_ACCESS`, `READ`, `CONNECT`, and `WRITE`.
- `perm_grant`/`perm_revoke` change public access; `allow_root`/`disallow_root` grant or revoke access for a specific root.
- Webhooks are distinct from user-facing walker endpoints: they use API key plus HMAC rather than JWT.

MEDUSA implication: per-user roots alone are insufficient for a defense collaboration platform. The PDR needs an explicit authorization model for organization, program, team, role, classification/handling caveat, and object-level sharing. Built-in roles are too coarse for that domain. The design must specify which graph objects can be connected across roots, which access level is necessary, how grants are audited, and how revocation propagates.

Sources: [HTTP authentication and permissions](https://docs.jaseci.org/reference/plugins/jac-scale-http/), [full-stack authentication](https://docs.jaseci.org/tutorials/fullstack/authentication/), [authenticated day-planner example](https://github.com/jaseci-labs/jac/tree/main/jac/examples/day_planner/auth).

## Persistence, storage, transactions, and schema change

Local `jac start` uses SQLite graph persistence by default. Setting `MONGODB_URI`, or deploying with the scale subsystem’s provisioned MongoDB, selects the Mongo backend.

The persistence reference documents:

- Runtime-generated schema fingerprints on persisted archetypes.
- Best-effort reads under schema drift plus explicit inspection, quarantine, alias, recovery, and filesystem-check operations.
- Compare-and-swap conflict detection on nodes read during a request, with retry or typed `409 write_conflict`.
- Blind graph appends can remain mergeable.
- External effects must be deferred with `on_commit(...)` so a conflict replay does not send an email, charge an account, or call another system twice.
- File/blob storage is obtained through the `store()` builtin; local and cloud adapters sit behind the same interface.

MEDUSA implication: optimistic replay is a major correctness constraint. Every external defense-system integration, notification, export, and AI job submission must be classified as pure, retry-safe, idempotent, or `on_commit`-deferred. The PDR should define migration and quarantine runbooks before the demo stores meaningful data.

Sources: [persistence and schema migration](https://docs.jaseci.org/reference/persistence/), [scale data and storage](https://docs.jaseci.org/reference/plugins/jac-scale-persistence/), [HTTP default persistence](https://docs.jaseci.org/reference/plugins/jac-scale-http/).

## Endpoints, APIs, and integration seams

Official examples expose either typed functions or walkers:

- A public/protected function becomes an endpoint whose parameters and return type define request and response shapes.
- Each exposed walker becomes `/walker/<name>` by default; inputs come from `has` fields and reported values appear in the response envelope.
- `@restspec` customizes HTTP method, path, protocol, path/query/body classification, content type, and envelope behavior.
- OpenAPI/Swagger, ReDoc, health endpoints, and graph visualization are generated by the runtime.
- Custom request middleware is possible through underscore-prefixed walkers.
- Webhooks, WebSockets, and server-to-server `sv import` are first-party patterns.

Client-side `sv import` causes the compiler to generate typed network stubs. Calls are `async` because the physical network remains real even when serialization glue is hidden.

MEDUSA implication: define a small set of domain-command/query interfaces rather than mirroring every node field as CRUD endpoints. Use custom REST paths only for external compatibility; keep internal client/server calls typed and compiler-generated.

Sources: [HTTP API & Walkers](https://docs.jaseci.org/reference/plugins/jac-scale-http/), [backend integration tutorial](https://docs.jaseci.org/tutorials/fullstack/backend-integration/), [backend APIs guide](https://docs.jaseci.org/build/backend-apis/).

## Frontend and full-stack patterns

Jac frontend functions return `JsxElement`. `has` fields inside a client function are reactive state; assignment triggers re-render. `can with entry` is the mount lifecycle, while dependency-triggered abilities cover reactive effects. React hooks and npm packages remain available when needed.

The official examples show:

- Presentational functions with props and callbacks.
- Stateful panels that fetch on mount.
- A small top-level app that composes feature panels.
- Conditional rendering for auth state.
- Typed objects and nodes crossing the server/client seam.
- Automatic server stubs via `sv import`.
- CSS and TSX interoperability.

MEDUSA implication: organize UI by operational feature slice and keep the top-level shell shallow. A feature panel should own only local interaction state; durable state and authorization remain on the server graph.

Sources: [jac-client reference](https://docs.jaseci.org/reference/plugins/jac-client/), [full-stack tutorials](https://docs.jaseci.org/tutorials/fullstack/project-setup/), [AI Day Planner](https://docs.jaseci.org/tutorials/first-app/build-ai-day-planner/), [`littleX` layout](https://github.com/jaseci-labs/jac/tree/main/jac/examples/littleX).

## AI and LLM integration

Jac delegates a typed function body with `by llm()`. Function names, parameter/return types, docstrings, and `sem` annotations form model context; the return type is the structured output constraint. Official examples use enums to constrain classification and `obj` types to constrain multi-field output.

Models are configured centrally in `jac.toml` under `[byllm.model]` or explicitly through a model object. The documentation supports local and LiteLLM-backed providers.

MEDUSA implication: AI output must remain advisory until deterministic policy validates it. Use closed enums and explicit objects, record model/configuration/provenance, separate evidence from inference, and never let `by llm()` directly mutate high-consequence graph state. A review/approval node and deterministic commit command should form a seam between AI recommendation and operational action.

Sources: [byLLM reference](https://docs.jaseci.org/reference/plugins/byllm/), [AI agents guide](https://docs.jaseci.org/build/ai-agents/), [AI Day Planner, Part 5](https://docs.jaseci.org/tutorials/first-app/build-ai-day-planner/).

## Testing

Jac has language-level `test "..." {}` blocks run by `jac test`. Each test has an isolated graph context. The official reference demonstrates:

- Object behavior.
- Node/walker mutation.
- Typed walker reports.
- Typed-edge graph structure.
- Exceptions and edge cases.
- Separate test files or co-located tests.
- HTTP-level tests with `JacTestClient`, including authentication.
- Parameterized tests and `jac.toml` configuration.

MEDUSA implication: make the module interface the test surface. Required suites should include authorization-denial cases, cross-root isolation, traversal correctness, conflict/replay behavior, schema upgrades and quarantine recovery, AI validation failures, audit immutability, and HTTP contract tests.

Sources: [testing reference](https://docs.jaseci.org/reference/testing/), [`littleX/tests`](https://github.com/jaseci-labs/jac/tree/main/jac/examples/littleX/tests).

## Deployment and operations

The scale subsystem documents:

- Local server and API-only modes.
- Manifest preview with `--dry-run`.
- Kubernetes deployment with `jac start app.jac --scale`.
- Source distribution to stock pods rather than a user-authored image build.
- TLS enablement, health/readiness checks, Prometheus metrics, secrets, autoscaling, persistent storage, and deployment removal.
- Optional microservice routing, where each configured service can become its own Deployment, Service, HPA, and PodDisruptionBudget behind a gateway.

MEDUSA implication: begin as a modular monolith. A documented `sv import` seam becomes real only when a second adapter/deployment is required. Split a module into a microservice for independent scaling, isolation, or deployment ownership—not merely to imitate a conventional stack.

Sources: [Kubernetes & Operations](https://docs.jaseci.org/reference/plugins/jac-scale-kubernetes/), [deployment tutorials](https://docs.jaseci.org/tutorials/deployment/local-server/).

## Folder architecture lessons for the PDR

The official scaffold is intentionally small: `jac.toml`, `main.jac`, `components/`, and `assets/`. Larger official examples add `lib/`, `tests/`, feature components, and optional declaration/implementation pairs (`module.jac` plus `module.impl.jac` or an `impl/` directory).

The code-organization reference advises starting inline, then splitting declaration from implementation only as a module becomes difficult to understand. Applied with deep-module design, a MEDUSA planning structure should use feature/domain modules whose interface hides graph traversal, persistence, and policy:

```text
medusa/
  jac.toml
  main.jac
  domain/
  capabilities/
  policy/
  integrations/
  frontend/
    features/
    shared/
  tests/
  assets/
  ops/
```

This is a planning recommendation, not generated application code. `domain/` holds archetypes and invariants; `capabilities/` holds command/query walkers and functions; `policy/` owns authorization and handling rules; `integrations/` contains adapters for external systems; frontend folders follow operational feature slices; tests cross the same module interfaces as callers. Add `.impl.jac` only when it improves locality.

Sources: [code organization](https://docs.jaseci.org/reference/code-organization/), [jac-client scaffold](https://docs.jaseci.org/reference/plugins/jac-client/), [`day_planner` variants](https://github.com/jaseci-labs/jac/tree/main/jac/examples/day_planner), [`littleX`](https://github.com/jaseci-labs/jac/tree/main/jac/examples/littleX).

## Highest-priority PDR questions

1. What exact real-world defense problem is the demo reproducing, and what public primary evidence supports it without exposing controlled information?
2. Which MEDUSA decisions are advisory versus authorized to change operational state?
3. What is the graph ownership model: user root, organization root, program root, or explicitly shared objects?
4. What authorization dimensions exceed Jac’s built-in `ADMIN`/`USER` roles?
5. Which traversals justify walkers, and which behaviors remain deterministic functions?
6. Which external effects can replay, and which require idempotency or `on_commit`?
7. What evidence, model configuration, and human approval must be retained for every AI-derived recommendation?
8. What is the schema migration, quarantine, backup, and recovery procedure?
9. What must work air-gapped or with local models?
10. What objective demo success metric proves that MEDUSA solves the selected defense-company issue?

