---
name: medusa-llm-traversal
description: >-
  MEDUSA's AI generation step -- constrained LLM-guided graph traversal
  with `visit ... by llm()`. Covers the mandatory sandwich (deterministic
  Jac filter, then LLM selection over survivors only, then deterministic
  validation), why the LLM can never override quantity or hard
  compatibility rules, capturing the visited path and per-selection
  rationale for explainability, `sem` prompt wiring, MockLLM testing, and
  the fail-loud rule that a bad generation must leave graph state
  unchanged. Use when building or debugging CreateProject, any `by llm()`
  call, or any step where AI judgment enters the design. Trigger on
  "visit by llm", "by llm", "byLLM", "LLM traversal", "AI selection",
  "rationale", "visited path", "MockLLM", or "generation".
---

# Constrained LLM-guided traversal

## The sandwich is the architecture

MEDUSA's whole credibility rests on one structural claim: **an LLM cannot override an engineering fact.** That isn't achieved by prompting well. It's achieved by never showing the model an invalid option in the first place.

```
1. DETERMINISTIC FILTER   plain Jac. Removes insufficient quantity
                          and known hard incompatibilities.
                                    ↓
2. LLM SELECTION          visit <survivors> by llm()
                          judgment only, over a pre-cleaned set
                                    ↓
3. DETERMINISTIC VALIDATION  plain Jac. Re-checks the assembled design.
```

Steps 1 and 3 are not belt-and-braces redundancy — they own different failures. Step 1 makes an invalid selection *impossible*. Step 3 catches a combination that is individually valid but collectively wrong (the assembled design exceeding budget, a subsystem left unsatisfied). Never collapse them into one.

If you ever find yourself writing a prompt that says "only choose products with available quantity above zero," that's the signal you've put the constraint in the wrong layer. Move it to step 1.

## The verified pattern

Confirmed to type-check on jac 0.34.5:

```jac
can choose with Category entry {
    # Step 1: deterministic gate. The model never sees what this removes.
    candidates: list[Product] = [];
    for p in [here ->:Stocks:->] {
        if p.available > 0 and not has_hard_conflict(p, self.locked_in) {
            candidates.append(p);
        }
    }

    # Step 2: judgment, over survivors only.
    visit candidates by llm();
}
sem Pick.choose = "Select products that best satisfy the mission requirement.";
```

Building the candidate list in plain Jac (rather than an inline traversal filter) is both cleaner and exactly what the PRD mandates. It also sidesteps a W1051 warning on inline field predicates.

**`visit ... by llm()` is not documented in the bundled guides.** `jac guide jac-by-llm` covers `by llm()` on functions only. It works — verified — but is thinly documented, so run `jac check` after any change to it and don't assume behavior beyond what you've tested.

The expression resolves as `Unknown`, so a W1051 warning here is expected and harmless.

## Traversal intent must be explicit

The PRD requires that traversal intent and selection limits are stated, not implied. Two mechanisms:

- **`sem`, not docstrings.** Docstrings are for humans and never reach the model. Only `sem` statements are included in the generated prompt — for the ability, each parameter, and each field of any returned object. A `by llm()` call without a `sem` is relying on the function name alone to carry the intent.
- **Selection limits in the prompt and enforced in code.** If a subsystem should pick at most two products, say so in `sem` *and* check it in step 3. The `sem` makes it likely; the validator makes it true.

## Explainability is a product requirement

Every AI-guided selection must carry a **visited path** and a **short rationale**. This isn't logging — it's user stories 17 and 18, it's on screen, and a selection the user can't interrogate is a demo failure even when the choice is good.

Capture both as the walker moves:

```jac
walker GenerateDesign {
    has mission: str,
        visited_path: list[str] = [],
        rationale: dict = {},
        reports: list[DesignView] = [];
}
```

Rationale should be a sentence a systems engineer would accept — what the product does for this mission, and what it was chosen over. "Best option" explains nothing. "Only in-stock sensor rated to 50 km/h wind; chosen over the EO camera which lacks a weather rating" is the bar.

## Fail loud, change nothing

Generation is live in the demo. There is no canned-design fallback, and there must not be one — a silent fallback would make the AI claim untrue on stage.

So: **a failed or invalid generation produces an explicit error and leaves graph state unchanged.** Practically, build the candidate design and validate it *before* committing anything to the persistent graph. Don't write nodes as you go and unwind on failure — a half-written design that the reset path has to clean up is how the demo becomes unrepeatable.

byLLM raises typed exceptions inheriting from a common base. Catch them at the `CreateProject` boundary, surface the specific failure to the user, and leave the previous state intact.

## Testing without live API calls

`MockLLM` makes generation deterministic for tests:

```jac
import from jaclang.byllm.lib { MockLLM }

glob llm = MockLLM(model_name="mockllm", config={"outputs": [...]});
```

Import path is `jaclang.byllm.lib` — not `byllm.lib`, which is an older packaging layout. `jac guide jac-by-llm` and `jac guide jac-testing` both cover this.

What to test with it, per the `tdd` skill's behavior groups:

- **Behavior group 3** — the inventory constraint. Point MockLLM at a product with insufficient quantity and assert it *cannot* be selected. This is the single most valuable test in the suite: it proves the sandwich holds, and it's the one that would catch someone "simplifying" step 1 away.
- **Behavior group 2** — the pre-filled intake produces a mission graph and the seven-stage workflow.

Test through `CreateProject`, never against the traversal walker directly — it's an internal, not one of the five seams.

## Scope

`by llm()` powers selection judgment. It does **not** generate the workflow structure (seven fixed stages), invent products (inventory is seeded), or propose purchases (no external procurement). If a model output would create any of those, the design has drifted from the PRD — see the scope boundary in the `medusa` skill.
