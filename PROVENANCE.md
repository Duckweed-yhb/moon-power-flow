# Provenance and licensing

This file records where the code, the design references, and the test data of
`moon-power-flow` come from.

## Origin of the source code

All MoonBit source under `dist/`, `model/`, `ybus/`, `solver/`, `cases/`, and
`examples/` was written for this project. No source file was copied from another
project.

## Design references

| Reference | Licence | What was taken |
|---|---|---|
| Public power-system textbooks (backward/forward sweep, nodal impedance, per-unit conventions) | — | The algorithm and the modelling conventions. Implemented independently. |
| `Zcxssxx/gridflow` | Apache-2.0 | Scope comparison only: it is a balanced positive-sequence NR solver and its README excludes unbalanced distribution models. No code, data, or test case copied. |
| `SupremeHuaji/MoonElec` | Apache-2.0 | Scope comparison only: it is a formula collection without network topology or iterative solving. No code copied. |

Neither project's source was read into this repository. The differentiation is
documented in the README's "查重状态" section.

## Test data

- `dist/fixtures_test.mbt` uses expected values produced by
  `scripts/gen_dist_fixtures.py`, an in-house Python script that implements the
  same backward/forward sweep independently of the MoonBit library.
- `dist/closed_form_test.mbt` uses a closed-form solution derived from the
  two-node quadratic equation; the derivation is written in the test file.
- The built-in cases (`dist/cases.mbt`, `cases/case_three_bus.mbt`) are authored
  for this repository. They are not MATPOWER or PGLib data.
- No third-party capture, corpus, or dataset is included.

## AI assistance

AI coding tools were used for package scaffolding, test drafts, and
documentation drafts. The choice of topic (three-phase unbalanced distribution
instead of balanced positive-sequence), the differentiation analysis, the
topology validation rules, and the fixture parameters were done by the author.
AI-generated tests were checked against the textbook formulas before being kept.

## Identity

All commits are authored by `Duckweed-yhb <3071974740@qq.com>`, the same person
who registered the project. No other person's name, account, or identity is used.

## Licence

MIT. See `LICENSE`.
