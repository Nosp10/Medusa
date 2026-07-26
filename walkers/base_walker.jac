"""Shared evaluation used by every specialized walker.

One scorer, two contexts: initial design and live revision both call
evaluate(), so every tradeoff is judged by the same yardstick and every
decision stays auditable.
"""
import from schema { env_rank }

def category_order() -> list[str] {
    return ["sensor", "processor", "comms", "power", "housing"];
}

def node_to_dict(c: any) -> dict {
    return {
        "name": c.name,
        "category": c.category,
        "cost_usd": c.cost_usd,
        "power_draw_w": c.power_draw_w,
        "env_rating": c.env_rating,
        "synergy_tags": c.synergy_tags,
        "supply_w": c.supply_w
    };
}

def all_components(category: str) -> list[dict] {
    out: list[dict] = [];
    for c in [root -->] {
        if hasattr(c, "category") and c.category == category {
            out.append(node_to_dict(c));
        }
    }
    return out;
}

def evaluate(comp: dict, constraints: dict, bonus_tags: list[str]) -> dict {
    notes: list[str] = [];
    mission_tags = constraints["mission_tags"];
    hits = [t for t in comp["synergy_tags"] if t in mission_tags];
    bonus_hits = [t for t in comp["synergy_tags"] if t in bonus_tags and t not in hits];
    score = 2.0 * len(hits) + 1.0 * len(bonus_hits);
    if hits {
        joined = ", ".join(hits);
        notes.append(f"matches mission needs: {joined}");
    }
    if bonus_hits {
        joined2 = ", ".join(bonus_hits);
        notes.append(f"category strengths: {joined2}");
    }
    budget = constraints["cost_budget_usd"];
    cost = comp["cost_usd"];
    cost_pen = round(5.0 * cost / budget, 2);
    score -= cost_pen;
    pct = int(100.0 * cost / budget);
    notes.append(f"cost ${int(cost)} = {pct}% of ${int(budget)} budget (-{cost_pen})");
    pbudget = constraints["power_budget_w"];
    draw = comp["power_draw_w"];
    if draw > 0.0 {
        power_pen = round(2.0 * draw / pbudget, 2);
        score -= power_pen;
        notes.append(f"draws {draw}W of {pbudget}W budget (-{power_pen})");
    }
    required = constraints["env_rating_min"];
    gap = env_rank(required) - env_rank(comp["env_rating"]);
    rating = comp["env_rating"];
    if gap > 0 {
        env_pen = 2.0 * gap;
        score -= env_pen;
        notes.append(f"{rating}-rated but mission needs {required} (-{env_pen})");
    } else {
        notes.append(f"{rating}-rated, meets {required} requirement");
    }
    return {"comp": comp, "score": round(score, 2), "notes": notes};
}

def by_score(row: dict) -> float {
    return row["score"];
}

def rank_rows(rows: list[dict]) -> list[dict] {
    return sorted(rows, key=by_score, reverse=True);
}

def package_result(category: str, ranked: list[dict], conflict_reason: str) -> dict {
    if conflict_reason != "" or len(ranked) == 0 {
        reason = conflict_reason if conflict_reason != "" else "no components available in category";
        return {"category": category, "pick": {}, "ranked": ranked, "conflict": True, "conflict_reason": reason};
    }
    return {"category": category, "pick": ranked[0], "ranked": ranked, "conflict": False, "conflict_reason": ""};
}
