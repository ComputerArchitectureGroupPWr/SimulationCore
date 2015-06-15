library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
Library UNISIM;
use UNISIM.vcomponents.all;

entity SimCore is
	port(
			rs232rx : in std_logic;
			rst : in std_logic;
			clk : in std_logic;
			rs232tx : out std_logic;
			led : out std_logic_vector(7 downto 0);
			CLKMULOUT : out std_logic;
			CLK2XOUT : out std_logic
	);
end SimCore;

architecture Behavioral of SimCore is

	component thermometersLogic
	port(
		rsTxBusy : IN std_logic;
		rst : IN std_logic;
		clk50Mhz : IN std_logic;
		clk3kHz : IN std_logic;         
		rsDataOut : OUT std_logic_vector(7 downto 0);
		rsTxStart : OUT std_logic;
		led : OUT std_logic_vector(7 downto 0)
		);
	end component;
	
	component heatersLogic
	port(
		rsDataIn : in std_logic_vector(7 downto 0);
      rsRdy : in std_logic;
      rst : in std_logic;
      clk50Mhz : in std_logic;
		readyOut : out std_logic
      );
	end component;
	
	component RS232
	port(
		rs232_rxd : in std_logic;
		txdi : in std_logic_vector(7 downto 0);
		txstart : in std_logic;
		reset : in std_logic;
		clk_50Mhz : in std_logic;
		clk_sys : in std_logic;
		rs232_txd : out std_logic;
		rxdo : out std_logic_vector(7 downto 0);
		rxrdy : out std_logic;
		txbusy : out std_logic
	);
	end component;
	
	component FeqDiv
	generic( width : integer );
	port(
		clkIn : IN std_logic;          
		clkOut : OUT std_logic
		);
	end component;
	
	COMPONENT ClockGenerator
	PORT(
		clk100Mhz : IN std_logic;
		reset : IN std_logic;          
		clk50Mhz : OUT std_logic
		);
	END COMPONENT;
	
   COMPONENT HeaterClockGenerator
	PORT(
		CLKIN_IN : IN std_logic;
		RST_IN : IN std_logic;          
		CLKFX_OUT : OUT std_logic;
		CLKIN_IBUFG_OUT : OUT std_logic;
		CLK0_OUT : OUT std_logic;
		CLK2X_OUT : OUT std_logic
		);
	END COMPONENT;
	
	signal clk50Mhz : std_logic;
	signal clk3kHz : std_logic;
	
	signal rsDataOut : std_logic_vector(7 downto 0);
	signal rsDataIn : std_logic_vector(7 downto 0);
	signal rsTxStart : std_logic;
	signal rsTxBusy : std_logic;
	signal rsRxRdy : std_logic;
	signal heatersLogicReady : std_logic;
	
	signal clkfx : std_logic;
	
	attribute keep : string;
	attribute keep of heatersLogicReady: signal is "True";
	
	attribute keep_hierarchy : string;
	attribute keep_hierarchy of thermometersLogic: component is "TRUE";
	attribute keep_hierarchy of heatersLogic: component is "TRUE";
	attribute keep_hierarchy of FeqDiv: component is "TRUE";
	attribute keep_hierarchy of RS232: component is "TRUE";
	
begin
	
	InstFeqDiv: FeqDiv generic map( width => 14 )
	port map(
		clkIn => clk50MHz,        
		clkOut => clk3kHz
	);
	
	InstThermometersLogic: thermometersLogic 
	port map(
		rsTxBusy => rsTxBusy,
		rst => rst,
		clk50Mhz => clk50Mhz,
		clk3kHz => clk3kHz,
		rsDataOut => rsDataOut,
		rsTxStart => rsTxStart,
		led => led
	);
	
	InstHeatersLogic: heatersLogic PORT MAP(
		rsDataIn => rsDataIn,
		rsRdy => rsRxRdy,
		rst => rst,
		clk50Mhz => clk50Mhz,
		readyOut => heatersLogicReady
	);
	
	InstRS232: RS232 port map(
		rs232_rxd => rs232rx,
		txdi => rsDataOut,
		txstart => rsTxStart,
		reset => rst,
		clk_50Mhz => clk50Mhz,
		clk_sys => clk50Mhz,
		rs232_txd => rs232tx,
		rxdo => rsDataIn,
		rxrdy => rsRxRdy,
		txbusy => rsTxBusy
	);
	
	Inst_ClockGenerator: ClockGenerator PORT MAP(
		clk100Mhz => clk,
		reset => rst,
		clk50Mhz => clk50Mhz
	);
	
	Inst_SystemClockGenerator: HeaterClockGenerator PORT MAP(
		CLKIN_IN => clk,
		RST_IN => rst,
		CLKFX_OUT => clkfx,
		CLKIN_IBUFG_OUT => open,
		CLK0_OUT => open,
		CLK2x_OUT => open
	);
	
	CLKMULOUT <= clkfx;
	
	Inst_SystemClockGenerator2: HeaterClockGenerator PORT MAP(
		CLKIN_IN => clkfx,
		RST_IN => rst,
		CLKFX_OUT => open,
		CLKIN_IBUFG_OUT => open,
		CLK0_OUT => open,
		CLK2X_OUT => CLK2XOUT
	);


end Behavioral;