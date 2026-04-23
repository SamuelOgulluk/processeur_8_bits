library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity proc8bits is
	Port (
		clk    : in  STD_LOGIC;
		reset  : in  STD_LOGIC;
		A_out  : out STD_LOGIC_VECTOR(7 downto 0);
		B_out  : out STD_LOGIC_VECTOR(7 downto 0);
		R_out  : out STD_LOGIC_VECTOR(7 downto 0);
		IR_out : out STD_LOGIC_VECTOR(15 downto 0);
		PC_out : out STD_LOGIC_VECTOR(7 downto 0);
		Z_out  : out STD_LOGIC;
		N_out  : out STD_LOGIC;
		C_out  : out STD_LOGIC;
		V_out  : out STD_LOGIC;
		halted : out STD_LOGIC
	);
end proc8bits;



-- Set d'instructions actuel : 
-- 0xC019 : LDAI A, imm (immediats sur les 8 bits de poids faible)
-- 0xD007 : LDBI B, imm (immediats sur les 8 bits de poids faible)
-- 0x0000 : ADD
-- 0x1000 : SUB
-- 0x2000 : AND
-- 0x3000 : OR
-- 0x4000 : XOR
-- 0x5000 : NOT
-- 0x6000 : SHL
-- 0x7000 : SHR
-- 0x8000 : SAR
-- 0x9000 : ROL
-- 0xA000 : MUL
-- 0xB000 : SQRT
-- 0xF000 : HALT



architecture rtl of proc8bits is
	type state_t is (FETCH, DECODE, EXEC_ALU, EXEC_ALU_WAIT, HALT); -- Etats de la machine à états
	signal state : state_t := FETCH;

	signal regA : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
	signal regB : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
	signal regR : STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
	signal regIR : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
	signal regPC : unsigned(7 downto 0) := (others => '0');

	signal flagZ : STD_LOGIC := '0';
	signal flagN : STD_LOGIC := '0';
	signal flagC : STD_LOGIC := '0';
	signal flagV : STD_LOGIC := '0';

	signal alu_op     : STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
	signal alu_result : STD_LOGIC_VECTOR(7 downto 0);
	signal alu_Z      : STD_LOGIC;
	signal alu_N      : STD_LOGIC;
	signal alu_C      : STD_LOGIC;
	signal alu_V      : STD_LOGIC;
	signal alu_ready  : STD_LOGIC;

	type rom_t is array (0 to 255) of STD_LOGIC_VECTOR(15 downto 0);
	constant program_rom : rom_t := (
		-- IR(15 downto 12) = opcode
		-- IR(7 downto 0)   = immediate pour LDAI/LDBI

		0  => x"C019", -- LDAI A, 25
		1  => x"D007", -- LDBI B, 7
		2  => x"0000", -- ADD
		3  => x"1000", -- SUB
		4  => x"2000", -- AND
		5  => x"3000", -- OR
		6  => x"4000", -- XOR
		7  => x"6000", -- SHL
		8  => x"7000", -- SHR
		9  => x"8000", -- SAR
		10 => x"9000", -- ROL
		11 => x"A000", -- MUL
		12 => x"B000", -- SQRT
		13 => x"F000", -- HALT
		others => x"F000"
	);
begin
	U_ALU: entity work.ual
		port map (
			clk    => clk,
			reset  => reset,
			A      => regA,
			B      => regB,
			OP     => alu_op,
			RESULT => alu_result,
			Z      => alu_Z,
			N      => alu_N,
			C      => alu_C,
			V      => alu_V,
			ready  => alu_ready
		);


	-- Processus de contrôle de la machine à états
	process(clk, reset)
		variable opcode : STD_LOGIC_VECTOR(3 downto 0);
	begin
		if reset = '1' then
			state <= FETCH;
			regA <= (others => '0');
			regB <= (others => '0');
			regR <= (others => '0');
			regIR <= (others => '0');
			regPC <= (others => '0');
			flagZ <= '0';
			flagN <= '0';
			flagC <= '0';
			flagV <= '0';
			alu_op <= (others => '0');
			halted <= '0';
		elsif rising_edge(clk) then
			case state is

				when FETCH =>
					if to_integer(regPC) <= 255 then
						regIR <= program_rom(to_integer(regPC));
					else
						regIR <= x"F000";
					end if;
					regPC <= regPC + 1;
					state <= DECODE;


				when DECODE =>
					opcode := regIR(15 downto 12);
					if opcode <= "1001" then
						alu_op <= opcode;
						state <= EXEC_ALU;
					elsif opcode = "1010" or opcode = "1011" then
						alu_op <= opcode;
						state <= EXEC_ALU_WAIT;
					elsif opcode = "1100" then -- LDAI
						regA <= regIR(7 downto 0);
						state <= FETCH;
					elsif opcode = "1101" then -- LDBI
						regB <= regIR(7 downto 0);
						state <= FETCH;
					elsif opcode = "1110" then -- MOVR
						if regIR(0) = '0' then
							regA <= regR;
						else
							regB <= regR;
						end if;
						state <= FETCH;
					elsif opcode = "1111" then
						halted <= '1';
						state <= HALT;
					else
						state <= FETCH;
					end if;

				-- Pour les opérations courtes
				when EXEC_ALU =>
					regR <= alu_result;
					flagZ <= alu_Z;
					flagN <= alu_N;
					flagC <= alu_C;
					flagV <= alu_V;
					state <= FETCH;

				-- Pour les opérations longues (MUL, SQRT)
				when EXEC_ALU_WAIT =>
					if alu_ready = '1' then
						regR <= alu_result;
						flagZ <= alu_Z;
						flagN <= alu_N;
						flagC <= alu_C;
						flagV <= alu_V;
						state <= FETCH;
					end if;

				when HALT =>
					state <= HALT;

				when others =>
					state <= FETCH;
			end case;
		end if;
	end process;

	A_out <= regA;
	B_out <= regB;
	R_out <= regR;
	IR_out <= regIR;
	PC_out <= std_logic_vector(regPC);
	Z_out <= flagZ;
	N_out <= flagN;
	C_out <= flagC;
	V_out <= flagV;
end rtl;
