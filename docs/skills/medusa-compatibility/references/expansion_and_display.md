# Downstream expansion and display shapes

## Where to stop expanding

The hardest question in impact expansion is not what to include but when to stop. Unbounded following of graph edges eventually touches everything and produces a proposal nobody can review.

Stop when a hop stops changing something the user or a gate cares about. Concretely, keep expanding while a change alters:

- a **selected product or quantity**,
- a **cost** figure,
- a **compatibility verdict**,
- a **workflow stage's** content (products, issues, rationale, verification work),
- or a **mandatory requirement's** satisfaction.

Stop when the next hop only reaches things none of those touch. A relationship that stays `compatible` with identical cost and quantity is a leaf — record that it was checked, don't expand through it.

This bounds naturally in MEDUSA because the design graph is a fixed three-level hierarchy (mission → subsystem → product), not an arbitrary mesh.

## The golden path's expansion

The scripted demo replaces a low-light camera with an in-stock weather-rated thermal camera. Every one of these must be reachable, because the PRD's acceptance criteria name them:

| Effect | Why it follows |
|---|---|
| **Mount** | Different form factor / mass → different mounting hardware |
| **Enclosure** | Weather rating changes housing requirements |
| **Power** | Thermal sensors draw differently → runtime against the 12h requirement |
| **Compute** | Thermal imagery changes processing load |
| **Communications** | Bandwidth for the new stream against intermittent LTE |
| **Cost** | Budget rollup against $75,000 |
| **Software** | Detection pipeline changes for thermal input |
| **Verification** | New tests in stage 7 for the weather claim |

If any is missing when the swap runs, the seed's relationships are incomplete — that's a data bug, not a UI bug. Behavior group 5 in `tdd` exists to catch it.

## Assessment panel

The inspection panel is where a user judges MEDUSA's reasoning, so verdict and evidence need to be readable at a glance, before any detail:

```
DECISION  Detection sensor -- Low-Light EO Camera (LL-4400)

  VERDICT      Conditional            DOMAIN   Environmental
  EVIDENCE     Verified specification
  SOURCE       LL-4400 datasheet rev C, environmental table

  ISSUE
    Rated IP54 and tested to 30 km/h wind. Mission requires sustained
    rain exposure and winds to 50 km/h. Night performance (0.001 lux)
    meets the 500 m detection requirement.

  RESOLUTIONS (in stock)
    1. Replace with Thermal Camera TC-900W  -- IP67, rated 80 km/h
                                               4 available
    2. Add weatherized enclosure ENC-22     -- 6 available
                                               retains LL-4400

  DOWNSTREAM (option 1)
    Mount · Enclosure · Power · Compute · Comms · Cost +$4,200 · Software
    · Verification (stage 7)
```

Verdict and evidence lead. The issue statement is prose because it has to be specific. Resolutions carry their availability inline — a user should never have to go check whether a suggestion is actually in stock.

## Proposal vs. mainline comparison

The comparison view must show product, quantity, cost, software, power, mounting, communications, and test changes **together** — that's user story 32, and the "together" is the point. A user flipping between tabs to assemble the picture themselves defeats the reveal.

Show before and after side by side, not a delta the reader has to compute:

```
                        MAINLINE v1          PROPOSED v2
  Detection sensor      LL-4400 (x2)         TC-900W (x2)
  Enclosure             ENC-10 (x2)          ENC-22 (x2)
  Mount                 MNT-standard (x2)    MNT-heavy (x2)
  Compute               NX-200               NX-200        (unchanged)
  Project cost          $42,000              $46,200       (+$4,200)
  Budget headroom       $33,000 / 44%        $28,800 / 38%
  Verification tasks    4                    6             (+2)
```

Mark unchanged rows explicitly rather than omitting them. "Compute: unchanged" is information — it tells the reviewer the expansion considered compute and concluded nothing moves, which is different from compute never having been checked.

## Blockers

When no in-stock alternative satisfies the requirement:

```
  RESOLUTIONS
    BLOCKER -- no available inventory satisfies this requirement.

    Nearest in-stock option: TC-400 (IP65, rated 45 km/h) -- still below
    the 50 km/h mission requirement.

    Available paths: relax the wind requirement, or add a verification
    test accepting the risk (moves verdict to conditional).
```

State the gap plainly, name the nearest miss and why it misses, and offer the non-hardware paths that do exist. What this must never do is suggest acquiring something — MEDUSA models no external purchasing.

## Rendering notes

The panel is a Jac client component (`.cl.jac`) — see `medusa-ui` for the Notion-inspired visual language, status colors for the four verdicts, and progressive disclosure. Keep verdict color semantics consistent everywhere a verdict appears; a `conditional` in the panel and a `conditional` on a graph node must read as the same state.
