# JBI Block – Physical Design Project Notes

## Design Overview

| Parameter             | Value                    |
|-----------------------|--------------------------|
| Block Name            | JBI Block                |
| Technology Node       | 14 nm                    |
| Metal Stack           | 9 Metal Layers (M1-M9)   |
| Macros                | 86 hard macros           |
| Standard Cells        | ~38,000                  |
| Target Frequency      | 1 GHz                    |
| Clock Domains         | 1                        |
| EDA Tool              | Cadence Innovus          |
| Timing Signoff        | Synopsys PrimeTime       |

---

## Stage-by-Stage Notes

### Stage 1: Design Import
- Netlist imported successfully with correct hierarchical structure
- MMMC views created: typical_view (TT 0.9V 25C), slow_view (SS 0.81V 125C), fast_view (FF 0.99V -40C)
- Initial timing report showed 0 setup violations in ideal clock mode
- Key files: netlist (.v), technology LEF, cell LEF, .lib files, SDC

### Stage 2: Floorplanning
- Core area defined with 65% utilization target
- Aspect ratio 1.0 (square die) chosen to balance routing in X and Y
- All 86 macros placed based on dataflow analysis:
  - Memory macros placed along top and bottom edges for easy power access
  - Logic macros placed centrally to minimize critical path length
- 2um halos applied around all macros
- IO pins distributed evenly on all 4 sides

**Challenges:**
- Initial macro placement caused high congestion in NW corner
- Resolution: Moved 3 large macros to SW corner and added 5um routing channel

### Stage 3: Power Planning (PDN)
- Core power rings: M9 (horizontal), M8 (vertical), width=4um, spacing=2um
- Power stripes:
  - M8: Horizontal stripes, pitch=20um, width=2um
  - M7: Vertical stripes, pitch=20um, width=2um
- Standard cell rails connected via sroute
- IR Drop Analysis: Max IR drop < 30mV (within 5% of VDD = 0.9V)
- EM check: All power nets pass EM rules

### Stage 4: Placement
- Standard cells placed with timing-driven mode
- Post-placement STA showed:
  - WNS: -0.12 ns (setup violation on critical path)
  - TNS: -0.45 ns
- Fixes applied:
  - Upsized 12 cells on critical path
  - Inserted 6 buffers on high-fanout nets (fanout > 20)
  - Post-fix WNS improved to -0.02 ns
- Congestion: Max routing congestion 72% (acceptable)

### Stage 5: Clock Tree Synthesis (CTS)
- Clock buffer library: BUFFD1/D2/D4/D8BWP14N16P57
- CTS Results:
  - Clock skew achieved: 38 ps (target: <=50 ps)
  - Insertion delay: 420 ps (target: <=500 ps)
  - Number of clock buffers inserted: ~480
- Post-CTS hold violations: 24 paths violated
  - Fixed by inserting hold buffers on all 24 paths
- Post-CTS setup WNS: +0.05 ns (positive slack - setup closed)

### Stage 6: Routing
- Global routing congestion: Max 68% (acceptable, <80% threshold)
- Detailed routing completed without any unrouted nets
- Post-routing DRC:
  - Initial DRC violations: 38
  - After iterative ECO routing fixes: 0 violations (DRC clean)
- Antenna violations: 5 found, fixed by inserting antenna diodes
- Net shielding applied to 4 sensitive analog control nets

### Stage 7: Sign-off
- STA Sign-off (PrimeTime equivalent):
  - Setup (WNS): +0.08 ns (positive)
  - Setup (TNS): 0 ps (fully closed)
  - Hold (WNS): +0.02 ns (positive)
  - Hold (TNS): 0 ps (fully closed)
- DRC Sign-off: CLEAN (0 violations)
- LVS Sign-off: PASS
- GDSII generated successfully

---

## Final Results

| Check              | Result           |
|--------------------|------------------|
| Setup WNS          | +0.08 ns         |
| Setup TNS          | 0 ps             |
| Hold WNS           | +0.02 ns         |
| Hold TNS           | 0 ps             |
| DRC Violations     | 0 (Clean)        |
| LVS Status         | Pass             |
| Utilization        | 65%              |
| Clock Skew         | 38 ps            |
| Insertion Delay    | 420 ps           |
| IR Drop (Max)      | 28 mV            |

---

## Key Learnings

1. **Macro placement is critical** – Poor macro placement at the start caused congestion that required re-floorplanning. Lesson: Always analyze dataflow before placing macros.

2. **IR drop near macro clusters** – Grouped macros create hot spots for IR drop. Fix: Additional M8 power stripes added in high-current regions.

3. **CTS skew vs. hold trade-off** – Tighter skew target helped setup but created more hold violations. Understanding this trade-off is important for 1 GHz designs.

4. **DRC fixing is iterative** – DRC violations require multiple ECO routing iterations. Starting with a clean floorplan significantly reduces post-route DRC count.

5. **Timing closure at 1 GHz requires** – Proper SDC constraints, tight CTS targets, and post-route optimization in that order.

---

## Tools & Commands Reference

### Cadence Innovus Key Commands
```tcl
# Import design
readDesign -def design.def

# Timing analysis
reportTiming -max_paths 20 -path_type full_clock

# Check design
checkDesign -synthesis

# Generate reports
reportPower > power.rpt
reportArea > area.rpt
```

---

*Notes maintained by: Tharshith | ECE Graduate | VLSI Physical Design*
