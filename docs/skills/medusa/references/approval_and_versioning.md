# Approval gates, mainline, and versioning

MEDUSA has exactly **one mainline** and at most **one active proposal**. There is no branching model — no concurrent proposals, no partial merges, no rebases, no stale-branch detection, no conflict resolution. The PRD puts all of that explicitly out of scope. If you find yourself reaching for version-vector or fork-point logic, stop: this is a simpler system than that, deliberately.

The mental model is a straight line:

```
mainline v1  --(one active proposal)-->  approve  -->  mainline v2
                                          |
                                       blocked by a gate
                                          |
                                    proposal stays active,
                                    mainline untouched
```

## The four hard gates

`ApproveProposal` blocks **only** on these four conditions. Nothing else blocks approval — resist adding a fifth gate without changing the PRD.

1. **Incompatibility** — a required relationship is `incompatible`.
2. **Quantity** — required inventory quantity is unavailable.
3. **Budget** — projected design cost exceeds the project budget ($75,000 in the demo).
4. **Unsatisfied requirement** — a mandatory mission requirement has no proposed solution.

### Conditional and unknown verdicts

A `conditional` or `unknown` relationship does **not** automatically block. It is approvable *only when the workflow contains an explicit verification test for it*. This is the mechanism that keeps uncertainty managed rather than hidden: MEDUSA never pretends an unknown is fine, and never refuses to move forward because something is unproven — it requires the uncertainty to be paired with planned work.

So the check is not "is this verdict clean?" but "is every non-clean verdict accounted for by a verification task in the seven-stage workflow?"

### Evaluate all gates, report all failures

Evaluate every gate and return **all** failures, not just the first one hit. A user who fixes the budget problem only to discover a quantity problem on the next attempt has a worse experience, and the demo needs to show gates independently anyway.

Each gate result should name the gate, the specific offending item, and why:

```
BLOCKED - Budget
  Projected cost $78,400 exceeds project budget $75,000 by $3,400.
  Largest contributors: thermal camera ($12,000), ruggedized enclosure ($4,200).
```

### Demonstrating each gate independently

Behavior group 6 in `tdd` requires four separate cases proving each gate blocks on its own. Design the seed so each is reachable without contorting the data — this is why the PRD asks for unrelated zero-quantity and incompatible products in the inventory. Keep the golden path clear of all four.

## What "immutable version" means here

On approval:

1. The proposal's changes become the new mainline.
2. A **new version** is created; the prior version is retained unchanged.
3. **Selected quantities update** to match the approved design, so inventory and mainline stay consistent.
4. A **before/after decision record** is preserved — what changed, why, and what it affected.

Immutable means the previous version is never rewritten in place. The simplest structure that satisfies this is an append-only chain of version nodes, each pointing at the design state it captured, with the current mainline being the newest. Don't reach for anything more elaborate; there is no history rewriting, no cherry-picking, and no need to reconstruct intermediate states.

## The before/after record

This is a first-class deliverable, not a log line. The demo's closing beat is showing that one understandable hardware concern became a complete, connected, approved engineering change — the record is what makes that visible. At minimum it captures:

- Which decision was selected and what its issue was.
- Which resolution was chosen, from which alternatives.
- Every downstream effect that expanded from it (mount, enclosure, power, compute, comms, cost, software, verification).
- The gate results at approval time.
- Cost before and after, against budget.

## What not to build

The PRD's out-of-scope list is doing real work here. Specifically absent by design:

- Concurrent proposals or any notion of two people editing at once.
- Rebase, merge conflict detection, or three-way diffing.
- Rolling back to an earlier version (history is retained for *reading*, not for reverting).
- Approval roles, sign-off chains, or permissions — there is one local user.

If a feature request implies any of these, it is a PRD change, not an implementation detail.
