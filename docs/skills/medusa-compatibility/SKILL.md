---
name: medusa-compatibility
description: >-
  MEDUSA's compatibility assessment contract -- the seven fields every
  evaluated relationship returns (verdict, issue domain, specific issue,
  evidence, source note, suggested resolutions, downstream effects), the
  precedence rule that verified specifications outrank AI inference, how
  resolutions stay limited to available inventory, when to return an
  honest blocker instead of an option, and how one accepted change
  expands into its downstream mount/enclosure/power/compute/comms/cost/
  software/verification effects. Use when building the decision
  inspection panel, ProposeChange, impact expansion, or any place a
  compatibility verdict is produced or displayed. Trigger on
  "compatibility", "verdict", "compatible", "conditional",
  "incompatible", "unknown", "evidence", "resolution", "downstream
  effects", "impact", or "assessment".
---

# Compatibility assessment

This is the analytical core of MEDUSA. The demo's pivot — a low-light camera whose night performance is fine but whose rain and wind performance is unverified — is a compatibility assessment, and the whole "one concern becomes a complete engineering change" reveal runs through this contract.

## The seven-field contract

Every evaluated relationship returns **all seven**. A partial assessment is a bug, and behavior group 4 in `tdd` asserts on exactly this.

| Field | Values / shape |
|---|---|
| **Verdict** | `compatible` · `conditional` · `incompatible` · `unknown` |
| **Issue domain** | `hardware` · `software` · `power` · `communications` · `mechanical` · `environmental` |
| **Specific issue** | A precise explanation of the mismatch or uncertainty |
| **Evidence** | `verified specification` · `internal test` · `prior design` · `AI inference` |
| **Source note** | Short human-readable origin for that evidence |
| **Suggested resolutions** | From available inventory only — or an explicit blocker |
| **Downstream effects** | Affected power, software, mounting, communications, cost, workflow stages |

Both enumerations are closed. Don't add a `marginal` verdict or a `thermal` domain — thermal is `environmental`, and marginal is `conditional` with a stated condition.

## The specific issue must be specific

This field is the difference between a warning and something actionable, and it's called out in the PRD as its own user story. The test: could a systems engineer act on this sentence alone?

- Not this: *"Camera may have weather issues."*
- This: *"Camera is rated IP54; the mission requires sustained rain exposure and winds to 50 km/h. No wind-loading or ingress test data exists for this unit."*

## Evidence precedence

**Verified specifications outrank inferred claims.** When a manufacturer spec and an AI inference disagree, the spec wins and the inference is discarded — not averaged, not presented as a competing view.

**Unknown stays visible.** The `unknown` verdict exists so MEDUSA can say "we don't know" rather than guessing. Never upgrade an `unknown` to `compatible` because a model found it plausible; that would make the evidence field a lie, and the evidence field is what lets a reviewer judge the reasoning.

The source note is what makes this checkable at a glance — "FLIR datasheet rev C, IP rating table" reads very differently from "inferred from similar LWIR units," and the user is entitled to tell them apart instantly.

## Conditional and unknown are approvable — with verification work

Neither verdict blocks approval on its own. Each is approvable **only when the seven-stage workflow contains an explicit verification test for it.** This is how MEDUSA manages uncertainty instead of hiding it: it won't pretend an unknown is fine, and it won't refuse to proceed because something is unproven — it requires the uncertainty to be paired with planned work.

So producing a `conditional` or `unknown` verdict carries an obligation: emit the verification task alongside it, bound to the specific relationship, in the right workflow stage. See `medusa`'s `approval_and_versioning.md` for how the gate reads this.

## Resolutions come from inventory, or say so

Suggested resolutions may include hardware substitutions, software changes, interface adapters, enclosure changes, or required verification tests. Hardware alternatives are **limited to products with sufficient available quantity** — MEDUSA never proposes an unusable replacement.

When nothing in stock satisfies the requirement, return an explicit **blocker**. An honest inventory gap is a correct, valuable answer and its own user story. Never pad a resolution list with a plausible-sounding option that isn't in the seed, and never suggest procurement — external purchasing is out of scope.

There is no minimum resolution count. Offer what actually exists.

## Downstream expansion

The demo's payoff: swapping one camera fans out into mount, enclosure, power, compute, communications, cost, software, and verification changes. `ProposeChange` returns all of it as one connected proposal.

Two rules keep this honest:

- **Expand only the affected region.** A component swap re-runs the checks its change actually touches — a cost change re-runs the budget rollup, a weight change re-runs mounting. It never triggers a full redesign, and the user should never see unrelated parts of the design churn.
- **Expansion is deterministic, not generated.** Downstream effects follow the graph's real relationships. If a new mount is required, it's because the mount's compatibility edge says so, not because a model suggested it. This is what makes the expansion trustworthy enough to approve.

Read `references/expansion_and_display.md` for where to stop expanding, and the display shapes for the assessment panel and the proposal-versus-mainline comparison.

## Where these get produced

- **During generation** — the deterministic validator after LLM traversal (see `medusa-llm-traversal`) produces assessments for the assembled design's relationships.
- **On inspection** — selecting a decision node shows its assessment.
- **During a proposal** — the revised design's affected relationships are reassessed.

Hard conflicts used by the pre-generation filter are a *different thing* from verdicts: `conflicts_with` is an always-true engineering fact the LLM may never see past, while `incompatible` is a verdict on an evaluated relationship that blocks approval. Keep them distinct — the glossary in `medusa-graph`'s `process_practices.md` covers why.
