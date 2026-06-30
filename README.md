# UFSS Submersible — Heading & Depth Autopilot Design

**Linear control design for a 6-DOF Unmanned Free-Swimming Submersible (UFSS):** trim, linearization, root-locus, full-state feedback, LQR, and observer-based output feedback in MATLAB/Simulink.

> Graduate course project — *MKT5106 Control of Linear Systems*, Mechatronics Engineering, Yıldız Technical University (2026).

---

## Overview

The UFSS is a slender free-swimming underwater vehicle. This project designs and compares closed-loop controllers for its two primary motion channels, starting from the full nonlinear rigid-body model and ending with optimal state-feedback:

- **Heading (yaw) channel** — rudder deflection `δr → ψ`
- **Depth (pitch) channel** — elevator deflection `δe → θ` (depth is regulated through the pitch loop)

The full 6-DOF dynamics are written in SNAME/Fossen form, linearized about a trim condition, and decoupled into a **longitudinal (pitch/depth)** and a **lateral (yaw/heading)** channel — the same structure used in fixed-wing flight dynamics.

**Design specification:** overshoot `OS ≤ 12%` and settling time `Ts ≤ 3 s` (2% criterion), with zero steady-state error to a step.

---

## Methods

The work is built up in stages, each adding capability:

1. **Modeling & open-loop analysis** — nonlinear 6-DOF model → small-signal linearization about trim → transfer functions and 4th-order state-space `(A, B, C, D)`; controllability and observability verified (full rank). Heading is Type-1 (integrator at the origin); depth is Type-0 with a slow, lightly-damped complex pole pair near the origin.
2. **Reproducing the textbook controller** — the reference rate-feedback design is rebuilt and shown to *fail* the 3 s spec (real `Ts ≈ 6.8 s`), exposing the limits of the second-order approximation.
3. **Root-locus design** — lag-lead compensators with deliberate pole–zero cancellation of the slow plant dynamics; integral action added to the pitch channel for zero steady-state error.
4. **State-space — full-state feedback (pole placement)** — one closed-loop pole is placed *on* the slow plant zero to cancel it, eliminating the large overshoot.
5. **State-space — output feedback with a rate-gyro Luenberger observer** — only position and angular-rate measurements `y = [ψ; ψ̇]` are used; observer poles set ~3× faster than the controller (separation principle).
6. **LQR (optimal control)** — `Q = ρ·CᵀC`, `R = 1`; achieves the same settling time as pole placement with roughly **half the control effort** and lower overshoot, trading off along the speed–effort Pareto front.

---

## Results

| Design | OS (%) | Ts (s) | Steady-state error |
|---|---|---|---|
| Heading — textbook (rate feedback) | 4.3 | 6.78 | 0 |
| Heading — root-locus (lag-lead) | 12.0 | 3.84 | 0 |
| Heading — state-space (full-state feedback) | 11.6 | **2.57** | 0 |
| Heading — observer (output feedback) | 11.6 | 2.58 | 0 |
| Pitch — root-locus (lag-lead + integrator) | 12.5 | 3.99 | 0 |
| Pitch — state-space (full-state feedback) | 11.6 | **2.57** | 0 |
| Pitch — observer (output feedback) | 11.6 | 2.57 | 0 |

The **LQR** design reaches `Ts ≈ 2.44 s` at `OS ≈ 6.1%` using about half the peak control effort of pole placement.

### Key finding

The dominant limit on real settling time is the **slow plant zero** (≈ −0.437): placing a "fast" dominant pair is not enough, because a slow closed-loop pole with large residue dominates the actual response. The second-order approximation (`Ts ≈ 4/ζωₙ`) is misleading here. Cancelling that slow mode — via compensator pole–zero cancellation (root-locus) or by placing a closed-loop pole on the zero (state-space) — is what brings overshoot and settling under control.

---

## Repository structure

```
.
├── README.md
├── LICENSE
├── src/
│   ├── ufss_model.m            % plant TFs, state-space, open-loop analysis
│   ├── ufss_rootlocus.m        % lag-lead root-locus designs (heading + pitch)
│   ├── ufss_statespace.m       % pole placement + Luenberger observer
│   ├── ufss_lqr.m              % LQR optimal full-state feedback
│   ├── ufss_build_simulink.m   % programmatic Simulink model builder
│   └── ufss_compare.m          % generates all comparison plots and metrics
├── figures/                    % step/impulse responses, root loci, pole maps, control effort
└── docs/
    └── UFSS_Report.pdf         % full project report
```

> Rename the scripts above to match your actual `.m` files.

---

## How to run

**Requirements:** MATLAB R2021b or newer with the **Control System Toolbox** (uses `tf`, `ss`, `place`, `lqr`, `feedback`, `rlocus`, `stepinfo`). Simulink is optional, only for the block-diagram model.

```matlab
% from the repository root
cd src
ufss_model        % build plant + state-space, run open-loop analysis
ufss_rootlocus    % root-locus (lag-lead) designs
ufss_statespace   % pole placement + observer
ufss_lqr          % LQR design
ufss_compare      % reproduce all comparison figures and the results table
```

To build and simulate the closed-loop model in Simulink:

```matlab
ufss_build_simulink('heading')   % or 'pitch'
```

---

## Attribution

The UFSS plant transfer functions and the baseline controller problem are taken from N. S. Nise, *Control Systems Engineering* (UFSS case study). All modeling choices, controller designs (root-locus, pole placement, observer, LQR), simulations, and analysis in this repository are my own work.

---

## Author

**Mustafa Altuntaş** — Mechatronics Engineer (M.Sc., Yıldız Technical University)
GitHub: [github.com/r9xdty](https://github.com/r9xdty) · LinkedIn: [mustafa-altuntas1](https://linkedin.com/in/mustafa-altuntas1)
