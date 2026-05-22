# =============================================================
# JBI Block - Clock Tree Synthesis (CTS) TCL Script
# Tool    : Synopsys ICC2
# Step    : CTS - Build balanced clock tree for 1 GHz clock
# =============================================================

puts "\n===== Starting Clock Tree Synthesis (CTS) - Synopsys ICC2 ====="

# -------------------------------------------------------------
# Step 1: Open Design
# -------------------------------------------------------------
open_lib ./icc2_db/jbi_block.dlib
open_block jbi_block

# -------------------------------------------------------------
# Step 2: Configure CTS Settings
# -------------------------------------------------------------
# Target skew  : <= 50ps
# Target max insertion delay: <= 500ps
# Clock: JBI_CLK (1 GHz, 1.0 ns period)

# Set clock tree references (buffer cells)
set_lib_cell_purpose -include cts \
    [get_lib_cells */BUFFD*BWP14N16P57]

# Set CTS target skew and latency
set_clock_tree_options \
    -target_skew 0.05 \
    -max_transition 0.08 \
    -max_capacitance 0.15

puts "CTS constraints set: Skew target=50ps, MaxTran=80ps"

# -------------------------------------------------------------
# Step 3: Pre-CTS Optimization (place_opt)
# -------------------------------------------------------------
puts "Running pre-CTS placement optimization..."

place_opt

puts "Pre-CTS place_opt complete"

# -------------------------------------------------------------
# Step 4: Run Clock Tree Synthesis
# -------------------------------------------------------------
puts "Running clock_opt (CTS)..."

# ICC2 clock_opt runs CTS + post-CTS optimization in one step
clock_opt

puts "CTS complete"

# -------------------------------------------------------------
# Step 5: Post-CTS Timing Analysis
# -------------------------------------------------------------
puts "Checking post-CTS timing..."

# Report setup timing
report_timing \
    -path_type full_clock \
    -nets \
    -max_paths 20 \
    -delay_type max \
    > ./reports/timing_postCTS_setup.rpt

# Report hold timing
report_timing \
    -path_type full_clock \
    -nets \
    -max_paths 20 \
    -delay_type min \
    > ./reports/timing_postCTS_hold.rpt

# Report clock tree summary
report_clock_qor > ./reports/clock_qor.rpt

# Report QoR summary
report_qor > ./reports/qor_postCTS.rpt

puts "Post-CTS timing reports generated in ./reports/"

# -------------------------------------------------------------
# Step 6: Post-CTS DRV Check
# -------------------------------------------------------------
check_design -checks pre_route_stage

puts "\n===== CTS Complete ====="
puts "Target: Skew <= 50ps, Max Insertion Delay <= 500ps"
puts "Reports saved to ./reports/ directory"

# Save block
save_block

# =============================================================
# End of CTS Script
# =============================================================
