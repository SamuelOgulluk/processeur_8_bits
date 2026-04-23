transcript on
onerror {quit -code 1}

# Se placer dans le dossier du script.
cd [file dirname [file normalize [info script]]]

# Recréer la librairie de travail.
if {[file exists work]} {vdel -lib work -all}
vlib work
vmap work work

# Compiler dans l'ordre des dépendances.
foreach f {
    ../short_operator/adders.vhd
    ../short_operator/main1.vhd
    ../long_operator/mult.vhd
    ../long_operator/sqrt.vhd
    ../UAL/ual.vhd
    ./proc8bits.vhd
    ./proc8bits_tb.vhd
} {
    vcom -2008 $f
}

# Simuler et tracer les signaux utiles.
vsim work.proc8bits_tb

foreach s {clk reset halted PC_out IR_out A_out B_out R_out Z_out N_out C_out V_out} {
    add wave -radix hexadecimal sim:/proc8bits_tb/$s
}

run 800 ns
wave zoom full
