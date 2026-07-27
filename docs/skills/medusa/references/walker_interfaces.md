# The five public walker interfaces

These are MEDUSA's entire external surface. The Jac client calls them; the tests call them; nothing else is exposed. Internal helpers are never made public merely so a test can reach them — see `tdd` for why that rule holds.

In Jac 0.34.5 a public walker is declared `walker:pub Name { ... }` and reached from the client with `root spawn Name(...)`. Results come back on a typed report channel:

```jac
walker:pub LoadWorkspace {
    has reports: list[WorkspaceView] = [];

    can load with Root entry {
        report build_workspace_view(here);
    }
}
```

Two verified details that bite here:

- `has reports: list[T] = [];` — the `= []` default is required. Without it, `reports` becomes a mandatory spawn argument and every client call fails.
- A walker spawned at `root` traverses nothing unless an ability tells it to. Always give it a `can ... with Root entry` starting ability.

Typing `reports` as a concrete type (not `list[dict]`) is what gives the client dot-access (`result.reports[0].budget_total`) instead of untyped dict keys.

---

## 1. LoadWorkspace

**Purpose**: hydrate the entire workspace in one call. The landing screen and every test's setup depend on it.

**Returns**: the inventory (categories, ~30 product models, specifications), the three quantity figures per product (`owned`, `available`, `selected`), the current project, the current design graph, the seven-stage workflow, the active proposal if one exists, and the approval state.

**Notes**:
- Unavailable and incompatible products are **returned, not filtered out**. The UI needs to show them as visible-but-unselectable so MEDUSA can explain *why* — hiding them is a PRD violation (user stories 6 and 7).
- This is the only read interface. Resist adding narrower getters; a second read path is how the client and tests start disagreeing about state.

## 2. CreateProject

**Purpose**: turn the nine intake answers into an initial design.

**Accepts**: the nine intake answers (see the PRD's *Demo Intake*). The user reviews interpreted requirements *before* this runs — generation never silently reinterprets the mission.

**Sequence** (order matters, and each step has an owner):
1. Convert answers into mission requirements.
2. **Deterministic filter** — remove products with insufficient available quantity or known hard incompatibilities. This runs in plain Jac, before any LLM involvement, so the model cannot override engineering facts.
3. **LLM-guided traversal** — `visit <candidates> by llm()` over the survivors only. See `medusa-llm-traversal`.
4. Record the visited path and per-selection rationale.
5. Construct the mission → subsystem → product graph.
6. **Deterministic validation** of the resulting relationships.
7. Emit the seven-stage workflow with products linked to stages.

**Failure behavior**: generation is live, and a failed or invalid generation must produce an **explicit error and leave graph state unchanged**. No partial writes, no canned-design fallback. Build the new graph and commit it only once validation passes.

## 3. ProposeChange

**Purpose**: expand one guided resolution into a complete engineering proposal.

**Accepts**: a selected decision node and a chosen resolution. The resolution must come from the suggestions MEDUSA offered — the user does not free-form edit the graph.

**Returns**: the revised design graph plus the downstream effects — affected mount, enclosure, power, compute, communications, cost, software, and verification work.

**Notes**:
- Recompute **only the affected region**, not the whole design. A cost change re-runs the budget rollup; a component swap re-runs the fit check for what it touches.
- Exactly **one active proposal** exists at a time. A second `ProposeChange` replaces the current proposal; it does not create a parallel one. There is no branch model here — see `approval_and_versioning.md`.
- Product alternatives are limited to available inventory. When nothing in stock can satisfy the requirement, return an honest **blocker** rather than inventing an option.

## 4. ApproveProposal

**Purpose**: evaluate the four hard gates and, on pass, cut the next immutable mainline version.

**Returns**: either a pass with the new version, or the specific gate that blocked and why. A blocked approval must name which gate failed — a generic "cannot approve" defeats the demo, which has to show each gate blocking independently.

Full gate semantics in `approval_and_versioning.md`.

## 5. ResetDemo

**Purpose**: restore seeded inventory, project, proposal, and version state so the scripted demo can be repeated.

**Notes**: reset must return state that is *identical* to a fresh start, including selected quantities and version history — behavior group 8 in `tdd` tests exactly this. Watch for Jac's persisted root between runs; `jac guide jac-testing` documents the persisted-root and `jac clean` gotcha that makes "it worked once" tests misleading.

---

## Keeping the seam honest

The temptation, every time, is to expose one more internal helper because it would make a test easier to write. Don't. If a behavior can't be observed through these five walkers, either it isn't observable behavior (so it shouldn't be tested) or the interface is genuinely missing something (so change the interface deliberately, and update this file).
