library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
Library UNISIM;
use UNISIM.vcomponents.all;

entity ClockGenerator is
    Port ( clk100Mhz : in  STD_LOGIC;
			  reset : in STD_LOGIC;
           clk50Mhz : out  STD_LOGIC);
end ClockGenerator;

architecture Behavioral of ClockGenerator is

begin
	DCM_SP_inst : DCM_BASE
   generic map (
      CLKDV_DIVIDE => 4.0,                   -- CLKDV divide value
		CLK_FEEDBACK => "NONE"         -- Specify clock feedback of NONE or 1X
   )
	
   port map (
      CLKIN => clk100Mhz,      -- 1-bit output: 0 degree clock output
      CLKDV => clk50Mhz,      -- 1-bit output: Divided clock output
      RST => reset            -- 1-bit input: Active high reset input
   );

end Behavioral;