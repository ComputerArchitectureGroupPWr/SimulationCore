library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity FeqDiv is
	Generic( width : integer );
	Port(		clkIn : in  STD_LOGIC;
				clkOut : out  STD_LOGIC);
end FeqDiv;

architecture Behavioral of FeqDiv is
	signal inner : STD_LOGIC_VECTOR(1 to width);
	attribute KEEP : string;
	attribute KEEP of clkIn: signal is "TRUE";
	attribute KEEP of clkOut: signal is "TRUE";
	attribute KEEP of inner: signal is "TRUE";
begin
	chain:
	for D in 1 to width generate
	begin
		chainBegin: if D = 1 generate
		begin
			process(clkIn)
			begin
				if rising_edge(clkIn) then
					inner(D) <= not inner(D);
				end if;
			end process;
		end generate;
		
		chainRest: if D /= 1 generate
		begin
			process(inner(D-1))
			begin
				if rising_edge(inner(D-1)) then
					inner(D) <= not inner(D);
				end if;
			end process;
		end generate;
		
	end generate;
	
	clkOut <= inner(width);
	
end Behavioral;

