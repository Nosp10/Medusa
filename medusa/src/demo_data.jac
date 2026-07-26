"""Curated inventory and the repeatable perimeter-monitoring scenario."""


obj CategorySeed {
    has key: str,
        name: str,
        description: str;
}


obj ProductSeed {
    has key: str,
        name: str,
        category: str,
        summary: str,
        unit_cost: float,
        owned: int,
        available: int,
        specs: list[str],
        relationships: list[str];
}


def category_seeds() -> list[CategorySeed] {
    return [
        CategorySeed(
            key="sensors",
            name="Sensors",
            description="Detection, identification, and perimeter awareness."
        ),
        CategorySeed(
            key="compute",
            name="Compute",
            description="Edge inference, recording, and operator workloads."
        ),
        CategorySeed(
            key="communications",
            name="Communications",
            description="Primary links, resilient backhaul, and radio fallback."
        ),
        CategorySeed(
            key="power",
            name="Power",
            description="Field batteries, charging, conversion, and backup."
        ),
        CategorySeed(
            key="structures",
            name="Structures",
            description="Masts, mounts, enclosures, and field installation."
        ),
        CategorySeed(
            key="support",
            name="Support",
            description="Storage, monitoring, diagnostics, and field service."
        )
    ];
}


def product_seeds() -> list[ProductSeed] {
    return [
        ProductSeed(
            key="sony-snc-vb632d",
            name="Sony SNC-VB632D",
            category="sensors",
            summary="Low-light 1080p camera selected by the initial design.",
            unit_cost=4200.0,
            owned=6,
            available=5,
            specs=[
                "0.03 lux minimum illumination",
                "1080p at 60 fps",
                "PoE+ / 12 VDC",
                "Rain and 50 km/h wind performance unverified"
            ],
            relationships=[
                "Streams H.264 to edge compute",
                "Requires weather enclosure",
                "Requires vibration-qualified mount"
            ]
        ),
        ProductSeed(
            key="flir-boson-640",
            name="Teledyne FLIR Boson 640",
            category="sensors",
            summary="Weather-rated long-wave infrared camera on the golden path.",
            unit_cost=7200.0,
            owned=4,
            available=3,
            specs=[
                "640 × 512 thermal core",
                "IP67 integration enclosure",
                "9–36 VDC input",
                "Operates from −40°C to 80°C"
            ],
            relationships=[
                "USB and MIPI video interfaces",
                "Pairs with PTU-D300E mount",
                "Adds thermal inference profile"
            ]
        ),
        ProductSeed(
            key="axis-q6315-le",
            name="Axis Q6315-LE",
            category="sensors",
            summary="High-performance PTZ camera retained as an honest dead end.",
            unit_cost=5300.0,
            owned=2,
            available=0,
            specs=[
                "1080p PTZ with 31× optical zoom",
                "OptimizedIR illumination",
                "IP66 / NEMA 4X",
                "High PoE"
            ],
            relationships=[
                "Compatible with operator dashboard",
                "Blocked by zero available quantity"
            ]
        ),
        ProductSeed(
            key="echodyne-echoguard",
            name="Echodyne EchoGuard",
            category="sensors",
            summary="Compact electronically scanned perimeter radar.",
            unit_cost=17500.0,
            owned=2,
            available=2,
            specs=[
                "Ground and low-altitude tracking",
                "Electronic scan with no moving antenna",
                "24 VDC nominal",
                "Ethernet track output"
            ],
            relationships=[
                "Cues optical and thermal sensors",
                "Requires mast alignment verification"
            ]
        ),
        ProductSeed(
            key="flir-ranger-hdc",
            name="Teledyne FLIR Ranger HDC MS",
            category="sensors",
            summary="Long-range multispectral surveillance sensor.",
            unit_cost=24800.0,
            owned=1,
            available=1,
            specs=[
                "Cooled MWIR and visible channels",
                "Long-range target recognition",
                "Rugged pan-tilt assembly",
                "48 VDC system input"
            ],
            relationships=[
                "Exceeds portable power preference",
                "Consumes most of project budget"
            ]
        ),
        ProductSeed(
            key="jetson-agx-orin",
            name="NVIDIA Jetson AGX Orin",
            category="compute",
            summary="Primary edge computer for detection and tracking inference.",
            unit_cost=1999.0,
            owned=4,
            available=3,
            specs=[
                "275 TOPS AI performance",
                "15–60 W configurable power",
                "64 GB unified memory",
                "Multiple camera interfaces"
            ],
            relationships=[
                "Runs thermal and visible inference",
                "Publishes tracks to alert gateway"
            ]
        ),
        ProductSeed(
            key="dell-poweredge-xr4000z",
            name="Dell PowerEdge XR4000z",
            category="compute",
            summary="Rugged short-depth server for field aggregation.",
            unit_cost=8500.0,
            owned=2,
            available=2,
            specs=[
                "Ruggedized edge chassis",
                "Wide operating-temperature support",
                "AC power input",
                "Dual 10 GbE"
            ],
            relationships=[
                "Requires inverter or facility power",
                "Hosts central recording services"
            ]
        ),
        ProductSeed(
            key="raspberry-pi-5",
            name="Raspberry Pi 5 8GB",
            category="compute",
            summary="Low-cost control computer for auxiliary services.",
            unit_cost=120.0,
            owned=8,
            available=6,
            specs=[
                "2.4 GHz quad-core CPU",
                "8 GB RAM",
                "5 VDC / 5 A",
                "Dual 4-lane MIPI"
            ],
            relationships=[
                "Runs device-health collector",
                "Not qualified for primary inference"
            ]
        ),
        ProductSeed(
            key="hpe-edgeline-el8000",
            name="HPE Edgeline EL8000",
            category="compute",
            summary="Rugged converged edge system with no available units.",
            unit_cost=12500.0,
            owned=1,
            available=0,
            specs=[
                "Rugged multi-blade chassis",
                "Accelerator support",
                "High peak power demand",
                "Dual hot-swap power"
            ],
            relationships=[
                "Blocked by zero available quantity",
                "Would require generator support"
            ]
        ),
        ProductSeed(
            key="synology-dva3221",
            name="Synology DVA3221",
            category="compute",
            summary="Four-bay video analytics and recording appliance.",
            unit_cost=2500.0,
            owned=2,
            available=2,
            specs=[
                "Up to 32 camera channels",
                "GPU-assisted analytics",
                "Four drive bays",
                "100–240 VAC"
            ],
            relationships=[
                "Records event video",
                "Requires AC inverter and storage drives"
            ]
        ),
        ProductSeed(
            key="peplink-max-br1-pro",
            name="Peplink MAX BR1 Pro 5G",
            category="communications",
            summary="Primary intermittent-LTE field gateway.",
            unit_cost=1399.0,
            owned=3,
            available=3,
            specs=[
                "5G and LTE dual-SIM",
                "Wi-Fi 6",
                "10–30 VDC input",
                "GPIO ignition sense"
            ],
            relationships=[
                "Carries dashboard alerts over LTE",
                "Falls back to mesh radio gateway"
            ]
        ),
        ProductSeed(
            key="rajant-dx2",
            name="Rajant BreadCrumb DX2",
            category="communications",
            summary="Portable mesh-radio node for local fallback.",
            unit_cost=2800.0,
            owned=6,
            available=5,
            specs=[
                "Dual-radio mobile mesh",
                "IP67 enclosure",
                "10–30 VDC input",
                "Ethernet client port"
            ],
            relationships=[
                "Extends around line-of-sight gap",
                "Backhauls to LTE gateway"
            ]
        ),
        ProductSeed(
            key="silvus-sc4200",
            name="Silvus StreamCaster SC4200",
            category="communications",
            summary="High-throughput tactical MIMO radio.",
            unit_cost=5900.0,
            owned=4,
            available=2,
            specs=[
                "4×4 MIMO mesh",
                "Up to 100 Mbps class throughput",
                "Rugged IP68 housing",
                "9–32 VDC"
            ],
            relationships=[
                "Supports high-rate video backhaul",
                "Power draw reduces battery margin"
            ]
        ),
        ProductSeed(
            key="ubiquiti-rocket-prism",
            name="Ubiquiti Rocket Prism 5AC",
            category="communications",
            summary="Directional point-to-point backhaul radio.",
            unit_cost=399.0,
            owned=5,
            available=4,
            specs=[
                "5 GHz airMAX ac",
                "24 V passive PoE",
                "Weather-resistant enclosure",
                "GPS synchronization"
            ],
            relationships=[
                "Requires clear line of sight",
                "Known incompatible with 802.3at PoE directly"
            ]
        ),
        ProductSeed(
            key="iridium-go-exec",
            name="Iridium GO! exec",
            category="communications",
            summary="Satellite fallback terminal retained as an unavailable option.",
            unit_cost=1600.0,
            owned=1,
            available=0,
            specs=[
                "L-band satellite connectivity",
                "Built-in battery",
                "Wi-Fi access point",
                "Low-bandwidth data"
            ],
            relationships=[
                "Blocked by zero available quantity",
                "Insufficient for continuous video"
            ]
        ),
        ProductSeed(
            key="goal-zero-yeti-6000x",
            name="Goal Zero Yeti 6000X",
            category="power",
            summary="High-capacity portable battery with integrated inverter.",
            unit_cost=6000.0,
            owned=3,
            available=2,
            specs=[
                "6071 Wh lithium capacity",
                "2000 W AC inverter",
                "12 V regulated output",
                "Solar charging input"
            ],
            relationships=[
                "Meets twelve-hour system runtime",
                "Accepts solar assistance"
            ]
        ),
        ProductSeed(
            key="ecoflow-delta-pro",
            name="EcoFlow DELTA Pro",
            category="power",
            summary="Portable 3.6 kWh battery and inverter.",
            unit_cost=3699.0,
            owned=5,
            available=4,
            specs=[
                "3600 Wh LFP capacity",
                "3600 W AC output",
                "1600 W solar input",
                "Bluetooth and Wi-Fi telemetry"
            ],
            relationships=[
                "Powers compute and communications",
                "Can parallel with spare battery"
            ]
        ),
        ProductSeed(
            key="battle-born-100ah",
            name="Battle Born 12V 100Ah LiFePO4",
            category="power",
            summary="Modular field battery for low-voltage loads.",
            unit_cost=950.0,
            owned=8,
            available=8,
            specs=[
                "1280 Wh nominal capacity",
                "12 V LiFePO4 chemistry",
                "100 A continuous output",
                "Internal battery management"
            ],
            relationships=[
                "Directly feeds 12 V devices",
                "Requires fused distribution"
            ]
        ),
        ProductSeed(
            key="victron-smartsolar-150-35",
            name="Victron SmartSolar MPPT 150/35",
            category="power",
            summary="Solar charge controller for field battery support.",
            unit_cost=420.0,
            owned=4,
            available=3,
            specs=[
                "150 V PV input",
                "35 A charge current",
                "12/24/48 V battery support",
                "Bluetooth monitoring"
            ],
            relationships=[
                "Connects solar array to battery",
                "Adds commissioning verification"
            ]
        ),
        ProductSeed(
            key="honda-eu2200i",
            name="Honda EU2200i",
            category="power",
            summary="Quiet generator available as a contingency only.",
            unit_cost=1200.0,
            owned=2,
            available=1,
            specs=[
                "2200 W peak output",
                "120 VAC inverter output",
                "3.2-hour rated-load runtime",
                "Fuel-powered"
            ],
            relationships=[
                "Violates battery-only mission preference",
                "May support contingency charging"
            ]
        ),
        ProductSeed(
            key="pelco-es6230",
            name="Pelco Esprit Enhanced ES6230-15",
            category="structures",
            summary="Weather-rated pan-tilt enclosure and mount.",
            unit_cost=2900.0,
            owned=4,
            available=4,
            specs=[
                "IP66 environmental sealing",
                "Pan-tilt positioning",
                "24 VAC / Hi-PoE input",
                "Wind-rated housing"
            ],
            relationships=[
                "Supports visible camera payload",
                "Power interface conditional with 12 V bus"
            ]
        ),
        ProductSeed(
            key="flir-ptu-d300e",
            name="FLIR PTU-D300E",
            category="structures",
            summary="Rugged high-payload pan-tilt unit for the thermal proposal.",
            unit_cost=7500.0,
            owned=3,
            available=2,
            specs=[
                "32 kg payload class",
                "IP66 environmental rating",
                "High wind-load capability",
                "24 VDC control power"
            ],
            relationships=[
                "Qualified for Boson thermal assembly",
                "Requires mount adapter plate"
            ]
        ),
        ProductSeed(
            key="videotec-nxm36",
            name="Videotec NXM36",
            category="structures",
            summary="Stainless-steel camera housing for harsh environments.",
            unit_cost=1400.0,
            owned=5,
            available=4,
            specs=[
                "AISI 316L stainless steel",
                "IP66/IP68 sealing",
                "Integrated heater option",
                "Sunshield included"
            ],
            relationships=[
                "Encloses Boson integration assembly",
                "Adds heater power in cold weather"
            ]
        ),
        ProductSeed(
            key="will-burt-hurry-up",
            name="Will-Burt Hurry-Up 42 ft Mast",
            category="structures",
            summary="Portable telescoping mast for temporary deployment.",
            unit_cost=2200.0,
            owned=3,
            available=3,
            specs=[
                "42 ft extended height",
                "Manual telescoping sections",
                "Guyed field deployment",
                "Portable kit"
            ],
            relationships=[
                "Raises radar and communications",
                "Requires high-wind guy verification"
            ]
        ),
        ProductSeed(
            key="manfrotto-161mk2b",
            name="Manfrotto 161MK2B Tripod",
            category="structures",
            summary="Heavy-duty field tripod for temporary sensor stations.",
            unit_cost=700.0,
            owned=4,
            available=4,
            specs=[
                "20 kg payload",
                "2.67 m maximum height",
                "Geared center column",
                "Aluminum construction"
            ],
            relationships=[
                "Supports low-profile camera station",
                "Not approved for radar wind load"
            ]
        ),
        ProductSeed(
            key="tripp-lite-smart1500",
            name="Tripp Lite SMART1500LCD",
            category="support",
            summary="Line-interactive UPS for recording and operator equipment.",
            unit_cost=450.0,
            owned=4,
            available=3,
            specs=[
                "1500 VA / 900 W",
                "120 VAC",
                "USB monitoring",
                "Automatic voltage regulation"
            ],
            relationships=[
                "Bridges battery source changes",
                "Protects recording appliance"
            ]
        ),
        ProductSeed(
            key="vaisala-wxt536",
            name="Vaisala WXT536",
            category="support",
            summary="Compact weather transmitter for validation evidence.",
            unit_cost=2100.0,
            owned=2,
            available=2,
            specs=[
                "Wind, rain, pressure, temperature, humidity",
                "IP66 housing",
                "RS-485 and SDI-12",
                "5–32 VDC"
            ],
            relationships=[
                "Records mission-condition evidence",
                "Feeds validation dashboard"
            ]
        ),
        ProductSeed(
            key="synology-hat3300-4t",
            name="Synology HAT3300-4T",
            category="support",
            summary="Four-terabyte surveillance recording drive.",
            unit_cost=150.0,
            owned=8,
            available=6,
            specs=[
                "4 TB SATA capacity",
                "5400 rpm",
                "1M-hour MTBF",
                "NAS workload firmware"
            ],
            relationships=[
                "Populates DVA3221 recorder",
                "Stores alert clips and tracks"
            ]
        ),
        ProductSeed(
            key="moxa-iologik-e1214",
            name="Moxa ioLogik E1214",
            category="support",
            summary="Remote I/O module for enclosure and power telemetry.",
            unit_cost=650.0,
            owned=4,
            available=4,
            specs=[
                "Six digital inputs",
                "Six relay outputs",
                "Dual Ethernet ports",
                "−10°C to 60°C operation"
            ],
            relationships=[
                "Monitors enclosure state",
                "Reports battery and tamper alarms"
            ]
        ),
        ProductSeed(
            key="fluke-87v-max",
            name="Fluke 87V MAX",
            category="support",
            summary="Rugged multimeter for field commissioning.",
            unit_cost=620.0,
            owned=3,
            available=3,
            specs=[
                "IP67 environmental rating",
                "CAT IV 600 V safety",
                "True-RMS measurement",
                "−15°C to 55°C operation"
            ],
            relationships=[
                "Verifies voltage drop and grounding",
                "Linked to assembly workflow"
            ]
        )
    ];
}
