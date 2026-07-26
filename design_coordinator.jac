"""Coordinator: runs the five specialized walkers in two waves and assembles
the architecture.

Wave 1 (sensor / processor / comms) walkers are fully independent — no shared
state, no ordering dependency — so they are architecturally parallel and can be
threaded later without touching walker logic. Wave 2 (power / housing) reads
the wave-1 picks for power sizing.
"""
import from schema { Mission }
import from walkers.base_walker { category_order }
import from walkers.sensor_walker { SensorWalker }
import from walkers.processor_walker { ProcessorWalker }
import from walkers.comms_walker { CommsWalker }
import from walkers.power_walker { PowerWalker }
import from walkers.housing_walker { HousingWalker }
import from llm_utils { parse_requirements, justify_choice }
import from inventory { render_inventory }

def announce(result: dict, constraints: dict) -> None {
    cat = result["category"];
    if result["conflict"] {
        reason = result["conflict_reason"];
        print(f"  [{cat}] CONFLICT — {reason}");
    } else {
        line = justify_choice(result["pick"], cat, constraints);
        print(f"  [{cat}] {line}");
    }
}

def total_cost(results: dict) -> float {
    tot = 0.0;
    for cat in results.keys() {
        r = results[cat];
        if not r["conflict"] {
            tot += r["pick"]["comp"]["cost_usd"];
        }
    }
    return tot;
}

def current_draw(results: dict) -> float {
    d = 0.0;
    for cat in ["sensor", "processor", "comms"] {
        if cat in results and not results[cat]["conflict"] {
            d += results[cat]["pick"]["comp"]["power_draw_w"];
        }
    }
    return d;
}

# Greedy budget fit: while over budget, take the swap with the best
# savings-per-score-lost ratio. Same evaluate() scores, so every swap is
# auditable against the ranked lists.
def fit_budget(results: dict, constraints: dict) -> dict {
    budget = constraints["cost_budget_usd"];
    swapmeta: dict = {};
    conflict = "";
    guard = 0;
    while total_cost(results) > budget and guard < 12 {
        guard += 1;
        before = total_cost(results);
        best_cat = "";
        best_alt: dict = {};
        best_ratio = -1.0;
        for cat in category_order() {
            if cat not in results or results[cat]["conflict"] {
                continue;
            }
            cur = results[cat]["pick"];
            for alt in results[cat]["ranked"] {
                saving = cur["comp"]["cost_usd"] - alt["comp"]["cost_usd"];
                if saving <= 0.0 {
                    continue;
                }
                if cat == "power" and alt["comp"]["supply_w"] < current_draw(results) {
                    continue;
                }
                loss = cur["score"] - alt["score"];
                denom = loss if loss > 0.0 else 0.01;
                ratio = saving / denom;
                if ratio > best_ratio {
                    best_ratio = ratio;
                    best_cat = cat;
                    best_alt = alt;
                }
            }
        }
        if best_cat == "" {
            conflict = f"total ${int(before)} exceeds ${int(budget)} budget and no cheaper alternatives remain — genuine requirement conflict";
            break;
        }
        old = results[best_cat]["pick"];
        results[best_cat]["pick"] = best_alt;
        if best_cat in swapmeta {
            swapmeta[best_cat]["new"] = best_alt["comp"];
        } else {
            swapmeta[best_cat] = {"old": old["comp"], "new": best_alt["comp"], "before": before};
        }
    }
    swaps: dict = {};
    for cat in swapmeta.keys() {
        meta = swapmeta[cat];
        oldname = meta["old"]["name"];
        newname = meta["new"]["name"];
        oldcost = int(meta["old"]["cost_usd"]);
        newcost = int(meta["new"]["cost_usd"]);
        was = int(meta["before"]);
        swaps[cat] = f"total ${was} exceeded the ${int(budget)} budget: swapped {oldname} (${oldcost}) for {newname} (${newcost})";
    }
    return {"swaps": swaps, "conflict": conflict};
}

def sync_mission(constraints: dict) -> None {
    for n in [root -->] {
        if hasattr(n, "mission_tags") {
            n.raw_text = constraints["raw"];
            n.env_rating_min = constraints["env_rating_min"];
            n.power_budget_w = constraints["power_budget_w"];
            n.cost_budget_usd = constraints["cost_budget_usd"];
            n.mission_tags = constraints["mission_tags"];
            return;
        }
    }
    root ++> Mission(
        raw_text=constraints["raw"],
        env_rating_min=constraints["env_rating_min"],
        power_budget_w=constraints["power_budget_w"],
        cost_budget_usd=constraints["cost_budget_usd"],
        mission_tags=constraints["mission_tags"]
    );
}

def select_all(constraints: dict, verbose: bool) -> dict {
    sync_mission(constraints);
    results: dict = {};
    # Wave 1 — independent specialists, architecturally parallel
    wave1 = [
        SensorWalker(constraints=constraints),
        ProcessorWalker(constraints=constraints),
        CommsWalker(constraints=constraints)
    ];
    for w in wave1 {
        root spawn w;
        results[w.result["category"]] = w.result;
        if verbose {
            announce(w.result, constraints);
        }
    }
    # Wave 2 — power sizing and enclosure depend on wave-1 picks
    pw = PowerWalker(constraints=constraints, prior_picks=results);
    root spawn pw;
    results["power"] = pw.result;
    if verbose {
        announce(pw.result, constraints);
    }
    hw = HousingWalker(constraints=constraints, prior_picks=results);
    root spawn hw;
    results["housing"] = hw.result;
    if verbose {
        announce(hw.result, constraints);
    }
    fitrep = fit_budget(results, constraints);
    if verbose {
        for cat in fitrep["swaps"].keys() {
            note = fitrep["swaps"][cat];
            print(f"  [budget fit] {cat}: {note}");
        }
        if fitrep["conflict"] != "" {
            c = fitrep["conflict"];
            print(f"  [budget fit] CONFLICT — {c}");
        }
    }
    return {"results": results, "budget_report": fitrep};
}

def run_design(mission_text: str) -> dict {
    constraints = parse_requirements(mission_text);
    print(f"\nMISSION: {mission_text}");
    tags = ", ".join(constraints["mission_tags"]);
    env = constraints["env_rating_min"];
    cb = int(constraints["cost_budget_usd"]);
    pb = int(constraints["power_budget_w"]);
    print(f"Parsed requirements: tags [{tags}], min env {env}, budget ${cb}, power {pb}W");
    print("\nPROPOSED ARCHITECTURE:");
    outcome = select_all(constraints, True);
    results = outcome["results"];
    tot = int(total_cost(results));
    print(f"\n  Architecture total: ${tot} (budget ${cb})");
    print(render_inventory(results, constraints));
    return {"constraints": constraints, "results": results, "budget_report": outcome["budget_report"]};
}
