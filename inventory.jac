"""Inventory report: every component considered per category — picked or not,
its score, and why the runners-up lost. This is the deliverable a program team
reviews, not a debug dump."""
import from llm_utils { explain_rejection }
import from walkers.base_walker { category_order }

def render_inventory(results: dict, constraints: dict) -> str {
    lines: list[str] = [];
    lines.append("");
    lines.append("=== INVENTORY REPORT — components considered ===");
    for cat in category_order() {
        if cat not in results {
            continue;
        }
        r = results[cat];
        lines.append("");
        header = cat.upper();
        lines.append(f"[{header}]");
        if r["conflict"] {
            reason = r["conflict_reason"];
            lines.append(f"  CONFLICT: {reason}");
        }
        lines.append("| Component | Cost | Power | Env | Score | Picked | Note |");
        lines.append("|---|---|---|---|---|---|---|");
        picked_name = "";
        if not r["conflict"] {
            picked_name = r["pick"]["comp"]["name"];
        }
        idx = 0;
        for row in r["ranked"] {
            comp = row["comp"];
            name = comp["name"];
            cost = int(comp["cost_usd"]);
            watts = comp["power_draw_w"];
            env = comp["env_rating"];
            score = row["score"];
            mark = "";
            note = "";
            if name == picked_name {
                mark = "YES";
            } elif idx < 4 and picked_name != "" {
                note = explain_rejection(row, results[cat]["pick"], constraints);
            }
            lines.append(f"| {name} | ${cost} | {watts}W | {env} | {score} | {mark} | {note} |");
            idx += 1;
        }
    }
    return "\n".join(lines);
}
