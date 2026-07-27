---
name: medusa
description: >-
  Build MEDUSA, a local graph-native defense prototyping demo in Jac: a
  seeded inventory graph becomes an explainable, budget-compliant,
  human-approved perimeter-monitoring design. Use for any MEDUSA work --
  the five public walker interfaces (LoadWorkspace, CreateProject,
  ProposeChange, ApproveProposal, ResetDemo), the four hard approval
  gates, the seven-stage workflow, mainline versioning, the scripted
  golden-path demo, or deciding whether a requested feature is in scope.
  This is the capstone: it sequences medusa-graph (graph model),
  medusa-llm-traversal (constrained visit-by-llm generation),
  medusa-compatibility (assessment contract), medusa-ui (three screens),
  and tdd (behavior tests through the walker seams). Trigger on "MEDUSA",
  "the demo", "approval gate", "mainline", "proposal", "intake",
  "golden path", "inventory graph", or any request to add, change, or
  scope a feature in this project.
---

# MEDUSA

## What this is

A local, graph-native defense prototyping demonstration built entirely in Jac. The full product definition lives in [.claude/medusa-context.md](../../medusa-context.md) — that PRD is the source of truth. This skill is how to *execute* it: the interface contract, the gates, the scope boundary, and which sibling skill owns which part.

The one-sentence product: a systems engineer opens a seeded inventory graph, answers a nine-question intake, gets an AI-generated initial design they can inspect and trace, finds a weather-risk decision, picks an in-stock resolution, sees it expand into a complete engineering change, and approves it through four hard gates into a new immutable mainline version.

## The scope boundary is the point

The PRD carries an unusually long out-of-scope list, and honoring it is this skill's highest-value job. Before building anything, check it against the PRD's **Out of Scope** section. The traps that come up most:

- **No CAD, PCB, simulation, or firmware.** MEDUSA draws *graphs*, not mechanical drawings. There are no dimensioned layouts, orthographic views, or title blocks anywhere in this product.
- **No external purchasing.** Every recommendation comes from seeded inventory. MEDUSA may say a capability is missing; it may never propose buying anything.
- **No live data.** All inventory is curated and seeded — no spreadsheets, CSVs, PDFs, ERP, or warehouse systems.
- **No branching or conflict resolution.** Exactly one mainline and at most one active proposal. No concurrent proposals, partial merges, rebases, or stale-branch handling.
- **No free-form graph editing.** The user selects a decision and chooses a guided resolution. They never draw arbitrary nodes or edges.
- **No auth, no multi-user.** One local user, no login.
- **All hand-authored source is Jac.** No hand-written JavaScript, TypeScript, Python, HTML, or CSS.

When a request falls outside this, say so plainly and point at the PRD line, rather than quietly building it.

## The five public walker interfaces

These are the entire external surface. The Jac client and the tests both go through them, and nothing else is exposed for testing. Read `references/walker_interfaces.md` for each one's inputs, outputs, and failure behavior.

1. **LoadWorkspace** — inventory, quantities, current project, design graph, workflow, proposal, approval state.
2. **CreateProject** — nine intake answers → initial design via constrained LLM-guided traversal.
3. **ProposeChange** — a selected decision + a chosen in-stock resolution → revised graph + downstream effects.
4. **ApproveProposal** — evaluate the four gates; on pass, cut a new immutable mainline version.
5. **ResetDemo** — restore seeded inventory, project, and proposal state.

In Jac 0.34.5 these are `walker:pub` declarations (verified against the scaffolder) — `:pub` is what makes a walker a callable endpoint with no login, which matches MEDUSA's single-local-user model. Internal helpers stay unexported; if a test needs something, it goes through one of these five or it doesn't get tested.

## The four hard approval gates

`ApproveProposal` blocks **only** on these four, and each must be independently demonstrable:

1. A required relationship is **incompatible**.
2. Required inventory **quantity is unavailable**.
3. Projected design **cost exceeds the project budget** ($75,000 in the demo).
4. A **mandatory mission requirement has no proposed solution**.

A `conditional` or `unknown` relationship is approvable *only* when the workflow contains an explicit verification test for it. Read `references/approval_and_versioning.md` for gate evaluation order, the before/after record, and what "immutable version" actually means here.

## Which skill owns what

This skill sequences; it does not duplicate. Load the sibling skill when you're working in its territory:

| Work | Skill |
|---|---|
| Node/edge/walker model, quantities, Jac language questions | `medusa-graph` |
| `visit ... by llm()`, deterministic pre-filter, rationale capture | `medusa-llm-traversal` |
| Verdict/evidence/resolution/downstream-effect assessments | `medusa-compatibility` |
| Three screens, deterministic SVG graph layout, Notion styling | `medusa-ui` |
| Tests through the five seams, the eight behavior groups | `tdd` |

## Build order

Work in tracer-bullet slices — one thin path end-to-end before widening. The order that respects real dependencies:

1. **Seed + LoadWorkspace.** Get the inventory graph and quantities loading and rendering before any AI is involved. This is also behavior group 1 in `tdd`.
2. **Intake + CreateProject.** Nine questions, requirement review, then deterministic filter → LLM traversal → deterministic validation → seven-stage workflow.
3. **Decision inspection + compatibility assessment.** The low-light camera's unverified weather performance is the demo's pivot; get its assessment fully populated.
4. **ProposeChange + downstream expansion.** One camera swap fanning out into mount, enclosure, power, compute, comms, cost, software, and verification work.
5. **ApproveProposal + versioning.** All four gates, each independently demonstrable, then the immutable version cut.
6. **ResetDemo.** Last, but not optional — the demo must be repeatable.

## Verify against the compiler, always

`jac 0.34.5` is installed and the toolchain is fast. Nothing gets handed over on inspection alone:

- `jac check <file>` — type-check and lint.
- `jac test` — run the behavior tests (see `tdd`).
- `jac start --dev main.jac` — run the app with hot reload for client files.
- `jac browse open localhost:8000` then `snapshot` / `click @e5` / `screenshot` — QA the running UI headlessly.

The compiler also ships ~30 authoritative reference guides (`jac guide` to list, `jac guide <name>` to read). These supersede any hand-written syntax summary, including anything in these skills — see `medusa-graph` for the task→guide routing table.

## Demo integrity rules

The scripted demo has to reach approval every time, so a few properties are load-bearing rather than nice-to-have:

- The golden path (low-light camera → in-stock weather-rated thermal camera) must always have sufficient available quantity.
- Every AI-guided selection must carry a visible visited path and a short rationale — an unexplained selection is a demo failure even if the choice is good.
- Generation must be **live**. A failed or invalid generation produces an explicit error and leaves graph state unchanged; it never silently falls back to a canned design.
- Unrelated zero-quantity and incompatible products stay in the seed on purpose, so MEDUSA can demonstrate honest dead ends.

Read `references/output_contract.md` for the Cost vs. Budget breakdown shape, quantity display rules, and tone.
