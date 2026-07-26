"""The LLM seam: the three natural-language functions.

These run on deterministic fallbacks so the demo always works offline.
To go live: `pip install byllm`, set an API key, and replace each body
with a `by llm()` declaration — same signatures, same call sites.
"""
import re;

def parse_requirements(text: str) -> dict {
    t = text.lower();
    tags: list[str] = [];
    keyword_map = [
        ["night", "night-vision"], ["night", "low-light"], ["dark", "night-vision"],
        ["weather", "all-weather"], ["rain", "all-weather"], ["storm", "all-weather"],
        ["snow", "all-weather"], ["fog", "all-weather"], ["maritime", "all-weather"],
        ["perimeter", "long-range"], ["border", "long-range"],
        ["movement", "motion-detection"], ["motion", "motion-detection"], ["intrusion", "motion-detection"],
        ["alert", "alerting"], ["notify", "alerting"], ["operator", "alerting"],
        ["identify", "video-analytics"], ["classify", "video-analytics"], ["video", "video-analytics"],
        ["covert", "silent"], ["quiet", "silent"], ["silent", "silent"],
        ["encrypt", "encrypted"], ["secure", "encrypted"],
        ["remote", "autonomous"], ["unattended", "autonomous"],
        ["vehicle", "vehicle-power"], ["satellite", "satcom"]
    ];
    for pair in keyword_map {
        if pair[0] in t and pair[1] not in tags {
            tags.append(pair[1]);
        }
    }
    env = "outdoor";
    for kw in ["weather", "rain", "storm", "snow", "fog", "maritime", "marine"] {
        if kw in t {
            env = "ruggedized";
        }
    }
    for kw in ["desert", "arctic", "extreme", "combat", "milspec", "mil-spec"] {
        if kw in t {
            env = "milspec";
        }
    }
    if "indoor" in t {
        env = "indoor";
    }
    budget = 10000.0;
    m = re.search("\\$\\s*([0-9][0-9,]*)", t);
    if m {
        budget = float(m.group(1).replace(",", ""));
    }
    power = 60.0;
    m2 = re.search("([0-9]+)\\s*w(att)?", t);
    if m2 {
        power = float(m2.group(1));
    }
    return {
        "raw": text,
        "mission_tags": tags,
        "env_rating_min": env,
        "power_budget_w": power,
        "cost_budget_usd": budget
    };
}

def justify_choice(pick_row: dict, category: str, constraints: dict) -> str {
    comp = pick_row["comp"];
    name = comp["name"];
    score = pick_row["score"];
    reasons = "; ".join(pick_row["notes"][:3]);
    return f"{name} (score {score}) — {reasons}";
}

def explain_rejection(row: dict, winner_row: dict, constraints: dict) -> str {
    penalties = [n for n in row["notes"] if "(-" in n];
    reason = penalties[-1] if len(penalties) > 0 else "weaker mission fit";
    s = row["score"];
    ws = winner_row["score"];
    wname = winner_row["comp"]["name"];
    return f"scored {s} vs {ws} for {wname}; {reason}";
}
