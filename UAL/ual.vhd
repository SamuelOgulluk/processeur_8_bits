library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity ual is
	Port (
		clk    : in  STD_LOGIC;
		reset  : in  STD_LOGIC;
		A      : in  STD_LOGIC_VECTOR(7 downto 0);
		B      : in  STD_LOGIC_VECTOR(7 downto 0);
		OP     : in  STD_LOGIC_VECTOR(3 downto 0);
		RESULT : out STD_LOGIC_VECTOR(7 downto 0);
		Z      : out STD_LOGIC;
		N      : out STD_LOGIC;
		C      : out STD_LOGIC;
		V      : out STD_LOGIC;
		ready  : out STD_LOGIC
	);
end ual;


architecture structural of ual is
	-- Sous-blocs de l'UAL (combinatoires + multi-cycle)

	signal add_sub_cmd : STD_LOGIC;
	signal add_sub_res : STD_LOGIC_VECTOR(7 downto 0);
	signal add_sub_c   : STD_LOGIC;
	signal add_sub_v   : STD_LOGIC;

	signal logic_sel : STD_LOGIC_VECTOR(1 downto 0);
	signal logic_res : STD_LOGIC_VECTOR(7 downto 0);

	signal shift_sel : STD_LOGIC_VECTOR(1 downto 0);
	signal shift_res : STD_LOGIC_VECTOR(7 downto 0);

	signal mul_ra   : STD_LOGIC_VECTOR(15 downto 0);
	signal mul_done : STD_LOGIC;
	signal mul_start : STD_LOGIC := '0';
	signal prev_op  : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
	signal sqrt_res : STD_LOGIC_VECTOR(7 downto 0);
	signal sqrt_done : STD_LOGIC;
	signal sqrt_start : STD_LOGIC := '0';
	signal sqrt_x    : STD_LOGIC_VECTOR(15 downto 0);

	signal result_i : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
	signal c_i      : STD_LOGIC := '0';
	signal v_i      : STD_LOGIC := '0';
begin
	-- Addition/Soustraction via add_sub_8bit (cmd=0: ADD, cmd=1: SUB)
	U_ADD_SUB: entity work.add_sub_8bit
		port map (
			A      => A,
			B      => B,
			cmd    => add_sub_cmd,
			RESULT => add_sub_res,
			C      => add_sub_c,
			V      => add_sub_v
		);

	-- Opérations logiques AND/OR/XOR/NOT
	U_LOGIC: entity work.logic_op_8bit
		port map (
			A      => A,
			B      => B,
			sel    => logic_sel,
			RESULT => logic_res
		);

	-- Décalages/rotation SHL/SHR/SAR/ROL
	U_SHIFT: entity work.shifter_8bit
		port map (
			A      => A,
			sel    => shift_sel,
			RESULT => shift_res
		);

	-- La racine carrée travaille sur 16 bits: extension de A sur 16 bits.
	sqrt_x <= x"00" & A;

	-- Multiplication séquentielle (sortie 16 bits, done quand terminé)
	U_MUL: entity work.multiplieur
	    port map (
	        clk => clk,
	        reset => reset,
	        start => mul_start,
	        a     => A,
	        b     => B,
	        ra    => mul_ra,
	        done  => mul_done
	    );

	-- Racine carrée séquentielle (done quand terminé)
	U_SQRT: entity work.sqrt_calculator
		port map (
			clk     => clk,
			reset   => reset,
			start   => sqrt_start,
			X_input => sqrt_x,
			result  => sqrt_res,
			done    => sqrt_done
		);

	-- Sélection interne des commandes pour les sous-blocs combinatoires.
	add_sub_cmd <= '0' when OP = "0000" else '1';

	with OP select
		logic_sel <= "00" when "0010", -- AND
					 "01" when "0011", -- OR
					 "10" when "0100", -- XOR
					 "11" when "0101", -- NOT
					 "00" when others;

	with OP select
		shift_sel <= "00" when "0110", -- SHL
					 "01" when "0111", -- SHR
					 "10" when "1000", -- SAR
					 "11" when "1001", -- ROL
					 "00" when others;

	process(clk, reset)
	begin
		if reset = '1' then
			prev_op <= (others => '0');
			mul_start <= '0';
			sqrt_start <= '0';
		elsif rising_edge(clk) then
			-- Impulsions de start d'un cycle seulement, sur front de changement d'OP.
			mul_start <= '0';
			sqrt_start <= '0';
			if OP = "1010" and prev_op /= "1010" then
				mul_start <= '1';
			end if;
			if OP = "1011" and prev_op /= "1011" then
				sqrt_start <= '1';
			end if;
			prev_op <= OP;
		end if;
	end process;

	-- Mux de résultat/flags selon OP.
	process(A, OP, add_sub_res, add_sub_c, add_sub_v, logic_res, shift_res, mul_ra, mul_done, sqrt_res)
	begin
		result_i <= (others => '0');
		c_i <= '0';
		v_i <= '0';

		case OP is
			when "0000" => -- ADD
				result_i <= add_sub_res;
				c_i <= add_sub_c;
				v_i <= add_sub_v;

			when "0001" => -- SUB
				result_i <= add_sub_res;
				c_i <= add_sub_c;
				v_i <= add_sub_v;

			when "0010" | "0011" | "0100" | "0101" => -- AND/OR/XOR/NOT
				result_i <= logic_res;

			when "0110" | "0111" | "1000" | "1001" => -- SHL/SHR/SAR/ROL
				result_i <= shift_res;
				if OP = "0110" or OP = "1001" then -- SHL ou ROL
					c_i <= A(7);
				else -- SHR ou SAR
					c_i <= A(0);
				end if;

			when "1010" => -- MUL
				result_i <= mul_ra(7 downto 0);
				   if (mul_done = '1') and (mul_ra(15 downto 8) /= "00000000") then
					   c_i <= '1';
					   v_i <= '1';
				   end if;

			when "1011" => -- SQRT
				result_i <= sqrt_res;

			when others =>
				result_i <= (others => '0');
		end case;
	end process;

	RESULT <= result_i;
	-- Flags dérivés du résultat sélectionné.
	Z <= '1' when result_i = x"00" else '0';
	N <= result_i(7);
	C <= c_i;
	V <= v_i;
	-- ready=1 immédiatement pour ops combinatoires, sinon attendre done pour MUL/SQRT.
	ready <= '1' when (OP /= "1010" and OP /= "1011") or (OP = "1010" and mul_done = '1') or (OP = "1011" and sqrt_done = '1') else '0';
end structural;



