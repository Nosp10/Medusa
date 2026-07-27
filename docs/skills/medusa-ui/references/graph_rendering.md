# Rendering the graphs

Both MEDUSA graphs are hierarchical and depth-bounded, which is what makes deterministic layout easy. Neither is a general graph — resist any layout algorithm that could produce different output on a second run.

## Deterministic positioning

The algorithm for both views:

1. Assign each node a **level** from the hierarchy (category → product; or mission → subsystem → product).
2. Level becomes the **x column**, at a fixed stride.
3. Within a level, order nodes by a **stable sort key** — seed order or name, never iteration order of a dict or set.
4. Distribute along **y** at fixed spacing, centering each parent against the span of its visible children.

No physics, no randomness, no animation-settled positions. Given the same graph and the same expand/collapse state, positions must be identical.

Collapse changes which nodes are *visible*, and therefore the y-distribution — that's expected. What must not change is the result for a given visible set.

## SVG structure

Build the SVG in Jac client declarations like any other JSX. A workable structure:

```
<svg viewBox={...}>              pan/zoom by transforming viewBox
  <g class="edges">              edges first, so nodes paint over them
  <g class="nodes">
     <g per node>                rect + label + status marker
```

Notes that save pain later:

- **Pan and zoom via `viewBox`**, not CSS transforms on a wrapper. It keeps stroke widths and hit targets in one coordinate space.
- **Edges before nodes** in document order — SVG has no z-index.
- **One group per node** carrying its own click target, rather than a separate invisible hit-layer.
- Keep click targets comfortably larger than the visual node. Dense graphs plus a live demo plus a trackpad is a bad combination for small targets.

## Node states

Every product node renders one availability state and, where assessed, one verdict state:

| State | Meaning | Treatment |
|---|---|---|
| Selectable | available > 0, no hard conflict | Normal surface |
| Zero-availability | available = 0 | Muted, not hidden; reason on inspect |
| Hard-incompatible | `conflicts_with` a locked-in choice | Muted + conflict marker; reason on inspect |
| Selected | in the current design | Emphasized |
| Proposed | changed by the active proposal | Distinct from selected |

**Muted never means removed.** Zero-availability and incompatible products stay on screen and stay inspectable — user stories 6 and 7. A user clicking a muted node must get the explanation, not a dead click.

The `proposed` state needs to be visually distinct from `selected`, because the comparison view's whole job is showing what's about to change.

## Verdict markers

The four verdicts appear on nodes and edges in the design graph. Use a subtle status color **plus** a shape or glyph — projector color reproduction is unreliable, and this is a live demo. Keep the mapping identical to the assessment panel in `medusa-compatibility`.

`unknown` should read as genuinely distinct from `compatible`, not as a lighter shade of fine. The PRD is emphatic that unknowns stay visible; a treatment that lets them fade into the background undoes that in the UI layer.

## Expand and collapse

Inventory categories collapse to keep a ~30-product tree readable. Persist expand state in client state so re-rendering after a walker call doesn't reset the user's view — losing the user's place mid-demo is jarring.

Default state on load: categories collapsed, so the landing screen reads as an overview rather than a wall. The demo narrative opens by exploring the range, which is easier from a collapsed start.

## Performance

There are ~30 products. This does not need virtualization, canvas rendering, incremental layout, or memoized subtrees. The PRD explicitly excludes performance targets for large graphs — plain SVG is the right call, and optimizing here is wasted effort that costs readability.

## Verifying

`jac browse` drives a real browser, so use it rather than trusting that it compiled:

```
jac browse open localhost:8000
jac browse snapshot          # accessibility tree, @e1-style refs
jac browse click @e5         # real input, not synthetic
jac browse screenshot
```

Walk the scripted path: open inventory → expand a category → create project → generate → select the camera decision → choose the thermal alternative → compare → approve → reset. If that round-trips through `jac browse`, the UI is demo-ready.

The snapshot's accessibility tree is also the cheapest way to catch unlabeled controls, which a dense interface like this accumulates quickly.
