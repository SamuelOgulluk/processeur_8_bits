library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity sqrt_calculator is
    port (
        clk       : in  std_logic;
        reset     : in  std_logic;
        start     : in  std_logic;
        X_input   : in  std_logic_vector(15 downto 0);
        result    : out std_logic_vector(7 downto 0);
        done      : out std_logic
    );
end sqrt_calculator;

architecture behavioral of sqrt_calculator is
begin
    
    sqrt_proc: process(clk, reset)
        variable X        : unsigned(31 downto 0);  -- Input (passée en 32bits)
        variable V        : unsigned(31 downto 0);  -- V = 2^(2n-2)
        variable Z        : unsigned(31 downto 0);  
        variable i        : integer range -1 to 15; -- compteur de boucle 
        variable state    : integer range 0 to 2;   -- 0: idle, 1: computing, 2: done
        
    begin
        if reset = '1' then
            X      := (others => '0');
            V      := (others => '0');
            Z      := (others => '0');
            i      := 15;
            state  := 0;
            done   <= '0';
            result <= (others => '0');
        

        elsif rising_edge(clk) then
            case state is
                -- Initialisation
                when 0 =>
                    done <= '0';
                    if start = '1' then
                        -- initialise l'algorithme
                        X := resize(unsigned(X_input), 32);
                        V := to_unsigned(2**30, 32); 
                        Z := (others => '0');
                        i := 15;  
                        state := 1;
                    end if;
                -- Calcul de la racine carrée
                when 1 =>
                    Z := Z + V;
                    
                    if X >= Z then
                        X := X - Z;
                        Z := Z + V;
                    else
                        Z := Z - V;
                    end if;
                    
                    Z := Z srl 1;
                    V := V srl 2;
                    i := i - 1;
                    if i < 0 then
                        state := 2;
                    end if;
                
                when 2 =>
                    result <= std_logic_vector(Z(7 downto 0));
                    done <= '1';
                    if start = '0' then
                        state := 0;
                    end if;
                when others =>
                    state := 0;
                    
            end case;
        end if;
    end process sqrt_proc;
    
end behavioral;