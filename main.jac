"""Scripted end-to-end demo — the acceptance script, runnable non-interactively.

    jac run main.jac
"""
import from graph_build { build_graph }
import from design_coordinator { run_design }
import from revise_walker { revise }

with entry {
    build_graph("library.json");

    session = run_design("Monitor a perimeter at night in bad weather and alert operators to movement.");

    # Delta 1: the budget gets cut 30% mid-design.
    session = revise(session, {"kind": "budget_cut", "pct": 30.0});

    # Delta 2: a milspec environmental requirement is added.
    session = revise(session, {"kind": "add_env_spec", "rating": "milspec"});

    # Delta 3: an extreme cut that no component set can satisfy — genuine conflict.
    session = revise(session, {"kind": "budget_cut", "pct": 80.0});
}
