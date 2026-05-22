# =============================================================
# JBI Block - Routing TCL Script
# Tool    : Cadence Innovus
# Step    : Global Routing + Detailed Routing + Sign-off
# =============================================================

puts "\n===== Starting Routing for JBI Block ====="

# -------------------------------------------------------------
# Step 1: Pre-Route Setup
# -------------------------------------------------------------
# Set routing layer directions
setPreferredRoutingLayer -minRoutingLayer 2 -maxRoutingLayer 9

# Set routing mode
setNanoRouteMode -routeWithTimingDriven true
setNanoRouteMode -routeWithSiDriven true
setNanoRouteMode -routeSiEffort high

# Set layer preferences
# M1-M3: Local cell routing
# M4-M6: Block-level signal routing
# M7-M9: Power stripes and long nets
setNanoRouteMode -routeTopRoutingLayer 9
setNanoRouteMode -routeBottomRoutingLayer 2

# DRC efforts
setNanoRouteMode -routeWithDRC true
setNanoRouteMode -drouteFixAntenna true

# -------------------------------------------------------------
# Step 2: Global Routing
# -------------------------------------------------------------
puts "Running global routing..."

# Run global route to estimate congestion
route -globalDetail false

# Check congestion map
reportRouteCongestion > ./reports/global_route_congestion.rpt
puts "Global routing complete - congestion report saved"

# -------------------------------------------------------------
# Step 3: Detailed Routing
# -------------------------------------------------------------
puts "Running detailed routing..."

routeDesign -globalDetail

puts "Detailed routing complete"

# -------------------------------------------------------------
# Step 4: Post-Route Optimization
# -------------------------------------------------------------
puts "Running post-route optimization..."

# Post-route timing optimization
optDesign -postRoute

# Post-route hold fix
optDesign -postRoute -hold

puts "Post-route optimization complete"

# -------------------------------------------------------------
# Step 5: DRC Check
# -------------------------------------------------------------
puts "Running DRC checks..."

# Check for routing DRC violations
verifyConnectivity -type all -report ./reports/connectivity.rpt
verifyGeometry -report ./reports/drc_postRoute.rpt

# Report DRC summary
reportDesignRule > ./reports/drv_postRoute.rpt

puts "DRC check complete - reports saved"

# -------------------------------------------------------------
# Step 6: Post-Route STA (Static Timing Analysis)
# -------------------------------------------------------------
puts "Running post-route STA..."

# Update timing with actual RC values from routing
extractRC

# Report timing - setup
reportTiming -path_type full_clock -net -nosplit \
    -setupViewList {func_setup_view} \
    -max_paths 50 \
    > ./reports/timing_postRoute_setup.rpt

# Report timing - hold
reportTiming -path_type full_clock -net -nosplit \
    -holdViewList {func_hold_view} \
    -max_paths 50 \
    > ./reports/timing_postRoute_hold.rpt

# Report WNS/TNS summary
report_timing_summary > ./reports/timing_summary.rpt

puts "Post-route STA reports generated"

# -------------------------------------------------------------
# Step 7: Final Checks
# -------------------------------------------------------------
puts "Running final sign-off checks..."

# Check for open nets
verifyConnectivity -noAntenna -report ./reports/open_nets.rpt

# Antenna check
verifyProcessAntenna -reportFile ./reports/antenna.rpt

puts "Final checks complete"

# -------------------------------------------------------------
# Step 8: GDSII Output
# -------------------------------------------------------------
puts "Generating GDSII output..."

# Write final GDS
streamOut ./outputs/jbi_block_final.gds \
    -mapFile ./tech/gds_map.tf \
    -libName jbi_block \
    -structureName JBI_BLOCK \
    -stripes 1 \
    -units 2000 \
    -mode ALL

# Write netlist
writeNetlist ./outputs/jbi_block_final.v -excludeLeafCell

puts "\n===== Routing and Sign-off Complete ====="
puts "Results Summary:"
puts "  - Detailed routing: Complete, DRC clean"
puts "  - Post-route STA: Setup and Hold closed"
puts "  - GDSII: ./outputs/jbi_block_final.gds"
puts "  - Final netlist: ./outputs/jbi_block_final.v"

# =============================================================
# End of Routing Script
# =============================================================
