"""Power specialist: hard requirement — supply must cover the draw of every
component already picked (reads the coordinator's shared result set)."""
import from walkers.base_walker { all_components, evaluate, rank_rows, package_result }

walker PowerWalker {
    has constraints: dict = {};
    has prior_picks: dict = {};
    has result: dict = {};

    can select with entry {
        draw = 0.0;
        for cat in self.prior_picks.keys() {
            r = self.prior_picks[cat];
            if not r["conflict"] {
                draw += r["pick"]["comp"]["power_draw_w"];
            }
        }
        eligible: list[dict] = [];
        for comp in all_components("power") {
            if comp["supply_w"] >= draw {
                eligible.append(comp);
            }
        }
        if len(eligible) == 0 {
            self.result = package_result("power", [], f"no power source can supply the {draw}W the selected components draw");
        } else {
            rows: list[dict] = [];
            for comp in eligible {
                row = evaluate(comp, self.constraints, ["solar", "autonomous", "renewable", "silent"]);
                supply = comp["supply_w"];
                row["notes"].append(f"supplies {supply}W vs {draw}W system draw");
                rows.append(row);
            }
            self.result = package_result("power", rank_rows(rows), "");
        }
    }
}
