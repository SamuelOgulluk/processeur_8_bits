# TP4 437 : UAL, Opérateurs et Processeur 8 bits

## Description
Ce projet implémente un processeur 8 bits et son Unité Arithmétique et Logique (UAL) en VHDL. Il regroupe des opérateurs combinatoires classiques et des opérateurs multi-cycles complexes, pilotés par une machine à états.

## Arborescence
* **`short_operator/`** : Opérateurs combinatoires (addition, soustraction, logique, décalages).
* **`long_operator/`** : Opérateurs multi-cycles gérés par signaux `start`/`done` (multiplication 16 bits, racine carrée).
* **`UAL/`** : Unité de traitement 8 bits. Route les calculs selon le code `OP`, génère les flags (`Z, N, C, V`) et le signal `ready`.
* **`processor/`** : Machine à états (FETCH, DECODE, EXEC) intégrant une ROM d'instructions.

## Opérations et Instructions
L'UAL gère 12 codes d'opération :
* **Combinatoires (`ready` immédiat)** : ADD, SUB, AND, OR, XOR, NOT, SHL, SHR, SAR, ROL.
* **Multi-cycles (`ready` différé)** : MUL, SQRT.

Le processeur exécute le jeu d'instructions suivant :
* `Cxxx` : LDAI (Charge une valeur immédiate dans A)
* `Dxxx` : LDBI (Charge une valeur immédiate dans B)
* `0x0000` à `B000` : Opérations de l'UAL
* `F000` : HALT (Arrêt du processeur)

## Simulation
* Test des opérateurs combinatoires : `short_operator/add_sub_8bit_tb_run.do`
* Test de l'UAL complète : `UAL/ual_tb_run.do`
* Test du processeur : `processor/proc8bits_run.do`
