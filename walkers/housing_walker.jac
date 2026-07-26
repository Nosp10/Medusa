"""Housing specialist: hard filter — enclosure rating must meet or exceed the
mission's minimum environmental spec."""
import from schema { env_rank }
import from walkers.base_walker { all_components, evaluate, rank_rows, package_result }

walker HousingWalker {
    has constraints: dict = {};
    has prior_picks: dict = {};
    has result: dict = {};

    can select with entry {
        required = self.constraints["env_rating_min"];
        eligible: list[dict] = [];
        for comp in all_components("housing") {
            if env_rank(comp["env_rating"]) >= env_rank(required) {
                eligible.append(comp);
            }
        }
        if len(eligible) == 0 {
            self.result = package_result("housing", [], f"no housing in the library meets the required {required} rating");
        } else {
            rows: list[dict] = [];
            for comp in eligible {
                rows.append(evaluate(comp, self.constraints, ["sealed", "weatherproof", "emi-shielded"]));
            }
            self.result = package_result("housing", rank_rows(rows), "");
        }
    }
}
