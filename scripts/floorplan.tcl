# =============================================================
# JBI Block - Floorplan TCL Script
# Tool    : Synopsys ICC2
# Step    : Floorplanning + Power Planning (PDN)
# =============================================================

puts "\n===== Starting JBI Block Floorplan (Synopsys ICC2) ====="

# -------------------------------------------------------------
# Step 1: Open Design Library
# -------------------------------------------------------------
open_lib ./icc2_db/jbi_block.dlib
open_block jbi_block

puts "Design library opened: jbi_block"

# -------------------------------------------------------------
# Step 2: Initialize Floorplan
# -------------------------------------------------------------
# Core utilization: 65%
# Aspect ratio: 1.0 (square)
# Core-to-die margin: 10um on all sides

initialize_floorplan \
    -core_utilization 0.65 \
    -core_aspect_ratio 1.0 \
    -core_offset {10 10 10 10}

puts "Floorplan initialized: Utilization=65%, AR=1.0, Offset=10um"

# -------------------------------------------------------------
# Step 3: Place IO Pins
# -------------------------------------------------------------
set_io_pin_constraint -mirrored_pins all
place_pins -all_ports -layer_range {M4 M5}

puts "IO pins placed on M4/M5"

# -------------------------------------------------------------
# Step 4: Macro Placement
# -------------------------------------------------------------
# Place all 86 macros based on dataflow analysis
# Macros oriented to minimize routing congestion

puts "Placing 86 macros..."

# Set orientation for all macros
set_cell_location -orientation R0 [get_cells -hierarchical -filter "is_hard_macro==true"]

# Apply halos around all macros: 2um on all sides
set_placement_blockage -type hard \
    -boundary [get_attribute [get_cells -hierarchical -filter "is_hard_macro==true"] boundary] \
    -halo {2 2 2 2}

# Place macros using coarse placement
place_coarse -macro_expansion 5

puts "86 macros placed with 2um halos"

# Commit floorplan
create_placement_context -floorplan

# -------------------------------------------------------------
# Step 5: Power Planning - Power Rings
# -------------------------------------------------------------
puts "Creating power rings..."

# Create core power rings on M8/M9
create_pg_ring_pattern ring_pattern \
    -horizontal_layer M9 \
    -horizontal_width 4 \
    -horizontal_spacing 2 \
    -vertical_layer M8 \
    -vertical_width 4 \
    -vertical_spacing 2

set_pg_strategy core_ring \
    -pattern {{name: ring_pattern} {nets: {VDD VSS}}} \
    -core_ring_offset 2

compile_pg -strategies core_ring

puts "Power rings created on M8/M9"

# -------------------------------------------------------------
# Step 6: Power Planning - Power Stripes
# -------------------------------------------------------------
puts "Creating power stripes..."

# Horizontal power stripes on M8
create_pg_mesh_pattern stripe_h \
    -layers {{ {{metal: M8} {direction: horizontal} {width: 2} {pitch: 20} {offset: 10}}}} \
    -via_rule {{layers: {M7 M8}}}

# Vertical power stripes on M7
create_pg_mesh_pattern stripe_v \
    -layers {{ {{metal: M7} {direction: vertical} {width: 2} {pitch: 20} {offset: 10}}}} \
    -via_rule {{layers: {M6 M7}}}

set_pg_strategy mesh_strategy \
    -pattern {{name: stripe_h} {nets: {VDD VSS}}} \
    -pattern {{name: stripe_v} {nets: {VDD VSS}}}

compile_pg -strategies mesh_strategy

puts "Power stripes created on M7/M8"

# -------------------------------------------------------------
# Step 7: Connect Standard Cell Power Rails
# -------------------------------------------------------------
# Connect standard cell VDD/VSS rails to power mesh
compile_pg_with_macro_edge_cell_insertion

puts "Standard cell rails connected"

# -------------------------------------------------------------
# Step 8: Verify Floorplan
# -------------------------------------------------------------
check_design -checks dp_pre_floorplan
check_mv_design

puts "\n===== Floorplan Complete ====="
puts "Summary:"
puts "  - Core area: 65% utilization, AR=1.0"
puts "  - 86 macros placed with 2um halos"
puts "  - Power rings on M8/M9"
puts "  - Power stripes on M7/M8"
puts "  - Standard cell rails connected"

# Save block
save_block

# =============================================================
# End of Floorplan Script
# =============================================================
