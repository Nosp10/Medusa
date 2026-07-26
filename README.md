# Medusa — Mission-to-Architecture Design Agent

Turns a plain-English mission need into a proposed defense system architecture
built from a graph of real components — and revises it live when requirements
change, explaining every KEEP / SWAP / CONFLICT decision.

Built in [Jac](https://www.jac-lang.org/) (jaclang 0.16): components are graph
nodes, compatibility is edges, and five **specialized walkers** (one per
hardware category) traverse the graph like a systems engineer would.

## Run it

```bash
jac run main.jac   # scripted end-to-end demo (the acceptance script)
jac run cli.jac    # interactive: type a mission, then inject changes
```

No API key or network needed — the three LLM functions run on deterministic
fallbacks (see "Going live with an LLM" below).

## Demo script (rehearsed)

1. Mission: *"Monitor a perimeter at night in bad weather and alert operators
   to movement."* → 5 picks stream with rationale + full inventory report.
2. `budget_cut 30` → the FLIR Boson thermal camera SWAPs to the cheaper
   Hikvision thermal, with the violated budget number named.
3. `add_env_spec milspec` → housing KEEPs (already milspec); power SWAPs to a
   MIL-STD-1275 adapter under combined budget + env pressure.
4. `budget_cut 80` → genuine CONFLICT: no component set can satisfy $1,400.

## Architecture

```
main.jac                  scripted demo          cli.jac   interactive loop
schema.jac                Component/Mission nodes, CompatibleWith edge
library.json              25 realistically-specced components, 5 per category
graph_build.jac           idempotent load + compatibility edge wiring
walkers/
  base_walker.jac         evaluate() — THE shared scorer (one yardstick for all)
  sensor_walker.jac       upweights detection/env-robustness tags
  processor_walker.jac    upweights on-board analytics
  comms_walker.jac        range/reliability over raw cost
  power_walker.jac        HARD: supply must cover picked components' draw
  housing_walker.jac      HARD: enclosure rating >= mission env spec
design_coordinator.jac    two-wave orchestration + greedy budget fit
revise_walker.jac         delta -> re-run walkers -> KEEP/SWAP/CONFLICT
inventory.jac             per-category considered-components report
llm_utils.jac             parse_requirements / justify_choice / explain_rejection
```

**Wave 1** (sensor, processor, comms) walkers are fully independent — no shared
state — so they're architecturally parallel and can be threaded without
touching walker logic. **Wave 2** (power, housing) reads wave-1 picks for
power sizing.

**Scoring** is a plain weighted sum, deliberately not a solver:
`2×mission-tag matches + 1×category strengths − cost penalty − power penalty −
env-gap penalty`. The same `evaluate()` runs at design time and revision time,
which is what makes every decision auditable against the inventory report.

**Budget fit** is a greedy pass: while the architecture total exceeds budget,
take the swap with the best savings-per-score-lost ratio; if nothing cheaper
remains, flag a genuine requirement conflict.

**Revision stability**: a prior pick is kept if it re-scores within 10% of the
new best and is no pricier — engineers don't churn a design over noise.

## Change grammar (CLI)

```
budget_cut 30                 # cut cost budget by 30%
add_env_spec milspec          # indoor | outdoor | ruggedized | milspec
mission_tags night-vision,encrypted,long-range
```

## Going live with an LLM

`llm_utils.jac` is the single seam. `pip install byllm`, set an API key, and
replace each function body with a `by llm()` declaration — same signatures,
same call sites. Everything else is untouched.

## Known simplifications (8-hour scope)

- Wave-1 "parallelism" is architectural, not threaded.
- Budget fit doesn't re-verify power eligibility after cross-category swaps
  (guarded only for the power category itself).
- `parse_requirements` fallback is keyword-based; the LLM version subsumes it.
- Jac persists the graph to `.jac/data/` between runs; `build_graph()` wipes
  and rebuilds so runs stay deterministic.
