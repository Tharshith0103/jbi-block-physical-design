# =============================================================
# JBI Block - Clock Tree Synthesis (CTS) TCL Script
# Tool    : Cadence Innovus
# Step    : CTS - Build and balance clock tree for 1 GHz clock
# =============================================================

puts "\n===== Starting Clock Tree Synthesis (CTS) ====="

# -------------------------------------------------------------
# Step 1: Set CTS Engine Mode
# -------------------------------------------------------------
setCTSMode -engine ck

# Use routing guides during CTS
setCTSMode -routeGuide true

# -------------------------------------------------------------
# Step 2: Define CTS Specification
# -------------------------------------------------------------
# Target clock skew: <= 50ps
# Target max insertion delay: <= 500ps
# Clock: JBI_CLK (1GHz, 1ns period)

createClockTreeSpec \
    -bufferList {BUFFD1BWP14N16P57 BUFFD2BWP14N16P57 BUFFD4BWP14N16P57 BUFFD8BWP14N16P57} \
    -file ./cts_spec/jbi_block_cts.ctstch

# -------------------------------------------------------------
# Step 3: Configure CTS Constraints
# -------------------------------------------------------------
# Maximum transition on clock tree buffers
setCTSMode -maxBufTran 0.08

# Maximum capacitance on clock tree nets
setCTSMode -maxNetCap 0.15

# Maximum fanout of clock buffers
setCTSMode -maxFanout 10

# Target skew
setCTSMode -targetSkew 0.05

# No inversion in clock tree
setCTSMode -noInverter false

# -------------------------------------------------------------
# Step 4: Pre-CTS Timing Analysis
# -------------------------------------------------------------
puts "Running pre-CTS timing analysis..."

setAnalysisMode -analysisType onChipVariation -cppr both
updateIoLatency -verbose
reportClockTree -postRoute false -localSkew

# -------------------------------------------------------------
# Step 5: Run Clock Tree Synthesis
# -------------------------------------------------------------
puts "Running CTS..."

clock_design

puts "CTS complete"

# -------------------------------------------------------------
# Step 6: Post-CTS Optimization
# -------------------------------------------------------------
puts "Running post-CTS optimization..."

# Perform post-CTS timing optimization
optDesign -postCTS

# Fix hold violations introduced after CTS
optDesign -postCTS -hold

puts "Post-CTS optimization complete"

# -------------------------------------------------------------
# Step 7: Post-CTS Timing Report
# -------------------------------------------------------------
puts "Generating post-CTS timing reports..."

# Report setup timing
reportTiming -path_type full_clock -net -nosplit \
    -setupViewList {func_setup_view} \
    -max_paths 20 \
    > ./reports/timing_postCTS_setup.rpt

# Report hold timing
reportTiming -path_type full_clock -net -nosplit \
    -holdViewList {func_hold_view} \
    -max_paths 20 \
    > ./reports/timing_postCTS_hold.rpt

# Report clock skew
reportClockTree -postRoute false -localSkew \
    > ./reports/cts_skew.rpt

puts "Post-CTS reports generated"

# -------------------------------------------------------------
# Step 8: Verify CTS Results
# -------------------------------------------------------------
checkDesign -synthesis

# Check DRVs after CTS
reportDesignRule > ./reports/drv_postCTS.rpt

puts "\n===== CTS Complete ====="
puts "Target: Skew <= 50ps, Max Insertion Delay <= 500ps"
puts "Reports saved to ./reports/ directory"

# =============================================================
# End of CTS Script
# =============================================================
