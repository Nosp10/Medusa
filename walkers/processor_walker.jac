"""Processor specialist: upweights on-board analytics for sensor-driven missions."""
import from walkers.base_walker { all_components, evaluate, rank_rows, package_result }

walker ProcessorWalker {
    has constraints: dict = {};
    has prior_picks: dict = {};
    has result: dict = {};

    can select with entry {
        rows: list[dict] = [];
        for comp in all_components("processor") {
            rows.append(evaluate(comp, self.constraints, ["ai-inference", "video-analytics", "edge-compute"]));
        }
        self.result = package_result("processor", rank_rows(rows), "");
    }
}
