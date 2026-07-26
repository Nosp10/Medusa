"""Graph schema for Medusa — mission-to-architecture design agent."""

node Component {
    has name: str;
    has category: str;          # sensor | processor | comms | power | housing
    has cost_usd: float;
    has power_draw_w: float;
    has env_rating: str;        # indoor | outdoor | ruggedized | milspec
    has synergy_tags: list[str];
    has supply_w: float = 0.0;  # power sources only: continuous watts delivered
}

node Mission {
    has raw_text: str = "";
    has env_rating_min: str = "outdoor";
    has power_budget_w: float = 60.0;
    has cost_budget_usd: float = 10000.0;
    has mission_tags: list[str] = [];
}

edge CompatibleWith {}

def env_rank(rating: str) -> int {
    order = {"indoor": 0, "outdoor": 1, "ruggedized": 2, "milspec": 3};
    return order.get(rating, 0);
}
