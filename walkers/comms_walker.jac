"""Comms specialist: range and reliability outweigh raw cost."""
import from walkers.base_walker { all_components, evaluate, rank_rows, package_result }

walker CommsWalker {
    has constraints: dict = {};
    has prior_picks: dict = {};
    has result: dict = {};

    can select with entry {
        rows: list[dict] = [];
        for comp in all_components("comms") {
            rows.append(evaluate(comp, self.constraints, ["long-range", "encrypted", "alerting"]));
        }
        self.result = package_result("comms", rank_rows(rows), "");
    }
}
