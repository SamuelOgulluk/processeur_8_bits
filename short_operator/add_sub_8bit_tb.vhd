-- Testbench pour add_sub_8bit
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity add_sub_8bit_tb is
end add_sub_8bit_tb;


-- Testbench architecture de l'additionneur-soustracteur 8 bits
architecture behavior of add_sub_8bit_tb is
    -- Signaux pour l'additionneur-soustracteur
    signal A      : std_logic_vector(7 downto 0) := (others => '0');
    signal B      : std_logic_vector(7 downto 0) := (others => '0');
    signal cmd    : std_logic := '0';
    signal RESULT : std_logic_vector(7 downto 0);
    signal C      : std_logic;
    signal V      : std_logic;

    -- Signaux pour les shifts
    signal A_sh      : std_logic_vector(7 downto 0) := x"A5"; -- 10100101
    signal sel_sh    : std_logic_vector(1 downto 0) := "00";
    signal RESULT_sh : std_logic_vector(7 downto 0);
    
    -- Signaux pour les opérations logiques
    signal A_log     : std_logic_vector(7 downto 0) := x"F0"; -- 11110000
    signal B_log     : std_logic_vector(7 downto 0) := x"0F"; -- 00001111
    signal sel_log   : std_logic_vector(1 downto 0) := "00";
    signal RESULT_log: std_logic_vector(7 downto 0);

begin
    -- Création d'une UAL partielle pour tester les trois composants séparément (ADD/SUB, SHIFTER, LOGIC)
    uut: entity work.add_sub_8bit
        port map (
            A => A,
            B => B,
            cmd => cmd,
            RESULT => RESULT,
            C => C,
            V => V
        );
    shifter_uut: entity work.shifter_8bit
        port map (
            A => A_sh,
            sel => sel_sh,
            RESULT => RESULT_sh
        );
    logic_uut: entity work.logic_op_8bit
        port map (
            A => A_log,
            B => B_log,
            sel => sel_log,
            RESULT => RESULT_log
        );

    
    stim_proc: process
        begin
            -- Test add/sub
            A <= x"12"; B <= x"34"; cmd <= '0'; wait for 10 ns;  -- 18 + 52 = 70
            A <= x"FF"; B <= x"01"; cmd <= '0'; wait for 10 ns;  -- 255 + 1 = 0 (overflow)
            A <= x"56"; B <= x"12"; cmd <= '1'; wait for 10 ns;  -- 86 - 18 = 68
            A <= x"01"; B <= x"17"; cmd <= '1'; wait for 10 ns; -- 1 - 23 = 234 (underflow)

            -- Test shifter avec différentes valeurs
            --Shifts sur A5 (10100101)
            A_sh <= x"A5"; sel_sh <= "00"; wait for 10 ns; -- SHL
            sel_sh <= "01"; wait for 10 ns; -- SHR
            sel_sh <= "10"; wait for 10 ns; -- SAR
            sel_sh <= "11"; wait for 10 ns; -- ROL

            --Shifts sur 3C (00111100)
            A_sh <= x"3C"; sel_sh <= "00"; wait for 10 ns; -- SHL
            sel_sh <= "01"; wait for 10 ns; -- SHR
            sel_sh <= "10"; wait for 10 ns; -- SAR
            sel_sh <= "11"; wait for 10 ns; -- ROL

            -- Test logique avec différentes valeurs
            -- logique sur F0 et 0F
            A_log <= x"F0"; B_log <= x"0F"; sel_log <= "00"; wait for 10 ns; -- AND
            sel_log <= "01"; wait for 10 ns; -- OR
            sel_log <= "10"; wait for 10 ns; -- XOR
            sel_log <= "11"; wait for 10 ns; -- NOT A

            -- logique sur AA et 55

            A_log <= x"AA"; B_log <= x"55"; sel_log <= "00"; wait for 10 ns;
            sel_log <= "01"; wait for 10 ns;
            sel_log <= "10"; wait for 10 ns;
            sel_log <= "11"; wait for 10 ns;
            wait;
        end process;
end behavior;
