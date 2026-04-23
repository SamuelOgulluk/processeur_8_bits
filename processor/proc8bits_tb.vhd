library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity proc8bits_tb is
end proc8bits_tb;

architecture sim of proc8bits_tb is
    signal clk    : STD_LOGIC := '0';
    signal reset  : STD_LOGIC := '1';
    signal A_out  : STD_LOGIC_VECTOR(7 downto 0);
    signal B_out  : STD_LOGIC_VECTOR(7 downto 0);
    signal R_out  : STD_LOGIC_VECTOR(7 downto 0);
    signal IR_out : STD_LOGIC_VECTOR(15 downto 0);
    signal PC_out : STD_LOGIC_VECTOR(7 downto 0);
    signal Z_out  : STD_LOGIC; -- Zero flag
    signal N_out  : STD_LOGIC; -- Negative flag
    signal C_out  : STD_LOGIC; -- Carry flag
    signal V_out  : STD_LOGIC; -- Overflow flag
    signal halted : STD_LOGIC;

begin
    DUT: entity work.proc8bits
        port map (
            clk    => clk,
            reset  => reset,
            A_out  => A_out,
            B_out  => B_out,
            R_out  => R_out,
            IR_out => IR_out,
            PC_out => PC_out,
            Z_out  => Z_out,
            N_out  => N_out,
            C_out  => C_out,
            V_out  => V_out,
            halted => halted
        );

    clk <= not clk after 5 ns;

    stim_proc: process
    begin
        reset <= '1';
        wait for 20 ns;
        reset <= '0';

        -- Exécuter le programme jusqu'à l'arrêt.
        wait until halted = '1';
        wait;
    end process;
end sim;
