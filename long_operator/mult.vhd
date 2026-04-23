Library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity multiplieur is
    port (
        clk : in std_logic;
        reset : in std_logic;
        start : in std_logic;
        a : in std_logic_vector(7 downto 0);
        b : in std_logic_vector(7 downto 0);

        ra : out std_logic_vector(15 downto 0); -- résultat de la multiplication
        done : out std_logic
    );
end multiplieur;

architecture A1 of multiplieur is
    signal a1 : std_logic_vector(7 downto 0);
    signal b1 : std_logic_vector(7 downto 0);
    signal rh : std_logic_vector(7 downto 0); -- partie haute du résultat intermédiaire
    signal rl: std_logic_vector(7 downto 0); -- partie basse du résultat intermédiaire
    signal cpt: natural range 0 to 8:=0; -- compteur de bits traités
    signal running : std_logic := '0';

    begin
        process (clk, reset)
            variable somme : unsigned(8 downto 0);
        begin
            if reset = '1' then
                a1 <= (others => '0');
                b1 <= (others => '0');
                rh <= (others => '0');
                rl <= (others => '0');
                cpt <= 0;
                ra <= (others => '0');
                running <= '0';
                done <= '0';
            
            -- Calcul de la multiplication par l'algorithme de Booth
            elsif rising_edge(clk) then
                done <= '0';
                if running = '0' then
                    if start = '1' then
                        a1 <= a;
                        b1 <= b;
                        rh <= (others => '0');
                        rl <= (others => '0');
                        cpt <= 0;
                        running <= '1';
                    end if;
                elsif cpt < 8 then
                    if b1(0) = '1' then
                        somme := ('0' & unsigned(rh)) + ('0' & unsigned(a1));
                    else
                        somme := ('0' & unsigned(rh));
                    end if;

                    rh <= std_logic_vector(somme(8 downto 1));
                    rl <= somme(0) & rl(7 downto 1);
                    b1 <= '0' & b1(7 downto 1);
                    cpt <= cpt + 1;

                    if cpt = 7 then
                        ra <= (somme(8) & std_logic_vector(somme(7 downto 1))) & (somme(0) & rl(7 downto 1));
                        running <= '0';
                        done <= '1';
                    end if;
                end if;
            end if;
        end process;
end A1;