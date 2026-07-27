"""MEDUSA's single deep product module.

The five walkers in this file are the external seam shared by the client and
tests. Graph shape, calculations, compatibility rules, and versioning remain
inside this module.
"""

import os;
import from byllm.lib { MockLLM }
import from src.demo_data {
    CategorySeed,
    ProductRelationshipSeed,
    ProductSeed,
    category_seeds,
    product_relationship_seeds,
    product_seeds,
}


node InventoryCategory {
    has key: str,
        name: str,
        description: str;
}


node Product {
    has key: str,
        name: str,
        category: str,
        summary: str,
        unit_cost: float,
        owned: int,
        available: int,
        selected: int,
        specs: list[str],
        relationships: list[str],
        scenario_tags: list[str] = [];
}


sem Product = "A concrete inventory product that could satisfy part of a field mission.";
sem Product.key = "Stable product key.";
sem Product.name = "Specific model name.";
sem Product.category = "Engineering subsystem category.";
sem Product.summary = "Mission-relevant purpose and important trade-off.";
sem Product.available = "Quantity available before any new selection.";
sem Product.specs = "Verified and curated product specifications.";


edge Contains: InventoryCategory --> Product {}

edge ProductRelationship: Product --> Product {
    has kind: str,
        note: str;
}


node Mission {
    has title: str;
}


node DesignSubsystem {
    has key: str,
        label: str;
}


node DesignDecision {
    has status: str = "compatible";
}


node ProposalGraph {
    has decision_key: str,
        resolution_key: str,
        total_cost: float,
        scenario: str = "valid";
}


node VersionSelection {}


edge OwnsMission: ProjectState --> Mission {}
edge HasSubsystem: Mission --> DesignSubsystem {}
edge HasDecision: DesignSubsystem --> DesignDecision {}
edge SelectsProduct: DesignDecision --> Product {}
edge OwnsProposal: ProjectState --> ProposalGraph {}
edge ProposesSubsystem: ProposalGraph --> DesignSubsystem {}
edge VersionContains: VersionRecord --> VersionSelection {}
edge SnapshotSelects: VersionSelection --> Product {}
edge Supersedes: VersionRecord --> VersionRecord {}


node ProjectState {
    has answers: list[str],
        total_cost: float,
        budget: float,
        generation_mode: str,
        traversal_product_keys: list[str] = [],
        version: int = 1,
        proposal_active: bool = False;
}


node VersionRecord {
    has number: int,
        label: str,
        total_cost: float,
        summary: str;
}


obj QuantityView {
    has owned: int,
        available: int,
        selected: int;
}


obj ProductView {
    has key: str,
        name: str,
        category: str,
        summary: str,
        unit_cost: float,
        quantity: QuantityView,
        specs: list[str],
        relationships: list[str],
        availability: str;
}


obj CategoryView {
    has key: str,
        name: str,
        description: str,
        products: list[ProductView];
}


obj RequirementView {
    has key: str,
        label: str,
        value: str,
        mandatory: bool,
        satisfied: bool;
}


obj MissionProfile {
    has scenario_tag: str,
        budget: float,
        deployment: str,
        environment: str;
}


obj DesignNodeView {
    has key: str,
        label: str,
        kind: str,
        subsystem: str,
        status: str,
        product_key: str;
}


obj WorkflowStageView {
    has number: int,
        title: str,
        detail: str,
        status: str,
        linked_products: list[str],
        verification: list[str];
}


obj TraversalStepView {
    has product_key: str,
        product_name: str,
        rationale: str,
        selected: bool;
}


obj SuggestedResolutionView {
    has key: str,
        title: str,
        kind: str,
        detail: str,
        product_key: str = "",
        available: bool = True;
}


obj DownstreamEffectView {
    has domain: str,
        summary: str;
}


obj CompatibilityAssessmentView {
    has decision_key: str,
        verdict: str,
        issue_domain: str,
        specific_issue: str,
        evidence: str,
        source_note: str,
        suggested_resolutions: list[SuggestedResolutionView],
        downstream_effects: list[DownstreamEffectView];
}


obj ProposalView {
    has active: bool,
        decision_key: str,
        resolution_key: str,
        baseline_product_keys: list[str],
        proposed_product_keys: list[str],
        removed_product_keys: list[str],
        added_product_keys: list[str],
        projected_cost: float,
        cost_delta: float,
        design_nodes: list[DesignNodeView],
        workflow: list[WorkflowStageView],
        downstream_effects: list[DownstreamEffectView],
        rationale: str;
}


obj ApprovalGateView {
    has key: str,
        title: str,
        status: str,
        detail: str;
}


obj VersionView {
    has number: int,
        label: str,
        status: str,
        product_keys: list[str],
        total_cost: float,
        added_product_keys: list[str],
        removed_product_keys: list[str],
        summary: str;
}


obj WorkspaceView {
    has categories: list[CategoryView],
        products: list[ProductView],
        project_active: bool,
        current_version: int;
    has requirements: list[RequirementView] = [],
        design_nodes: list[DesignNodeView] = [],
        workflow: list[WorkflowStageView] = [],
        traversal: list[TraversalStepView] = [],
        assessments: list[CompatibilityAssessmentView] = [],
        proposal: ProposalView | None = None,
        gates: list[ApprovalGateView] = [],
        approval_ready: bool = False,
        versions: list[VersionView] = [],
        selected_product_keys: list[str] = [],
        total_cost: float = 0.0,
        budget: float = 75000.0,
        generation_mode: str = "not-started",
        error: str = "";
}


def _compatibility_assessments(
    state: ProjectState | None
) -> list[CompatibilityAssessmentView] {
    if state is None or "sony-snc-vb632d" not in _selected_product_keys(state) {
        return [];
    }
    return [
        CompatibilityAssessmentView(
            decision_key="sony-snc-vb632d",
            verdict="conditional",
            issue_domain="environmental",
            specific_issue="The low-light camera meets night-imaging needs, but its stability and usable image quality in rain and 50 km/h wind are not verified for this temporary mast installation.",
            evidence="AI inference",
            source_note="Curated demo specifications plus the mission weather envelope; no qualifying field-test record is attached.",
            suggested_resolutions=[
                SuggestedResolutionView(
                    key="thermal-golden",
                    title="Use the weather-rated FLIR Boson 640",
                    kind="hardware substitution",
                    detail="Replace the visible low-light camera with the in-stock IP67 thermal core.",
                    product_key="flir-boson-640"
                ),
                SuggestedResolutionView(
                    key="add-enclosure",
                    title="Add the Videotec NXM36 enclosure",
                    kind="enclosure change",
                    detail="Protect the sensor assembly and add a heater-ready harsh-weather housing.",
                    product_key="videotec-nxm36"
                ),
                SuggestedResolutionView(
                    key="adapt-power",
                    title="Add regulated thermal power",
                    kind="interface adapter",
                    detail="Add the in-stock Victron controller and a fused 24 V conversion branch.",
                    product_key="victron-smartsolar-150-35"
                ),
                SuggestedResolutionView(
                    key="thermal-profile",
                    title="Load the thermal inference profile",
                    kind="software change",
                    detail="Switch Jetson preprocessing and person/vehicle detection to calibrated thermal imagery."
                ),
                SuggestedResolutionView(
                    key="weather-test",
                    title="Run a weather and vibration trial",
                    kind="verification test",
                    detail="Verify detection range and image stability in rain, fog, dust, and 50 km/h wind."
                )
            ],
            downstream_effects=[
                DownstreamEffectView(
                    domain="mount",
                    summary="Replace the Pelco mount with the higher-payload FLIR PTU-D300E."
                ),
                DownstreamEffectView(
                    domain="enclosure",
                    summary="Add the Videotec NXM36 stainless enclosure and heater allowance."
                ),
                DownstreamEffectView(
                    domain="power",
                    summary="Add a regulated 24 V branch and update the twelve-hour load profile."
                ),
                DownstreamEffectView(
                    domain="compute",
                    summary="Reserve Jetson camera bandwidth for the Boson thermal stream."
                ),
                DownstreamEffectView(
                    domain="communications",
                    summary="Recalculate LTE alert payloads for thermal clips and metadata."
                ),
                DownstreamEffectView(
                    domain="cost",
                    summary="Projected mainline cost rises by $9,420 and remains within budget."
                ),
                DownstreamEffectView(
                    domain="software",
                    summary="Load and calibrate the thermal inference profile."
                ),
                DownstreamEffectView(
                    domain="validation",
                    summary="Add thermal range, rain, fog, dust, wind, and false-alarm tests."
                )
            ]
        )
    ];
}


def _demo_selection_outputs() -> list[object] {
    # The deterministic model chooses the first one or two candidates after
    # Jac has removed unavailable and incompatible inventory. Integer choices
    # stay stable even when graph traversal order differs between runtimes.
    return [[0, 1]] * 120;
}


glob _live_llm: bool = os.environ.get("MEDUSA_LLM_MODE", "demo") == "live",
    demo_selection_model = MockLLM(
        model_name="mockllm",
        config={"outputs": _demo_selection_outputs()}
    );


def _generation_mode() -> str {
    return "live-llm" if _live_llm else "demo-llm";
}


def _selection_rationale(product: Product) -> str {
    rationales: dict[str, str] = {
        "sony-snc-vb632d": "Strong low-light performance and sufficient stock; weather evidence remains conditional.",
        "echodyne-echoguard": "Electronically scanned radar avoids a moving antenna and covers the known sight-line gap.",
        "jetson-agx-orin": "Available edge AI capacity supports detection, tracking, and a ten-second alert target.",
        "peplink-max-br1-pro": "Matches the intermittent-LTE primary link and accepts the field DC bus.",
        "rajant-dx2": "Provides an in-stock local mesh fallback around mixed terrain.",
        "goal-zero-yeti-6000x": "Portable battery capacity supports the twelve-hour runtime with solar assistance.",
        "pelco-es6230": "Available weather housing and pointing hardware supports the initial visible camera.",
        "will-burt-hurry-up": "Portable mast satisfies temporary setup and sensor elevation needs.",
        "vaisala-wxt536": "Captures wind and rain evidence during mission-condition validation.",
        "moxa-iologik-e1214": "Adds enclosure, tamper, and battery telemetry to the remote dashboard."
    };
    return rationales[product.key]
        if product.key in rationales
        else "Selected by the constrained mission traversal from available inventory.";
}


def _mission_profile(answers: list[str]) -> MissionProfile {
    deployment = answers[1].lower();
    environment = answers[5].lower();
    mission = answers[0].lower();
    scenario_tag = "thermal"
        if "thermal" in mission or "thermal" in environment
        else "vehicle"
        if "vehicle" in deployment
        else "baseline";
    budget = 100000.0 if "100" in answers[8] else 75000.0;
    return MissionProfile(
        scenario_tag=scenario_tag,
        budget=budget,
        deployment=deployment,
        environment=environment
    );
}


def _eligible(product: Product, profile: MissionProfile) -> bool {
    if product.available <= product.selected {
        return False;
    }
    return profile.scenario_tag in product.scenario_tags;
}


def _validate_generated_design(
    origin: Root, selected_keys: list[str], profile: MissionProfile
) -> str {
    for category_key in [
        "sensors", "compute", "communications", "power", "structures", "support"
    ] {
        selected_for_category = False;
        for key in selected_keys {
            product = _product_by_key(origin, key);
            if product is not None and product.category == category_key {
                selected_for_category = True;
            }
        }
        if not selected_for_category {
            return f"Generation did not select an eligible {category_key} product for the mission profile.";
        }
    }
    total_cost: float = 0.0;
    for key in selected_keys {
        product = _product_by_key(origin, key);
        if product is None or product.available <= product.selected {
            return "Generation selected inventory that is no longer available.";
        }
        total_cost += product.unit_cost;
    }
    if total_cost > profile.budget {
        return f"Generation exceeds the interpreted ${profile.budget:,.0f} budget.";
    }
    return "";
}


walker _SelectDesign {
    has goal: str,
        profile: MissionProfile,
        selected_products: list[Product] = [],
        traversal: list[TraversalStepView] = [];

    can start with Root entry {
        visit [here -->[?:InventoryCategory]];
    }

    can choose with InventoryCategory entry {
        candidates: list[Product] = [
            product
            for product in [here ->:Contains:->]
            if _eligible(product, self.profile)
        ];
        if _live_llm {
            visit candidates by llm(
                select=(1, 2),
                intent=f"{self.goal} Choose only the smallest mission-relevant set for the {here.name} subsystem."
            );
        } else {
            visit candidates by demo_selection_model(
                select=(1, 2),
                intent=f"{self.goal} Choose only the smallest mission-relevant set for the {here.name} subsystem."
            );
        }
    }

    can record with Product entry {
        if here.key not in [p.key for p in self.selected_products] {
            self.selected_products.append(here);
            self.traversal.append(
                TraversalStepView(
                    product_key=here.key,
                    product_name=here.name,
                    rationale=_selection_rationale(here),
                    selected=True
                )
            );
        }
    }
}


def _product_view(product: Product) -> ProductView {
    return ProductView(
        key=product.key,
        name=product.name,
        category=product.category,
        summary=product.summary,
        unit_cost=product.unit_cost,
        quantity=QuantityView(
            owned=product.owned,
            available=product.available,
            selected=product.selected
        ),
        specs=product.specs,
        relationships=product.relationships,
        availability="available" if product.available > 0 else "unavailable"
    );
}


def _project_state(origin: Root) -> ProjectState | None {
    states = [origin -->[?:ProjectState]];
    return states[0] if states else None;
}


def _product_by_key(origin: Root, key: str) -> Product | None {
    for category in [origin -->[?:InventoryCategory]] {
        for product in [category ->:Contains:->] {
            if product.key == key {
                return product;
            }
        }
    }
    return None;
}


def _selected_product_keys(state: ProjectState | None) -> list[str] {
    if state is None {
        return [];
    }
    missions = [state ->:OwnsMission:->];
    if not missions {
        return [];
    }
    keys: list[str] = [];
    for subsystem in [missions[0] ->:HasSubsystem:->] {
        for decision in [subsystem ->:HasDecision:->] {
            for product in [decision ->:SelectsProduct:->] {
                keys.append(product.key);
            }
        }
    }
    return keys;
}


def _proposal_graph(state: ProjectState | None) -> ProposalGraph | None {
    if state is None {
        return None;
    }
    proposals = [state ->:OwnsProposal:->];
    return proposals[0] if proposals else None;
}


def _proposal_product_keys(state: ProjectState | None) -> list[str] {
    proposal = _proposal_graph(state);
    if proposal is None {
        return [];
    }
    keys: list[str] = [];
    for subsystem in [proposal ->:ProposesSubsystem:->] {
        for decision in [subsystem ->:HasDecision:->] {
            for product in [decision ->:SelectsProduct:->] {
                keys.append(product.key);
            }
        }
    }
    return keys;
}


def _persist_design(
    origin: Root,
    state: ProjectState,
    product_keys: list[str],
    proposal: ProposalGraph | None = None
) {
    parent = proposal if proposal is not None else (
        state +>:OwnsMission:+> Mission(title="Adverse-weather perimeter monitoring")
    )[0];
    labels: dict[str, str] = {
        "sensors": "Detect & track",
        "compute": "Edge compute",
        "communications": "Alerts & backhaul",
        "power": "Field power",
        "structures": "Mount & protect",
        "support": "Verify & sustain"
    };
    for category_key in [
        "sensors", "compute", "communications", "power", "structures", "support"
    ] {
        subsystem = DesignSubsystem(key=category_key, label=labels[category_key]);
        if proposal is not None {
            parent +>:ProposesSubsystem:+> subsystem;
        } else {
            parent +>:HasSubsystem:+> subsystem;
        }
        for key in product_keys {
            product = _product_by_key(origin, key);
            if product is not None and product.category == category_key {
                decision = DesignDecision(
                    status="conditional" if key == "sony-snc-vb632d" else "compatible"
                );
                subsystem +>:HasDecision:+> decision;
                decision +>:SelectsProduct:+> product;
            }
        }
    }
}


def _snapshot_product_keys(record: VersionRecord) -> list[str] {
    keys: list[str] = [];
    for selection in [record ->:VersionContains:->] {
        for product in [selection ->:SnapshotSelects:->] {
            keys.append(product.key);
        }
    }
    return keys;
}


def _persist_version_snapshot(
    origin: Root, record: VersionRecord, product_keys: list[str]
) {
    selection = VersionSelection();
    record +>:VersionContains:+> selection;
    for key in product_keys {
        product = _product_by_key(origin, key);
        if product is not None {
            selection +>:SnapshotSelects:+> product;
        }
    }
}


def _requirements(answers: list[str]) -> list[RequirementView] {
    keys = [
        "mission",
        "deployment",
        "coverage",
        "targets",
        "performance",
        "environment",
        "power",
        "operator-comms",
        "budget"
    ];
    labels = [
        "Mission goal",
        "Deployment style",
        "Coverage area",
        "Detection targets",
        "Detection performance",
        "Environmental conditions",
        "Operating duration and power",
        "Operator and communications needs",
        "Project budget"
    ];
    return [
        RequirementView(
            key=keys[index],
            label=labels[index],
            value=answer,
            mandatory=True,
            satisfied=True
        )
        for (index, answer) in enumerate(answers)
    ];
}


def _design_nodes(
    origin: Root, selected_product_keys: list[str]
) -> list[DesignNodeView] {
    nodes: list[DesignNodeView] = [
        DesignNodeView(
            key="mission",
            label="Adverse-weather perimeter monitoring",
            kind="mission",
            subsystem="mission",
            status="active",
            product_key=""
        )
    ];
    subsystem_labels: dict[str, str] = {
        "sensors": "Detect & track",
        "compute": "Edge compute",
        "communications": "Alerts & backhaul",
        "power": "Field power",
        "structures": "Mount & protect",
        "support": "Verify & sustain"
    };
    for category in [origin -->[?:InventoryCategory]] {
        nodes.append(
            DesignNodeView(
                key=f"subsystem-{category.key}",
                label=subsystem_labels[category.key],
                kind="subsystem",
                subsystem=category.key,
                status="active",
                product_key=""
            )
        );
        for product in [category ->:Contains:->] {
            if product.key in selected_product_keys {
                nodes.append(
                    DesignNodeView(
                        key=f"decision-{product.key}",
                        label=product.name,
                        kind="product",
                        subsystem=category.key,
                        status="conditional"
                        if product.key == "sony-snc-vb632d"
                        else "compatible",
                        product_key=product.key
                    )
                );
            }
        }
    }
    return nodes;
}


def _workflow(selected_product_keys: list[str]) -> list[WorkflowStageView] {
    thermal: bool = "flir-boson-640" in selected_product_keys;
    return [
        WorkflowStageView(
            number=1,
            title="Confirm requirements",
            detail="Approve the nine interpreted mission requirements before field work.",
            status="complete",
            linked_products=[],
            verification=[]
        ),
        WorkflowStageView(
            number=2,
            title="Select detection hardware",
            detail="Qualify the weather-rated thermal camera and radar against the 500 m target."
            if thermal
            else "Bench the radar and low-light camera against the 500 m target.",
            status="ready" if thermal else "attention",
            linked_products=[
                key
                for key in selected_product_keys
                if key in [
                    "sony-snc-vb632d",
                    "flir-boson-640",
                    "echodyne-echoguard"
                ]
            ],
            verification=[
                "Verify thermal detection range in rain and 50 km/h wind"
                if thermal
                else "Verify camera stability in rain and 50 km/h wind"
            ]
        ),
        WorkflowStageView(
            number=3,
            title="Select compute and software",
            detail="Load the calibrated thermal inference profile, person/vehicle detection, animal filtering, and track fusion."
            if thermal
            else "Load person/vehicle detection, animal filtering, and track fusion.",
            status="ready",
            linked_products=[
                key for key in selected_product_keys if key == "jetson-agx-orin"
            ],
            verification=[]
        ),
        WorkflowStageView(
            number=4,
            title="Configure power",
            detail="Commission the revised twelve-hour battery profile, Victron controller, and fused 24 V thermal branch."
            if thermal
            else "Commission the twelve-hour battery profile and fused DC distribution.",
            status="ready",
            linked_products=[
                key
                for key in selected_product_keys
                if key in [
                    "goal-zero-yeti-6000x",
                    "victron-smartsolar-150-35"
                ]
            ],
            verification=["Run a twelve-hour load test"]
        ),
        WorkflowStageView(
            number=5,
            title="Configure communications and alerts",
            detail="Use LTE first and mesh fallback for thermal alert metadata and event clips."
            if thermal
            else "Use LTE first and mesh radio fallback for dashboard alerts.",
            status="ready",
            linked_products=[
                key
                for key in selected_product_keys
                if key in ["peplink-max-br1-pro", "rajant-dx2"]
            ],
            verification=["Force an LTE outage and confirm mesh failover"]
        ),
        WorkflowStageView(
            number=6,
            title="Assemble and deploy",
            detail="Install the mast, PTU-D300E, thermal enclosure, weather station, and telemetry."
            if thermal
            else "Install the mast, enclosure, weather station, and telemetry.",
            status="ready",
            linked_products=[
                key
                for key in selected_product_keys
                if key in [
                    "pelco-es6230",
                    "flir-ptu-d300e",
                    "videotec-nxm36",
                    "will-burt-hurry-up",
                    "moxa-iologik-e1214"
                ]
            ],
            verification=["Torque and guy the mast for the specified wind load"]
        ),
        WorkflowStageView(
            number=7,
            title="Validate against mission conditions",
            detail="Record detection range, alert latency, weather, and false alarms.",
            status="planned",
            linked_products=[
                key for key in selected_product_keys if key == "vaisala-wxt536"
            ],
            verification=[
                "Night detection at 500 m",
                "Alert latency below ten seconds",
                "Rain, fog, dust, and wind trial"
            ] + (
                ["Thermal range and false-alarm calibration"]
                if thermal
                else []
            )
        )
    ];
}


def _proposal_view(
    origin: Root, state: ProjectState | None
) -> ProposalView | None {
    proposal_graph = _proposal_graph(state);
    if state is None or proposal_graph is None {
        return None;
    }
    baseline_keys = _selected_product_keys(state);
    proposed_keys = _proposal_product_keys(state);
    removed = [
        key
        for key in baseline_keys
        if key not in proposed_keys
    ];
    added = [
        key
        for key in proposed_keys
        if key not in baseline_keys
    ];
    return ProposalView(
        active=True,
        decision_key=proposal_graph.decision_key,
        resolution_key=proposal_graph.resolution_key,
        baseline_product_keys=baseline_keys,
        proposed_product_keys=proposed_keys,
        removed_product_keys=removed,
        added_product_keys=added,
        projected_cost=proposal_graph.total_cost,
        cost_delta=proposal_graph.total_cost - state.total_cost,
        design_nodes=_design_nodes(origin, proposed_keys),
        workflow=_workflow(proposed_keys),
        downstream_effects=_compatibility_assessments(state)[0].downstream_effects,
        rationale="Replace the unverified low-light weather path with an in-stock IP67 thermal assembly and propagate its mechanical, power, software, communications, and validation effects."
    );
}


def _approval_gates(
    state: ProjectState | None
) -> list[ApprovalGateView] {
    proposal = _proposal_graph(state);
    if state is None or proposal is None {
        return [];
    }
    scenario = proposal.scenario;
    return [
        ApprovalGateView(
            key="compatibility",
            title="Required compatibility",
            status="blocked" if scenario == "incompatible" else "passed",
            detail="A required thermal-to-mount relationship is incompatible."
            if scenario == "incompatible"
            else "Required relationships are compatible; conditional claims have explicit verification."
        ),
        ApprovalGateView(
            key="quantity",
            title="Inventory quantity",
            status="blocked" if scenario == "quantity" else "passed",
            detail="The proposed thermal assembly exceeds available quantity."
            if scenario == "quantity"
            else "Every proposed product has sufficient available quantity."
        ),
        ApprovalGateView(
            key="budget",
            title="Project budget",
            status="blocked" if scenario == "budget" else "passed",
            detail=f"Projected cost exceeds the ${state.budget:,.0f} budget."
            if scenario == "budget"
            else f"Projected cost is ${proposal.total_cost:,.0f}, within the ${state.budget:,.0f} budget."
        ),
        ApprovalGateView(
            key="requirements",
            title="Mandatory mission coverage",
            status="blocked" if scenario == "requirement" else "passed",
            detail="The mandatory remote-alert requirement has no proposed solution."
            if scenario == "requirement"
            else "All nine mandatory mission requirements have a proposed solution."
        )
    ];
}


def _approval_ready(state: ProjectState | None) -> bool {
    gates = _approval_gates(state);
    return len(gates) == 4 and all(gate.status == "passed" for gate in gates);
}


def _versions(
    origin: Root, state: ProjectState | None
) -> list[VersionView] {
    if state is None {
        return [];
    }
    views: list[VersionView] = [];
    records = [origin -->[?:VersionRecord]];
    previous_keys: list[str] = [];
    for number in range(1, state.version + 1) {
        for record in records {
            if record.number == number {
                product_keys = _snapshot_product_keys(record);
                views.append(
                    VersionView(
                        number=record.number,
                        label=record.label,
                        status="active"
                        if record.number == state.version
                        else "historical",
                        product_keys=product_keys,
                        total_cost=record.total_cost,
                        added_product_keys=[
                            key for key in product_keys if key not in previous_keys
                        ],
                        removed_product_keys=[
                            key for key in previous_keys if key not in product_keys
                        ],
                        summary=record.summary
                    )
                );
                previous_keys = product_keys;
            }
        }
    }
    return views;
}


def _traversal(
    origin: Root, state: ProjectState | None
) -> list[TraversalStepView] {
    if state is None {
        return [];
    }
    steps: list[TraversalStepView] = [];
    for key in state.traversal_product_keys {
        product = _product_by_key(origin, key);
        if product is not None {
            steps.append(
                TraversalStepView(
                    product_key=product.key,
                    product_name=product.name,
                    rationale=_selection_rationale(product),
                    selected=True
                )
            );
        }
    }
    return steps;
}


def _seed_inventory(origin: Root) {
    categories_by_key: dict[str, InventoryCategory] = {};
    products_by_key: dict[str, Product] = {};
    for category_seed in category_seeds() {
        category = (
            origin ++> InventoryCategory(
                key=category_seed.key,
                name=category_seed.name,
                description=category_seed.description
            )
        )[0];
        categories_by_key[category.key] = category;
    }
    for product_seed in product_seeds() {
        product = Product(
            key=product_seed.key,
            name=product_seed.name,
            category=product_seed.category,
            summary=product_seed.summary,
            unit_cost=product_seed.unit_cost,
            owned=product_seed.owned,
            available=product_seed.available,
            selected=0,
            specs=product_seed.specs,
            relationships=product_seed.relationships,
            scenario_tags=product_seed.scenario_tags
        );
        categories_by_key[product_seed.category] +>:Contains:+> product;
        products_by_key[product.key] = product;
    }
    for relationship_seed in product_relationship_seeds() {
        source = products_by_key[relationship_seed.from_key];
        target = products_by_key[relationship_seed.to_key];
        source +>:ProductRelationship(
            kind=relationship_seed.kind,
            note=relationship_seed.note
        ):+> target;
    }
}


def _ensure_seeded_inventory(origin: Root) {
    categories = [origin -->[?:InventoryCategory]];
    needs_reseed = len(categories) == 0;
    for category in categories {
        for product in [category ->:Contains:->] {
            if len(product.scenario_tags) == 0 {
                needs_reseed = True;
            }
        }
    }
    if needs_reseed {
        for state in [origin -->[?:ProjectState]] {
            del state;
        }
        for version in [origin -->[?:VersionRecord]] {
            del version;
        }
        for category in categories {
            del category;
        }
        _seed_inventory(origin);
    }
}


def _workspace(origin: Root) -> WorkspaceView {
    categories: list[CategoryView] = [];
    products: list[ProductView] = [];
    for category in [origin -->[?:InventoryCategory]] {
        category_products: list[ProductView] = [];
        for product in [category ->:Contains:->] {
            product_view = _product_view(product);
            category_products.append(product_view);
            products.append(product_view);
        }
        categories.append(
            CategoryView(
                key=category.key,
                name=category.name,
                description=category.description,
                products=category_products
            )
        );
    }
    state = _project_state(origin);
    selected_keys = _selected_product_keys(state);
    return WorkspaceView(
        categories=categories,
        products=products,
        project_active=state is not None,
        current_version=state.version if state is not None else 0,
        requirements=_requirements(state.answers) if state is not None else [],
        design_nodes=_design_nodes(origin, selected_keys)
        if state is not None
        else [],
        workflow=_workflow(selected_keys)
        if state is not None
        else [],
        traversal=_traversal(origin, state),
        assessments=_compatibility_assessments(state),
        proposal=_proposal_view(origin, state),
        gates=_approval_gates(state),
        approval_ready=_approval_ready(state),
        versions=_versions(origin, state),
        selected_product_keys=selected_keys
        if state is not None
        else [],
        total_cost=state.total_cost if state is not None else 0.0,
        budget=state.budget if state is not None else 75000.0,
        generation_mode=state.generation_mode
        if state is not None
        else "not-started"
    );
}


walker:pub LoadWorkspace {
    has reports: list[WorkspaceView] = [];

    can load with Root entry {
        _ensure_seeded_inventory(here);
        report _workspace(here);
    }
}


walker:pub CreateProject {
    has answers: list[str];
    has reports: list[WorkspaceView] = [];

    can create with Root entry {
        _ensure_seeded_inventory(here);
        if len(self.answers) != 9 {
            invalid = _workspace(here);
            invalid.error = "Mission intake requires exactly nine answers.";
            report invalid;
            disengage;
        }

        for existing in [here -->[?:ProjectState]] {
            del existing;
        }
        for existing_version in [here -->[?:VersionRecord]] {
            del existing_version;
        }
        for category in [here -->[?:InventoryCategory]] {
            [category ->:Contains:->](=selected=0);
        }

        try {
            profile = _mission_profile(self.answers);
            generated = here spawn _SelectDesign(
                goal=self.answers[0],
                profile=profile
            );
            selected_keys = [
                product.key for product in generated.selected_products
            ];
            validation_error = _validate_generated_design(
                here, selected_keys, profile
            );
            if validation_error != "" {
                failed = _workspace(here);
                failed.error = validation_error;
                report failed;
                disengage;
            }
            total_cost = 0.0;
            for product in generated.selected_products {
                product.selected = 1;
                total_cost += product.unit_cost;
            }
            state = (here ++> ProjectState(
                answers=self.answers,
                traversal_product_keys=selected_keys,
                total_cost=total_cost,
                budget=profile.budget,
                generation_mode=_generation_mode()
            ))[0];
            _persist_design(here, state, selected_keys);
            initial_version = (here ++> VersionRecord(
                number=1,
                label="Initial mission design",
                total_cost=total_cost,
                summary="Constrained LLM-guided traversal created the first mainline design."
            ))[0];
            _persist_version_snapshot(here, initial_version, selected_keys);
            report _workspace(here);
        } except Exception as generation_error {
            failed = _workspace(here);
            failed.error = f"Generation failed: {str(generation_error)}";
            report failed;
        }
    }
}


walker:pub ProposeChange {
    has decision_key: str,
        resolution_key: str,
        scenario: str = "valid";
    has reports: list[WorkspaceView] = [];

    can propose with Root entry {
        state = _project_state(here);
        if state is None {
            missing = _workspace(here);
            missing.error = "Create a project before proposing a change.";
            report missing;
            disengage;
        }
        if self.decision_key != "sony-snc-vb632d"
        or self.resolution_key != "thermal-golden" {
            invalid = _workspace(here);
            invalid.error = "The demo accepts the in-stock thermal resolution for the low-light camera decision.";
            report invalid;
            disengage;
        }

        added_keys = [
            "flir-boson-640",
            "flir-ptu-d300e",
            "videotec-nxm36",
            "victron-smartsolar-150-35"
        ];
        for key in added_keys {
            candidate = _product_by_key(here, key);
            if candidate is None or candidate.available <= candidate.selected {
                blocked = _workspace(here);
                blocked.error = "The thermal proposal requires inventory that is no longer available.";
                report blocked;
                disengage;
            }
        }

        baseline_keys = _selected_product_keys(state);
        proposed_keys = [
            key
            for key in baseline_keys
            if key not in ["sony-snc-vb632d", "pelco-es6230"]
        ] + added_keys;
        proposed_cost: float = 0.0;
        for key in proposed_keys {
            candidate = _product_by_key(here, key);
            if candidate is not None {
                proposed_cost += candidate.unit_cost;
            }
        }
        for existing in [state ->:OwnsProposal:->] {
            del existing;
        }
        proposal = ProposalGraph(
            decision_key=self.decision_key,
            resolution_key=self.resolution_key,
            total_cost=82000.0
            if self.scenario == "budget"
            else proposed_cost,
            scenario=self.scenario
            if self.scenario in [
                "valid",
                "incompatible",
                "quantity",
                "budget",
                "requirement"
            ]
            else "valid"
        );
        state +>:OwnsProposal:+> proposal;
        _persist_design(here, state, proposed_keys, proposal=proposal);
        state.proposal_active = True;
        report _workspace(here);
    }
}


walker:pub ApproveProposal {
    has reports: list[WorkspaceView] = [];

    can approve with Root entry {
        state = _project_state(here);
        if state is None {
            missing = _workspace(here);
            missing.error = "There is no active proposal to approve.";
            report missing;
            disengage;
        }
        assert state is not None;
        proposal = _proposal_graph(state);
        if proposal is None {
            missing = _workspace(here);
            missing.error = "There is no active proposal to approve.";
            report missing;
            disengage;
        }
        if not _approval_ready(state) {
            blocked = _workspace(here);
            messages: dict[str, str] = {
                "incompatible": "Approval blocked: a required relationship is incompatible.",
                "quantity": "Approval blocked: required inventory quantity is insufficient.",
                "budget": "Approval blocked: the proposal exceeds the project budget.",
                "requirement": "Approval blocked: a mandatory requirement has no proposed solution."
            };
            blocked.error = messages[proposal.scenario];
            report blocked;
            disengage;
        }
        after_keys = _proposal_product_keys(state);
        current_version = state.version;
        next_version = current_version + 1;

        for category in [here -->[?:InventoryCategory]] {
            for product in [category ->:Contains:->] {
                product.selected = 1 if product.key in after_keys else 0;
            }
        }
        version_record = (here ++> VersionRecord(
            number=next_version,
            label="Weather-rated thermal revision",
            total_cost=proposal.total_cost,
            summary="Approved the guided thermal resolution and retained the initial design as immutable history."
        ))[0];
        _persist_version_snapshot(here, version_record, after_keys);
        previous_versions = [
            record
            for record in [here -->[?:VersionRecord]]
            if record.number == current_version
        ];
        if previous_versions {
            version_record +>:Supersedes:+> previous_versions[0];
        }
        state.total_cost = proposal.total_cost;
        state.version = next_version;
        state.proposal_active = False;
        for mission in [state ->:OwnsMission:->] {
            del mission;
        }
        _persist_design(here, state, after_keys);
        del proposal;
        report _workspace(here);
    }
}


walker:pub ResetDemo {
    has reports: list[WorkspaceView] = [];

    can reset with Root entry {
        _ensure_seeded_inventory(here);
        for state in [here -->[?:ProjectState]] {
            del state;
        }
        for version in [here -->[?:VersionRecord]] {
            del version;
        }
        for category in [here -->[?:InventoryCategory]] {
            for product in [category ->:Contains:->] {
                product.selected = 0;
            }
        }
        report _workspace(here);
    }
}
