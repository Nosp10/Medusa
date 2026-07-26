"""Live revision: apply a requirement delta, re-run every walker with the same
shared scorer, and fitrep KEEP / SWAP / CONFLICT per prior pick."""
import copy;
import from design_coordinator { select_all, total_cost }
import from walkers.base_walker { category_order }

def parse_delta(text: str) -> dict {
    parts = text.strip().split();
    if len(parts) == 0 {
        return {};
    }
    cmd = parts[0].lower();
    if cmd == "budget_cut" and len(parts) > 1 {
        return {"kind": "budget_cut", "pct": float(parts[1])};
    }
    if cmd == "add_env_spec" and len(parts) > 1 {
        return {"kind": "add_env_spec", "rating": parts[1].lower()};
    }
    if cmd == "mission_tags" and len(parts) > 1 {
        return {"kind": "mission_tags", "tags": parts[1].split(",")};
    }
    return {};
}

def describe_delta(delta: dict) -> str {
    kind = delta["kind"];
    if kind == "budget_cut" {
        pct = delta["pct"];
        return f"budget cut by {pct}%";
    }
    if kind == "add_env_spec" {
        rating = delta["rating"];
        return f"new environmental spec: {rating} minimum";
    }
    tags = ", ".join(delta["tags"]);
    return f"mission profile changed to [{tags}]";
}

def apply_delta(constraints: dict, delta: dict) -> dict {
    c = copy.deepcopy(constraints);
    kind = delta["kind"];
    if kind == "budget_cut" {
        c["cost_budget_usd"] = round(c["cost_budget_usd"] * (1.0 - delta["pct"] / 100.0), 2);
    } elif kind == "add_env_spec" {
        c["env_rating_min"] = delta["rating"];
    } elif kind == "mission_tags" {
        c["mission_tags"] = delta["tags"];
    }
    return c;
}

def revise(session: dict, delta: dict) -> dict {
    old_results = session["results"];
    new_constraints = apply_delta(session["constraints"], delta);
    print("");
    print(f"=== REQUIREMENT CHANGE: {describe_delta(delta)} ===");
    outcome = select_all(new_constraints, False);
    new_results = outcome["results"];
    fitrep = outcome["budget_report"];
    for cat in category_order() {
        old_r = old_results.get(cat, {});
        new_r = new_results.get(cat, {});
        if len(new_r) == 0 {
            continue;
        }
        if new_r["conflict"] {
            reason = new_r["conflict_reason"];
            print(f"  [{cat}] CONFLICT — {reason}");
            continue;
        }
        new_pick = new_r["pick"];
        new_name = new_pick["comp"]["name"];
        old_conflict = len(old_r) == 0 or old_r["conflict"];
        if old_conflict {
            print(f"  [{cat}] RESOLVED — now {new_name}");
            continue;
        }
        old_name = old_r["pick"]["comp"]["name"];
        if old_name == new_name {
            s = new_pick["score"];
            print(f"  [{cat}] KEEP {old_name} — still the best fit under the new constraints (score {s})");
            continue;
        }
        # Stability rule: keep the prior pick if it re-scores within 10% of the
        # new best and is no pricier (so reverting can never break the budget).
        old_row: dict = {};
        for row in new_r["ranked"] {
            if row["comp"]["name"] == old_name {
                old_row = row;
            }
        }
        if len(old_row) > 0
            and old_row["score"] >= new_pick["score"] * 0.9
            and old_row["comp"]["cost_usd"] <= new_pick["comp"]["cost_usd"]
            and cat not in fitrep["swaps"] {
            new_r["pick"] = old_row;
            os = old_row["score"];
            ns = new_pick["score"];
            print(f"  [{cat}] KEEP {old_name} — re-scores {os} vs {ns} for {new_name}, within the 10% switching threshold");
            continue;
        }
        why = fitrep["swaps"].get(cat, "");
        if old_name not in why {
            why = "";
        }
        if why == "" {
            if len(old_row) == 0 {
                why = f"{old_name} no longer meets a hard constraint under the new requirements";
            } elif cat in fitrep["swaps"] {
                nb0 = int(new_constraints["cost_budget_usd"]);
                oc0 = int(old_row["comp"]["cost_usd"]);
                nc0 = int(new_pick["comp"]["cost_usd"]);
                why = f"the ${nb0} budget can no longer accommodate {old_name} (${oc0}); {new_name} (${nc0}) is the best affordable option";
            } else {
                os2 = old_row["score"];
                ns2 = new_pick["score"];
                why = f"re-scores {os2} vs {ns2} under the new constraints";
            }
        }
        print(f"  [{cat}] SWAP {old_name} -> {new_name} — {why}");
    }
    if fitrep["conflict"] != "" {
        c = fitrep["conflict"];
        print(f"  [budget] CONFLICT — {c}");
    }
    tot = int(total_cost(new_results));
    nb = int(new_constraints["cost_budget_usd"]);
    print(f"  Revised architecture total: ${tot} (budget ${nb})");
    return {"constraints": new_constraints, "results": new_results, "budget_report": fitrep};
}
