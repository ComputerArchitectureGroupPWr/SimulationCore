LIBRARY ieee;
USE ieee.std_logic_1164.ALL;
USE ieee.numeric_std.ALL;
 
ENTITY heatersLogicTB IS
END heatersLogicTB;
 
ARCHITECTURE behavior OF heatersLogicTB IS 
 
    -- Component Declaration for the Unit Under Test (UUT)
 
    COMPONENT heatersLogic
    PORT(
         rsDataIn : IN  std_logic_vector(7 downto 0);
         rsRdy : IN  std_logic;
         rst : IN  std_logic;
         clk50Mhz : IN  std_logic
        );
    END COMPONENT;
    

   --Inputs
   signal rsDataIn : std_logic_vector(7 downto 0) := (others => '0');
   signal rsRdy : std_logic := '0';
   signal rst : std_logic := '0';
   signal clk50Mhz : std_logic := '0';

   -- Clock period definitions
   constant clk50Mhz_period : time := 20 ns;
 
BEGIN
 
	-- Instantiate the Unit Under Test (UUT)
   uut: heatersLogic PORT MAP (
          rsDataIn => rsDataIn,
          rsRdy => rsRdy,
          rst => rst,
          clk50Mhz => clk50Mhz
        );

   -- Clock process definitions
   clk50Mhz_process :process
   begin
		clk50Mhz <= '0';
		wait for clk50Mhz_period/2;
		clk50Mhz <= '1';
		wait for clk50Mhz_period/2;
   end process;
 

   -- Stimulus process
   stim_proc: process
   begin		
      rst <= '1';
      wait for 100 ns;	
		rst <= '0';
      wait for clk50Mhz_period*10;
		
		rsDataIn <= X"22";
		rsRdy <= '1';
		wait for clk50Mhz_period;
		rsDataIn <= X"00";
		rsRdy <= '0';
		wait for 3*clk50Mhz_period;
		
		rsDataIn <= X"55";
		rsRdy <= '1';
		wait for clk50Mhz_period;
		rsDataIn <= X"00";
		rsRdy <= '0';
		wait for 3*clk50Mhz_period;
		
		rsDataIn <= X"01";
		rsRdy <= '1';
		wait for clk50Mhz_period;
		rsDataIn <= X"00";
		rsRdy <= '0';
		wait for 3*clk50Mhz_period;
		
		rsDataIn <= X"FF";
		rsRdy <= '1';
		wait for clk50Mhz_period;
		rsDataIn <= X"00";
		rsRdy <= '0';
		wait for 3*clk50Mhz_period;
      wait;
   end process;

END;
