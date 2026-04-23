library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library work;
use work.all;

----------------------------------------------------------------
-- Gestion des opérations d'addition et de soustraction
----------------------------------------------------------------

entity add_sub_8bit is
	Port (
		A      : in  STD_LOGIC_VECTOR(7 downto 0);
		B      : in  STD_LOGIC_VECTOR(7 downto 0);
		cmd    : in  STD_LOGIC; -- 0 pour addition, 1 pour soustraction
		RESULT : out STD_LOGIC_VECTOR(7 downto 0);
		C      : out STD_LOGIC; -- Carry
		V      : out STD_LOGIC -- Overflow
	);
end add_sub_8bit;

architecture rtl of add_sub_8bit is
	signal a_int, b_int, sum : std_logic_vector(7 downto 0);
	signal carry : std_logic_vector(8 downto 0);
	signal b2 : std_logic_vector(7 downto 0);
	signal v_flag : std_logic;
begin
	b2 <= B when cmd = '0' else not B;
	a_int <= A;
	carry(0) <= '0' when cmd = '0' else '1';

	-- Additionneur à propagation de retenue
	GEN_FA: for i in 0 to 7 generate
	begin
		FA: entity work.full_adder
			port map(
				A    => a_int(i),
				B    => b2(i),
				Cin  => carry(i),
				S    => sum(i),
				Cout => carry(i + 1)
			);
	end generate GEN_FA;

	RESULT <= sum;
	C <= carry(8);
	-- Calcul du flag overflow (V)
	v_flag <= (a_int(7) xor b2(7) xor cmd) xor (sum(7) xor carry(8));
	V <= v_flag;
end rtl;

----------------------------------------------------------------
-- Gestion des opérations de shift et de rotations
----------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity shifter_8bit is
	Port (
		A      : in  STD_LOGIC_VECTOR(7 downto 0);
		sel    : in  STD_LOGIC_VECTOR(1 downto 0); -- 00: SHL, 01: SHR, 10: SAR, 11: ROL
		RESULT : out STD_LOGIC_VECTOR(7 downto 0)
	);
end shifter_8bit;

architecture rtl of shifter_8bit is
begin
	process(A, sel)
	begin
		case sel is
			when "00" =>
				RESULT <= A(6 downto 0) & '0';
			when "01" =>
				RESULT <= '0' & A(7 downto 1);
			when "10" =>
				RESULT <= A(7) & A(7 downto 1);
			when others =>
				RESULT <= A(6 downto 0) & A(7);
		end case;
	end process;
end rtl;



----------------------------------------------------------------
-- Gestion des opérations logiques
----------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity logic_op_8bit is
	Port (
		A      : in  STD_LOGIC_VECTOR(7 downto 0);
		B      : in  STD_LOGIC_VECTOR(7 downto 0);
		sel    : in  STD_LOGIC_VECTOR(1 downto 0); -- 00: AND, 01: OR, 10: XOR, 11: NOT
		RESULT : out STD_LOGIC_VECTOR(7 downto 0)
	);
end logic_op_8bit;

architecture rtl of logic_op_8bit is
begin
	process(A, B, sel)
	begin
		case sel is
			when "00" =>
				RESULT <= A and B;
			when "01" =>
				RESULT <= A or B;
			when "10" =>
				RESULT <= A xor B;
			when others =>
				RESULT <= not A;
		end case;
	end process;
end rtl;
