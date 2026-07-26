"""MEDUSA's three-screen interactive client.

The UI is deliberately kept in one Jac client module: small visual helpers,
three screen components, and one stateful shell that calls the five public
walkers. Styling is inline Jac data, so there is no maintained CSS or
JavaScript beside the product source.
"""

sv import from .medusa {
    ApprovalGateView,
    ApproveProposal,
    CategoryView,
    CompatibilityAssessmentView,
    CreateProject,
    DesignNodeView,
    DownstreamEffectView,
    LoadWorkspace,
    ProductView,
    ProposalView,
    ProposeChange,
    ResetDemo,
    SuggestedResolutionView,
    TraversalStepView,
    VersionView,
    WorkflowStageView,
    WorkspaceView,
}


glob INK = "#202124",
    MUTED = "#6B6F76",
    BORDER = "#E3E4E7",
    CANVAS = "#F5F5F3",
    PANEL = "#FFFFFF",
    INDIGO = "#5B5BD6",
    INDIGO_SOFT = "#EEEEFF",
    CORAL = "#E46E56",
    CORAL_SOFT = "#FFF0EC",
    GREEN = "#2F7D5A",
    GREEN_SOFT = "#EAF6F0",
    AMBER = "#A56A13",
    AMBER_SOFT = "#FFF6DF",
    RED = "#B44545",
    RED_SOFT = "#FFF0F0",
    g = "g",
    rect = "rect",
    text = "text",
    line = "line",
    circle = "circle",
    path = "path",
    CATEGORY_COLORS: dict[str, str] = {
        "sensors": "#5B5BD6",
        "compute": "#3079C8",
        "communications": "#B66A2C",
        "power": "#A78616",
        "structures": "#6C6F76",
        "support": "#2F7D5A"
    },
    DEFAULT_ANSWERS: list[str] = [
        "Monitor a remote perimeter at night in bad weather and alert an operator when people or vehicles enter the protected area.",
        "Temporary fixed installation with field setup within four hours.",
        "Two-kilometer mixed-terrain perimeter, two vehicle gates, and one known line-of-sight gap.",
        "Detect people and vehicles; filter animals.",
        "Detect at 500 meters, alert within 10 seconds, and maintain a low false-alarm rate.",
        "Operate in darkness, rain, fog, dust, winds up to 50 km/h, and temperatures from −10°C to 45°C.",
        "Operate for at least 12 hours using batteries; solar assistance is available but not required.",
        "Support one remote operator, intermittent LTE, local radio fallback, and dashboard alerts.",
        "Remain within a $75,000 project budget and use only available inventory."
    ],
    QUESTION_LABELS: list[str] = [
        "What mission must the prototype accomplish?",
        "How will the system be deployed?",
        "What area must it cover?",
        "Which targets matter?",
        "What performance defines success?",
        "Which environmental conditions must it survive?",
        "How long must it operate and from what power?",
        "How will operators receive alerts?",
        "What constraints are non-negotiable?"
    ],
    QUESTION_HINTS: list[str] = [
        "Describe the operational outcome, not a preferred product.",
        "Permanent, vehicle-mounted, or temporary field installation.",
        "Distance, terrain, gates, and known visibility gaps.",
        "People, vehicles, animals, aircraft, or other objects.",
        "Range, latency, confidence, and false-alarm tolerance.",
        "Lighting, weather, wind, dust, and temperature.",
        "Runtime, battery, generator, or solar constraints.",
        "Operator count, primary link, fallback, and alert surface.",
        "Budget, schedule, stock, safety, or policy limits."
    ],
    QUICK_OPTIONS: list[list[str]] = [
        ["Perimeter intrusion alerts", "Remote area awareness"],
        ["Temporary fixed site", "Vehicle-mounted"],
        ["2 km mixed terrain", "Two guarded gates"],
        ["People + vehicles", "Vehicles only"],
        ["500 m / 10 sec", "300 m / 15 sec"],
        ["Bad weather + darkness", "Fair weather"],
        ["12 hr battery", "24 hr hybrid"],
        ["LTE + radio fallback", "Local operator only"],
        ["$75k + in-stock only", "$100k ceiling"]
    ];


def panel_style(padding: str = "18px") -> dict[str, object] {
    return {
        "backgroundColor": PANEL,
        "border": f"1px solid {BORDER}",
        "borderRadius": "14px",
        "padding": padding,
        "boxShadow": "0 1px 2px rgba(28, 29, 31, 0.04)"
    };
}


def button_style(kind: str = "secondary") -> dict[str, object] {
    base: dict[str, object] = {
        "border": "0",
        "borderRadius": "9px",
        "padding": "9px 13px",
        "fontSize": "13px",
        "fontWeight": "650",
        "cursor": "pointer",
        "lineHeight": "1.2"
    };
    if kind == "primary" {
        return {**base, "backgroundColor": INK, "color": "#FFFFFF"};
    }
    if kind == "indigo" {
        return {**base, "backgroundColor": INDIGO, "color": "#FFFFFF"};
    }
    if kind == "danger" {
        return {**base, "backgroundColor": RED_SOFT, "color": RED};
    }
    if kind == "ghost" {
        return {
            **base,
            "backgroundColor": "transparent",
            "color": MUTED
        };
    }
    return {
        **base,
        "backgroundColor": "#F0F0EE",
        "color": INK,
        "border": f"1px solid {BORDER}"
    };
}


def pill_style(tone: str = "neutral") -> dict[str, object] {
    background = "#F0F0EE";
    color = MUTED;
    if tone == "green" {
        background = GREEN_SOFT;
        color = GREEN;
    } elif tone == "amber" {
        background = AMBER_SOFT;
        color = AMBER;
    } elif tone == "red" {
        background = RED_SOFT;
        color = RED;
    } elif tone == "indigo" {
        background = INDIGO_SOFT;
        color = INDIGO;
    } elif tone == "coral" {
        background = CORAL_SOFT;
        color = CORAL;
    }
    return {
        "display": "inline-flex",
        "alignItems": "center",
        "gap": "5px",
        "padding": "4px 8px",
        "borderRadius": "999px",
        "backgroundColor": background,
        "color": color,
        "fontSize": "11px",
        "fontWeight": "700",
        "letterSpacing": "0.02em"
    };
}


def short(text: str, length: int = 22) -> str {
    return text if len(text) <= length else text[:length - 1] + "…";
}


def money(value: float) -> str {
    return f"${value:,.0f}";
}


def find_product(products: list[ProductView], key: str) -> ProductView | None {
    for product in products {
        if product.key == key {
            return product;
        }
    }
    return None;
}


def category_index(key: str) -> int {
    keys = [
        "sensors",
        "compute",
        "communications",
        "power",
        "structures",
        "support"
    ];
    return keys.index(key) if key in keys else 0;
}


def subsystem_index(key: str) -> int {
    return category_index(key);
}


def product_rank(
    nodes: list[DesignNodeView], target: DesignNodeView
) -> int {
    rank = 0;
    for node in nodes {
        if node.kind == "product" and node.subsystem == target.subsystem {
            if node.key == target.key {
                return rank;
            }
            rank += 1;
        }
    }
    return rank;
}


def ProductDrawer(
    selected: ProductView | None,
    onClose: Callable[[], None]
) -> JsxElement {
    if selected is None {
        return <aside style={{
            **panel_style(),
            "height": "fit-content",
            "color": MUTED,
            "textAlign": "center",
            "padding": "40px 20px"
        }}>
            <div style={{"fontSize": "30px", "marginBottom": "10px"}}>◎</div>
            <div style={{"fontWeight": "700", "color": INK}}>Select a product node</div>
            <p style={{"fontSize": "13px", "lineHeight": "1.5"}}>
                Specifications, quantities, and known relationships will appear here.
            </p>
        </aside>;
    }
    availability_tone = "green"
        if selected.quantity.available > selected.quantity.selected
        else "red";
    return <aside style={{**panel_style("0"), "overflow": "hidden", "height": "fit-content"}}>
        <div style={{
            "padding": "18px",
            "backgroundColor": CATEGORY_COLORS[selected.category],
            "color": "#FFFFFF"
        }}>
            <div style={{
                "display": "flex",
                "justifyContent": "space-between",
                "gap": "12px",
                "alignItems": "flex-start"
            }}>
                <div>
                    <div style={{
                        "fontSize": "11px",
                        "fontWeight": "750",
                        "textTransform": "uppercase",
                        "letterSpacing": "0.08em",
                        "opacity": "0.78"
                    }}>{selected.category}</div>
                    <h2 style={{"fontSize": "19px", "margin": "6px 0 0"}}>
                        {selected.name}
                    </h2>
                </div>
                <button
                    aria-label="Close product details"
                    onClick={lambda { onClose(); }}
                    style={{
                        **button_style("ghost"),
                        "color": "#FFFFFF",
                        "padding": "4px 7px",
                        "fontSize": "18px"
                    }}
                >×</button>
            </div>
            <p style={{
                "fontSize": "13px",
                "lineHeight": "1.5",
                "margin": "10px 0 0",
                "opacity": "0.9"
            }}>{selected.summary}</p>
        </div>
        <div style={{"padding": "18px"}}>
            <div style={{
                "display": "grid",
                "gridTemplateColumns": "repeat(3, 1fr)",
                "gap": "8px",
                "marginBottom": "18px"
            }}>
                {for entry in [
                    ["Owned", str(selected.quantity.owned)],
                    ["Available", str(selected.quantity.available)],
                    ["Selected", str(selected.quantity.selected)]
                ] {
                    <div key={entry[0]} style={{
                        "padding": "10px",
                        "borderRadius": "10px",
                        "backgroundColor": CANVAS
                    }}>
                        <div style={{"fontSize": "10px", "color": MUTED}}>{entry[0]}</div>
                        <div style={{
                            "fontSize": "18px",
                            "fontWeight": "750",
                            "marginTop": "3px"
                        }}>{entry[1]}</div>
                    </div>
                }}
            </div>
            <div style={{
                "display": "flex",
                "justifyContent": "space-between",
                "alignItems": "center",
                "marginBottom": "18px"
            }}>
                <span style={pill_style(availability_tone)}>
                    {"● In stock" if availability_tone == "green" else "● Unavailable"}
                </span>
                <strong style={{"fontSize": "15px"}}>{money(selected.unit_cost)}</strong>
            </div>
            <div style={{"marginBottom": "18px"}}>
                <h3 style={{
                    "fontSize": "12px",
                    "textTransform": "uppercase",
                    "letterSpacing": "0.06em",
                    "margin": "0 0 9px",
                    "color": MUTED
                }}>Specifications</h3>
                {for (index, spec) in enumerate(selected.specs) {
                    <div key={str(index)} style={{
                        "display": "flex",
                        "gap": "8px",
                        "fontSize": "12px",
                        "lineHeight": "1.45",
                        "marginBottom": "7px"
                    }}>
                        <span style={{"color": INDIGO}}>◆</span><span>{spec}</span>
                    </div>
                }}
            </div>
            <div>
                <h3 style={{
                    "fontSize": "12px",
                    "textTransform": "uppercase",
                    "letterSpacing": "0.06em",
                    "margin": "0 0 9px",
                    "color": MUTED
                }}>Known relationships</h3>
                {for (index, relationship) in enumerate(selected.relationships) {
                    <div key={str(index)} style={{
                        "fontSize": "12px",
                        "lineHeight": "1.45",
                        "padding": "8px 10px",
                        "borderLeft": f"2px solid {BORDER}",
                        "marginBottom": "6px",
                        "backgroundColor": "#FAFAF9"
                    }}>{relationship}</div>
                }}
            </div>
        </div>
    </aside>;
}


def GraphControls(
    zoom: float,
    onZoomIn: Callable[[], None],
    onZoomOut: Callable[[], None],
    onPan: Callable[[float, float], None],
    onReset: Callable[[], None]
) -> JsxElement {
    return <div style={{
        "position": "absolute",
        "right": "12px",
        "top": "12px",
        "display": "flex",
        "alignItems": "center",
        "gap": "5px",
        "padding": "5px",
        "border": f"1px solid {BORDER}",
        "borderRadius": "10px",
        "backgroundColor": "rgba(255,255,255,0.94)",
        "boxShadow": "0 4px 14px rgba(32,33,36,0.08)"
    }}>
        <button aria-label="Pan left" onClick={lambda { onPan(-50.0, 0.0); }} style={button_style("ghost")}>←</button>
        <button aria-label="Pan up" onClick={lambda { onPan(0.0, -50.0); }} style={button_style("ghost")}>↑</button>
        <button aria-label="Pan down" onClick={lambda { onPan(0.0, 50.0); }} style={button_style("ghost")}>↓</button>
        <button aria-label="Pan right" onClick={lambda { onPan(50.0, 0.0); }} style={button_style("ghost")}>→</button>
        <span style={{"height": "22px", "width": "1px", "backgroundColor": BORDER}}></span>
        <button aria-label="Zoom out" onClick={lambda { onZoomOut(); }} style={button_style("ghost")}>−</button>
        <span style={{"fontSize": "11px", "fontWeight": "700", "minWidth": "38px", "textAlign": "center"}}>
            {f"{zoom * 100:.0f}%"}
        </span>
        <button aria-label="Zoom in" onClick={lambda { onZoomIn(); }} style={button_style("ghost")}>+</button>
        <button aria-label="Reset graph view" onClick={lambda { onReset(); }} style={button_style("secondary")}>Reset</button>
    </div>;
}


def InventoryGraph(
    categories: list[CategoryView],
    collapsed: list[str],
    selected_key: str,
    zoom: float,
    pan_x: float,
    pan_y: float,
    onSelect: Callable[[str], None],
    onToggleCategory: Callable[[str], None],
    onZoomIn: Callable[[], None],
    onZoomOut: Callable[[], None],
    onPan: Callable[[float, float], None],
    onReset: Callable[[], None]
) -> JsxElement {
    view_width = 1200.0 / zoom;
    view_height = 720.0 / zoom;
    return <div style={{
        "position": "relative",
        "height": "calc(100vh - 220px)",
        "minHeight": "520px",
        "overflow": "hidden",
        "backgroundColor": "#FBFBFA",
        "border": f"1px solid {BORDER}",
        "borderRadius": "14px"
    }}>
        <GraphControls
            {zoom}
            {onZoomIn}
            {onZoomOut}
            {onPan}
            {onReset}
        />
        <svg
            width="100%"
            height="100%"
            viewBox={f"{pan_x} {pan_y} {view_width} {view_height}"}
            aria-label="Inventory relationship graph"
            style={{
                "display": "block",
                "backgroundImage": "radial-gradient(#DADBDD 1px, transparent 1px)",
                "backgroundSize": "18px 18px"
            }}
        >
            {for category in categories {
                category_x = 42 + category_index(category.key) * 190;
                color = CATEGORY_COLORS[category.key];
                is_collapsed = category.key in collapsed;
                <g
                    key={category.key}
                    role="button"
                    aria-label={"Expand " + category.name if is_collapsed else "Collapse " + category.name}
                    onClick={lambda { onToggleCategory(category.key); }}
                    style={{"cursor": "pointer"}}
                >
                    <rect x={category_x} y="38" width="158" height="54" rx="12" fill={color} />
                    <text x={category_x + 14} y="61" fill="#FFFFFF" fontSize="13" fontWeight="750">
                        {category.name}
                    </text>
                    <text x={category_x + 14} y="78" fill="#FFFFFF" fontSize="10" opacity="0.78">
                        {str(len(category.products)) + " models"}
                    </text>
                    <text x={category_x + 140} y="67" fill="#FFFFFF" fontSize="16" textAnchor="middle">
                        {"+" if is_collapsed else "−"}
                    </text>
                </g>
                if not is_collapsed {
                    for (product_i, product) in enumerate(category.products) {
                        product_y = 122 + product_i * 108;
                        available = product.quantity.available > product.quantity.selected;
                        selected = product.key == selected_key;
                        <line
                            key={"line-" + product.key}
                            x1={category_x + 79}
                            y1="92"
                            x2={category_x + 79}
                            y2={product_y}
                            stroke={color}
                            strokeWidth="1.5"
                            opacity="0.28"
                        />
                        <g
                            key={product.key}
                            role="button"
                            aria-label={"Open " + product.name}
                            onClick={lambda { onSelect(product.key); }}
                            style={{"cursor": "pointer"}}
                        >
                            <rect
                                x={category_x}
                                y={product_y}
                                width="158"
                                height="76"
                                rx="10"
                                fill="#FFFFFF"
                                stroke={INDIGO if selected else BORDER}
                                strokeWidth={3 if selected else 1}
                            />
                            <circle
                                cx={category_x + 14}
                                cy={product_y + 17}
                                r="5"
                                fill={GREEN if available else RED}
                            />
                            <text
                                x={category_x + 25}
                                y={product_y + 21}
                                fill={INK}
                                fontSize="11"
                                fontWeight="700"
                            >{short(product.name, 20)}</text>
                            <text x={category_x + 14} y={product_y + 43} fill={MUTED} fontSize="9.5">
                                {"Avail " + str(product.quantity.available) + "  •  Own " + str(product.quantity.owned)}
                            </text>
                            <text x={category_x + 14} y={product_y + 61} fill={color} fontSize="10" fontWeight="700">
                                {money(product.unit_cost)}
                            </text>
                            {if not available {
                                <text
                                    x={category_x + 146}
                                    y={product_y + 61}
                                    textAnchor="end"
                                    fill={RED}
                                    fontSize="9"
                                    fontWeight="700"
                                >DEAD END</text>
                            }}
                        </g>
                    }
                }
            }}
        </svg>
    </div>;
}


def InventoryScreen(
    workspace: WorkspaceView,
    selected_key: str,
    collapsed: list[str],
    zoom: float,
    pan_x: float,
    pan_y: float,
    onSelect: Callable[[str], None],
    onToggleCategory: Callable[[str], None],
    onZoomIn: Callable[[], None],
    onZoomOut: Callable[[], None],
    onPan: Callable[[float, float], None],
    onResetView: Callable[[], None],
    onCreate: Callable[[], None]
) -> JsxElement {
    selected = find_product(workspace.products, selected_key);
    available_count = len([
        product
        for product in workspace.products
        if product.quantity.available > product.quantity.selected
    ]);
    return <main style={{"padding": "22px 24px 30px"}}>
        <div style={{
            "display": "flex",
            "justifyContent": "space-between",
            "alignItems": "flex-end",
            "gap": "18px",
            "marginBottom": "18px"
        }}>
            <div>
                <div style={pill_style("indigo")}>INVENTORY GRAPH</div>
                <h1 style={{"fontSize": "28px", "margin": "10px 0 5px", "letterSpacing": "-0.03em"}}>
                    Build from what is already available.
                </h1>
                <p style={{"margin": "0", "fontSize": "13px", "color": MUTED}}>
                    {str(len(workspace.products)) + " products · " + str(available_count) + " actionable · six engineering subsystems"}
                </p>
            </div>
            <button onClick={lambda { onCreate(); }} style={{**button_style("primary"), "padding": "11px 16px"}}>
                ＋ Create New Project
            </button>
        </div>
        <div style={{
            "display": "grid",
            "gridTemplateColumns": "minmax(0, 1fr) 330px",
            "gap": "16px",
            "alignItems": "start"
        }}>
            <InventoryGraph
                categories={workspace.categories}
                {collapsed}
                {selected_key}
                {zoom}
                {pan_x}
                {pan_y}
                {onSelect}
                {onToggleCategory}
                {onZoomIn}
                {onZoomOut}
                {onPan}
                onReset={onResetView}
            />
            <ProductDrawer {selected} onClose={lambda { onSelect(""); }} />
        </div>
    </main>;
}


def MissionIntake(
    answers: list[str],
    step: int,
    onAnswer: Callable[[int, str], None],
    onQuick: Callable[[int, str], None],
    onRestore: Callable[[int], None],
    onBack: Callable[[], None],
    onNext: Callable[[], None],
    onCancel: Callable[[], None],
    onGenerate: Callable[[], None]
) -> JsxElement {
    phase_names = ["Mission", "Performance", "Operations", "Review"];
    return <main style={{
        "maxWidth": "1050px",
        "margin": "0 auto",
        "padding": "30px 24px 48px"
    }}>
        <div style={{
            "display": "flex",
            "justifyContent": "space-between",
            "alignItems": "flex-start",
            "gap": "18px",
            "marginBottom": "22px"
        }}>
            <div>
                <div style={pill_style("coral")}>MISSION INTAKE</div>
                <h1 style={{"fontSize": "28px", "margin": "10px 0 6px", "letterSpacing": "-0.03em"}}>
                    Tell MEDUSA what success looks like.
                </h1>
                <p style={{"fontSize": "13px", "color": MUTED, "margin": "0", "maxWidth": "650px", "lineHeight": "1.5"}}>
                    Nine scripted answers are pre-filled. Adjust any detail, then review the interpreted mission before generation.
                </p>
            </div>
            <button onClick={lambda { onCancel(); }} style={button_style("ghost")}>Cancel</button>
        </div>
        <div style={{
            **panel_style("12px"),
            "display": "grid",
            "gridTemplateColumns": "repeat(4, 1fr)",
            "gap": "8px",
            "marginBottom": "16px"
        }}>
            {for (phase_i, phase) in enumerate(phase_names) {
                <div key={phase} style={{
                    "padding": "9px 11px",
                    "borderRadius": "9px",
                    "backgroundColor": INDIGO_SOFT if phase_i == step else "transparent",
                    "color": INDIGO if phase_i == step else MUTED,
                    "fontSize": "12px",
                    "fontWeight": "700"
                }}>
                    <span style={{"opacity": "0.7", "marginRight": "6px"}}>{str(phase_i + 1)}</span>
                    {phase}
                </div>
            }}
        </div>
        {if step < 3 {
            <section style={{"display": "grid", "gap": "12px"}}>
                {for question_i in range(step * 3, step * 3 + 3) {
                    <article key={str(question_i)} style={panel_style("18px")}>
                        <div style={{
                            "display": "grid",
                            "gridTemplateColumns": "36px minmax(0, 1fr)",
                            "gap": "12px"
                        }}>
                            <div style={{
                                "width": "30px",
                                "height": "30px",
                                "display": "grid",
                                "placeItems": "center",
                                "borderRadius": "9px",
                                "backgroundColor": INK,
                                "color": "#FFFFFF",
                                "fontSize": "12px",
                                "fontWeight": "750"
                            }}>{str(question_i + 1)}</div>
                            <div>
                                <div style={{
                                    "display": "flex",
                                    "justifyContent": "space-between",
                                    "gap": "12px",
                                    "alignItems": "center"
                                }}>
                                    <h2 style={{"fontSize": "15px", "margin": "0"}}>
                                        {QUESTION_LABELS[question_i]}
                                    </h2>
                                    <button
                                        onClick={lambda { onRestore(question_i); }}
                                        style={{**button_style("ghost"), "padding": "5px 8px", "fontSize": "11px"}}
                                    >Restore scripted</button>
                                </div>
                                <p style={{"fontSize": "11px", "color": MUTED, "margin": "5px 0 9px"}}>
                                    {QUESTION_HINTS[question_i]}
                                </p>
                                <div style={{"display": "flex", "gap": "6px", "flexWrap": "wrap", "marginBottom": "9px"}}>
                                    {for quick in QUICK_OPTIONS[question_i] {
                                        <button
                                            key={quick}
                                            onClick={lambda { onQuick(question_i, quick); }}
                                            style={{
                                                **pill_style("neutral"),
                                                "border": f"1px solid {BORDER}",
                                                "cursor": "pointer"
                                            }}
                                        >{quick}</button>
                                    }}
                                </div>
                                <textarea
                                    aria-label={QUESTION_LABELS[question_i]}
                                    rows={3}
                                    value={answers[question_i]}
                                    onChange={lambda e: ChangeEvent {
                                        onAnswer(question_i, e.target.value);
                                    }}
                                    style={{
                                        "boxSizing": "border-box",
                                        "width": "100%",
                                        "resize": "vertical",
                                        "padding": "11px 12px",
                                        "border": f"1px solid {BORDER}",
                                        "borderRadius": "10px",
                                        "backgroundColor": "#FCFCFB",
                                        "color": INK,
                                        "fontFamily": "inherit",
                                        "fontSize": "13px",
                                        "lineHeight": "1.45",
                                        "outlineColor": INDIGO
                                    }}
                                />
                            </div>
                        </div>
                    </article>
                }}
            </section>
        } else {
            <section style={panel_style("22px")}>
                <div style={{
                    "display": "flex",
                    "justifyContent": "space-between",
                    "alignItems": "center",
                    "marginBottom": "16px"
                }}>
                    <div>
                        <h2 style={{"fontSize": "18px", "margin": "0 0 4px"}}>
                            Review interpreted requirements
                        </h2>
                        <p style={{"fontSize": "12px", "color": MUTED, "margin": "0"}}>
                            MEDUSA will treat each item as mandatory and will only traverse actionable inventory.
                        </p>
                    </div>
                    <span style={pill_style("green")}>9 / 9 COMPLETE</span>
                </div>
                <div style={{
                    "display": "grid",
                    "gridTemplateColumns": "repeat(3, minmax(0, 1fr))",
                    "gap": "10px"
                }}>
                    {for (answer_i, answer) in enumerate(answers) {
                        <article key={str(answer_i)} style={{
                            "padding": "13px",
                            "border": f"1px solid {BORDER}",
                            "borderRadius": "10px",
                            "backgroundColor": "#FAFAF9"
                        }}>
                            <div style={{
                                "fontSize": "10px",
                                "fontWeight": "750",
                                "letterSpacing": "0.05em",
                                "color": INDIGO,
                                "marginBottom": "6px"
                            }}>{"R" + str(answer_i + 1) + " · MANDATORY"}</div>
                            <div style={{"fontSize": "12px", "fontWeight": "700", "marginBottom": "5px"}}>
                                {QUESTION_LABELS[answer_i]}
                            </div>
                            <p style={{"fontSize": "11px", "lineHeight": "1.45", "color": MUTED, "margin": "0"}}>
                                {answer}
                            </p>
                        </article>
                    }}
                </div>
                <div style={{
                    "marginTop": "14px",
                    "padding": "12px 14px",
                    "borderRadius": "10px",
                    "backgroundColor": AMBER_SOFT,
                    "color": AMBER,
                    "fontSize": "12px",
                    "lineHeight": "1.45"
                }}>
                    <strong>AI boundary:</strong>{" "}hard incompatibilities and insufficient quantities are removed before LLM-guided traversal. The final graph is validated deterministically.
                </div>
            </section>
        }}
        <footer style={{
            "display": "flex",
            "justifyContent": "space-between",
            "alignItems": "center",
            "marginTop": "18px"
        }}>
            <button onClick={lambda { onBack(); }} style={button_style("secondary")}>
                {"← Inventory" if step == 0 else "← Back"}
            </button>
            <div style={{"display": "flex", "alignItems": "center", "gap": "10px"}}>
                <span style={{"fontSize": "11px", "color": MUTED}}>
                    {"Step " + str(step + 1) + " of 4"}
                </span>
                {if step < 3 {
                    <button onClick={lambda { onNext(); }} style={button_style("primary")}>
                        Continue →
                    </button>
                } else {
                    <button onClick={lambda { onGenerate(); }} style={{**button_style("indigo"), "padding": "11px 17px"}}>
                        Generate constrained design ✦
                    </button>
                }}
            </div>
        </footer>
    </main>;
}


def DesignGraph(
    nodes: list[DesignNodeView],
    selected_key: str,
    zoom: float,
    pan_x: float,
    pan_y: float,
    onSelect: Callable[[str], None],
    onZoomIn: Callable[[], None],
    onZoomOut: Callable[[], None],
    onPan: Callable[[float, float], None],
    onReset: Callable[[], None]
) -> JsxElement {
    view_width = 1180.0 / zoom;
    view_height = 690.0 / zoom;
    return <div style={{
        "position": "relative",
        "height": "610px",
        "overflow": "hidden",
        "border": f"1px solid {BORDER}",
        "borderRadius": "14px",
        "backgroundColor": "#FBFBFA"
    }}>
        <GraphControls {zoom} {onZoomIn} {onZoomOut} {onPan} {onReset} />
        <svg
            width="100%"
            height="100%"
            viewBox={f"{pan_x} {pan_y} {view_width} {view_height}"}
            aria-label="Mission design graph"
            style={{
                "display": "block",
                "backgroundImage": "radial-gradient(#DADBDD 1px, transparent 1px)",
                "backgroundSize": "18px 18px"
            }}
        >
            {for node in nodes {
                if node.kind == "subsystem" {
                    subsystem_y = 56 + subsystem_index(node.subsystem) * 101;
                    <path
                        key={"mission-edge-" + node.key}
                        d={f"M 202 333 C 240 333, 225 {subsystem_y + 27}, 270 {subsystem_y + 27}"}
                        fill="none"
                        stroke={CATEGORY_COLORS[node.subsystem]}
                        strokeWidth="2"
                        opacity="0.35"
                    />
                } elif node.kind == "product" {
                    product_y = 56 + subsystem_index(node.subsystem) * 101;
                    product_x = 520 + product_rank(nodes, node) * 205;
                    <line
                        key={"product-edge-" + node.key}
                        x1="424"
                        y1={product_y + 27}
                        x2={product_x}
                        y2={product_y + 27}
                        stroke={CATEGORY_COLORS[node.subsystem]}
                        strokeWidth="1.6"
                        opacity="0.36"
                    />
                }
            }}
            <g>
                <rect x="42" y="291" width="160" height="84" rx="16" fill={INK} />
                <text x="59" y="319" fill="#FFFFFF" fontSize="10" fontWeight="750" letterSpacing="1.2">MISSION</text>
                <text x="59" y="341" fill="#FFFFFF" fontSize="12" fontWeight="700">Adverse-weather</text>
                <text x="59" y="357" fill="#FFFFFF" fontSize="12" fontWeight="700">perimeter monitoring</text>
            </g>
            {for node in nodes {
                if node.kind == "subsystem" {
                    subsystem_y = 56 + subsystem_index(node.subsystem) * 101;
                    <g key={node.key}>
                        <rect
                            x="270"
                            y={subsystem_y}
                            width="154"
                            height="54"
                            rx="12"
                            fill={CATEGORY_COLORS[node.subsystem]}
                        />
                        <text x="286" y={subsystem_y + 23} fill="#FFFFFF" fontSize="10" opacity="0.76">
                            {node.subsystem.upper()}
                        </text>
                        <text x="286" y={subsystem_y + 41} fill="#FFFFFF" fontSize="12" fontWeight="750">
                            {short(node.label, 21)}
                        </text>
                    </g>
                } elif node.kind == "product" {
                    product_y = 56 + subsystem_index(node.subsystem) * 101;
                    product_x = 520 + product_rank(nodes, node) * 205;
                    selected = node.product_key == selected_key;
                    status_color = AMBER if node.status == "conditional" else GREEN;
                    <g
                        key={node.key}
                        role="button"
                        aria-label={"Open " + node.label}
                        onClick={lambda { onSelect(node.product_key); }}
                        style={{"cursor": "pointer"}}
                    >
                        <rect
                            x={product_x}
                            y={product_y}
                            width="174"
                            height="54"
                            rx="11"
                            fill="#FFFFFF"
                            stroke={INDIGO if selected else BORDER}
                            strokeWidth={3 if selected else 1}
                        />
                        <rect
                            x={product_x}
                            y={product_y}
                            width="6"
                            height="54"
                            rx="3"
                            fill={CATEGORY_COLORS[node.subsystem]}
                        />
                        <text x={product_x + 18} y={product_y + 23} fill={INK} fontSize="11" fontWeight="700">
                            {short(node.label, 24)}
                        </text>
                        <circle cx={product_x + 21} cy={product_y + 39} r="4" fill={status_color} />
                        <text x={product_x + 31} y={product_y + 43} fill={status_color} fontSize="9" fontWeight="700">
                            {node.status.upper()}
                        </text>
                    </g>
                }
            }}
        </svg>
    </div>;
}


def CompatibilityPanel(
    assessment: CompatibilityAssessmentView,
    onPropose: Callable[[str], None]
) -> JsxElement {
    return <section style={{**panel_style("0"), "overflow": "hidden"}}>
        <div style={{"padding": "18px", "borderBottom": f"1px solid {BORDER}"}}>
            <div style={{
                "display": "flex",
                "justifyContent": "space-between",
                "alignItems": "center",
                "gap": "12px"
            }}>
                <div>
                    <div style={{"fontSize": "10px", "fontWeight": "750", "color": MUTED, "letterSpacing": "0.06em"}}>
                        COMPATIBILITY ASSESSMENT
                    </div>
                    <h2 style={{"fontSize": "16px", "margin": "6px 0 0"}}>Low-light weather decision</h2>
                </div>
                <span style={pill_style("amber")}>● CONDITIONAL</span>
            </div>
        </div>
        <div style={{"padding": "18px"}}>
            <div style={{
                "display": "grid",
                "gridTemplateColumns": "repeat(2, 1fr)",
                "gap": "8px",
                "marginBottom": "13px"
            }}>
                <div style={{"padding": "10px", "backgroundColor": CANVAS, "borderRadius": "9px"}}>
                    <div style={{"fontSize": "10px", "color": MUTED}}>ISSUE DOMAIN</div>
                    <strong style={{"fontSize": "12px"}}>{assessment.issue_domain.upper()}</strong>
                </div>
                <div style={{"padding": "10px", "backgroundColor": CANVAS, "borderRadius": "9px"}}>
                    <div style={{"fontSize": "10px", "color": MUTED}}>EVIDENCE</div>
                    <strong style={{"fontSize": "12px"}}>{assessment.evidence}</strong>
                </div>
            </div>
            <p style={{"fontSize": "12px", "lineHeight": "1.55", "margin": "0 0 10px"}}>
                {assessment.specific_issue}
            </p>
            <p style={{
                "fontSize": "11px",
                "lineHeight": "1.45",
                "color": MUTED,
                "margin": "0 0 18px",
                "paddingLeft": "10px",
                "borderLeft": f"2px solid {BORDER}"
            }}>{assessment.source_note}</p>
            <h3 style={{"fontSize": "12px", "margin": "0 0 9px"}}>Guided resolutions</h3>
            <div style={{"display": "grid", "gap": "7px"}}>
                {for resolution in assessment.suggested_resolutions {
                    <article key={resolution.key} style={{
                        "padding": "11px",
                        "border": f"1px solid {INDIGO if resolution.key == 'thermal-golden' else BORDER}",
                        "borderRadius": "10px",
                        "backgroundColor": INDIGO_SOFT if resolution.key == "thermal-golden" else "#FAFAF9"
                    }}>
                        <div style={{
                            "display": "flex",
                            "justifyContent": "space-between",
                            "alignItems": "flex-start",
                            "gap": "10px"
                        }}>
                            <div>
                                <div style={{"fontSize": "11px", "fontWeight": "750"}}>{resolution.title}</div>
                                <div style={{"fontSize": "10px", "color": MUTED, "marginTop": "3px"}}>
                                    {resolution.kind + " · " + ("in stock" if resolution.available else "unavailable")}
                                </div>
                            </div>
                            {if resolution.key == "thermal-golden" {
                                <button
                                    onClick={lambda { onPropose("valid"); }}
                                    style={{**button_style("indigo"), "padding": "7px 9px", "fontSize": "10px"}}
                                >Use resolution</button>
                            }}
                        </div>
                        <p style={{"fontSize": "10.5px", "lineHeight": "1.4", "margin": "7px 0 0", "color": MUTED}}>
                            {resolution.detail}
                        </p>
                    </article>
                }}
            </div>
        </div>
    </section>;
}


def ProposalPanel(
    proposal: ProposalView,
    gates: list[ApprovalGateView],
    approval_ready: bool,
    onPropose: Callable[[str], None],
    onApprove: Callable[[], None]
) -> JsxElement {
    scenarios = [
        ["valid", "All pass"],
        ["incompatible", "Incompatible"],
        ["quantity", "Quantity"],
        ["budget", "Budget"],
        ["requirement", "Requirement"]
    ];
    return <section style={{"display": "grid", "gap": "12px"}}>
        <article style={panel_style("18px")}>
            <div style={{
                "display": "flex",
                "justifyContent": "space-between",
                "alignItems": "flex-start",
                "gap": "12px"
            }}>
                <div>
                    <div style={pill_style("indigo")}>ACTIVE PROPOSAL</div>
                    <h2 style={{"fontSize": "17px", "margin": "9px 0 4px"}}>Weather-rated thermal revision</h2>
                    <p style={{"fontSize": "11px", "lineHeight": "1.45", "color": MUTED, "margin": "0"}}>
                        {proposal.rationale}
                    </p>
                </div>
                <div style={{"textAlign": "right", "minWidth": "90px"}}>
                    <div style={{"fontSize": "19px", "fontWeight": "800"}}>{money(proposal.projected_cost)}</div>
                    <div style={{"fontSize": "11px", "color": CORAL}}>
                        {"+" + money(proposal.cost_delta)}
                    </div>
                </div>
            </div>
            <div style={{
                "display": "grid",
                "gridTemplateColumns": "1fr 1fr",
                "gap": "9px",
                "marginTop": "14px"
            }}>
                <div style={{"padding": "11px", "backgroundColor": RED_SOFT, "borderRadius": "9px"}}>
                    <div style={{"fontSize": "10px", "fontWeight": "750", "color": RED}}>REMOVED</div>
                    {for key in proposal.removed_product_keys {
                        <div key={key} style={{"fontSize": "10.5px", "marginTop": "5px"}}>{"− " + key}</div>
                    }}
                </div>
                <div style={{"padding": "11px", "backgroundColor": GREEN_SOFT, "borderRadius": "9px"}}>
                    <div style={{"fontSize": "10px", "fontWeight": "750", "color": GREEN}}>ADDED</div>
                    {for key in proposal.added_product_keys {
                        <div key={key} style={{"fontSize": "10.5px", "marginTop": "5px"}}>{"+ " + key}</div>
                    }}
                </div>
            </div>
            <div style={{
                "marginTop": "10px",
                "padding": "12px",
                "border": f"1px solid {BORDER}",
                "borderRadius": "10px",
                "backgroundColor": "#FAFAF9"
            }}>
                <div style={{"fontSize": "10px", "fontWeight": "750", "color": MUTED}}>
                    DOWNSTREAM EXPANSION
                </div>
                <div style={{
                    "display": "grid",
                    "gridTemplateColumns": "repeat(2, minmax(0, 1fr))",
                    "gap": "6px 12px",
                    "marginTop": "8px"
                }}>
                    {for effect in proposal.downstream_effects {
                        <div key={effect.domain} style={{
                            "display": "grid",
                            "gridTemplateColumns": "14px minmax(0, 1fr)",
                            "gap": "5px",
                            "fontSize": "10px",
                            "lineHeight": "1.4",
                            "color": MUTED
                        }}>
                            <span style={{"color": INDIGO, "fontWeight": "800"}}>↳</span>
                            <span>
                                <strong style={{"color": INK}}>{effect.domain + ": "}</strong>
                                {effect.summary}
                            </span>
                        </div>
                    }}
                </div>
            </div>
        </article>
        <article style={panel_style("16px")}>
            <div style={{"fontSize": "11px", "fontWeight": "750", "marginBottom": "8px"}}>
                Gate demonstration lab
            </div>
            <div style={{"display": "flex", "gap": "5px", "flexWrap": "wrap"}}>
                {for scenario in scenarios {
                    <button
                        key={scenario[0]}
                        onClick={lambda { onPropose(scenario[0]); }}
                        style={{
                            **button_style("secondary"),
                            "padding": "7px 9px",
                            "fontSize": "10px"
                        }}
                    >{scenario[1]}</button>
                }}
            </div>
            <p style={{"fontSize": "10px", "color": MUTED, "margin": "8px 0 0"}}>
                Each preset alters only one deterministic gate so the blocking rule is independently visible.
            </p>
        </article>
        <article style={panel_style("16px")}>
            <div style={{
                "display": "flex",
                "justifyContent": "space-between",
                "alignItems": "center",
                "marginBottom": "10px"
            }}>
                <h3 style={{"fontSize": "12px", "margin": "0"}}>Hard approval gates</h3>
                <span style={pill_style("green" if approval_ready else "red")}>
                    {"READY" if approval_ready else "BLOCKED"}
                </span>
            </div>
            <div style={{"display": "grid", "gap": "6px"}}>
                {for gate in gates {
                    <div key={gate.key} style={{
                        "padding": "9px 10px",
                        "borderRadius": "9px",
                        "backgroundColor": GREEN_SOFT if gate.status == "passed" else RED_SOFT,
                        "display": "grid",
                        "gridTemplateColumns": "20px 1fr",
                        "gap": "7px"
                    }}>
                        <span style={{
                            "color": GREEN if gate.status == "passed" else RED,
                            "fontWeight": "800"
                        }}>{"✓" if gate.status == "passed" else "×"}</span>
                        <div>
                            <div style={{"fontSize": "10.5px", "fontWeight": "750"}}>{gate.title}</div>
                            <div style={{"fontSize": "9.5px", "lineHeight": "1.35", "color": MUTED, "marginTop": "2px"}}>
                                {gate.detail}
                            </div>
                        </div>
                    </div>
                }}
            </div>
            <button
                onClick={lambda { onApprove(); }}
                style={{
                    **button_style("indigo" if approval_ready else "danger"),
                    "width": "100%",
                    "marginTop": "11px"
                }}
            >
                {"Approve and create v2" if approval_ready else "Attempt approval (show blocker)"}
            </button>
        </article>
    </section>;
}


def WorkflowView(stages: list[WorkflowStageView]) -> JsxElement {
    return <section style={{"display": "grid", "gap": "9px"}}>
        {for stage in stages {
            <article key={str(stage.number)} style={{
                **panel_style("16px"),
                "display": "grid",
                "gridTemplateColumns": "42px minmax(0, 1fr) 220px",
                "gap": "14px",
                "alignItems": "start"
            }}>
                <div style={{
                    "width": "38px",
                    "height": "38px",
                    "borderRadius": "12px",
                    "display": "grid",
                    "placeItems": "center",
                    "backgroundColor": GREEN_SOFT if stage.status in ["ready", "complete"] else AMBER_SOFT,
                    "color": GREEN if stage.status in ["ready", "complete"] else AMBER,
                    "fontWeight": "800",
                    "fontSize": "13px"
                }}>{str(stage.number)}</div>
                <div>
                    <div style={{"display": "flex", "alignItems": "center", "gap": "8px"}}>
                        <h3 style={{"fontSize": "14px", "margin": "0"}}>{stage.title}</h3>
                        <span style={pill_style(
                            "green" if stage.status in ["ready", "complete"] else "amber"
                        )}>{stage.status.upper()}</span>
                    </div>
                    <p style={{"fontSize": "12px", "lineHeight": "1.45", "color": MUTED, "margin": "7px 0 9px"}}>
                        {stage.detail}
                    </p>
                    <div style={{"display": "flex", "flexWrap": "wrap", "gap": "5px"}}>
                        {for product_key in stage.linked_products {
                            <span key={product_key} style={pill_style("neutral")}>{product_key}</span>
                        }}
                    </div>
                </div>
                <div style={{
                    "padding": "10px",
                    "borderRadius": "10px",
                    "backgroundColor": "#FAFAF9",
                    "minHeight": "42px"
                }}>
                    <div style={{"fontSize": "9px", "fontWeight": "750", "color": MUTED, "marginBottom": "5px"}}>
                        VERIFICATION
                    </div>
                    {if len(stage.verification) == 0 {
                        <div style={{"fontSize": "10.5px", "color": MUTED}}>No additional test.</div>
                    } else {
                        for (task_i, task) in enumerate(stage.verification) {
                            <div key={str(task_i)} style={{
                                "fontSize": "10.5px",
                                "lineHeight": "1.35",
                                "marginBottom": "4px"
                            }}>{"□ " + task}</div>
                        }
                    }}
                </div>
            </article>
        }}
    </section>;
}


def TraceView(steps: list[TraversalStepView]) -> JsxElement {
    return <section style={panel_style("20px")}>
        <div style={{
            "display": "flex",
            "justifyContent": "space-between",
            "alignItems": "center",
            "marginBottom": "14px"
        }}>
            <div>
                <h2 style={{"fontSize": "17px", "margin": "0 0 4px"}}>LLM-guided traversal trace</h2>
                <p style={{"fontSize": "11px", "color": MUTED, "margin": "0"}}>
                    The model could choose only from nodes that survived deterministic quantity and compatibility filtering.
                </p>
            </div>
            <span style={pill_style("indigo")}>{str(len(steps)) + " VISITED"}</span>
        </div>
        {if len(steps) == 0 {
            <div style={{
                "padding": "30px",
                "textAlign": "center",
                "color": MUTED,
                "backgroundColor": CANVAS,
                "borderRadius": "10px"
            }}>
                The trace belongs to version 1. Reset and generate again to replay it.
            </div>
        } else {
            <div style={{"display": "grid", "gridTemplateColumns": "repeat(2, 1fr)", "gap": "8px"}}>
                {for (step_i, trace) in enumerate(steps) {
                    <article key={trace.product_key} style={{
                        "padding": "12px",
                        "border": f"1px solid {BORDER}",
                        "borderRadius": "10px",
                        "display": "grid",
                        "gridTemplateColumns": "28px 1fr",
                        "gap": "9px"
                    }}>
                        <div style={{
                            "width": "26px",
                            "height": "26px",
                            "display": "grid",
                            "placeItems": "center",
                            "borderRadius": "8px",
                            "backgroundColor": INDIGO_SOFT,
                            "color": INDIGO,
                            "fontSize": "10px",
                            "fontWeight": "800"
                        }}>{str(step_i + 1)}</div>
                        <div>
                            <div style={{"fontSize": "11.5px", "fontWeight": "750"}}>{trace.product_name}</div>
                            <p style={{"fontSize": "10.5px", "lineHeight": "1.4", "color": MUTED, "margin": "4px 0 0"}}>
                                {trace.rationale}
                            </p>
                        </div>
                    </article>
                }}
            </div>
        }}
    </section>;
}


def VersionsView(versions: list[VersionView]) -> JsxElement {
    return <section style={{"display": "grid", "gap": "10px"}}>
        {for version in versions {
            <article key={str(version.number)} style={{
                **panel_style("18px"),
                "borderColor": INDIGO if version.status == "active" else BORDER
            }}>
                <div style={{
                    "display": "flex",
                    "justifyContent": "space-between",
                    "gap": "16px",
                    "alignItems": "flex-start"
                }}>
                    <div style={{"display": "flex", "gap": "12px"}}>
                        <div style={{
                            "width": "40px",
                            "height": "40px",
                            "display": "grid",
                            "placeItems": "center",
                            "borderRadius": "12px",
                            "backgroundColor": INDIGO_SOFT if version.status == "active" else CANVAS,
                            "color": INDIGO if version.status == "active" else MUTED,
                            "fontWeight": "800"
                        }}>{"v" + str(version.number)}</div>
                        <div>
                            <div style={{"display": "flex", "gap": "7px", "alignItems": "center"}}>
                                <h3 style={{"fontSize": "14px", "margin": "0"}}>{version.label}</h3>
                                <span style={pill_style("indigo" if version.status == "active" else "neutral")}>
                                    {version.status.upper()}
                                </span>
                            </div>
                            <p style={{"fontSize": "11px", "lineHeight": "1.45", "color": MUTED, "margin": "6px 0 0"}}>
                                {version.summary}
                            </p>
                        </div>
                    </div>
                    <div style={{"textAlign": "right"}}>
                        <div style={{"fontSize": "18px", "fontWeight": "800"}}>{money(version.total_cost)}</div>
                        <div style={{"fontSize": "10px", "color": MUTED}}>
                            {str(len(version.product_keys)) + " selected products"}
                        </div>
                    </div>
                </div>
                <div style={{
                    "display": "grid",
                    "gridTemplateColumns": "1fr 1fr",
                    "gap": "8px",
                    "marginTop": "13px"
                }}>
                    <div style={{"padding": "10px", "borderRadius": "9px", "backgroundColor": GREEN_SOFT}}>
                        <div style={{"fontSize": "9px", "fontWeight": "750", "color": GREEN}}>ADDED IN THIS VERSION</div>
                        <div style={{"display": "flex", "gap": "4px", "flexWrap": "wrap", "marginTop": "6px"}}>
                            {for key in version.added_product_keys {
                                <span key={key} style={{**pill_style("green"), "fontSize": "9px"}}>{key}</span>
                            }}
                        </div>
                    </div>
                    <div style={{"padding": "10px", "borderRadius": "9px", "backgroundColor": RED_SOFT}}>
                        <div style={{"fontSize": "9px", "fontWeight": "750", "color": RED}}>REMOVED IN THIS VERSION</div>
                        {if len(version.removed_product_keys) == 0 {
                            <div style={{"fontSize": "10px", "color": MUTED, "marginTop": "6px"}}>Nothing removed.</div>
                        } else {
                            <div style={{"display": "flex", "gap": "4px", "flexWrap": "wrap", "marginTop": "6px"}}>
                                {for key in version.removed_product_keys {
                                    <span key={key} style={{**pill_style("red"), "fontSize": "9px"}}>{key}</span>
                                }}
                            </div>
                        }}
                    </div>
                </div>
            </article>
        }}
    </section>;
}


def DesignWorkspace(
    workspace: WorkspaceView,
    selected_key: str,
    tab: str,
    zoom: float,
    pan_x: float,
    pan_y: float,
    onTab: Callable[[str], None],
    onSelect: Callable[[str], None],
    onZoomIn: Callable[[], None],
    onZoomOut: Callable[[], None],
    onPan: Callable[[float, float], None],
    onResetView: Callable[[], None],
    onPropose: Callable[[str], None],
    onApprove: Callable[[], None],
    onResetDemo: Callable[[], None]
) -> JsxElement {
    selected = find_product(workspace.products, selected_key);
    assessment: CompatibilityAssessmentView | None = workspace.assessments[0]
        if len(workspace.assessments) > 0
        else None;
    tabs = [
        ["graph", "Design graph"],
        ["workflow", "7-stage workflow"],
        ["decision", "Decision & gates"],
        ["trace", "AI trace"],
        ["versions", "Version history"]
    ];
    return <main style={{"padding": "22px 24px 34px"}}>
        <div style={{
            "display": "flex",
            "justifyContent": "space-between",
            "alignItems": "flex-end",
            "gap": "18px",
            "marginBottom": "17px"
        }}>
            <div>
                <div style={{"display": "flex", "alignItems": "center", "gap": "8px"}}>
                    <span style={pill_style("indigo")}>DESIGN WORKSPACE</span>
                    <span style={pill_style("green")}>{"MAINLINE v" + str(workspace.current_version)}</span>
                    <span style={pill_style("amber" if workspace.current_version == 1 else "green")}>
                        {"1 CONDITIONAL" if workspace.current_version == 1 else "THERMAL PATH VERIFIED"}
                    </span>
                </div>
                <h1 style={{"fontSize": "27px", "margin": "10px 0 5px", "letterSpacing": "-0.03em"}}>
                    Remote adverse-weather perimeter prototype
                </h1>
                <p style={{"fontSize": "12px", "color": MUTED, "margin": "0"}}>
                    {str(len(workspace.selected_product_keys)) + " selected products · " + workspace.generation_mode + " · deterministic validation"}
                </p>
            </div>
            <div style={{"display": "flex", "gap": "8px", "alignItems": "center"}}>
                <div style={{**panel_style("9px 12px"), "textAlign": "right"}}>
                    <div style={{"fontSize": "10px", "color": MUTED}}>PROJECTED / BUDGET</div>
                    <div style={{"fontSize": "15px", "fontWeight": "800"}}>
                        {money(workspace.total_cost) + " / " + money(workspace.budget)}
                    </div>
                </div>
                <button onClick={lambda { onResetDemo(); }} style={button_style("danger")}>↻ Reset demo</button>
            </div>
        </div>
        {if workspace.error != "" {
            <div style={{
                "marginBottom": "12px",
                "padding": "11px 13px",
                "borderRadius": "10px",
                "backgroundColor": RED_SOFT,
                "color": RED,
                "fontSize": "12px",
                "fontWeight": "650"
            }}>{"⚠ " + workspace.error}</div>
        }}
        <nav style={{
            **panel_style("6px"),
            "display": "flex",
            "gap": "4px",
            "marginBottom": "14px",
            "overflowX": "auto"
        }}>
            {for tab_item in tabs {
                <button
                    key={tab_item[0]}
                    onClick={lambda { onTab(tab_item[0]); }}
                    style={{
                        **button_style("ghost"),
                        "backgroundColor": INK if tab == tab_item[0] else "transparent",
                        "color": "#FFFFFF" if tab == tab_item[0] else MUTED,
                        "whiteSpace": "nowrap"
                    }}
                >{tab_item[1]}</button>
            }}
        </nav>
        {if tab == "graph" {
            <div style={{
                "display": "grid",
                "gridTemplateColumns": "minmax(0, 1fr) 330px",
                "gap": "14px",
                "alignItems": "start"
            }}>
                <DesignGraph
                    nodes={workspace.design_nodes}
                    {selected_key}
                    {zoom}
                    {pan_x}
                    {pan_y}
                    {onSelect}
                    {onZoomIn}
                    {onZoomOut}
                    {onPan}
                    onReset={onResetView}
                />
                <div style={{"display": "grid", "gap": "12px"}}>
                    <ProductDrawer {selected} onClose={lambda { onSelect(""); }} />
                    {if assessment is not None and selected_key == "sony-snc-vb632d" {
                        <CompatibilityPanel assessment={assessment} {onPropose} />
                    } elif workspace.current_version == 1 {
                        <div style={{
                            **panel_style("16px"),
                            "fontSize": "11px",
                            "lineHeight": "1.45",
                            "color": MUTED
                        }}>
                            Select the <strong style={{"color": AMBER}}>Sony SNC-VB632D</strong>{" "}node to inspect the unresolved weather decision.
                        </div>
                    }}
                </div>
            </div>
        } elif tab == "workflow" {
            <WorkflowView stages={workspace.workflow} />
        } elif tab == "decision" {
            <div style={{
                "display": "grid",
                "gridTemplateColumns": "minmax(0, 1.2fr) minmax(330px, 0.8fr)",
                "gap": "14px",
                "alignItems": "start"
            }}>
                <div>
                    {if assessment is not None {
                        <CompatibilityPanel assessment={assessment} {onPropose} />
                    } else {
                        <article style={{**panel_style("24px"), "backgroundColor": GREEN_SOFT}}>
                            <span style={pill_style("green")}>APPROVED MAINLINE</span>
                            <h2 style={{"fontSize": "18px", "margin": "10px 0 6px"}}>
                                The weather-rated thermal path is active.
                            </h2>
                            <p style={{"fontSize": "12px", "lineHeight": "1.5", "color": MUTED, "margin": "0"}}>
                                Version 2 retained the before/after record, updated quantities, and carried the thermal tests into the workflow.
                            </p>
                        </article>
                    }}
                </div>
                <div>
                    {if workspace.proposal is not None {
                        <ProposalPanel
                            proposal={workspace.proposal}
                            gates={workspace.gates}
                            approval_ready={workspace.approval_ready}
                            {onPropose}
                            {onApprove}
                        />
                    } else {
                        <article style={panel_style("22px")}>
                            <div style={{"fontSize": "30px", "marginBottom": "8px"}}>
                                {"✓" if workspace.current_version > 1 else "◇"}
                            </div>
                            <h3 style={{"fontSize": "15px", "margin": "0 0 6px"}}>
                                {"No active proposal" if workspace.current_version == 1 else "Proposal merged into v2"}
                            </h3>
                            <p style={{"fontSize": "11px", "lineHeight": "1.45", "color": MUTED, "margin": "0"}}>
                                {"Choose the in-stock thermal resolution to create one." if workspace.current_version == 1 else "Open Version history to compare immutable mainline records."}
                            </p>
                        </article>
                    }}
                </div>
            </div>
        } elif tab == "trace" {
            <TraceView steps={workspace.traversal} />
        } elif tab == "versions" {
            <VersionsView versions={workspace.versions} />
        } else {
            <WorkflowView stages={workspace.workflow} />
        }}
    </main>;
}


def:pub MedusaApp() -> JsxElement {
    has workspace: WorkspaceView | None = None,
        screen: str = "inventory",
        answers: list[str] = list(DEFAULT_ANSWERS),
        intake_step: int = 0,
        selected_key: str = "",
        collapsed_categories: list[str] = [],
        active_tab: str = "graph",
        zoom: float = 1.0,
        pan_x: float = 0.0,
        pan_y: float = 0.0,
        loading: bool = True,
        activity: str = "Loading seeded inventory…";

    async can with entry {
        await load_workspace();
    }

    async def load_workspace -> None {
        loading = True;
        activity = "Loading seeded inventory…";
        result = root spawn LoadWorkspace();
        if len(result.reports) > 0 {
            workspace = result.reports[0];
            selected_key = "";
        }
        loading = False;
    }

    def show_inventory -> None {
        screen = "inventory";
        selected_key = "";
        reset_view();
    }

    def start_intake -> None {
        answers = list(DEFAULT_ANSWERS);
        intake_step = 0;
        screen = "intake";
    }

    def show_design -> None {
        if workspace is not None {
            screen = "design";
            if selected_key == "" and len(workspace.selected_product_keys) > 0 {
                selected_key = workspace.selected_product_keys[0];
            }
        }
    }

    def update_answer(index: int, value: str) -> None {
        answers = [
            value if item_index == index else answer
            for (item_index, answer) in enumerate(answers)
        ];
    }

    def use_quick(index: int, value: str) -> None {
        update_answer(index, value);
    }

    def restore_answer(index: int) -> None {
        update_answer(index, DEFAULT_ANSWERS[index]);
    }

    def intake_back -> None {
        if intake_step == 0 {
            screen = "inventory";
        } else {
            intake_step = intake_step - 1;
        }
    }

    def intake_next -> None {
        intake_step = min(3, intake_step + 1);
    }

    async def generate_project -> None {
        loading = True;
        activity = "Traversing the actionable inventory graph…";
        result = root spawn CreateProject(answers=answers);
        if len(result.reports) > 0 {
            next_workspace = result.reports[0];
            workspace = next_workspace;
            if next_workspace.project_active {
                screen = "design";
                active_tab = "graph";
                selected_key = "sony-snc-vb632d";
                reset_view();
            }
        }
        loading = False;
    }

    async def propose_change(scenario: str) -> None {
        loading = True;
        activity = "Regenerating the affected design region…";
        result = root spawn ProposeChange(
            decision_key="sony-snc-vb632d",
            resolution_key="thermal-golden",
            scenario=scenario
        );
        if len(result.reports) > 0 {
            workspace = result.reports[0];
            active_tab = "decision";
        }
        loading = False;
    }

    async def approve_proposal -> None {
        loading = True;
        activity = "Evaluating four hard approval gates…";
        result = root spawn ApproveProposal();
        if len(result.reports) > 0 {
            next_workspace = result.reports[0];
            workspace = next_workspace;
            if next_workspace.current_version > 1 {
                active_tab = "versions";
                selected_key = "flir-boson-640";
            } else {
                active_tab = "decision";
            }
        }
        loading = False;
    }

    async def reset_demo -> None {
        loading = True;
        activity = "Restoring the untouched seeded workspace…";
        result = root spawn ResetDemo();
        if len(result.reports) > 0 {
            workspace = result.reports[0];
        }
        answers = list(DEFAULT_ANSWERS);
        intake_step = 0;
        active_tab = "graph";
        selected_key = "";
        collapsed_categories = [];
        reset_view();
        screen = "inventory";
        loading = False;
    }

    def select_product(key: str) -> None {
        selected_key = key;
    }

    def toggle_category(key: str) -> None {
        collapsed_categories = [
            category
            for category in collapsed_categories
            if category != key
        ] if key in collapsed_categories else collapsed_categories + [key];
    }

    def zoom_in -> None {
        zoom = min(1.7, zoom + 0.15);
    }

    def zoom_out -> None {
        zoom = max(0.65, zoom - 0.15);
    }

    def pan_graph(dx: float, dy: float) -> None {
        pan_x = pan_x + dx;
        pan_y = pan_y + dy;
    }

    def reset_view -> None {
        zoom = 1.0;
        pan_x = 0.0;
        pan_y = 0.0;
    }

    return <div style={{
        "position": "fixed",
        "inset": "0",
        "overflow": "auto",
        "backgroundColor": CANVAS,
        "color": INK,
        "fontFamily": "Inter, ui-sans-serif, -apple-system, BlinkMacSystemFont, 'Segoe UI', sans-serif"
    }}>
        <header style={{
            "position": "sticky",
            "top": "0",
            "zIndex": "30",
            "height": "58px",
            "display": "flex",
            "alignItems": "center",
            "justifyContent": "space-between",
            "padding": "0 24px",
            "backgroundColor": "rgba(255,255,255,0.94)",
            "backdropFilter": "blur(12px)",
            "borderBottom": f"1px solid {BORDER}"
        }}>
            <div style={{"display": "flex", "alignItems": "center", "gap": "11px"}}>
                <div style={{
                    "width": "32px",
                    "height": "32px",
                    "display": "grid",
                    "placeItems": "center",
                    "borderRadius": "10px",
                    "backgroundColor": INK,
                    "color": "#FFFFFF",
                    "fontWeight": "900",
                    "fontSize": "14px",
                    "letterSpacing": "-0.04em"
                }}>M</div>
                <div>
                    <div style={{"fontSize": "14px", "fontWeight": "850", "letterSpacing": "0.08em"}}>MEDUSA</div>
                    <div style={{"fontSize": "9px", "color": MUTED}}>Graph-native defense prototyping</div>
                </div>
            </div>
            <nav style={{"display": "flex", "alignItems": "center", "gap": "4px"}}>
                <button
                    onClick={show_inventory}
                    style={{
                        **button_style("ghost"),
                        "color": INK if screen == "inventory" else MUTED,
                        "backgroundColor": CANVAS if screen == "inventory" else "transparent"
                    }}
                >Inventory</button>
                {if workspace is not None and workspace.project_active {
                    <button
                        onClick={show_design}
                        style={{
                            **button_style("ghost"),
                            "color": INK if screen == "design" else MUTED,
                            "backgroundColor": CANVAS if screen == "design" else "transparent"
                        }}
                    >Design</button>
                }}
                <span style={{
                    "height": "22px",
                    "width": "1px",
                    "backgroundColor": BORDER,
                    "margin": "0 5px"
                }}></span>
                <span style={pill_style("neutral")}>FICTIONALIZED DEMO</span>
            </nav>
        </header>
        {if workspace is None {
            <main style={{
                "height": "calc(100vh - 59px)",
                "display": "grid",
                "placeItems": "center",
                "color": MUTED
            }}>
                <div style={{"textAlign": "center"}}>
                    <div style={{"fontSize": "32px", "marginBottom": "10px"}}>◎</div>
                    <div>Preparing MEDUSA…</div>
                </div>
            </main>
        } else {
            if screen == "inventory" {
                <InventoryScreen
                    key="inventory-screen"
                    {workspace}
                    {selected_key}
                    collapsed={collapsed_categories}
                    {zoom}
                    {pan_x}
                    {pan_y}
                    onSelect={select_product}
                    onToggleCategory={toggle_category}
                    onZoomIn={zoom_in}
                    onZoomOut={zoom_out}
                    onPan={pan_graph}
                    onResetView={reset_view}
                    onCreate={start_intake}
                />
            } elif screen == "intake" {
                <MissionIntake
                    key="mission-intake"
                    {answers}
                    step={intake_step}
                    onAnswer={update_answer}
                    onQuick={use_quick}
                    onRestore={restore_answer}
                    onBack={intake_back}
                    onNext={intake_next}
                    onCancel={show_inventory}
                    onGenerate={generate_project}
                />
            } else {
                <DesignWorkspace
                    key="design-workspace"
                    {workspace}
                    {selected_key}
                    tab={active_tab}
                    {zoom}
                    {pan_x}
                    {pan_y}
                    onTab={lambda value: str { active_tab = value; }}
                    onSelect={select_product}
                    onZoomIn={zoom_in}
                    onZoomOut={zoom_out}
                    onPan={pan_graph}
                    onResetView={reset_view}
                    onPropose={propose_change}
                    onApprove={approve_proposal}
                    onResetDemo={reset_demo}
                />
            }
        }}
        {if loading {
            <div style={{
                "position": "fixed",
                "inset": "0",
                "zIndex": "80",
                "display": "grid",
                "placeItems": "center",
                "backgroundColor": "rgba(245,245,243,0.76)",
                "backdropFilter": "blur(4px)"
            }}>
                <div style={{
                    **panel_style("22px 26px"),
                    "display": "flex",
                    "alignItems": "center",
                    "gap": "13px",
                    "boxShadow": "0 18px 48px rgba(32,33,36,0.14)"
                }}>
                    <div style={{
                        "width": "28px",
                        "height": "28px",
                        "display": "grid",
                        "placeItems": "center",
                        "borderRadius": "10px",
                        "backgroundColor": INDIGO_SOFT,
                        "color": INDIGO,
                        "fontWeight": "900"
                    }}>✦</div>
                    <div>
                        <div style={{"fontSize": "13px", "fontWeight": "750"}}>{activity}</div>
                        <div style={{"fontSize": "10px", "color": MUTED, "marginTop": "3px"}}>Jac graph state is updating.</div>
                    </div>
                </div>
            </div>
        }}
    </div>;
}
