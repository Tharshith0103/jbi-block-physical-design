# JBI Block – Physical Design Project Notes

## Design Overview

| Parameter             | Value                         |
|-----------------------|-------------------------------|
| Block Name            | JBI Block                     |
| Technology Node       | 14 nm                         |
| Metal Stack           | 9 Metal Layers (M1-M9)        |
| Macros                | 86 hard macros                |
| Standard Cells        | ~38,000                       |
| Target Frequency      | 1 GHz (Period = 1 ns)         |
| Clock Domains         | 1                             |
| Target Utilization    | ~65%                          |
| PnR Tool              | Synopsys ICC2                 |
| Timing Signoff        | Synopsys PrimeTime (PT)       |
| Synthesis Tool        | Synopsys Design Compiler      |
| Parasitic Extraction  | Synopsys StarRC               |

---

## Stage-by-Stage Notes

### Stage 1: Design Import & Setup
- Read gate-level netlist (.v), technology LEF, cell LEFs, and timing libraries (.lib)
- Loaded SDC constraints file: 1 GHz clock (JBI_CLK), I/O delays, DRV constraints
- Configured MMMC views in ICC2:
  - typical_view  : TT 0.9V 25C
  - slow_view     : SS 0.81V 125C
  - fast_view     : FF 0.99V -40C
- Initial timing check showed 0 setup violations in ideal clock mode
- Tool: Synopsys ICC2

### Stage 2: Floorplanning
- Core area defined with 65% utilization target
- Aspect ratio 1.0 (square die) to balance routing in X and Y
- All 86 macros placed based on dataflow analysis:
  - Memory macros placed along top/bottom edges for easy power rail access
  - Logic macros placed centrally to minimize critical path length
- 2um halos applied around all macros using `set_placement_blockage`
- IO pins distributed evenly on all 4 sides
- Tool: Synopsys ICC2

**Challenges:**
- Initial macro placement caused high congestion in NW corner
- Resolution: Moved 3 large macros to SW corner and added 5um routing channel

### Stage 3: Power Planning (PDN)
- Core power rings on M9 (horizontal) and M8 (vertical), width=4um, spacing=2um
- Power stripes:
  - M8: Horizontal stripes, pitch=20um, width=2um
  - M7: Vertical stripes, pitch=20um, width=2um
- Standard cell rails connected via `compile_pg_with_macro_edge_cell_insertion`
- IR Drop Analysis: Max IR drop < 30mV (within 5% of VDD = 0.9V)
- EM check: All power nets pass EM rules at target frequency
- Tool: Synopsys ICC2

### Stage 4: Placement
- Standard cell placement using ICC2 `place_coarse` and `place_opt`
- Post-placement STA showed:
  - WNS: -0.12 ns (setup violation on critical path)
  - TNS: -0.45 ns
- Fixes applied:
  - Upsized 12 cells on critical path
  - Inserted 6 buffers on high-fanout nets (fanout > 20)
  - Post-fix WNS improved to -0.02 ns
- Congestion: Max routing congestion 72% (acceptable)
- Tool: Synopsys ICC2

### Stage 5: Clock Tree Synthesis (CTS)
- CTS performed using ICC2 `clock_opt`
- CTS Results:
  - Clock skew achieved: 38 ps (target: <= 50 ps)
  - Insertion delay: 420 ps (target: <= 500 ps)
  - Clock buffers inserted: ~480
- Post-CTS hold violations: 24 paths
  - Fixed by hold buffer insertion on all 24 paths
- Post-CTS setup WNS: +0.05 ns (positive slack achieved)
- Tool: Synopsys ICC2

### Stage 6: Routing
- Global and detailed routing using ICC2 `route_auto`
- Metal layer usage:
  - M1-M5: Local standard cell interconnect
  - M6-M9: Long signal nets and power stripes
- Post-routing DRC:
  - Initial DRC violations: 38
  - After ECO routing fixes: 0 violations (DRC clean)
- Antenna violations: 5 found, fixed by inserting antenna diodes
- Net shielding applied on 4 sensitive clock nets to reduce crosstalk
- Tool: Synopsys ICC2

### Stage 7: Sign-off
- Parasitic extraction performed using **Synopsys StarRC**
- STA Sign-off using **Synopsys PrimeTime (PT)**:
  - Setup (WNS): +0.08 ns (positive)
  - Setup (TNS): 0 ps (fully closed)
  - Hold (WNS): +0.02 ns (positive)
  - Hold (TNS): 0 ps (fully closed)
- DRC Sign-off: CLEAN (0 violations)
- LVS Sign-off: PASS
- GDSII generated from ICC2

---

## Final Results

| Check                  | Result           |
|------------------------|------------------|
| Setup WNS              | +0.08 ns         |
| Setup TNS              | 0 ps             |
| Hold WNS               | +0.02 ns         |
| Hold TNS               | 0 ps             |
| DRC Violations         | 0 (Clean)        |
| LVS Status             | Pass             |
| Utilization            | ~65%             |
| Clock Skew             | 38 ps            |
| Insertion Delay        | 420 ps           |
| IR Drop (Max)          | 28 mV            |
| Clock Frequency        | 1 GHz            |

---

## Key Learnings

1. **Macro placement is critical** – Poor macro placement caused congestion that required re-floorplanning. Always analyze dataflow before placing macros.

2. **IR drop near macro clusters** – Grouped macros create hot spots. Fix: Additional M8 power stripes added in high-current regions.

3. **CTS skew vs. hold trade-off** – Tighter skew target helped setup but created hold violations. This trade-off is important for 1 GHz designs.

4. **DRC fixing is iterative** – Starting with a clean floorplan significantly reduces post-route DRC count.

5. **Parasitic extraction is critical for sign-off** – StarRC-extracted parasitics used in PrimeTime give accurate sign-off timing vs. estimated RC from routing.

---

## Tools & Commands Reference

### Synopsys ICC2 Key Commands
```tcl
# Initialize design
open_lib ./icc2_db/jbi_block.dlib
open_block jbi_block

# Floorplan
initialize_floorplan -core_utilization 0.65 -aspect_ratio 1.0

# Placement
place_coarse
place_opt

# CTS
clock_opt

# Routing
route_auto

# Timing reports
report_timing -path_type full_clock -nets -max_paths 20
report_qor

# DRC check
check_design -checks dp_pre_route
verify_drc

# Write GDSII
write_gds ./outputs/jbi_block_final.gds
```

### Synopsys PrimeTime Sign-off Commands
```tcl
# Read design
read_db ./icc2_db/jbi_block.dlib
read_sdc ./constraints/jbi_block.sdc

# Read StarRC parasitics
read_parasitics -format SPEF ./outputs/jbi_block.spef

# Timing analysis
update_timing
report_timing -max_paths 50 -path_type full_clock
report_qor
```

---

*Notes maintained by: Tharshith | ECE Graduate | VLSI Physical Design Trainee*
*Implemented as part of VLSI Physical Design Training Program*
