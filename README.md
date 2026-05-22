# JBI Block – VLSI Physical Design

> **Technology:** 14nm | **Metal Layers:** 9 | **Macros:** 86 | **Standard Cells:** 38,000 | **Clock Frequency:** 1 GHz | **Clock Domains:** 1

---

## Project Overview

This project demonstrates a complete **RTL-to-GDSII Physical Design (PD) flow** for the JBI Block — a complex IP block implemented at the 14nm technology node. The design contains 86 hard macros and approximately 38,000 standard cells, targeting a single-clock-domain architecture at 1 GHz.

The entire PD flow was executed using industry-standard EDA tools and methodologies, covering floorplanning, power delivery network (PDN) design, placement, clock tree synthesis (CTS), routing, and sign-off.

---

## Design Specifications

| Parameter             | Value                    |
|-----------------------|--------------------------|
| Technology Node       | 14 nm                    |
| Metal Layers          | 9 (M1 to M9)             |
| Number of Macros      | 86                       |
| Standard Cell Count   | ~38,000                  |
| Target Clock Frequency| 1 GHz (Period = 1 ns)    |
| Clock Domains         | 1 (Single clock domain)  |
| Design Style          | Block-level PD           |
| Flow Type             | RTL to GDSII             |

---

## Physical Design Flow

### 1. Design Import & Setup
- Read gate-level netlist (.v), technology LEF, cell LEFs, and timing libraries (.lib)
- Load SDC constraints file defining clock period, input/output delays, and design rule constraints
- Set up Multi-Mode Multi-Corner (MMMC) analysis views for setup and hold checks
- Run initial timing check to confirm constraints are correctly loaded

### 2. Floorplanning
- Defined core area with target utilization of ~65%
- Set aspect ratio and die/core boundary
- Placed all 86 macros with proper orientation, spacing, and channel routing considerations
- Applied macro placement guidelines: no macro-to-macro abutment, halo/blockage around macros
- Reserved routing channels between macros for signal and power routing

### 3. Power Planning (PDN)
- Created power rings around the core for VDD and VSS
- Added power stripes/straps across the core on upper metal layers (M7, M8, M9)
- Connected standard cell power rails (VDD/VSS) through via stacks to power stripes
- Ran IR drop analysis and verified power delivery network integrity
- Ensured electromigration (EM) compliance on all power nets

### 4. Placement
- Performed standard cell placement targeting timing and congestion closure
- Applied placement blockages around macros to prevent cell crowding
- Ran trial route and timing analysis post-placement
- Fixed high-fanout nets with buffer insertion
- Checked and resolved DRVs (max transition, max capacitance, max fanout)

### 5. Clock Tree Synthesis (CTS)
- Defined clock tree constraints: target skew and maximum insertion delay
- Built balanced clock tree for the 1 GHz clock
- Inserted clock buffers/inverters to achieve uniform clock distribution
- Verified clock skew and latency post-CTS
- Fixed hold violations introduced after CTS using hold buffer insertion

### 6. Routing
- Performed global routing followed by detailed routing
- Used upper metal layers (M6–M9) for power stripes and long signal nets
- Used lower metal layers (M1–M5) for local cell interconnect
- Fixed all routing DRCs: spacing violations, width violations, via enclosures
- Applied net shielding on sensitive clock nets to reduce crosstalk

### 7. Sign-off
- Ran Static Timing Analysis (STA) across all corners (SS, TT, FF)
- Verified setup and hold timing closure with positive slack
- Performed Design Rule Check (DRC) — all violations resolved
- Ran Layout vs. Schematic (LVS) check for netlist vs. layout verification
- Generated final GDSII output

---

## Repository Structure

```
jbi-block-physical-design/
├── README.md                  # Project documentation
├── constraints/
│   └── jbi_block.sdc          # Synopsys Design Constraints (SDC)
├── scripts/
│   ├── floorplan.tcl          # Floorplan TCL script
│   ├── cts.tcl                # Clock Tree Synthesis TCL script
│   └── routing.tcl            # Routing TCL script
└── docs/
    └── project_notes.md       # Flow notes, results, and observations
```

---

## Tools Used

| Tool                   | Purpose                              |
|------------------------|--------------------------------------|
| Cadence Innovus        | Place & Route (Floorplan to GDSII)   |
| Synopsys PrimeTime     | Static Timing Analysis (Sign-off)    |
| Synopsys IC Compiler   | Synthesis reference                  |
| OpenLane               | Open-source PD flow reference        |

---

## Key Challenges & Solutions

| Challenge                          | Solution Applied                                      |
|------------------------------------|-------------------------------------------------------|
| Macro placement congestion         | Re-placed macros with wider routing channels          |
| Setup timing violations post-CTS   | Cell upsizing and buffer insertion on critical paths  |
| Hold violations after CTS          | Inserted hold buffers on violating paths              |
| IR drop near macro clusters        | Added additional power stripes on M8 layer            |
| Routing congestion in macro corners| Applied local routing blockages and cell spreading    |

---

## Results Summary

| Metric                  | Result                     |
|-------------------------|----------------------------|
| WNS (Worst Negative Slack) | Met (positive slack)    |
| TNS (Total Negative Slack) | 0 ps (fully closed)     |
| Clock Frequency Achieved   | 1 GHz                   |
| Final Utilization          | ~65%                    |
| DRC Violations             | 0 (clean)               |
| LVS Status                 | Pass                    |
| Total Macros               | 86                      |
| Total Standard Cells       | ~38,000                 |

---

## Author

**Tharshith**
ECE Graduate | VLSI Physical Design Engineer
Hyderabad, India

---

## Related Projects

- [ALU Physical Design](https://github.com/Tharshith0103) — ALU block implemented using open-source PD flow
- APEX-86 Block — Physical Design block project (upcoming)

---

*This project was implemented as part of VLSI Physical Design training covering the complete RTL-to-GDSII flow at 14nm technology node.*
