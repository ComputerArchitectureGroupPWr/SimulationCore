library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library unisim;
use unisim.vcomponents.all;

entity DummyRO is
  port(   
			osc_out : out std_logic;
			clk : in std_logic
		);
end DummyRO;

architecture low_level_definition of DummyRO is

	signal clkDiv2 : std_logic;

	attribute keep : string;
	attribute keep of osc_out: signal is "true";
	attribute s: string;
	attribute s of osc_out: signal is "yes";

	
begin
	osc_out <= clkDiv2;
				 
	toggle_flop: FD
	port map (	D => not clkDiv2,
					Q => clkDiv2,
					C => clk);

end low_level_definition;
