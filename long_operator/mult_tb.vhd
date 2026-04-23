library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplieur_tb is
end multiplieur_tb;

architecture sim of multiplieur_tb is
    signal clk   : std_logic := '0';
    signal reset : std_logic := '0';
    signal start : std_logic := '0';
    signal a     : std_logic_vector(7 downto 0) := (others => '0');
    signal b     : std_logic_vector(7 downto 0) := (others => '0');
    signal ra    : std_logic_vector(15 downto 0);
    signal done  : std_logic;

begin
    -- Instanciation du multiplieur
    UUT: entity work.multiplieur
        port map (
            clk   => clk,
            reset => reset,
            start => start,
            a     => a,
            b     => b,
            ra    => ra,
            done  => done
        );

    -- Génération de l'horloge
    clk_process : process
    begin
        while true loop
            clk <= '0'; wait for 10 ns;
            clk <= '1'; wait for 10 ns;
        end loop;
    end process;

    -- Stimulus
    stim_proc: process
    begin
        -- Reset
        reset <= '1'; wait for 25 ns;
        reset <= '0'; wait for 20 ns;

        -- Multiplication 0F x 03
        a <= x"0F"; b <= x"03"; start <= '1'; wait for 20 ns;
        start <= '0';
        wait until done = '1';
        wait for 20 ns;

        -- Multiplication 20 x 10
        a <= x"20"; b <= x"10"; start <= '1'; wait for 20 ns;
        start <= '0';
        wait until done = '1';
        wait for 20 ns;

        wait;
    end process;
end sim;
