# Output contract

Fixed output shapes, independent of which sibling skill produced the content. These apply to what MEDUSA renders on screen and to how you report analysis in conversation while building.

## Quantities: always three figures

Every product carries `owned`, `available`, and `selected for this design`. There is no other inventory state — no on-order, reserved, in-transit, or backordered. Show all three together; showing only availability hides why a product is constrained.

Unavailable products stay **visible and inspectable**, rendered as unselectable with the reason attached. Same for known-incompatible products. Hiding them is a PRD violation — the whole point is that MEDUSA explains dead ends rather than silently pruning them.

## Cost vs. Budget breakdown

Included with the initial design and recomputed after every proposal, not just the first pass:

```
| Subsystem       | Est. Cost | % of Budget | Notes                        |
|-----------------|-----------|-------------|------------------------------|
| Detection       | $18,400   | 25%         | 2x thermal camera            |
| Compute         | $6,200    | 8%          |                              |
| Communications  | $4,800    | 6%          | LTE + radio fallback         |
| Power           | $9,100    | 12%         | 12h runtime, battery         |
| Structures      | $3,500    | 5%          |                              |
| **Total**       | **$42,000** | **56%**   | Budget: $75,000              |
```

State the remaining margin explicitly ("$33,000 / 44% of budget remaining"). If a design is over budget, **lead with that** — it is one of the four hard gates, not a footnote.

When showing a proposal, show cost **before and after** side by side. A delta the user has to compute themselves is a worse comparison view.

## No procurement fields

Do **not** add a `source: new procurement | existing inventory` field or anything like it. MEDUSA models no external purchasing — every line item comes from seeded inventory, so the distinction is meaningless and implies a capability the product deliberately lacks. Cost is what the owned equipment represents against the project budget.

MEDUSA may state that no in-stock item satisfies a requirement. It may not suggest buying one.

## Compatibility assessments

Every evaluated relationship returns the same seven fields — verdict, issue domain, specific issue, evidence, source note, suggested resolutions, downstream effects. That contract is owned by `medusa-compatibility`; don't reshape it here.

## Suggested resolutions

Resolutions come from available inventory only. When nothing in stock satisfies the requirement, return an explicit **blocker** — an honest inventory gap is a valid, useful answer, and one of the PRD's stated user stories. Never pad the list with a plausible-sounding option that isn't in the seed.

There is no minimum number of resolutions. Offer what genuinely exists; one real option beats one real option plus one invented one.

## Tone

Professional, analytical, precise — the audience is a systems engineer. Lead with the conclusion (compliant/non-compliant, compatible/incompatible, approved/blocked) before the supporting detail.

Carry uncertainty forward rather than smoothing it over. Verified specifications outrank AI inference, and an `unknown` that stays visibly unknown is more useful than a confident guess. The evidence and source-note fields exist precisely so a reader can tell which is which.

## Starting a session

MEDUSA has no chat-style initialization prompt. Project setup happens through the **nine-question intake screen**, pre-filled for the scripted demo, with a requirement-review step before generation. If you're helping the user build and the design objective or budget isn't established, read them from the PRD's *Pre-Filled Demo Answers* rather than asking — the demo's parameters are already decided ($75,000 budget, 2 km perimeter, 12h runtime, 500 m detection, −10°C to 45°C, winds to 50 km/h).

## Interface interactions

Supported graph interactions are exactly: pan, zoom, expand, collapse, select. Dragging nodes, reconnecting edges, creating nodes, and saving custom layouts are out of scope — MEDUSA is not a general graph editor. Layouts are deterministic so the demo looks the same every run; see `medusa-ui`.
