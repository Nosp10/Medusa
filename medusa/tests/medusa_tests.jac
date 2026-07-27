"""Behavior tests for MEDUSA's five public walker interfaces."""

import from src.medusa {
    ApproveProposal,
    CreateProject,
    LoadWorkspace,
    ProposeChange,
    ResetDemo,
}


def demo_answers() -> list[str] {
    return [
        "Monitor a remote perimeter at night in bad weather and alert an operator when people or vehicles enter the protected area.",
        "Temporary fixed installation with field setup within four hours.",
        "Two-kilometer mixed-terrain perimeter, two vehicle gates, and one known line-of-sight gap.",
        "Detect people and vehicles; filter animals.",
        "Detect at 500 meters, alert within 10 seconds, and maintain a low false-alarm rate.",
        "Operate in darkness, rain, fog, dust, winds up to 50 km/h, and temperatures from −10°C to 45°C.",
        "Operate for at least 12 hours using batteries; solar assistance is available but not required.",
        "Support one remote operator, intermittent LTE, local radio fallback, and dashboard alerts.",
        "Remain within a $75,000 project budget and use only available inventory."
    ];
}


def vehicle_answers() -> list[str] {
    answers = demo_answers();
    answers[0] = "Monitor vehicle approaches from a vehicle-mounted prototype and alert a local operator.";
    answers[1] = "Vehicle-mounted installation with field setup within four hours.";
    answers[5] = "Operate in fair weather and normal road vibration.";
    answers[7] = "Support one local operator with LTE backhaul and dashboard alerts.";
    answers[8] = "Remain within a $100,000 project budget and use only available inventory.";
    return answers;
}


test "seeded workspace exposes the complete actionable inventory" {
    result = root spawn LoadWorkspace();

    assert len(result.reports) == 1;
    workspace = result.reports[0];
    assert len(workspace.categories) == 6;
    assert len(workspace.products) == 30;
    assert len(workspace.categories) == 6;
    assert all(key in [c.key for c in workspace.categories] for key in [
        "sensors", "compute", "communications", "power", "structures", "support"
    ]);

    thermal = [p for p in workspace.products if p.key == "flir-boson-640"];
    assert len(thermal) == 1;
    assert thermal[0].quantity.owned == 4;
    assert thermal[0].quantity.available == 3;
    assert thermal[0].quantity.selected == 0;

    unavailable = [p for p in workspace.products if p.key == "axis-q6315-le"];
    assert len(unavailable) == 1;
    assert unavailable[0].quantity.available == 0;
    assert unavailable[0].availability == "unavailable";
}


test "pre-filled intake generates an explainable seven-stage design" {
    result = root spawn CreateProject(answers=demo_answers());

    assert len(result.reports) == 1;
    workspace = result.reports[0];
    assert workspace.project_active;
    assert workspace.current_version == 1;
    assert len(workspace.requirements) == 9;
    assert len(workspace.design_nodes) >= 16;
    assert len(workspace.workflow) == 7;
    assert [stage.title for stage in workspace.workflow] == [
        "Confirm requirements",
        "Select detection hardware",
        "Select compute and software",
        "Configure power",
        "Configure communications and alerts",
        "Assemble and deploy",
        "Validate against mission conditions"
    ];
    assert "sony-snc-vb632d" in workspace.selected_product_keys;
    assert "echodyne-echoguard" in workspace.selected_product_keys;
    assert "axis-q6315-le" not in workspace.selected_product_keys;
    assert "hpe-edgeline-el8000" not in workspace.selected_product_keys;
    assert "iridium-go-exec" not in workspace.selected_product_keys;
    assert len(workspace.traversal) >= 10;
    assert all(step.rationale != "" for step in workspace.traversal);
    assert workspace.total_cost < workspace.budget;
    assert workspace.generation_mode in ["live-llm", "demo-llm"];
    assert workspace.error == "";
}


test "vehicle intake selects a distinct graph-backed scenario" {
    root spawn ResetDemo();
    result = root spawn CreateProject(answers=vehicle_answers());
    workspace = result.reports[0];

    assert workspace.project_active;
    assert workspace.budget == 100000.0;
    assert "flir-ranger-hdc" in workspace.selected_product_keys;
    assert "dell-poweredge-xr4000z" in workspace.selected_product_keys;
    assert "ecoflow-delta-pro" in workspace.selected_product_keys;
    assert "sony-snc-vb632d" not in workspace.selected_product_keys;
    assert "goal-zero-yeti-6000x" not in workspace.selected_product_keys;
    assert len(workspace.design_nodes) >= 13;
    assert workspace.error == "";
}


test "the low-light decision has a complete compatibility explanation" {
    result = root spawn CreateProject(answers=demo_answers());
    workspace = result.reports[0];

    assert len(workspace.assessments) == 1;
    assessment = workspace.assessments[0];
    assert assessment.decision_key == "sony-snc-vb632d";
    assert assessment.verdict == "conditional";
    assert assessment.issue_domain == "environmental";
    assert assessment.specific_issue != "";
    assert assessment.evidence == "AI inference";
    assert assessment.source_note != "";
    assert len(assessment.suggested_resolutions) >= 5;
    thermal = [
        resolution
        for resolution in assessment.suggested_resolutions
        if resolution.product_key == "flir-boson-640"
    ];
    assert len(thermal) == 1;
    assert thermal[0].available;
    assert all(effect.summary != "" for effect in assessment.downstream_effects);
    assert [
        effect.domain for effect in assessment.downstream_effects
    ] == [
        "mount",
        "enclosure",
        "power",
        "compute",
        "communications",
        "cost",
        "software",
        "validation"
    ];
}


test "the golden thermal proposal expands every affected design region" {
    root spawn CreateProject(answers=demo_answers());
    result = root spawn ProposeChange(
        decision_key="sony-snc-vb632d",
        resolution_key="thermal-golden"
    );
    workspace = result.reports[0];
    proposal = workspace.proposal;

    assert proposal is not None;
    assert "sony-snc-vb632d" in workspace.selected_product_keys;
    assert "flir-boson-640" not in workspace.selected_product_keys;
    if proposal is not None {
        assert proposal.active;
        assert proposal.decision_key == "sony-snc-vb632d";
        assert proposal.resolution_key == "thermal-golden";
        assert len(proposal.removed_product_keys) == 2;
        assert all(key in proposal.removed_product_keys for key in ["sony-snc-vb632d", "pelco-es6230"]);
        assert len(proposal.added_product_keys) == 4;
        assert all(key in proposal.added_product_keys for key in ["flir-boson-640", "flir-ptu-d300e", "videotec-nxm36", "victron-smartsolar-150-35"]);
        assert proposal.projected_cost == 51168.0;
        assert proposal.cost_delta == 9420.0;
        assert "flir-boson-640" in proposal.proposed_product_keys;
        assert "flir-ptu-d300e" in proposal.proposed_product_keys;
        assert "videotec-nxm36" in proposal.proposed_product_keys;
        assert "victron-smartsolar-150-35" in proposal.proposed_product_keys;
        assert len(proposal.design_nodes) > len(workspace.design_nodes);
        assert len(proposal.workflow[1].linked_products) == 2;
        assert all(key in proposal.workflow[1].linked_products for key in ["flir-boson-640", "echodyne-echoguard"]);
        assert "thermal" in proposal.workflow[2].detail.lower();
        assert "victron-smartsolar-150-35" in proposal.workflow[3].linked_products;
        assert "thermal" in proposal.workflow[4].detail.lower();
        assert "flir-ptu-d300e" in proposal.workflow[5].linked_products;
        assert "videotec-nxm36" in proposal.workflow[5].linked_products;
        assert any("thermal" in task.lower() for task in proposal.workflow[6].verification);
    }
}


test "approval blocks an incompatible required relationship" {
    root spawn CreateProject(answers=demo_answers());
    root spawn ProposeChange(
        decision_key="sony-snc-vb632d",
        resolution_key="thermal-golden",
        scenario="incompatible"
    );
    workspace = (root spawn ApproveProposal()).reports[0];

    assert not workspace.approval_ready;
    assert workspace.current_version == 1;
    assert [
        gate.key for gate in workspace.gates if gate.status == "blocked"
    ] == ["compatibility"];
    assert "incompatible" in workspace.error.lower();
}


test "approval blocks insufficient inventory quantity" {
    root spawn CreateProject(answers=demo_answers());
    root spawn ProposeChange(
        decision_key="sony-snc-vb632d",
        resolution_key="thermal-golden",
        scenario="quantity"
    );
    workspace = (root spawn ApproveProposal()).reports[0];

    assert not workspace.approval_ready;
    assert workspace.current_version == 1;
    assert [
        gate.key for gate in workspace.gates if gate.status == "blocked"
    ] == ["quantity"];
    assert "quantity" in workspace.error.lower();
}


test "approval blocks a projected budget excess" {
    root spawn CreateProject(answers=demo_answers());
    root spawn ProposeChange(
        decision_key="sony-snc-vb632d",
        resolution_key="thermal-golden",
        scenario="budget"
    );
    workspace = (root spawn ApproveProposal()).reports[0];

    assert not workspace.approval_ready;
    assert workspace.current_version == 1;
    assert workspace.proposal is not None;
    if workspace.proposal is not None {
        assert workspace.proposal.projected_cost > workspace.budget;
    }
    assert [
        gate.key for gate in workspace.gates if gate.status == "blocked"
    ] == ["budget"];
    assert "budget" in workspace.error.lower();
}


test "approval blocks an unsatisfied mandatory requirement" {
    root spawn CreateProject(answers=demo_answers());
    root spawn ProposeChange(
        decision_key="sony-snc-vb632d",
        resolution_key="thermal-golden",
        scenario="requirement"
    );
    workspace = (root spawn ApproveProposal()).reports[0];

    assert not workspace.approval_ready;
    assert workspace.current_version == 1;
    assert [
        gate.key for gate in workspace.gates if gate.status == "blocked"
    ] == ["requirements"];
    assert "mandatory requirement" in workspace.error.lower();
}


test "the generation trace persists across proposals and approved versions" {
    generated = (root spawn CreateProject(answers=demo_answers())).reports[0];
    original_trace = [
        step.product_key for step in generated.traversal
    ];

    proposed = (root spawn ProposeChange(
        decision_key="sony-snc-vb632d",
        resolution_key="thermal-golden"
    )).reports[0];
    approved = (root spawn ApproveProposal()).reports[0];
    reloaded = (root spawn LoadWorkspace()).reports[0];

    assert len(original_trace) == 10;
    assert [step.product_key for step in proposed.traversal] == original_trace;
    assert [step.product_key for step in approved.traversal] == original_trace;
    assert [step.product_key for step in reloaded.traversal] == original_trace;
    assert all(step.rationale != "" for step in reloaded.traversal);
}


test "valid approval creates an immutable version and updates quantities" {
    root spawn CreateProject(answers=demo_answers());
    root spawn ProposeChange(
        decision_key="sony-snc-vb632d",
        resolution_key="thermal-golden"
    );
    approved = (root spawn ApproveProposal()).reports[0];
    workspace = (root spawn LoadWorkspace()).reports[0];

    assert approved.current_version == 2;
    assert workspace.current_version == 2;
    assert len(workspace.versions) == 2;
    assert workspace.versions[0].number == 1;
    assert workspace.versions[0].status == "historical";
    assert "sony-snc-vb632d" in workspace.versions[0].product_keys;
    assert "flir-boson-640" not in workspace.versions[0].product_keys;
    assert workspace.versions[1].number == 2;
    assert workspace.versions[1].status == "active";
    assert "sony-snc-vb632d" not in workspace.versions[1].product_keys;
    assert "flir-boson-640" in workspace.versions[1].product_keys;
    assert len(workspace.versions[1].added_product_keys) == 4;
    assert all(key in workspace.versions[1].added_product_keys for key in [
        "flir-boson-640", "flir-ptu-d300e", "videotec-nxm36", "victron-smartsolar-150-35"
    ]);
    assert len(workspace.versions[1].removed_product_keys) == 2;
    assert all(key in workspace.versions[1].removed_product_keys for key in [
        "sony-snc-vb632d", "pelco-es6230"
    ]);
    assert workspace.proposal is None;
    assert workspace.total_cost == 51168.0;
    assert "thermal" in workspace.workflow[2].detail.lower();

    selected_by_key = {
        product.key: product.quantity.selected
        for product in workspace.products
    };
    assert selected_by_key["sony-snc-vb632d"] == 0;
    assert selected_by_key["pelco-es6230"] == 0;
    assert selected_by_key["flir-boson-640"] == 1;
    assert selected_by_key["flir-ptu-d300e"] == 1;
    assert selected_by_key["videotec-nxm36"] == 1;
    assert selected_by_key["victron-smartsolar-150-35"] == 1;
}


test "reset restores the untouched seeded workspace" {
    root spawn CreateProject(answers=demo_answers());
    root spawn ProposeChange(
        decision_key="sony-snc-vb632d",
        resolution_key="thermal-golden"
    );
    root spawn ApproveProposal();
    reset = (root spawn ResetDemo()).reports[0];
    workspace = (root spawn LoadWorkspace()).reports[0];

    assert not reset.project_active;
    assert not workspace.project_active;
    assert workspace.current_version == 0;
    assert workspace.proposal is None;
    assert workspace.gates == [];
    assert workspace.versions == [];
    assert workspace.selected_product_keys == [];
    assert workspace.total_cost == 0.0;
    assert len(workspace.categories) == 6;
    assert len(workspace.products) == 30;
    assert all(product.quantity.selected == 0 for product in workspace.products);
    thermal = [
        product
        for product in workspace.products
        if product.key == "flir-boson-640"
    ][0];
    assert thermal.quantity.owned == 4;
    assert thermal.quantity.available == 3;
}
