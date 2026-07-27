---
name: medusa-graph
description: >-
  MEDUSA's graph model and the Jac language workflow for building it --
  inventory categories and product nodes, owned/available/selected
  quantities, compatibility and mission-to-subsystem-to-product edges,
  and the walker roles that filter, generate, and validate a design. Also
  the routing layer to the Jac compiler's bundled reference guides
  (`jac guide`), which are the authoritative language spec, plus the
  verified gotchas and the check/test/run loop. Use before modeling any
  node or edge type, before writing or editing any .jac file, when a
  `jac check` diagnostic is unclear, or when deciding where code should
  live. Trigger on "node", "edge", "walker", "graph model", "schema",
  "quantities", "jac syntax", "jac check", ".jac", "Jaseci", or any Jac
  language question.
---

# MEDUSA graph model and Jac workflow

## Do not write Jac from memory

The Jac language moves fast and its syntax is easy to confuse with Python or JSX. The compiler ships ~30 curated reference guides that are the authoritative spec — they update with the compiler, so they are always more current than any hand-written summary, **including this skill**.

```
jac guide                      # list every guide
jac guide <name>               # read one
jac guide --search <keyword>   # find by topic
```

Installed and verified here: **jac 0.34.5**. (Older notes referencing `jaclang 0.16.7` or `pip install jaclang` are stale — this machine has the `jac` binary at `~/.local/bin/jac`, and byLLM imports from `jaclang.byllm.lib`.)

### Task → guide routing

| Doing this | Load this guide |
|---|---|
| Anything at all, first time | `jac-core-cheatsheet` |
| Defining nodes/edges, queries, filters | `jac-node-edge-patterns` |
| Walker traversal, `visit`/`report`/`spawn`, exit abilities | `jac-walker-patterns` |
| Declaring fields, defaults, ordering | `jac-has-fields` |
| Type errors, `any` boundaries, W1051 warnings | `jac-types` |
| Public endpoints, `walker:pub`, response envelope | `jac-sv-endpoints` |
| `:pub` vs `:priv` semantics | `jac-sv-auth` |
| Graph persistence, querying, schema changes | `jac-sv-persistence` |
| `by llm()`, structured output, MockLLM | `jac-by-llm` |
| Test blocks, `jac test`, persisted-root gotcha | `jac-testing` |
| Splitting files, `.impl.jac`, annexes | `jac-impl-files` |
| Where code runs (client/server), `cl`/`sv` overrides | `jac-codespaces` |
| Client components, JSX, reactive state | `jac-cl-components` |
| Build failures, stale cache, diagnostics | `jac-debugging` |
| `jac.toml` settings | `jac-config` |

## The fix loop

```
jac check <file>     # type-check + lint; diagnostics link to the right guide
jac test             # behavior tests (see the tdd skill)
jac start --dev main.jac
jac browse open localhost:8000   # then snapshot / click @e5 / screenshot
```

`jac check` diagnostics carry `→ run 'jac guide <name>'` hints — follow them rather than guessing. When output looks stale or inexplicable, `jac-debugging` covers `jac clean` vs `jac purge` vs `.jac/data`.

Never hand over Jac that hasn't been through `jac check`. Several plausible-looking constructs fail or silently do nothing; the ones already confirmed here are listed in `references/verified_gotchas.md`.

## MEDUSA's graph model

Full detail in `references/graph_model.md`. The shape:

- **Six inventory categories** — sensors, compute, communications, power, structures, support equipment. Roughly 30 specific product models across them, all seeded.
- **Products carry three quantities** — `owned`, `available`, `selected`. Never add a fourth state; the PRD fixes these three.
- **Compatibility edges** between products, carrying the assessment contract owned by `medusa-compatibility`.
- **The design graph is a fixed hierarchy** — mission → subsystem → product. Not an arbitrary graph; the layout depends on this being predictable.
- **Version nodes** form an append-only chain for the mainline (see `medusa`'s `approval_and_versioning.md`).

Model only attributes something actually reads. An attribute that no filter, score, assessment, or display ever touches is noise — and in a seeded demo it's noise you have to hand-author 30 times.

## Walker roles

MEDUSA's walkers split by job, and the split is load-bearing for the PRD's "AI cannot override engineering facts" rule:

1. **Public interface walkers** (`walker:pub`) — the five external entry points. See `medusa`'s `references/walker_interfaces.md`.
2. **The deterministic filter** — plain Jac, no LLM. Removes insufficient-quantity and known-incompatible products *before* any model sees them.
3. **The LLM-guided traversal walker** — `visit <candidates> by llm()` over survivors only. Owned by `medusa-llm-traversal`.
4. **The deterministic validator** — runs *after* traversal, checks the assembled design's relationships. Catches anything the model got wrong.
5. **The impact-expansion walker** — takes one accepted change and walks only the affected region. Never a full redesign.

Steps 2 and 4 sandwich step 3 on purpose. That sandwich is the architecture: determinism owns the facts, the LLM owns the judgment, and the LLM's output is re-checked by determinism.

## Process discipline

`references/process_practices.md` covers the parts worth keeping as the build grows: a lightweight glossary before naming node and edge types, the filter for which decisions deserve a durable write-up, tracer-bullet slices with an explicit human-in-the-loop split, and keeping a running map of open design questions instead of one monolithic planning pass.

## File layout

Follow the Jac convention the compiler infers and the scaffolder generates, not a generic `src/` tree. Suffixes are meaningful to the compiler (`jac guide jac-codespaces`):

```
medusa/
├── jac.toml
├── main.jac              # composes server + client
├── medusa.sv.jac         # the deep module: five walker:pub interfaces
├── demo_data.sv.jac      # 30-product seed + pre-filled scenario
├── frontend.cl.jac       # the three screens
├── frontend.impl.jac     # handler bodies
├── components/*.cl.jac   # graph renderer, panels, cards
└── medusa.test.jac       # behavior tests through the five seams
```

This preserves the PRD's architectural intent exactly — one deep module, no repository/controller/DTO/adapter/use-case layers, split a file only when its size causes a demonstrated locality problem. Only the filenames change, to ones the toolchain understands.
