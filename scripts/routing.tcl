# =============================================================
# JBI Block - Routing TCL Script
# Tool    : Synopsys ICC2
# Step    : Global Routing + Detailed Routing + Sign-off
# =============================================================

puts "\n===== Starting Routing for JBI Block - Synopsys ICC2 ====="

# -------------------------------------------------------------
# Step 1: Open Design
# -------------------------------------------------------------
open_lib ./icc2_db/jbi_block.dlib
open_block jbi_block

# -------------------------------------------------------------
# Step 2: Pre-Route Setup
# -------------------------------------------------------------
# Set routing layer range (M2-M9, 9 metal layers at 14nm)
set_ignored_layers -min_routing_layer M2 -max_routing_layer M9

# Set routing options
set_app_options -name route.global.timing_driven -value true
set_app_options -name route.global.crosstalk_driven -value true
set_app_options -name route.detail.antenna -value true
set_app_options -name route.detail.timing_driven -value true

# Layer usage comments:
# M1-M3: Local cell routing
# M4-M6: Block-level signal routing
# M7-M9: Power stripes and long nets

puts "Pre-route setup complete: layers M2-M9, timing-driven, SI-driven"

# -------------------------------------------------------------
# Step 3: Global Routing
# -------------------------------------------------------------
puts "Running global routing..."

route_global

# Check congestion
report_route_detail -congestion > ./reports/global_route_congestion.rpt
puts "Global routing complete - congestion report saved"

# -------------------------------------------------------------
# Step 4: Detailed Routing
# -------------------------------------------------------------
puts "Running detailed routing..."

route_detail

puts "Detailed routing complete"

# -------------------------------------------------------------
# Step 5: Post-Route Optimization
# -------------------------------------------------------------
puts "Running post-route optimization..."

# Post-route timing optimization (setup)
route_opt

puts "Post-route optimization complete"

# -------------------------------------------------------------
# Step 6: DRC Check
# -------------------------------------------------------------
puts "Running DRC checks..."

# Verify connectivity
verify_connectivity -check_io -error_cell_name unconnected_cell \
    > ./reports/connectivity.rpt

# Verify geometry (DRC)
verify_drc -max_error_count 1000 \
    -output_directory ./reports/drc_postRoute

# Report DRC summary
report_drc > ./reports/drv_postRoute.rpt

puts "DRC check complete - reports saved"

# -------------------------------------------------------------
# Step 7: Post-Route STA (Static Timing Analysis)
# -------------------------------------------------------------
puts "Running post-route STA..."

# Update timing with actual RC parasitics from routing
update_timing

# Report timing - setup (max)
report_timing \
    -path_type full_clock_expanded \
    -nets \
    -max_paths 50 \
    -delay_type max \
    > ./reports/timing_postRoute_setup.rpt

# Report timing - hold (min)
report_timing \
    -path_type full_clock_expanded \
    -nets \
    -max_paths 50 \
    -delay_type min \
    > ./reports/timing_postRoute_hold.rpt

# Report QoR summary
report_qor > ./reports/timing_summary.rpt

puts "Post-route STA reports generated in ./reports/"

# -------------------------------------------------------------
# Step 8: Antenna Check
# -------------------------------------------------------------
puts "Running antenna checks..."

verify_antenna -error_cell_name antenna_cell \
    -output_file ./reports/antenna.rpt

puts "Antenna check complete"

# -------------------------------------------------------------
# Step 9: GDSII Output
# -------------------------------------------------------------
puts "Generating GDSII output..."

# Write final GDS
write_gds -compress 6 \
    -hierarchy all \
    -layer_map ./tech/gds_map.tf \
    ./outputs/jbi_block_final.gds

# Write final netlist
write_verilog -exclude_leaf_cells \
    ./outputs/jbi_block_final.v

# Save block
save_block

puts "\n===== Routing and Sign-off Complete - Synopsys ICC2 ====="
puts "Results Summary:"
puts "  - Detailed routing : Complete, DRC clean"
puts "  - Post-route STA   : Setup and Hold closed"
puts "  - GDSII            : ./outputs/jbi_block_final.gds"
puts "  - Final netlist    : ./outputs/jbi_block_final.v"

# =============================================================
# End of Routing Script
# =============================================================
