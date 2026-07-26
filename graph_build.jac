"""Loads library.json into the graph and wires compatibility edges.

Rebuilds from scratch on every run so the persisted .jac session never
accumulates stale nodes.
"""
import json;
import from schema { Component, CompatibleWith }

def build_graph(lib_path: str) -> int {
    for old in [root -->] {
        del old;
    }
    f = open(lib_path, "r");
    data = json.load(f);
    f.close();
    comps: list = [];
    for item in data {
        c = Component(
            name=item["name"],
            category=item["category"],
            cost_usd=float(item["cost_usd"]),
            power_draw_w=float(item["power_draw_w"]),
            env_rating=item["env_rating"],
            synergy_tags=item["synergy_tags"],
            supply_w=float(item.get("supply_w", 0.0))
        );
        root ++> c;
        comps.append(c);
    }
    edges = 0;
    for i in range(len(comps)) {
        for j in range(i + 1, len(comps)) {
            a = comps[i];
            b = comps[j];
            if a.category == b.category {
                continue;
            }
            if (a.power_draw_w + b.power_draw_w) > 80.0 {
                continue;
            }
            if "indoor-only" in a.synergy_tags and b.env_rating != "indoor" {
                continue;
            }
            if "indoor-only" in b.synergy_tags and a.env_rating != "indoor" {
                continue;
            }
            a +>:CompatibleWith:+> b;
            edges += 1;
        }
    }
    print(f"[graph] {len(comps)} components loaded, {edges} compatibility edges built");
    return len(comps);
}
