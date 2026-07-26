"""Sensor specialist: upweights detection and environment-robustness tags."""
import from walkers.base_walker { all_components, evaluate, rank_rows, package_result }

walker SensorWalker {
    has constraints: dict = {};
    has prior_picks: dict = {};
    has result: dict = {};

    can select with entry {
        rows: list[dict] = [];
        for comp in all_components("sensor") {
            rows.append(evaluate(comp, self.constraints, ["thermal", "night-vision", "all-weather", "motion-detection"]));
        }
        self.result = package_result("sensor", rank_rows(rows), "");
    }
}
