# MEDUSA

MEDUSA is a graph-native, human-in-the-loop workspace for turning available
inventory into an explainable prototype design. The maintained application
source is entirely Jac.

## Run the demo

From this directory:

```sh
MEDUSA_LLM_MODE=demo JAC_DISABLED_PLUGINS='jac-scale:*' ../.venv/bin/jac start --dev
```

Open [http://localhost:8000](http://localhost:8000).

The default `demo` mode is deterministic and requires no API credentials. To
exercise the real byLLM selection boundary, configure a supported model and
start with `MEDUSA_LLM_MODE=live`.

## Verify

```sh
MEDUSA_LLM_MODE=demo JAC_DISABLED_PLUGINS='jac-scale:*,jac-client:*' \
  ../.venv/bin/jac test tests/medusa_tests.jac

MEDUSA_LLM_MODE=demo JAC_DISABLED_PLUGINS='jac-scale:*' \
  ../.venv/bin/jac build
```

## Code map

- `src/demo_data.jac` — the 30 concrete inventory products.
- `src/medusa.jac` — graph model, five public walkers, proposal gates, and
  immutable versions.
- `src/ui.cl.jac` — the three-screen Jac client and its visual components.
- `tests/medusa_tests.jac` — deterministic acceptance and regression tests.
- `main.jac` — the root-scoped launch shim used by Jac's client toolchain.

## Demo path

1. Explore or collapse inventory categories and inspect a product.
2. Create a project and complete the four mission-intake steps.
3. Generate the v1 design, inspect its graph, workflow, trace, and versions.
4. Open the Sony low-light compatibility decision and use the thermal
   resolution.
5. Use the gate lab to demonstrate each blocked case independently.
6. Restore **All pass**, approve the proposal, and inspect immutable v1/v2
   history.
7. Use **Reset demo** to return inventory quantities and project state to the
   starting point.
