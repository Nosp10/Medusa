# MEDUSA's graph model

Read `jac guide jac-node-edge-patterns` before writing any of this — the syntax below is illustrative of the *model*, and the guide is authoritative on the *language*.

## Inventory side

### Categories

Six, fixed by the PRD: sensors, compute, communications, power, structures, support equipment. The inventory screen renders these as an expandable left-to-right tree, so a category node needs only what the tree shows.

```jac
node Category {
    has name: str,
        description: str = "";
}
```

### Products

Roughly 30 specific product models — real-feeling model names, not generic equipment classes. User story 4 is explicit that a viewer must be able to inspect *specific models*, so "Thermal Camera" is not acceptable where "FLIR-T840 LWIR" is meant.

```jac
node Product {
    has name: str,
        category: str,
        specs: dict,
        owned: int,
        available: int,
        unit_cost: int,
        selected: int = 0,
        notes: str = "";
}
```

Two rules that come up constantly:

- **Exactly three quantity states**: `owned`, `available`, `selected for this design`. No on-order, reserved, in-transit, or backordered — the PRD fixes this list.
- **Zero-availability products stay in the seed.** They are not dead weight; they let MEDUSA demonstrate an honest dead end (user story 6, presenter story 42). Same for deliberately incompatible products.

`specs` as a `dict` is fine for display, but anything the deterministic filter *branches on* should be a real typed field. A filter reading `p.specs["ip_rating"]` is a runtime surprise waiting to happen; a filter reading `p.weather_rated` is checkable.

### Field ordering

Non-default fields must all come before any defaulted field, on every archetype. Violating it is a hard error (`E2004`), and it's easy to trip when adding a required field to a node that already has defaults — the new field has to move *up*, not append. `jac guide jac-has-fields` is the reference.

Jac 0.34.5 also supports the comma form, which is what the scaffolder generates:

```jac
node Product {
    has name: str,
        category: str,
        selected: int = 0;
}
```

## Relationship side

### Compatibility edges

Product-to-product relationships carry the assessment. The seven-field contract belongs to `medusa-compatibility` — model the edge to hold it rather than inventing a parallel shape:

```jac
edge CompatibleWith: Product --> Product;
edge ConflictsWith: Product --> Product;
```

**Declare endpoint types** (`edge E: A --> B;`, with `-->` not `->`). An untyped edge makes traversal results `Unknown`-typed, which turns into W1051 warnings and runtime surprises against typed parameters. Verified: `edge Stocks: Category -> Product;` is a syntax error; `-->` is correct.

`conflicts_with` is what the deterministic pre-filter reads. It encodes hard, always-true engineering facts — never soft preferences, because the LLM is not allowed to override it.

### The design graph

A fixed three-level hierarchy, not an arbitrary graph:

```
Mission ──> Subsystem ──> Product
```

The design screen's layout depends on this being predictable, and the PRD explicitly rules out AI-generated workflow structures. Subsystems map onto the mission's functional areas (detection, compute, communications, power, structures).

### Workflow stages

Seven, always the same, never generated:

1. Confirm requirements
2. Select detection hardware
3. Select compute and software
4. Configure power
5. Configure communications and alerts
6. Assemble and deploy
7. Validate against mission conditions

MEDUSA changes the products, issues, rationale, and verification work *within* these stages. It never invents a different skeleton. Selected inventory links to stages so the design and the plan cannot drift apart (user story 21).

### Version chain

Append-only. Each approval creates a new version node; prior versions are never rewritten. See `medusa`'s `approval_and_versioning.md` — and note there is no branching, so this really is a chain, not a tree.

## Querying

Bracket filter syntax, with the node type included:

```jac
in_stock = [here ->:Stocks:->[?:Product, available > 0]];
```

Verified in 0.34.5: the old parenthesized form `(?...)` was **removed** and is a hard error (`E0048`) — use `[?...]`. Including the node type (`[?:Product, ...]`) rather than a bare field predicate also avoids an `Unknown`-type warning.

`++>` returns a **list**, not the created node. Index it immediately:

```jac
created = root ++> Product(name="FLIR-T840", ...);
product = created[0];
```

## Modeling discipline

Only model what something reads. Before adding an attribute, name the filter, score, assessment field, or UI element that consumes it — if you can't, don't add it. In a seeded demo every extra attribute is 30 more hand-authored values that can drift out of sync with the golden path.

The inverse also holds: if the deterministic filter or an approval gate needs a fact, it belongs in the model as a typed field, not buried in a free-text note the code has to parse.
