# MEDUSA Product Requirements Document

**Product:** MEDUSA  
**Document type:** Product Requirements Document  
**Status:** Ready for implementation planning  
**Delivery target:** Local demonstration  
**Implementation constraint:** All hand-authored application source is Jac  

This document supersedes the ForgeGraph concept in `jac-defense-prototyping-platform-pdr-v2.md`. The retained idea is a graph-native defense prototyping workspace; the product name, demo incident, scope, human workflow, module design, and delivery constraints are replaced by the decisions below.

## Problem Statement

Defense engineering teams may own useful cameras, thermal sensors, radar units, compute devices, radios, batteries, enclosures, mounts, and support equipment without having a clear way to determine which available items can form a mission-ready prototype.

Inventory lists show products and quantities, but they usually do not explain:

- whether two selected products are compatible;
- whether the compatibility is hardware, software, power, communications, mechanical, or environmental;
- what evidence supports a compatibility claim;
- which available alternatives could resolve a problem;
- how one substitution affects the rest of the design; or
- whether the complete design satisfies the mission and project budget.

MEDUSA demonstrates this problem through a fictionalized modern response to Boeing's SBInet border-surveillance program. Public GAO reporting described camera instability in adverse weather, radar mechanical and alignment problems, signal loss, power failures, terrain gaps, and poor adverse-weather performance. MEDUSA does not recreate SBInet, use real program data, or claim to model Boeing's proprietary architecture. It uses the public incident as inspiration for a clear fictional mission:

> Design a portable perimeter-monitoring prototype that detects and tracks people or vehicles at night, remains reliable in rain and high wind, and alerts a remote operator using only currently available inventory.

The MVP must prove that a graph-native platform can turn this mission and a seeded inventory into an explainable initial design, then help a human improve and approve it.

## Solution

MEDUSA is a local, graph-native defense prototyping demonstration built in Jac.

The user begins on a clean inventory graph containing roughly 30 specific product models across sensors, compute, communications, power, structures, and support equipment. Every product displays relevant specifications and the quantities owned, available, and selected for the current design.

From the inventory, the user selects **Create New Project** and reviews a nine-question intake that is pre-filled for the scripted demo. MEDUSA converts those answers into mission requirements and launches a Jac walker through the inventory graph.

The walker:

1. removes products with insufficient available quantity or known hard incompatibilities;
2. uses `visit ... by llm()` to choose mission-relevant successors from the remaining graph;
3. records the visited path and selection rationale;
4. constructs an initial mission-to-subsystem-to-product graph;
5. validates the resulting relationships deterministically; and
6. produces a fixed seven-stage implementation workflow.

The initial design intentionally includes a low-light camera whose night performance is suitable but whose rain and wind performance is unverified. The user selects that decision and reviews a structured compatibility assessment. MEDUSA suggests only resolutions that exist in available inventory. The demo's golden path replaces the camera with an in-stock weather-rated thermal camera.

MEDUSA expands that one change into its affected mount, enclosure, power, compute, communications, project cost, software, and verification work. The user compares the proposal with the current mainline and approves it only after four hard approval gates pass.

The result is a more sophisticated, human-approved design graph, an updated workflow, updated selected quantities, and an immutable before/after decision record.

## Demo Intake

The project intake uses exactly nine questions. Every structured question offers quick options and a custom value. The mission goal and unusual constraints accept open-ended text.

1. **Mission goal**  
   What must the system accomplish?
2. **Deployment style**  
   Portable, temporary fixed, permanent fixed, vehicle-mounted, or custom.
3. **Coverage area**  
   Perimeter length, terrain, entry points, and known blind spots.
4. **Detection targets**  
   People, vehicles, animals, drones, or custom targets.
5. **Detection performance**  
   Minimum range, maximum alert delay, and acceptable false-alarm level.
6. **Environmental conditions**  
   Darkness, rain, fog, dust, wind, and operating-temperature range.
7. **Operating duration and power**  
   Required runtime and available battery, solar, generator, or facility power.
8. **Operator and communications needs**  
   Operator count and location, available networks, and preferred alert method.
9. **Project budget**  
   Total project budget and preference for existing inventory.

### Pre-Filled Demo Answers

1. Monitor a remote perimeter at night in bad weather and alert an operator when people or vehicles enter the protected area.
2. Temporary fixed installation with field setup within four hours.
3. Two-kilometer mixed-terrain perimeter, two vehicle gates, and one known line-of-sight gap.
4. Detect people and vehicles; filter animals.
5. Detect at 500 meters, alert within 10 seconds, and maintain a low false-alarm rate.
6. Operate in darkness, rain, fog, dust, winds up to 50 km/h, and temperatures from −10°C to 45°C.
7. Operate for at least 12 hours using batteries; solar assistance is available but not required.
8. Support one remote operator, intermittent LTE, local radio fallback, and dashboard alerts.
9. Remain within a $75,000 project budget and use only available inventory.

## User Stories

1. As a systems engineer, I want to open directly into the MEDUSA workspace, so that the demo begins without authentication or setup friction.
2. As a systems engineer, I want to see inventory as a graph, so that categories, products, and engineering relationships are understandable together.
3. As a systems engineer, I want to expand and collapse inventory categories, so that a wide inventory remains readable.
4. As a systems engineer, I want to inspect specific product models, so that I can see more than generic equipment categories.
5. As a systems engineer, I want to see owned, available, and selected quantities, so that the design reflects real inventory limits.
6. As a systems engineer, I want unavailable products to remain visible, so that I understand why they cannot be selected.
7. As a systems engineer, I want incompatible products to remain inspectable, so that MEDUSA can explain the incompatibility rather than silently hiding it.
8. As a systems engineer, I want to start a project from the inventory workspace, so that mission planning begins with what the organization already owns.
9. As a systems engineer, I want a short guided intake, so that I can provide useful constraints without writing a formal specification.
10. As a presenter, I want the intake pre-filled, so that the scripted demo is quick and repeatable.
11. As a systems engineer, I want to change any pre-filled answer, so that MEDUSA can demonstrate dynamic generation.
12. As a systems engineer, I want to review the interpreted requirements before generation, so that AI does not silently change the mission.
13. As a systems engineer, I want MEDUSA to generate an initial graph, so that I am not starting from a blank design surface.
14. As a systems engineer, I want the generation walker to consider only inventory with sufficient available quantity, so that every selectable recommendation is actionable.
15. As a systems engineer, I want known hard incompatibilities removed before AI reasoning, so that an LLM cannot override engineering facts.
16. As a systems engineer, I want LLM-guided traversal among valid candidates, so that product selection responds to the mission rather than following a static path.
17. As a systems engineer, I want to see the graph path visited by the walker, so that the initial design is explainable.
18. As a systems engineer, I want a short rationale for each AI-guided selection, so that I can judge the reasoning.
19. As a systems engineer, I want the initial design organized from mission to subsystem to product, so that its structure is understandable at a glance.
20. As a systems engineer, I want a consistent seven-stage workflow, so that every design has a predictable implementation path.
21. As a systems engineer, I want selected inventory linked to workflow stages, so that the design and plan cannot drift apart.
22. As a systems engineer, I want to select a decision node, so that I can inspect and improve a specific choice.
23. As a systems engineer, I want every evaluated relationship to show a verdict, so that I know whether it is compatible, conditional, incompatible, or unknown.
24. As a systems engineer, I want every issue categorized by engineering domain, so that I can distinguish hardware, software, power, communications, mechanical, and environmental problems.
25. As a systems engineer, I want a specific issue statement, so that a generic warning becomes actionable.
26. As a systems engineer, I want to see the evidence type and source note, so that verified facts are distinguishable from prior-design evidence and AI inference.
27. As a systems engineer, I want MEDUSA to suggest hardware, software, interface, enclosure, or verification resolutions, so that I can improve the design without free-form graph editing.
28. As a systems engineer, I want selectable product alternatives limited to available inventory, so that MEDUSA never proposes an unusable replacement.
29. As a systems engineer, I want a blocker when no in-stock alternative can satisfy the requirement, so that inventory gaps remain honest.
30. As a systems engineer, I want to choose the weather-rated thermal-camera alternative, so that I can resolve the demo's environmental risk.
31. As a systems engineer, I want MEDUSA to expand the camera change into downstream impacts, so that a small substitution becomes a complete engineering proposal.
32. As a systems engineer, I want to compare the proposal with the mainline, so that I can see product, quantity, cost, software, power, mounting, communications, and test changes together.
33. As a systems engineer, I want exactly one active proposal, so that the demo avoids branch-management complexity.
34. As a systems engineer, I want incompatible relationships to block approval, so that known-invalid designs cannot become the mainline.
35. As a systems engineer, I want insufficient quantities to block approval, so that an approved design is buildable from inventory.
36. As a systems engineer, I want an over-budget design to block approval, so that the project budget remains a real constraint.
37. As a systems engineer, I want an unsatisfied mandatory requirement to block approval, so that an incomplete design cannot appear mission-ready.
38. As a systems engineer, I want conditional or unknown relationships paired with explicit verification work, so that uncertainty is managed rather than hidden.
39. As a systems engineer, I want approval to create a new immutable mainline version, so that the accepted before/after decision is preserved.
40. As a systems engineer, I want selected quantities to update with the approved design, so that the inventory and mainline stay consistent.
41. As a presenter, I want a guaranteed in-stock golden path, so that the core demonstration can always reach approval.
42. As a presenter, I want unrelated zero-quantity and incompatible examples in inventory, so that MEDUSA can demonstrate honest dead ends.
43. As a presenter, I want to reset all demo state, so that the complete story can be repeated reliably.
44. As a viewer, I want a clean Notion-inspired interface, so that a technical graph product feels approachable.
45. As a viewer, I want deterministic graph layouts, so that the demonstration remains stable and visually legible.
46. As a viewer, I want to pan, zoom, expand, collapse, and select graph nodes, so that I can explore without turning MEDUSA into a general graph editor.

## Implementation Decisions

### Product Scope

- MEDUSA remains a general defense prototyping concept; the MVP demonstrates one fictionalized SBInet-inspired perimeter-monitoring mission.
- The MVP is decision support only. It does not connect to operational sensors, command systems, procurement systems, or warehouse systems.
- All inventory data is curated and seeded.
- The inventory contains roughly 30 product models across six categories: sensors, compute, communications, power, structures, and support equipment.
- The seed includes credible quantities, specifications, relationships, deliberate evidence gaps, known incompatibilities, zero-availability products, and one guaranteed approval path.
- External purchasing is not modeled. MEDUSA may describe a missing capability but cannot recommend or simulate an external purchase.
- Inventory state contains only `owned`, `available`, and `selected for this design`.
- The application has one local user and no authentication.
- The delivery target is a local browser session started with `jac start`.

### Core Product Module

MEDUSA will be designed as one deep module. Its implementation owns:

- the graph model;
- seeded inventory behavior;
- project creation;
- deterministic candidate filtering;
- LLM-guided walker traversal;
- compatibility assessment;
- suggestions;
- cost and quantity calculation;
- downstream impact expansion;
- workflow construction;
- approval gating;
- mainline versioning; and
- demo reset.

The module exposes five public walker interfaces:

1. **LoadWorkspace**  
   Returns the inventory, quantities, current project, current design graph, workflow, proposal, and approval state.
2. **CreateProject**  
   Accepts the nine intake answers and generates the initial design through constrained LLM-guided traversal.
3. **ProposeChange**  
   Accepts a selected decision and a chosen in-stock resolution, then returns the revised graph and downstream effects.
4. **ApproveProposal**  
   evaluates the four hard gates and, when valid, creates the next immutable mainline version.
5. **ResetDemo**  
   Restores the seeded inventory, project, and proposal state.

These walker interfaces are the external seam shared by the Jac client and tests. Internal helpers are not exposed merely for testing.

### Jac and AI Decisions

- Every maintained application source module will be Jac.
- There will be no hand-authored JavaScript, TypeScript, Python, HTML, or CSS.
- The UI and styling will be expressed in Jac client declarations.
- Generated browser artifacts and runtime dependencies required by the Jac toolchain are permitted but are not maintained source.
- Jac's built-in graph persistence is the only data store.
- The LLM participates in graph traversal using `visit ... by llm()`.
- Before LLM-guided traversal, deterministic Jac rules remove unavailable products and known hard incompatibilities.
- The LLM selects only from the remaining successors and cannot override quantity or hard-compatibility rules.
- Traversal intent and selection limits must be explicit.
- The visited path and selection rationale are returned for display.
- Deterministic validation evaluates the final graph after AI traversal.
- The demo requires live LLM-guided generation; a failed or invalid generation must produce an explicit error and leave graph state unchanged.

### Compatibility Assessment

Every evaluated relationship returns one compact assessment containing:

- **Verdict:** compatible, conditional, incompatible, or unknown.
- **Issue domain:** hardware, software, power, communications, mechanical, or environmental.
- **Specific issue:** a precise explanation of the mismatch or uncertainty.
- **Evidence:** verified specification, internal test, prior design, or AI inference.
- **Source note:** a short human-readable origin for the evidence.
- **Suggested resolutions:** available hardware substitutions, software changes, interface adapters, enclosure changes, or required verification tests.
- **Downstream effects:** affected power, software, mounting, communications, cost, and workflow stages.

Verified engineering facts take precedence over inferred claims. Unknown information remains visible.

### Human-in-the-Loop Design

- AI generates the initial graph.
- The user reviews interpreted requirements before generation.
- The user does not draw arbitrary nodes or relationships.
- The user selects a decision and chooses a guided resolution, adjusts a requirement, adds a verification task, or adds a short rationale.
- MEDUSA regenerates only the affected design region and workflow content.
- The MVP supports one mainline and one active proposal.
- There are no concurrent proposals, partial merges, rebases, or conflict resolution.
- Approval replaces the mainline with a new immutable version and retains a before/after record.

### Approval Rules

MEDUSA blocks approval only when:

1. a required relationship is incompatible;
2. required inventory quantity is unavailable;
3. projected design cost exceeds the project budget; or
4. a mandatory mission requirement has no proposed solution.

A conditional or unknown relationship may be approved only when the workflow contains an explicit verification test for it.

### Workflow

Every project uses the same seven-stage skeleton:

1. Confirm requirements.
2. Select detection hardware.
3. Select compute and software.
4. Configure power.
5. Configure communications and alerts.
6. Assemble and deploy.
7. Validate against mission conditions.

MEDUSA changes the graph-linked products, issues, rationale, and verification work within these stages. It does not invent an arbitrary workflow structure.

### User Interface

The MVP has three screens:

1. **Inventory Graph**  
   The landing screen. It shows category and product nodes, specifications, quantities, relationships, availability, and compatibility details. It contains the Create New Project action.
2. **Mission Intake**  
   A guided, pre-filled nine-question flow with quick options, custom values, and a requirement-review step.
3. **Design Workspace**  
   The initial design graph, seven-stage workflow, selected inventory, compatibility assessment, guided suggestions, one proposal, comparison, approval state, version history, and reset action.

The visual language is clean, restrained, information-dense, and inspired by Notion. It favors neutral surfaces, clear typography, compact panels, subtle status colors, and progressive disclosure.

Graphs use deterministic SVG layouts rendered by Jac client declarations:

- Inventory uses an expandable left-to-right category tree.
- Design uses a fixed mission-to-subsystem-to-product flow.
- Supported interactions are pan, zoom, expand, collapse, and select.
- Dragging nodes, reconnecting edges, arbitrary node creation, and saved custom layouts are out of scope.

### Folder Architecture

The implementation begins with the smallest structure that preserves locality:

```text
medusa/
├── jac.toml
├── src/
│   ├── main.jac
│   ├── medusa.jac
│   ├── demo_data.jac
│   └── ui.jac
└── tests/
    └── medusa_tests.jac
```

- `main.jac` composes and starts the application.
- `medusa.jac` contains the deep product module and its five public walker interfaces.
- `demo_data.jac` contains the 30-product seed and pre-filled scenario.
- `ui.jac` contains the three screens and their Jac client declarations.
- `medusa_tests.jac` tests behavior only through the public walker interfaces.
- No repository, controller, DTO, use-case, adapter, or one-file-per-archetype layers are introduced.
- A file is split only when its size produces a demonstrated locality problem.

## Testing Decisions

Tests exercise observable behavior through the same five public walker interfaces used by the client. They must not assert on private helpers, traversal implementation details, or internal graph arrangement that callers cannot observe.

The MVP has eight required behavior groups:

1. **Seeded workspace**  
   Loading the workspace returns all seeded product models, categories, specifications, relationships, and correct quantities.
2. **Project generation**  
   The pre-filled intake produces a mission graph and the seven-stage workflow.
3. **Inventory constraint**  
   LLM-guided traversal cannot select a product whose available quantity is insufficient.
4. **Compatibility explanation**  
   Assessments contain verdict, issue domain, specific issue, evidence, source note, available resolutions, and downstream effects.
5. **Golden proposal**  
   Replacing the low-light camera with the in-stock weather-rated thermal camera updates all expected affected regions.
6. **Approval gates**  
   Separate cases prove that incompatibility, insufficient quantity, budget excess, and an unsatisfied mandatory requirement each block approval.
7. **Version creation**  
   A valid proposal becomes a new immutable mainline version and updates selected quantities.
8. **Reset behavior**  
   Reset restores the original inventory, project, proposal, and version state.

Jac's first-class test blocks and isolated graph contexts are the only testing mechanism required. UI styling does not receive pixel-level tests in the MVP.

## Acceptance Criteria

The core demo is accepted when a reviewer can:

1. Open MEDUSA directly into the seeded inventory graph.
2. Explore roughly 30 products across all six inventory categories.
3. Inspect product specifications and owned, available, and selected quantities.
4. Start a new project from the inventory screen.
5. Review the nine pre-filled mission answers.
6. Generate an initial graph through constrained `visit ... by llm()` traversal.
7. See which inventory nodes were visited and why they were selected.
8. See a seven-stage graph-linked implementation workflow.
9. Select the low-light camera decision and understand its unverified weather performance.
10. See hardware, software, power, communications, mechanical, environmental, and test resolutions where applicable.
11. Select only an in-stock weather-rated thermal-camera alternative.
12. See the downstream mount, enclosure, power, compute, communications, cost, software, and validation effects.
13. Compare the proposal with the mainline.
14. Demonstrate that each hard gate can block approval.
15. Approve the valid golden-path proposal.
16. See the new mainline version, updated selected quantities, updated workflow, and retained before/after record.
17. Reset MEDUSA to its initial demo state.

## Out of Scope

- Real SBInet data, Boeing proprietary information, or claims that MEDUSA would have prevented the historical program's failures.
- Live inventory imports, spreadsheets, ERP systems, warehouse systems, or external databases.
- External product catalogs, procurement recommendations, purchasing, replenishment, or simulated orders.
- Multiple organizations, multiple users, authentication, authorization, invitations, or role administration.
- Concurrent proposals, arbitrary branching, partial merges, rebasing, or conflict resolution.
- Free-form graph editing, drag-to-connect, node creation, or custom saved layouts.
- Operational sensor control, live alerts, radio transmission, SMS delivery, or command-and-control integration.
- CAD, PCB design, simulation, firmware development, or source-control integration.
- Multiple workflow templates or AI-generated workflow structures.
- External evidence-document ingestion or automated verification.
- Production security certification, export-control handling, classification workflows, or audit compliance.
- Docker, Kubernetes, cloud deployment, CI/CD, multi-process scaling, or air-gapped packaging.
- Performance targets for large enterprise graphs.
- Mobile or desktop-native applications.
- Any hand-authored application source outside Jac.

## Further Notes

### Demo Narrative

1. Open the inventory graph and briefly explore the product range and quantities.
2. Select Create New Project.
3. Show the pre-filled adverse-weather perimeter mission.
4. Generate the initial design and watch the walker path appear.
5. Open the low-light camera decision.
6. Show that night performance is acceptable but rain and wind performance is unverified.
7. Review the structured issue and in-stock resolutions.
8. Choose the weather-rated thermal camera.
9. Reveal the expanded mount, enclosure, power, compute, communications, software, cost, and test impacts.
10. Compare the proposal with the mainline.
11. Approve the valid proposal.
12. Show the improved graph, updated workflow, updated selected quantities, and immutable version record.

The visual reveal is that one understandable hardware concern becomes a complete, connected, and approvable engineering change.

### Success Measures

- A first-time viewer can explain MEDUSA's purpose after the demo.
- The complete scripted flow reaches approval without manual data repair.
- Every selectable alternative is available in sufficient quantity.
- Every AI-guided selection is traceable through a visible visited path and rationale.
- No known incompatible relationship reaches an approved mainline.
- The four hard approval gates are independently demonstrable.
- The full demo can be reset and repeated locally.
- The implementation stays within the agreed five public walker interfaces and minimal folder architecture.

### Primary-Source Basis

The design is grounded in current primary sources:

- [Jac language site](https://jaclang.org/)
- [Jac full-stack web documentation](https://docs.jaseci.org/build/fullstack-web/)
- [Jac byLLM reference, including LLM-guided `visit`](https://docs.jaseci.org/reference/plugins/byllm/)
- [Jac code-organization reference](https://docs.jaseci.org/reference/code-organization/)
- [Jac testing reference](https://docs.jaseci.org/reference/testing/)
- [Jac repository](https://github.com/jaseci-labs/jac)
- [This Is Jac full-stack showcase](https://github.com/jaseci-labs/this_is_jac)
- [GAO-09-1013T: SBInet testing problems](https://www.gao.gov/products/gao-09-1013t)
- [GAO-10-158: SBInet testing and performance limitations](https://www.gao.gov/products/gao-10-158)
- [GAO-11-448T: SBInet shortcomings and adverse-weather performance](https://www.gao.gov/products/gao-11-448t)

The Jac sources contain far more examples than MEDUSA needs, including compiler internals, native compilation, WebAssembly, microservices, authentication, and package interoperability. This PRD intentionally applies only the example families relevant to a small graph-native, AI-guided, persistent, full-stack Jac application. It does not claim that every example or test fixture in the Jac repository should become part of MEDUSA.

The companion [Jac platform-pattern research note](research/jac-platform-patterns.md) records the inspected example scope, the nine official repository example families found during research, and the platform conclusions used here.
