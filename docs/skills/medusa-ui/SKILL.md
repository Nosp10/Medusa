---
name: medusa-ui
description: >-
  MEDUSA's client UI, written entirely in Jac client declarations -- the
  three screens (Inventory Graph, Mission Intake, Design Workspace),
  deterministic SVG graph layouts with pan/zoom/expand/collapse/select,
  the clean Notion-inspired visual language, and the rule that no
  JavaScript, TypeScript, HTML, or CSS is ever hand-authored. Covers
  .cl.jac component shape, handler bodies in .impl.jac, calling the five
  public walkers with `root spawn`, and QA-ing the running app with
  `jac browse`. Use for any screen, component, layout, styling, or graph
  rendering work. Trigger on "UI", "screen", "component", "render",
  "layout", "SVG", "graph view", "styling", "Notion", "intake screen",
  "workspace", ".cl.jac", or "frontend".
---

# MEDUSA UI

## All source is Jac

No hand-authored JavaScript, TypeScript, Python, HTML, or CSS. The UI and its styling are expressed in Jac client declarations. Generated browser artifacts and toolchain runtime dependencies are permitted — they just aren't maintained source.

This is a hard PRD constraint, and it's the one most likely to erode under pressure ("just a small `.css` file"). It doesn't.

Load `jac guide jac-cl-components` before writing any component, and `jac guide jac-cl-organization` before adding one to an existing screen. `jac guide jac-cl-styling` covers styling patterns. These are authoritative; this skill covers only what's MEDUSA-specific.

## Component shape

Verified against the 0.34.5 scaffolder. A client component is a `def:pub` returning `JsxElement`, with reactive state declared via `has`, mount effects in `can with entry`, and handler *bodies* separated into `.impl.jac`:

```jac
# frontend.cl.jac
sv import from medusa { Product, LoadWorkspace }

def:pub app -> JsxElement {
    has products: list[Product] = [],
        selected_id: str = "";

    can with entry {
        loadWorkspace();
    }

    async def loadWorkspace -> None;

    return <div>...</div>;
}
```

```jac
# frontend.impl.jac
impl app.loadWorkspace -> None {
    result = root spawn LoadWorkspace();
    products = result.reports;
}
```

Key details:

- **`sv import`** pulls server types and walkers into client code, giving typed dot-access (`product.available`) instead of untyped dict keys. Type `reports` concretely on the server side for this to work.
- **`root spawn <Walker>()`** is how the client calls the API — the five public walkers are the only calls the client makes.
- **File suffixes are meaningful** to the compiler: `.cl.jac` client, `.sv.jac` server, `.impl.jac` bodies. See `jac guide jac-codespaces` for how placement is inferred and when to override.

## The three screens

### 1. Inventory Graph (landing)

Opens directly — no auth, no setup. Shows category and product nodes with specifications, all three quantities, relationships, availability, and compatibility detail. Contains the **Create New Project** action.

Layout: an **expandable left-to-right category tree**. Categories collapse so a wide inventory stays readable.

The rule that governs this screen: **unavailable and incompatible products stay visible and inspectable**, rendered as unselectable with the reason attached. Never filter them out — explaining a dead end is the feature.

### 2. Mission Intake

The nine-question guided flow, pre-filled for the demo. Every structured question offers quick options plus a custom value; mission goal and unusual constraints take open text. Any pre-filled answer must be editable — that's how dynamic generation gets demonstrated.

Ends with a **requirement-review step** before generation. AI never silently reinterprets the mission.

### 3. Design Workspace

The initial design graph, seven-stage workflow, selected inventory, compatibility assessment panel, guided suggestions, the one proposal, the comparison view, approval state, version history, and reset.

Layout: a **fixed mission → subsystem → product flow**.

## Deterministic layouts

Graph layouts are deterministic — same seed, same positions, every run. This is a demo-integrity requirement (presenter story 45): a force-directed layout that settles differently each run makes the demo unrepeatable and the screenshots inconsistent.

Compute positions from the graph's structure, not from simulation or randomness. Both MEDUSA layouts are hierarchical and depth-bounded, so this is straightforward: assign a column per level, distribute nodes within a column by stable sort order, done.

Supported interactions are exactly **pan, zoom, expand, collapse, select**. Out of scope: dragging nodes, reconnecting edges, creating nodes, saved custom layouts. MEDUSA is not a general graph editor — declining these is correct behavior, not a gap.

Read `references/graph_rendering.md` for the SVG structure, hit targets, and node state styling.

## Visual language

Clean, restrained, information-dense, Notion-inspired: neutral surfaces, clear typography, compact panels, subtle status colors, progressive disclosure.

"Information-dense" and "restrained" together mean: fit real content on screen without decoration competing with it. No gradients, no shadows-as-ornament, no color that isn't carrying meaning.

Status colors carry the four verdicts (`compatible` / `conditional` / `incompatible` / `unknown`) and availability states. Keep them **subtle and consistent** — a `conditional` on a graph node and a `conditional` in the assessment panel must read as the same state. Since color is the primary verdict signal, pair it with text or an icon so it survives a projector with poor color reproduction, which is a real risk for a live demo.

Progressive disclosure is what makes density workable: the graph shows verdict state, selecting a node reveals the full seven-field assessment. Don't try to show everything at once.

`jac guide jac-shadcn-blocks` carries a spacing scale, type scale, and structural skeletons worth following rather than reinventing.

## QA the running app

```
jac start --dev main.jac          # hot reload for client files
jac browse open localhost:8000
jac browse snapshot               # accessibility tree with @e1 refs
jac browse click @e5
jac browse screenshot
jac browse console                # buffered console output
```

`jac browse` drives a real headless browser, so it's the way to confirm a screen actually works rather than merely compiling. Use it to walk the scripted demo path end to end before declaring the UI done — the snapshot's accessibility tree also surfaces unlabeled controls, which matter for a dense interface like this one.

`jac guide jac-debugging` covers client-side staleness (W1101/W1051 drift after a server contract change), which shows up as a client that compiles against a walker signature that no longer exists.
