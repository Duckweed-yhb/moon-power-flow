# moon-power-flow

[中文](./README.md) · English

A pure-MoonBit **three-phase unbalanced distribution-network backward/forward sweep power-flow kernel** for radial distribution systems: per-phase independent loads, branch 3x3 complex impedance matrices (retaining mutual phase impedances), and no balanced-three-phase assumption.

A **single-phase balanced Gauss-Seidel (GS) solver** is kept in the same repository as a comparison baseline, to show what the balanced assumption misses under the same network parameters. The two lines are separate packages with separate tests.

> Scope note: the three-phase side covers "one slack (substation head) + radial tree topology"; it excludes meshed networks and PV nodes. The neutral wire is a first-order approximation only (a uniform or per-edge neutral conductor impedance gives the neutral-point displacement), not a full three-phase four-wire model; ZIP covers only the three static characteristics (constant power / current / impedance). The single-phase side models one Slack plus several PQ nodes (plus a ZIP variant). Planned items are listed under "Planned" and are not claimed as implemented.

## Quick start

Local toolchain: moon 0.1.20261104 (moonc v0.10.20+65efd5b93). Run commands from the repository root; both the default target and explicit targets work.

| Purpose | Command |
|---|---|
| Add to another MoonBit project | `moon add Duckweed/moon-power-flow@0.2.0` |
| Static check (native, warnings as errors) | `moon check --target native --deny-warn` |
| Run tests (native) | `moon test --target native` |
| Static check (wasm-gc) | `moon check --target wasm-gc --deny-warn` |
| Run tests (wasm-gc) | `moon test --target wasm-gc` |
| Three-phase distribution demo (native) | `moon run examples/dist_demo --target native` |
| Single-phase balanced demo (native) | `moon run examples/demo --target native` |

CI (`.github/workflows/ci.yml`) runs `moon fmt --check`, a wasm-gc / js / native matrix of `check --deny-warn` + `build` + `test`, plus native example runs; the wasm target is verified locally only.

## Package layout

```text
moon-power-flow/
├── dist/       Three-phase unbalanced distribution: phasors, 3x3 impedance matrix, radial topology validation, backward/forward sweep, transformer branches, OLTC tap regulation, per-phase switching (open phase)
├── model/      Single-phase balanced model: buses, branches, network; consistency validation and structured errors
├── ybus/       Single-phase nodal complex admittance matrix Ybus assembly
├── solver/     Single-phase GS iteration, convergence criterion, branch complex power flow and losses
├── cases/      Built-in single-phase three-bus case and default convergence parameters
├── examples/demo/        Single-phase GS demo
└── examples/dist_demo/   Three-phase backward/forward sweep demo
```

## Units, base values, and tolerances

- All quantities are per-unit (p.u.). **The two sides do not share a base**: the three-phase `dist` built-in cases use `S_B = 100 kVA` with 230 V base phase voltage (`Z_B = 230²/(100e3/3) ≈ 1.587 Ω`, see the comment in `dist/cases.mbt`), while the single-phase `cases` / `solver` cases use `S_B = 100 MVA`. Cross-side comparison is only meaningful for dimensionless quantities (VUF, power-balance residual); do not compare p.u. numbers across the two sides.
- The library ships **no Ω→p.u. helper**: compute `Z_B = U_ph² / (S_B / 3)` (three-phase, phase-voltage base) yourself and divide the ohmic value by it. A wrong base does not raise an error — it silently drives voltage drop, losses and VUF toward zero, which is the easiest mistake to make and the hardest to notice here.
- Impedance `z = r + jx`, admittance `y = 1/z`; injected power convention `S = P + jQ`.
- Single-phase GS: loads are expressed as negative net injection; nodal current `I_i = conj(S_i) / conj(V_i)`; convergence requires the maximum modulus difference of complex voltages across all PQ nodes in one sweep to stay below threshold.
- Three-phase sweep: loads are entered with "consumed positive"; backward current `I_load = conj(S_load / V)`, forward `V_to = V_from − Z · I_branch`; convergence criterion is the maximum modulus difference of non-root three-phase complex voltages.
- Test tolerances: Ybus entries vs hand calculation `1e-9`; three-phase voltages vs an independent Python sweep `1e-9`; single-phase converged voltage anchors `1e-6`. Floating-point results differ in last digits across backends, so assertions always use tolerances.

## Implemented

### Three-phase unbalanced (`dist/`, main line)

- `Phasor`: a/b/c three-phase complex phasor with per-phase add/subtract, conjugate, per-phase division, and maximum modulus.
- `Z3`: symmetric 3x3 complex impedance matrix (three self impedances + three mutual impedances); matrix times phasor yields the three-phase voltage drop.
- Radial validation (`build_topology`): unique ids, root exists, endpoints exist, edge count = node count − 1, root reaches every node; failures return structured `TopoErr` instead of panicking.
- BFS topological order, parent edge, parent node, and child table; backward sweep uses reverse order and forward sweep uses source-to-leaf order.
- Backward/forward sweep (`sweep`): flat start, three-phase coupled voltage drops, convergence criterion, iteration cap; non-convergence returns `SweepErr::NotConverged`.
- Six built-in cases: four-node unbalanced, four-node balanced (three-phase degenerate check), two-node with mutual impedance, two-node transformer, two-node open-phase, two-node scrambled ids.
- Transformer branch (`TxSpec`): off-nominal ratio `k = V_sec/V_pri` plus leakage impedance 3x3 referred to the secondary. At k=1 the model degenerates to a plain line with the same impedance; forward `V_sec = k·V_pri − Z_t·I_sec`, primary current `I_pri = k·I_sec` for complex-power conservation; loss uses secondary leakage impedance and secondary current. No magnetizing branch, no vector-group phase shift.
- OLTC tap regulation (`dist/oltc.mbt`): integer tap `[tap_min, tap_max]`, per-step ratio change, target voltage magnitude plus deadband; states distinguish in-band / raise / lower / upper limit / lower limit; `run_oltc` closes the loop by repeatedly sweeping, reading the controlled bus a-phase voltage, moving and clamping taps until in-band, hitting a limit, or exhausting moves. Non-transformer controlled edge or missing node returns structured `OltcErr::Control`.
- Per-phase switching / open phase (`Switch`): an open phase carries zero branch current and a dead downstream phase; the other two phases serve loads normally; power balance holds on closed phases only.
- ZIP static loads (shared `model/zip.mbt`): `S(V) = S0·(α + β·|V| + γ·|V|²)`; the three-phase `sweep_zip` scales each phase by its own voltage magnitude, the single-phase `gauss_seidel_zip` scales net injection by node voltage; with α=1 each side matches the constant-power solver.
- Symmetric components and VUF (`dist/unbalance.mbt`): Fortescue decomposition into zero / positive / negative sequence; `VUF = |V2|/|V1| × 100%`. When the positive sequence is near zero (pure negative or zero sequence) it returns 0 instead of inf/NaN; a floating-point residual would otherwise inflate the ratio to 1e17, which has no engineering meaning. `dist_demo` prints VUF at every bus.
- Neutral-point displacement (`dist/neutral.mbt`, first-order four-wire approximation): the neutral conductor shares the topology, and the neutral branch current is the negative of the three-phase current sum. `neutral_voltages` takes a uniform neutral impedance, `neutral_voltages_per_edge` takes a per-edge impedance array; `phase_to_neutral` gives the load-end phase-to-neutral voltage.
- Branch losses and power balance (`dist/loss.mbt`): per-phase `S_p = (Z3·I)_p · conj(I_p)`, mutual phase impedance already included in `(Z3·I)`; `branch_losses` gives per-branch three-phase losses, `total_loss_active` gives network active loss, and `load_demand_active` / `root_injection_active` feed the balance check. The acceptance criterion is conservation, not a reference number: root injection = load demand + losses.

### Single-phase balanced (`model/` + `ybus/` + `solver/`, comparison)

- Bus types Slack / PQ (PV only reserved as an enum value), network validation and structured `NetErr`.
- Ybus assembly: diagonal entries are the sum of connected branch admittances; off-diagonal entries are negated.
- GS iteration, convergence criterion, iteration cap, branch complex power and losses.
- One three-bus case and a GS demo.

## Verified (local run, 2026-11-13)

- `moon test` on wasm / wasm-gc / js / native: **89/89**, consistent across all four backends.
- `moon check --deny-warn` on all four targets: 0 warnings.
- Transformer comparison: k=1 matches a plain line bit-for-bit; k=1.05 raises secondary voltage; larger leakage lowers it; transformer feeder active-power balance holds. OLTC: invalid config rejected, tap-ratio mapping correct, limits clamped, closed loop does not worsen the target. Open phase: open phase current/voltage zero, closed phases normal, balance on closed phases.
- Three-phase demo (`moon run examples/dist_demo --target native`; js also run): the four-node unbalanced case converges in 4 sweeps, `max |dV| ≈ 4.6e-10`; bus 2 three-phase voltages are about `0.9974 pu @ -0.16°`, `0.9991 pu @ -120.05°`, `0.9985 pu @ 119.91°` — the three phases no longer match, exactly what a balanced assumption would erase.
- Independent baseline: the 24 voltage components of the four-node case are computed by `scripts/gen_dist_fixtures.py` (an independent Python backward/forward sweep) and hard-coded in `dist/fixtures_test.mbt`; they are not taken from this library's output.
- Single-phase side: the three-bus GS case converges in 8 sweeps; expected Ybus values are hand-calculated.
- Published: `Duckweed/moon-power-flow@0.2.0` reached mooncakes on 2026-11-10 (Latest 0.2.0, MIT). The 2026-11-11 local 73/73 is a historical record; on 2026-11-13 all four backends were re-run at 89/89 with strict `--deny-warn` checks passing.

## Planned (not implemented this round, not counted as delivered)

- Full three-phase four-wire model (per-phase loads between phase and neutral, neutral modelled segment by segment); only the first-order neutral-point displacement exists today.
- Meshed / weakly meshed networks and multi-root (multi-source) distribution systems.
- Distributed generation (PV-type nodes) and reactive power limits.
- Newton-Raphson and continuation power flow (voltage collapse margin). The GitHub reference `Zcxssxx/gridflow` (not published to mooncakes) covers balanced positive-sequence NR; this project prioritizes the unbalanced distribution gap.
- IEEE 123 / 34 node standard cases, sparse storage, and large-scale networks.

## Validation and failure-path coverage

| Failure case | Returned value | Covered by |
|---|---|---|
| Single-phase: missing Slack | `Err(NoSlack)` | `model/validate_test.mbt` |
| Single-phase: more than one Slack | `Err(MultipleSlack(n))` | `model/validate_test.mbt` |
| Single-phase: duplicate bus id | `Err(DuplicateId(id))` | `model/validate_test.mbt` |
| Single-phase: unknown branch endpoint | `Err(UnknownEndpoint(k, id))` | `model/validate_test.mbt` |
| Single-phase: zero branch impedance | `Err(ZeroImpedance(k))` | `model/validate_test.mbt` |
| Single-phase: GS non-convergence | `Err(NotConverged(iter, dV))` | `solver/solver_test.mbt` |
| Three-phase: root missing | `Err(RootNotFound)` | `dist/dist_test.mbt` |
| Three-phase: duplicate node id | `Err(DuplicateNodeId(id))` | `dist/dist_test.mbt` |
| Three-phase: meshed (edges ≠ n−1) | `Err(NotRadial)` | `dist/dist_test.mbt` |
| Three-phase: disconnected graph | `Err(Disconnected(id))` | `dist/dist_test.mbt` |
| Three-phase: sweep non-convergence | `Err(NotConverged(iter, dV))` | `dist/dist_test.mbt` |

## Known limits and scope

- The three-phase side applies only to radial tree networks; meshed and weakly meshed networks need separate handling and are currently rejected.
- The three-phase side is three-wire: branch coupling is a 3×3 phase impedance matrix; the neutral conductor does not enter the power-flow iteration and appears only as a post-processing neutral-point displacement. ZIP static loads (constant power / current / impedance) are included.
- No sparse storage; dense matrices are used as node count grows, so this is not aimed at large-scale systems.
- The single-phase side targets small networks with mild parameters; high R/X ratios or near-singular cases may fail to converge and return a structured error.
- The complex-number type is a lightweight record defined in this library, covering only the operations needed by the solver; it does not aim for a complete general math library.

## Duplicate-check status (measured 2026-11-09)

- `moon search loadflow`: no module found.
- `moon search power`: hits `SupremeHuaji/MoonElec@0.1.0`, an electrical-engineering formula library (circuits, three-phase power, transformers, motors, signal and control). It is a formula collection with no network topology, Ybus assembly, or iterative power-flow solving, and does not overlap this library.
- Public GitHub repository `Zcxssxx/gridflow` (https://github.com/Zcxssxx/gridflow , Apache-2.0): a MoonBit balanced positive-sequence AC power-flow library using polar-coordinate Newton-Raphson, PQ/PV/slack, a MATPOWER case subset, and PGLib-OPF 14/30/118 bus validation; it has not been published to mooncakes.io (`moon view Zcxssxx/gridflow` returns 404 and `moon search gridflow` has no hit). It targets the **balanced positive-sequence** direction, distinct from this library's three-phase unbalanced main line.
- Difference: this library's main line is **three-phase unbalanced distribution** (per-phase independent loads, 3x3 mutual-coupled impedance, radial backward/forward sweep); gridflow explicitly excludes unbalanced distribution models. The single-phase GS part serves only as a comparison baseline, not the main selling point.

## License

MIT; see `LICENSE`.
