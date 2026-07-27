---
name: tdd
description: >-
  Test-driven development for MEDUSA -- the red-to-green loop, what makes
  a test worth having, and where tests are allowed to attach. Covers
  seams (MEDUSA's five public walker interfaces are the pre-agreed
  seams), the three anti-patterns (implementation-coupled, tautological,
  horizontal slicing), the rules of the loop, Jac `test` blocks and
  `jac test`, the shared-persisted-root trap, MockLLM for LLM steps, and
  the eight required behavior groups the MVP must cover. Use before
  writing any test, when a test is hard to write, when tempted to expose
  an internal helper for testability, or when building any feature
  test-first. Trigger on "test", "TDD", "red-green", "test-first",
  "coverage", "behavior test", "jac test", "MockLLM", "assert", or
  "seam".
---

# TDD for MEDUSA

Adapted from [mattpocock's TDD skill](https://github.com/mattpocock/skills/blob/main/skills/engineering/tdd/SKILL.md), specialized to Jac and MEDUSA's interface contract.

The core of TDD is the **red → green loop**. This skill is about making that loop produce tests worth having. Read it *before and during* cycles, not after.

Before naming tests, read [.claude/medusa-context.md](../../medusa-context.md) so test names use the product's actual vocabulary — `mainline`, `proposal`, `available`, `selected`, `conditional`, `gate`. A test named in invented vocabulary is a test nobody can map back to a requirement.

## What a good test is

**Tests verify behavior through public interfaces, not internal implementation.** Implementation changes; behavior shouldn't. A test coupled to internals breaks when you refactor something that worked fine, which teaches the team to distrust the suite.

A good test reads as a specification. `"insufficient quantity blocks approval"` tells you what MEDUSA guarantees. It also survives refactoring, because it never looks inside.

## Seams: where tests attach

A **seam** is the public boundary you test at — the interface where behavior is observable without reaching into internals.

**Test only at pre-agreed seams.** For MEDUSA the seams are already agreed, and the PRD names them: **the five public walker interfaces**.

1. `LoadWorkspace`
2. `CreateProject`
3. `ProposeChange`
4. `ApproveProposal`
5. `ResetDemo`

That's the list. Tests must not assert on private helpers, traversal implementation details, or internal graph arrangement a caller can't observe.

This makes the usual hard question easy. When a test is awkward to write, the answer is never "expose the helper." It's one of:

- The behavior isn't observable → it isn't behavior, don't test it.
- The seam is genuinely missing something → change the interface deliberately, and update `medusa`'s `references/walker_interfaces.md`.

The PRD states it directly: internal helpers are not exposed merely for testing.

## Anti-patterns

**Implementation-coupled.** Mocking internal collaborators, asserting on private abilities, or checking results through a side channel — inspecting graph internals directly instead of reading what a walker reported. Diagnostic: the test breaks when you refactor internals even though external behavior is unchanged.

In MEDUSA this most often looks like asserting on the shape of the design graph rather than on what `CreateProject` returned.

**Tautological.** Computing the expected value with the same logic as the code under test. `assert total == sum(p.unit_cost for p in products)` doesn't test the budget rollup — it reimplements it, and it passes by construction even when both are wrong. Derive expectations from an independent source: a known-good literal, a worked example, or the PRD. The demo budget is $75,000 and the seed is fixed, so real expected numbers exist — use them.

**Horizontal slicing.** Writing all the tests up front, before any implementation. Bulk tests verify imagined rather than actual behavior, they lock in test structure before you've learned what the implementation wants to be, and they go insensitive to real change. The antidote is **vertical slicing**: one test, then one implementation, then repeat. Each test is a tracer bullet that reacts to what the last cycle taught you.

The eight behavior groups below are a *coverage checklist*, not a batch to write in one sitting.

## Rules of the loop

1. **Red before green.** Write the failing test first. Watch it fail. Then write the minimum code to pass it — no speculative features, no anticipating the next test.
2. **One slice at a time.** One seam, one test, one minimal implementation per cycle.
3. **Refactoring is not part of the loop.** It belongs to review, not to red-green.

## Jac testing mechanics

Tests are first-class language blocks. `jac run` ignores them; `jac test` runs them. Assertions are plain `assert`.

```jac
test "insufficient quantity blocks approval" {
    result = root spawn ApproveProposal();
    assert not result.reports[0].approved;
    assert result.reports[0].blocked_by == "quantity";
}
```

`root spawn W()` returns the walker instance; every `report` it made is in `result.reports`, in report order.

Run them:

```
jac test medusa.jac              # all tests in a file
jac test medusa.jac -t "insufficient quantity blocks approval"
jac test -x                      # stop on first failure
jac test -v                      # one line per test
```

`-f` filters test *files* by glob; `-t` selects one test by name. They are not interchangeable.

### Two file-naming traps

- **Never name a file `test_*.jac`** — the `test_` prefix collides with Python's test-module import machinery.
- **`<mod>.test.jac` is an annex, not a standalone file.** It attaches to the same-basename module, so `medusa.test.jac` pairs with `medusa.sv.jac`'s module and you run `jac test medusa.jac`. An annex with no base module fails with `No module named`. The annex sees the module's declarations without imports, which keeps tests out of the main file.

### The shared persisted root

This one silently invalidates suites, so it's worth internalizing: **tests in a file run in declaration order against one shared `root`, and anything hung off `root` persists to `.jac/data` between runs.**

Consequences:

- A later test sees nodes an earlier test created.
- A green suite goes red on re-run because last run's nodes are still there — or crashes with `NodeAnchor ... is not a valid reference` when stale anchors meet recompiled code.

Two defenses, use both:

- `jac clean --all --force` (or `jac clean --data`) before a run.
- **Write assertions defensively.** Count what you just created or filter by a unique field; never assert on totals hanging off `root`. `assert len([root-->]) == 30` is a test that will betray you.

MEDUSA has a natural advantage here: `ResetDemo` is a product feature. Leaning on it for setup keeps tests honest, because it exercises the same path the demo relies on.

### LLM steps

Never hit a real model in tests. Use `MockLLM` with canned outputs:

```jac
import from jaclang.byllm.lib { MockLLM }

glob llm = MockLLM(model_name="mockllm", config={"outputs": [...]});
```

Import path is `jaclang.byllm.lib`. See `medusa-llm-traversal` and `jac guide jac-by-llm`.

### Scope note

`jac guide jac-testing` also documents `JacTestClient`, an in-process endpoint client driven from **Python**. MEDUSA hand-authors no Python, and the PRD is explicit that Jac's test blocks and isolated graph contexts are the only mechanism required. Stay in Jac test blocks.

## The eight required behavior groups

Coverage the MVP must reach. Each is written test-first, one vertical slice at a time — not all at once.

| # | Group | Asserts |
|---|---|---|
| 1 | **Seeded workspace** | `LoadWorkspace` returns all seeded models, categories, specs, relationships, and correct quantities |
| 2 | **Project generation** | Pre-filled intake produces a mission graph and the seven-stage workflow |
| 3 | **Inventory constraint** | LLM traversal *cannot* select a product with insufficient available quantity |
| 4 | **Compatibility explanation** | Assessments carry all seven fields |
| 5 | **Golden proposal** | Camera → thermal swap updates every expected affected region |
| 6 | **Approval gates** | Four separate cases: incompatibility, quantity, budget, unsatisfied requirement each block independently |
| 7 | **Version creation** | A valid proposal becomes a new immutable mainline version and updates selected quantities |
| 8 | **Reset behavior** | Reset restores original inventory, project, proposal, and version state |

Group 3 is the highest-value test in the suite. It's the one proving an LLM cannot override an engineering fact — the claim MEDUSA's credibility rests on — and the one that would catch someone "simplifying away" the deterministic pre-filter.

Group 6 needs four distinct tests, not one parameterized over four inputs. Each gate must be independently demonstrable, and a shared setup that happens to trip two gates proves neither.

UI styling gets no pixel-level tests in the MVP. Use `jac browse` for interactive QA instead — see `medusa-ui`.
