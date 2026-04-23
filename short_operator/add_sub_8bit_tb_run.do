# Créer la librairie de travail
vlib work

# Compiler les fichiers VHDL
vcom ../short_operator/adders.vhd
vcom ../short_operator/main1.vhd
vcom ../short_operator/add_sub_8bit_tb.vhd

# Lancer la simulation
vsim work.add_sub_8bit_tb

# Ajouter les signaux à la fenêtre de visualisation
add wave -radix hexadecimal -position end sim:/add_sub_8bit_tb/*

run 200 ns

view wave full