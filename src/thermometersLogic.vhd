library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
Library UNISIM;
use UNISIM.vcomponents.all;

entity thermometersLogic is
	generic(
			termNumber : natural := 128
	);
	port(
			rsTxBusy : in std_logic;
			rst : in std_logic;
			clk50Mhz : in std_logic;
			clk3kHz : in std_logic;
			rsDataOut : out std_logic_vector(7 downto 0);
			rsTxStart : out std_logic;
			led : out std_logic_vector(7 downto 0)
	);
end thermometersLogic;

architecture Behavioral of thermometersLogic is

	component DummyRO
	port(
		clk : IN std_logic;          
		osc_out : OUT std_logic
		);
	end component;
	
	COMPONENT toplevel
	PORT(
		clk : IN std_logic;          
		Vccint : OUT std_logic_vector(15 downto 0);
		temint : OUT std_logic_vector(15 downto 0);
		busy : OUT std_logic;
		alarm : OUT std_logic
		);
	END COMPONENT;

   constant THERM_NUMBER_SYSMON_Temp : integer := 2;
   constant THERM_NUMBER_SYSMON_Vcc : integer := 3;
	
	signal chosenTermometr : integer range 0 to termNumber;
	signal termometrCounter : integer range 0 to 2**16-1;
	
	type state_type is (Start, Numer, Czekaj1, Wartosc1, Czekaj2, Wartosc0); 
   signal state, next_state : state_type; 
   signal rsTxStart_i : std_logic;
	signal rsDataOut_i : std_logic_vector(7 downto 0);
	signal termometrRegister : std_logic_vector(15 downto 0);
	signal termometr : std_logic_vector(termNumber downto 0);
	signal termometrEnable : std_logic_vector(termNumber downto 0);
	signal selectedTermometr : std_logic;
	signal nextTerm : std_logic;

	signal clk3kHzD : std_logic;
	signal clk3kHzD2 : std_logic;
	
	signal sysmon_vcc : std_logic_vector(15 downto 0);
	signal sysmon_tem : std_logic_vector(15 downto 0);

	attribute keep : string;
	attribute keep of termometr : signal is "true";
	attribute keep of termometrEnable : signal is "true";
	attribute keep of nextTerm : signal is "true";
	attribute keep of termometrRegister : signal is "true";
	attribute keep of selectedTermometr : signal is "true";
	
	attribute keep_hierarchy : string;
	attribute keep_hierarchy of DummyRO: component is "true";
	
	attribute s: string;
	attribute s of termometr: signal is "yes";
	attribute s of termometrEnable: signal is "yes";

begin

	Inst_toplevel: toplevel PORT MAP(
		clk => clk50Mhz,
		Vccint => sysmon_vcc,
		temint => sysmon_tem,
		busy => open,
		alarm => open
	);

	led <= X"55";
	Termometers:
	for I in 1 to termNumber generate
		Inst_DummyRO: DummyRO PORT MAP(
			osc_out => termometr(I),
			clk => clk50Mhz
		);
	end generate;
	
	Termometr_Counter:
	process (selectedTermometr, nextTerm, clk50Mhz)
	begin
		if nextTerm = '1' and clk50Mhz = '0' then
			termometrCounter <= 0;
		elsif selectedTermometr'event and selectedTermometr = '1' then
			termometrCounter <= termometrCounter + 1;
		end if;
	end process;
	
	process (chosenTermometr, termometr)
	begin
		selectedTermometr <= termometr(chosenTermometr);
	end process;
	
	process (nextTerm, rst)
	begin
		if rst='1' then
			termometrRegister <= (others => '0');
		elsif nextTerm'event and nextTerm = '1' then
			termometrRegister <= std_logic_vector(to_unsigned(termometrCounter,16));
		end if;
	end process;

	Chosen_Termometr:
	process (clk3kHz, rst, chosenTermometr) 
	begin
		if rst='1' or chosenTermometr = termNumber then 
			chosenTermometr <= 0;
			termometrEnable <= (others => '0');
		elsif clk3kHz='1' and clk3kHz'event then
			chosenTermometr <= chosenTermometr + 1;
			for I in 1 to termNumber loop
				if I = chosenTermometr+1 then 
					termometrEnable(I) <= '1';
				else
					termometrEnable(I) <= '0';
				end if;
			end loop;
		end if;
	end process;
	
	Next_Term1: 
	process (clk50Mhz)
	begin
		if clk50Mhz'event and clk50Mhz='1' then  
			clk3kHzD <= clk3kHz;
		end if;
	end process;
	
	Next_Term2: 
	process (clk50Mhz)
	begin
		if clk50Mhz'event and clk50Mhz='1' then  
			clk3kHzD2 <= clk3kHzD;
		end if;
	end process;
	
	nextTerm <= (not clk3kHzD2) and clk3kHzD;

   Synchro: 
	process (clk50Mhz, rst)
   begin
		if (rst = '1') then
			state <= Start;
         rsDataOut <= X"00";
			rsTxStart <= '0';
      else
			if (clk50Mhz'event and clk50Mhz = '1') then
            state <= next_state;
            rsDataOut <= rsDataOut_i;
				rsTxStart <= rsTxStart_i;
         end if;        
      end if;
   end process;
 
   Output: 
	process (state, rsTxBusy, termometrRegister, chosenTermometr)
   begin
		if (state = Numer and rsTxBusy = '0') then
         rsDataOut_i <= std_logic_vector(to_unsigned(chosenTermometr - 1,8));
			rsTxStart_i <= '1';
		elsif (state = Wartosc1 and rsTxBusy = '0') then
			if (chosenTermometr = THERM_NUMBER_SYSMON_Temp) then
				rsDataOut_i <= sysmon_tem(15 downto 8);
			elsif (chosenTermometr = THERM_NUMBER_SYSMON_Vcc) then
				rsDataOut_i <= sysmon_vcc(15 downto 8);
			else
				rsDataOut_i <= termometrRegister(15 downto 8);
			end if;
			rsTxStart_i <= '1';
		elsif (state = Wartosc0 and rsTxBusy = '0') then
		   if (chosenTermometr = THERM_NUMBER_SYSMON_Temp) then
				rsDataOut_i <= sysmon_tem(7 downto 0);
			elsif (chosenTermometr = THERM_NUMBER_SYSMON_Vcc) then
				rsDataOut_i <= sysmon_vcc(7 downto 0);
			else
				rsDataOut_i <= termometrRegister(7 downto 0);
			end if;
			rsTxStart_i <= '1';
      else
         rsDataOut_i <= X"00";
			rsTxStart_i <= '0';
      end if;
   end process;
 
   Next_stage: 
	process (state, rsTxBusy, nextTerm)
   begin
      next_state <= state;
      case (state) is
         when Start =>
            if nextTerm = '1' then
               next_state <= Numer;
            end if;
         when Numer =>
            if rsTxBusy = '1' then
               next_state <= Czekaj1;
            end if;
         when Czekaj1 =>
            if rsTxBusy = '0' then
               next_state <= Wartosc1;
            end if;
			when Wartosc1 =>
            if rsTxBusy = '1' then
               next_state <= Czekaj2;
            end if;
			when Czekaj2 =>
            if rsTxBusy = '0' then
               next_state <= Wartosc0;
            end if;
			when Wartosc0 =>
            if rsTxBusy = '1' then
               next_state <= Start;
            end if;
         when others =>
            next_state <= Start;
      end case;      
   end process;

end Behavioral;

