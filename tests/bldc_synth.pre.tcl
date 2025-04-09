###############################################################################
# bldc_synth.pre.tcl
# Script TCL pour fixer les génériques top-level de bldc_top
###############################################################################

# Exemple : on veut PWM = ~50Hz sous 1MHz => MAX_CPT=20000
# et on veut RAMP_INC_PERIOD=500
# On applique cela à l'ensemble du fichier set actuel (top-level).
# [current_fileset] = sources_1

set_property generic {MAX_CPT=20000 RAMP_INC_PERIOD=500} [current_fileset]

###############################################################################
# Fin du fichier bldc_synth.pre.tcl
###############################################################################
