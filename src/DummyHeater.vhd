library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library unisim;
use unisim.vcomponents.all;

entity DummyHeater is
  port(   
			heaterOut : out std_logic;
			heaterIn : in std_logic
		);
end DummyHeater;

architecture low_level_definition of DummyHeater is

	signal outSignal : std_logic;

	attribute keep : string;
	attribute keep of heaterOut: signal is "true";
	attribute keep of outSignal: signal is "true";
	attribute s: string;
	attribute s of heaterOut: signal is "yes";
	attribute s of outSignal: signal is "yes";
	
begin
	heaterOut <= outSignal;
			
	outSignal <= heaterIn;

end low_level_definition;
