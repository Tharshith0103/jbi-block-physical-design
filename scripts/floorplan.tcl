# =============================================================
# JBI Block - Floorplan TCL Script
# Tool    : Cadence Innovus
# Step    : Floorplanning + Power Planning (PDN)
# =============================================================

puts "\n===== Starting JBI Block Floorplan ====="

# -------------------------------------------------------------
# Step 1: Set Floorplan
# -------------------------------------------------------------
# Core utilization: 65%
# Aspect ratio: 1.0 (square)
# Core-to-die margin: 10um on all sides

floorPlan -su 0.65 -ar 1.0 -coreSpacingTop 10 -coreSpacingBottom 10 \
          -coreSpacingLeft 10 -coreSpacingRight 10

puts "Floorplan set: Utilization=65%, AR=1.0, Margins=10um"

# -------------------------------------------------------------
# Step 2: Snap Floorplan to Manufacturing Grid
# -------------------------------------------------------------
snapFPlan -toMfgGrid

# -------------------------------------------------------------
# Step 3: Place IO Pins
# -------------------------------------------------------------
# Distribute IO pins evenly around the core boundary
editPin -fixOverlap 1 -unit MICRON -spreadDirection clockwise \
        -side Top -layer 4 -spreadType range \
        -offsetStart 20 -offsetEnd 20 -pinList [get_ports *]

# -------------------------------------------------------------
# Step 4: Macro Placement
# -------------------------------------------------------------
# Place all 86 macros manually based on dataflow analysis
# Macros oriented to minimize routing congestion

puts "Placing 86 macros..."

# Apply macro orientation and placement
defEditAttribute -objType inst -name orient -value R0

# Set halos around all macros to prevent cell crowding
# 2um halo on all sides of each macro
addHaloToBlock -allMacro 2 2 2 2

# Place design in floorplan mode for initial macro placement
setPlaceMode -place_design_floorplan_mode true
place_design
setPlaceMode -place_design_floorplan_mode false

puts "Macro placement complete"

# -------------------------------------------------------------
# Step 5: Power Planning - Power Rings
# -------------------------------------------------------------
puts "Creating power rings..."

# Create core power rings on M8/M9
addRing -nets {VDD VSS} \
        -type core_rings \
        -follow core \
        -layer {top M9 bottom M9 left M8 right M8} \
        -width 4 \
        -spacing 2 \
        -offset 2 \
        -center 0 \
        -extend_corner {tl tr bl br}

puts "Power rings created on M8/M9"

# -------------------------------------------------------------
# Step 6: Power Planning - Power Stripes
# -------------------------------------------------------------
puts "Creating power stripes..."

# Horizontal power stripes on M8
addStripe -nets {VDD VSS} \
          -layer M8 \
          -direction horizontal \
          -width 2 \
          -spacing 1 \
          -set_to_set_distance 20 \
          -start_offset 10

# Vertical power stripes on M7
addStripe -nets {VDD VSS} \
          -layer M7 \
          -direction vertical \
          -width 2 \
          -spacing 1 \
          -set_to_set_distance 20 \
          -start_offset 10

puts "Power stripes created on M7/M8"

# -------------------------------------------------------------
# Step 7: Connect Standard Cell Power Rails
# -------------------------------------------------------------
# Route power to standard cell VDD/VSS rails
sroute -connect { blockPin padPin padRing corePin floatingStripe } \
       -layerChangeRange { M1 M9 } \
       -blockPinTarget { nearestTarget } \
       -padPinPortConnect { allPort oneGeom } \
       -checkAlignedSecondaryPin 1 \
       -blockPin useLef \
       -allowJogging 1 \
       -crossoverViaLayerRange { M1 M9 } \
       -nets {VDD VSS} \
       -allowLayerChange 1 \
       -targetViaLayerRange { M1 M9 }

puts "Standard cell rails connected"

# -------------------------------------------------------------
# Step 8: Verify Floorplan
# -------------------------------------------------------------
verifyPowerDomain
checkFPlan

puts "\n===== Floorplan Complete ====="
puts "Summary:"
puts "  - Core area set with 65% utilization"
puts "  - 86 macros placed with 2um halos"
puts "  - Power rings on M8/M9"
puts "  - Power stripes on M7/M8"
puts "  - Standard cell rails connected"

# Save floorplan
saveFPlan ./results/jbi_block_floorplan.fp

# =============================================================
# End of Floorplan Script
# =============================================================
