# =============================================================
# JBI Block - Synopsys Design Constraints (SDC)
# Technology : 14nm
# Clock Freq : 1 GHz (Period = 1.0 ns)
# Tool       : Cadence Innovus / Synopsys PrimeTime
# =============================================================

set_units -time ns -resistance kOhm -capacitance pF -power mW -voltage V -current mA

# -------------------------------------------------------------
# Clock Definition
# -------------------------------------------------------------
# Primary clock - 1 GHz (1.0 ns period)
create_clock -name JBI_CLK -period 1.0 -waveform {0.0 0.5} [get_ports clk]

# Clock transition constraints
set_clock_transition -rise 0.05 [get_clocks JBI_CLK]
set_clock_transition -fall 0.05 [get_clocks JBI_CLK]

# Clock uncertainty (setup and hold)
set_clock_uncertainty -setup 0.05 [get_clocks JBI_CLK]
set_clock_uncertainty -hold  0.02 [get_clocks JBI_CLK]

# Clock source latency
set_clock_latency -source 0.1 [get_clocks JBI_CLK]

# -------------------------------------------------------------
# Input / Output Delays
# -------------------------------------------------------------
# Input delay: 40% of clock period
set_input_delay -max 0.4 -clock JBI_CLK [all_inputs]
set_input_delay -min 0.1 -clock JBI_CLK [all_inputs]

# Output delay: 40% of clock period
set_output_delay -max 0.4 -clock JBI_CLK [all_outputs]
set_output_delay -min 0.1 -clock JBI_CLK [all_outputs]

# Remove constraints from clock port itself
remove_input_delay [get_ports clk]

# -------------------------------------------------------------
# Driving Cell Constraints
# -------------------------------------------------------------
set_driving_cell -lib_cell BUFFD4BWP14N16P57 -pin Z [all_inputs]
remove_driving_cell [get_ports clk]

# -------------------------------------------------------------
# Load Constraints
# -------------------------------------------------------------
set_load -pin_load 0.02 [all_outputs]

# -------------------------------------------------------------
# Design Rule Constraints
# -------------------------------------------------------------
# Maximum transition time on all nets
set_max_transition 0.15 [current_design]

# Maximum capacitance on all nets
set_max_capacitance 0.2 [current_design]

# Maximum fanout
set_max_fanout 20 [current_design]

# Tighter constraints on clock nets
set_max_transition 0.05 -clock_path [current_design]

# -------------------------------------------------------------
# False Paths
# -------------------------------------------------------------
# False path on asynchronous reset
set_false_path -from [get_ports rst_n]

# False path on test/scan mode
set_false_path -from [get_ports test_mode]

# -------------------------------------------------------------
# Multi-Cycle Paths (if applicable)
# -------------------------------------------------------------
# Example: 2-cycle multicycle path for slow data paths
# set_multicycle_path 2 -setup -from [get_cells U_SLOW_REG*] -to [get_cells U_DST_REG*]
# set_multicycle_path 1 -hold  -from [get_cells U_SLOW_REG*] -to [get_cells U_DST_REG*]

# -------------------------------------------------------------
# Operating Conditions
# -------------------------------------------------------------
# Nominal operating conditions for typical corner
# set_operating_conditions -max WCCOM -min BCCOM

# -------------------------------------------------------------
# End of SDC
# -------------------------------------------------------------
