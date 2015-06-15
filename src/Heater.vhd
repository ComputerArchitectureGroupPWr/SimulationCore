library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity Heater is
	port(
			rst : in std_logic;
			clk50Mhz : in std_logic;
			pulseWidth : in std_logic_vector(7 downto 0);
			heaterEnable : out std_logic
	);
end Heater;

architecture Behavioral of Heater is
	signal counter : integer range 0 to 255;
	signal pulseWidthReg : integer range 0 to 255;
	signal heaterEnableSignal : std_logic;
	
	attribute keep : string;
	attribute keep of heaterEnable: signal is "true";
	
	attribute S: string;
	attribute S of heaterEnable: signal is "yes";
	
begin
	heaterEnable <= heaterEnableSignal;

	process(clk50Mhz,rst,counter)
	begin
		if rst='1' or counter = 255 then
			counter <= 0;
		elsif clk50Mhz'event and clk50Mhz = '1' then
			counter <= counter + 1;
		end if;
	end process;
	
	process(clk50Mhz,rst)
	begin
		if rst = '1' then
			pulseWidthReg <= 0;
		elsif clk50Mhz'event and clk50Mhz = '1' then
			pulseWidthReg <= to_integer(unsigned(pulseWidth));
		end if;
	end process;
	
	heaterEnableSignal <= '1' when pulseWidthReg > counter else '0';
	
end Behavioral;

