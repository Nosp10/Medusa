# Verified gotchas

Every item below was confirmed by running the compiler on this machine — `jac 0.34.5`, 2026-07-26. Nothing here is inherited from memory or from older docs.

This file is deliberately short. It holds only what the bundled guides don't make obvious, or what a previous version of Jac did differently. For anything else, `jac guide <name>` is authoritative — see the routing table in SKILL.md.

**Re-verify this file whenever the toolchain is upgraded.** Version-specific behavior is exactly what goes stale, and a confidently wrong reference is worse than no reference.

---

## `++>` returns the node, not a list

```jac
created = root ++> P(name="one");
print(type(created).__name__);   # P
print(created.name);             # "one"   <- direct access works
```

Older Jac (0.16.x) returned a list here, making `created[0]` the idiomatic form. **That is no longer true.** In 0.34.5 you get the node itself, and `created[0]` raises at runtime.

If you're reading code or notes that index immediately after a connect, they predate this change.

## Edge declarations use `-->`, not `->`

```jac
edge Stocks: Category --> Product;    # correct
edge Stocks: Category -> Product;     # error[E0001]: Expected '-->', got '->'
```

Declare endpoint types on every edge. An untyped edge yields `Unknown`-typed traversal results, which surfaces as W1051 warnings and breaks type-checking against typed parameters.

## Parenthesized filters were removed

```jac
visit [-->[?:Product, available > 0]];   # correct
visit [-->](?available > 0);             # error[E0048]: removed syntax
```

The compiler names this one directly: *"Parenthesized filter syntax '(?:...)' was removed. Use bracket syntax '[?:...]' instead."*

Include the **node type** in the filter (`[?:Product, available > 0]`), not just a bare field predicate. A bare predicate still type-checks but emits a W1051 "could not be resolved" warning.

## Field ordering: defaults last, always

```jac
node Bad {
    has a: str = "x",
        b: int;              # error[E2004]: Non default attribute 'b'
}                            #              follows default attribute
```

Confirmed on 0.34.5. This bites most when adding a required field to a node that already has defaults — the new field must move *up*, not append to the bottom. `jac guide jac-has-fields` is the reference.

## `visit ... by llm()` is real and compiles

MEDUSA's core mechanic type-checks clean:

```jac
can choose with Category entry {
    candidates: list[Product] = [];
    for p in [here ->:Stocks:->] {
        if p.available > 0 and not p.blocked {
            candidates.append(p);
        }
    }
    visit candidates by llm();
}
sem Pick.choose = "Select the products best matching the mission.";
```

Two notes:

- It is **not documented in the bundled guides** — `jac guide jac-by-llm` covers `by llm()` on functions only, with no mention of LLM-guided `visit`. Verified working anyway, but treat it as thinly documented and lean on `jac check` when changing it.
- The `visit ... by llm()` expression resolves as `Unknown`, producing a W1051 warning. That is expected and harmless — the compiler can't know what the model will return.

Building the candidate list in plain Jac first (as above) is both cleaner than inline filters and exactly what the PRD requires: deterministic rules remove, then the LLM selects from survivors.

## byLLM imports come from `jaclang.byllm.lib`

```jac
import from jaclang.byllm.lib { Model }
import from jaclang.byllm.lib { MockLLM }
```

Not `byllm.lib` — that path is from an older packaging layout. There is no separate `pip install byllm` on this machine; byLLM ships with the `jac` binary (`jac model` manages local model weights).

## `has` supports a comma form

Both are valid; the scaffolder generates the comma form:

```jac
has author: str,
    text: str;
```

## A walker at `root` traverses nothing on its own

Spawning is not traversing. Without a `Root`-triggered ability, the walker runs, reports its defaults, and exits having visited zero nodes:

```jac
can start with Root entry {
    visit [-->];
}
```

This is the quiet failure mode — no error, just an empty result.

## `reports` needs its `= []` default

```jac
has reports: list[Message] = [];
```

Without the default, `reports` becomes a **required spawn argument** and every call site fails. Typing it concretely (not `list[dict]`) is also what gives the client dot-access instead of untyped dict keys.

## `sem`, not docstrings, drives LLM behavior

Docstrings are for humans and are **not** included in the generated prompt. Only `sem` statements reach the model — for the function, each parameter, and each field of a returned object.
