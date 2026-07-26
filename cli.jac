"""Interactive demo loop.

    jac run cli.jac

Type a mission in plain English, watch the walkers pick an architecture,
then inject requirement changes and watch it revise live.
"""
import from graph_build { build_graph }
import from design_coordinator { run_design }
import from revise_walker { parse_delta, revise }

with entry {
    build_graph("library.json");
    print("");
    print("=== MEDUSA — mission-to-architecture design agent ===");
    mission = input("Mission need > ");
    if mission.strip() == "" {
        mission = "Monitor a perimeter at night in bad weather and alert operators to movement.";
        print(f"(using default: {mission})");
    }
    session = run_design(mission);
    while True {
        print("");
        print("Change grammar: budget_cut <pct> | add_env_spec <indoor|outdoor|ruggedized|milspec> | mission_tags <a,b,c>   (blank to finish)");
        change = input("Change > ");
        if change.strip() == "" {
            break;
        }
        delta = parse_delta(change);
        if len(delta) == 0 {
            print("Unrecognized change — use the grammar above.");
            continue;
        }
        session = revise(session, delta);
    }
    print("Done.");
}
