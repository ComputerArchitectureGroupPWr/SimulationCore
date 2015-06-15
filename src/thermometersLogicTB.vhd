LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY thermometersLogicTB IS
END thermometersLogicTB;
 
ARCHITECTURE behavior OF thermometersLogicTB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
   COMPONENT thermometersLogic 
   PORT(
         rsTxBusy : IN  std_logic;
         rst : IN  std_logic;
         clk50Mhz : IN  std_logic;
         clk3kHz : IN  std_logic;
         rsDataOut : OUT  std_logic_vector(7 downto 0);
         rsTxStart : OUT  std_logic
        );
   END COMPONENT;

   --Inputs
   signal rsTxBusy : std_logic := '0';
   signal rst : std_logic := '0';
   signal clk50Mhz : std_logic := '0';
   signal clk3kHz : std_logic := '0';

 	--Outputs
   signal rsDataOut : std_logic_vector(7 downto 0);
   signal rsTxStart : std_logic;

   -- Clock period definitions
   constant clk50Mhz_period : time := 20 ns;
   constant clk3kHz_period : time := 327680 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: thermometersLogic PORT MAP (
          rsTxBusy => rsTxBusy,
          rst => rst,
          clk50Mhz => clk50Mhz,
          clk3kHz => clk3kHz,
          rsDataOut => rsDataOut,
          rsTxStart => rsTxStart
        );

   -- Clock process definitions
   clk50Mhz_process :process
   begin
		clk50Mhz <= '0';
		wait for clk50Mhz_period/2;
		clk50Mhz <= '1';
		wait for clk50Mhz_period/2;
   end process;
 
   clk3kHz_process :process
   begin
		clk3kHz <= '0';
		wait for clk3kHz_period/2;
		clk3kHz <= '1';
		wait for clk3kHz_period/2;
   end process;
	
	rs232Proc: process(rsTxStart)
	begin
		if rsTxStart'event and rsTxStart = '1' then
			rsTxBusy <= '1' after 20 ns, '0' after 78125 ns;
		end if;
	end process;

   -- Stimulus process
   stim_proc: process
   begin		
		rst <= '1';
      wait for 5 ns;	
		rst <= '0';
      wait;
   end process;

END;
