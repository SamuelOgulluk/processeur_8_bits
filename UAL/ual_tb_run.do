
# # Créer la librairie de travail
vlib work

# Compiler les fichiers VHDL
vcom ../short_operator/adders.vhd
vcom ../short_operator/main1.vhd
vcom ../long_operator/mult.vhd
vcom ../long_operator/sqrt.vhd
vcom ../UAL/ual.vhd
vcom ../UAL/ual_tb.vhd

# Lancer la simulation
vsim work.ual_tb

# Ajouter les signaux à la fenêtre de visualisation
add wave -radix decimal -position end sim:/ual_tb/*

# Démarrer la simulation pour 250 ns
run 250 ns

view wave full
