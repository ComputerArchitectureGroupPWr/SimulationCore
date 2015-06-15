library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity heatersLogic is
        generic(
                heatNumber : natural := 20
        );
        port(
                rsDataIn : in std_logic_vector(7 downto 0);
                rsRdy : in std_logic;
                rst : in std_logic;
                clk50Mhz : in std_logic;
					 readyOut : out std_logic
        );
end heatersLogic;

architecture Behavioral of heatersLogic is

	component Heater
	port(
			rst : IN std_logic;
			clk50Mhz : IN std_logic;
			pulseWidth : IN std_logic_vector(7 downto 0);
			heaterEnable : OUT std_logic
		);
	end component;
	
	attribute keep_hierarchy : string;
	attribute keep_hierarchy of Heater: component is "TRUE";
	
	type registers is array (1 to heatNumber) of std_logic_vector(7 downto 0);
	signal reg : registers := (others => X"00");
	
   type state_type is (start, number, value); 
   signal state, next_state : state_type;
   signal save : std_logic := '0';
	signal hNumber : integer range 0 to heatNumber := 0;
	
	type enableSignal is array (1 to heatNumber) of std_logic;
	signal heaterEnableSignal : enableSignal := (others => '0');
	
	attribute keep : string;
	attribute keep of heaterEnableSignal: signal is "true";
	attribute S: string;
	attribute S of heaterEnableSignal: signal is "yes";

begin

	readyOut <= '1';

	Heaters_instances:
	for I in 1 to heatNumber generate
		InstHeater: Heater port map(
			rst => rst,
			clk50Mhz => clk50Mhz,
			pulseWidth => reg(I),
			heaterEnable => heaterEnableSignal(I)
		);
	end generate;
	
	SYNC_PROC: process (clk50Mhz)
   begin
      if (clk50Mhz'event and clk50Mhz = '1') then
         if (rst = '1') then
            state <= start;
            reg <= (others => X"00");
         else
            state <= next_state;
            for I in 1 to heatNumber loop
					if I = hNumber and save = '1' then
						reg(I) <= rsDataIn;
					else
						reg(I) <= reg(I);
					end if;
				end loop;
         end if;        
      end if;
   end process;
 
   OUTPUT_DECODE: process (state, rsDataIn, rsRdy, hNumber)
   begin
      if (state = number and rsRdy = '1') then
         hNumber <= to_integer(unsigned(rsDataIn));
			save <= '0';
		elsif (state = value and rsRdy = '1') then
			hNumber <= hNumber;
			save <= '1';
      else
         hNumber <= hNumber;
			save <= '0';
      end if;
   end process;
 
   NEXT_STATE_DECODE: process (state, rsDataIn, rsRdy)
   begin
      next_state <= state;
      case (state) is
         when start =>
            if rsRdy = '1' and rsDataIn = X"55" then
               next_state <= number;
            end if;
         when number =>
            if rsRdy = '1' then
               next_state <= value;
            end if;
         when value =>
            if rsRdy = '1' then
               next_state <= start;
            end if;
         when others =>
            next_state <= start;
      end case;      
   end process;

end Behavioral;

