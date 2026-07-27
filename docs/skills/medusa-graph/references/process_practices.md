# Process practices

Judgment calls about how much ceremony MEDUSA actually needs. It is a scoped demo with a delivery target, not a long-lived platform — so the bar for adding process is high, and most of the value here is in the first two sections.

## 1. A glossary before you name node and edge types

Pin down what each term means in one line before committing to it. The failure this prevents is real and specific: the deterministic filter and the compatibility assessor quietly disagreeing about what "incompatible" means, which in MEDUSA would mean the LLM sees candidates it should never have seen.

```
- available: owned minus committed elsewhere; the only quantity the filter reads
- selected:  committed to THIS design; changes only on approval
- conflicts_with: a hard, always-true engineering fact -- never a preference
- incompatible: a verdict on an evaluated relationship -- blocks approval
- conditional: works only if a stated condition holds -- approvable WITH a verification task
- unknown: not enough evidence to judge -- approvable WITH a verification task
```

`conflicts_with` (an edge, read by the filter) and `incompatible` (a verdict, read by a gate) being different things is exactly the kind of distinction worth writing down once.

If a new walker needs a term that isn't on the list, that's a signal — either it's inventing vocabulary the design doesn't need, or there's a real gap worth naming.

## 2. Which decisions deserve a durable record

MEDUSA emits two different kinds of record, and conflating them creates noise:

- **The demo's decision record** is a product feature, governed by the PRD. Every AI-guided selection carries a visited path and rationale; every approval retains a before/after record. That is not optional and not subject to this filter.
- **Your engineering decisions while building** are a different thing. Promote one to a durable write-up only when all three hold: it's **hard to reverse**, it's **surprising without context**, and it was a **real trade-off** with genuine alternatives.

Choosing the variant-module file layout over the PRD's `src/` tree clears that bar. Naming a helper does not.

## 3. Tracer-bullet slices, with an explicit human split

Build one thin path end-to-end before widening. Not all nodes, then all edges, then all walkers — that produces a system that compiles and demonstrates nothing until the very end, which is a bad shape for a demo with a deadline.

The build order in the `medusa` skill is already sliced this way. Within each slice, the split that matters:

- **Runs unattended**: deterministic filtering, budget rollups, re-running validation after a swap, rendering.
- **Needs a human**: anything where the LLM's judgment becomes a design fact, any gate that blocks, any case where no in-stock alternative exists. These are the moments MEDUSA is *for* — don't automate them away for convenience.

Prefer more, thinner slices. "Does LoadWorkspace return correct quantities" is far easier to review than "does the workspace work."

## 4. For the parts that don't fit in one pass, keep a question map

When a piece is too tangled to resolve in one sitting — how downstream impact expansion decides where to stop, how a conditional verdict binds to a specific verification task — keep a running list of the open questions rather than forcing a single monolithic design pass. Resolve them one at a time; each resolution usually spawns the next.

Treat it as a map of where the design still has open edges, not a to-do list to rush.

## 5. Let the PRD arbitrate

MEDUSA has an unusually complete PRD ([.claude/medusa-context.md](../../../medusa-context.md)). When a design question comes up, check it before inventing an answer — it very often already decided, including things that feel like implementation details (three quantity states, seven workflow stages, four gates, exactly one proposal).

When the PRD genuinely doesn't cover something, prefer the choice that keeps the demo simple and repeatable. "What makes the scripted flow reach approval reliably" is the tiebreaker, because that's the actual success measure.

When the PRD is *wrong* — as with the folder architecture, which predates the current Jac conventions — say so explicitly and record the deviation rather than silently diverging.
