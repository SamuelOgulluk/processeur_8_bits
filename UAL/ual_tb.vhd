-- TestBench de toute l'UAL

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ual_tb is
end ual_tb;

architecture sim of ual_tb is
    signal clk    : STD_LOGIC := '0';
    signal reset  : STD_LOGIC := '0';
    signal A      : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal B      : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
    signal OP     : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
    signal RESULT : STD_LOGIC_VECTOR(7 downto 0);
    signal Z      : STD_LOGIC;
    signal N      : STD_LOGIC;
    signal C      : STD_LOGIC;
    signal V      : STD_LOGIC;
    signal ready  : STD_LOGIC;



begin

    UUT: entity work.ual
    port map (
        clk    => clk,
        reset  => reset,
        A      => A,
        B      => B,
        OP     => OP,
        RESULT => RESULT,
        Z      => Z,
        N      => N,
        C      => C,
        V      => V,
        ready  => ready
    );
    clk_process : process
    begin
        while true loop
            clk <= '0';
            wait for 1 ns;
            clk <= '1';
            wait for 1 ns;
        end loop;
    end process;
    stim_proc: process
        variable prod_res : STD_LOGIC_VECTOR(7 downto 0);
    begin
        -- Séquence de reset
        reset <= '1';
        wait for 5 ns;
        reset <= '0';
        wait for 2 ns;

        -- ADD / SUB
        A <= x"14"; B <= x"22"; OP <= "0000"; wait for 2 ns;
        A <= x"20"; B <= x"05"; OP <= "0001"; wait for 2 ns;

        -- AND / OR / XOR / NOT
        A <= x"A5"; B <= x"3C"; OP <= "0010"; wait for 2 ns; -- AND
        A <= x"A5"; B <= x"3C"; OP <= "0011"; wait for 2 ns; -- OR
        A <= x"A5"; B <= x"3C"; OP <= "0100"; wait for 2 ns; -- XOR
        A <= x"A5"; B <= x"3C"; OP <= "0101"; wait for 2 ns; -- NOT

        -- SHL / SHR / SAR / ROL
        A <= x"81"; B <= x"00"; OP <= "0110"; wait for 2 ns;
        A <= x"81"; B <= x"00"; OP <= "0111"; wait for 2 ns;
        A <= x"81"; B <= x"00"; OP <= "1000"; wait for 2 ns;
        A <= x"81"; B <= x"00"; OP <= "1001"; wait for 2 ns;


        OP <= "0000";
        wait until rising_edge(clk);
        A <= x"0A"; B <= x"0A"; OP <= "1010";
        wait until ready = '1';
        wait for 0 ns;
        prod_res := RESULT;
        wait until ready = '0';

        OP <= "0000";
        wait until rising_edge(clk);
        A <= x"0B"; B <= x"0B"; OP <= "1010";
        wait until ready = '1';
        wait for 0 ns;
        prod_res := RESULT;
        wait until ready = '0';


        OP <= "0000";
        wait until rising_edge(clk);
        A <= prod_res;  OP <= "1011";
        wait until ready = '1';
        wait until ready = '0';


        -- SQRT

        OP <= "0000";
        wait until rising_edge(clk);
        A <= x"10"; OP <= "1011";
        wait until ready = '1';
        wait until ready = '0';

        OP <= "0000";
        wait until rising_edge(clk);
        A <= x"FF"; OP <= "1011";
        wait until ready = '1';
        wait until ready = '0';

        -- MUL

        OP <= "0000";
        wait until rising_edge(clk);
        A <= x"20"; B <= x"10"; OP <= "1010";
        wait until ready = '1';
        wait until ready = '0';



        wait;
    end process;
end sim;
