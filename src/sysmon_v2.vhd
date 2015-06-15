library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
library UNISIM;
use UNISIM.VComponents.all;
entity toplevel is
Port (clk : in STD_LOGIC;
Vccint : out STD_LOGIC_VECTOR (15 downto 0);
temint : out STD_LOGIC_VECTOR (15 downto 0);
busy : out STD_LOGIC;
alarm : out STD_LOGIC);
end toplevel;
architecture Behavioral of toplevel is
signal dobus : std_logic_vector(15 downto 0);
signal vccint_temp : std_logic_vector(15 downto 0);
signal temint_temp : std_logic_vector(15 downto 0);
signal vccint_temp_next : std_logic_vector(15 downto 0);
signal temint_temp_next : std_logic_vector(15 downto 0);
signal addr : std_logic_vector(6 downto 0);
signal addr_next : std_logic_vector(6 downto 0);
signal alm: std_logic_vector(2 downto 0);
signal eos: std_logic;
signal rdy: std_logic;

type state_type is (read_vcc, store_vcc, read_tem, store_tem);
signal currState, nextState : state_type;

begin

process(clk)
begin
	if rising_edge(clk) then
		currState <= nextState;
		vccint_temp <= vccint_temp_next;
		temint_temp <= temint_temp_next;
		addr <= addr_next;
	end if;
end process;

process(currState, dobus, vccint_temp, temint_temp)
begin
	case currState is
		when read_vcc =>
			nextState <= store_vcc;
			vccint_temp_next <= vccint_temp;
			temint_temp_next <= temint_temp;
			addr_next <= "0000001";
		when store_vcc =>
			if rdy = '1' then
				nextState <= read_tem;
				vccint_temp_next <= "000000" & dobus(15 downto 6);
			else
				nextState <= store_vcc;
				vccint_temp_next <= vccint_temp;
			end if;
			temint_temp_next <= temint_temp;
			addr_next <= "0000001";
		when read_tem =>
			nextState <= store_tem;
			vccint_temp_next <= vccint_temp;
			temint_temp_next <= temint_temp;
			addr_next <= "0000000";
		when store_tem =>
			if rdy = '1' then
				nextState <= read_vcc;
				temint_temp_next <= "000000" & dobus(15 downto 6);
			else
				nextState <= store_tem;
				temint_temp_next <= temint_temp;
			end if;
			vccint_temp_next <= vccint_temp;
			addr_next <= "0000000";
		when others =>
			nextState <= read_vcc;
			vccint_temp_next <= vccint_temp;
			temint_temp_next <= temint_temp;
			addr_next <= "0000000";
	end case;
end process;

vccint <= vccint_temp;
temint <= temint_temp;

-- Connect ALM[2] (Vccaux alarm) to output
alarm <= alm(2);

my_sysmon : SYSMON
generic map(
INIT_40 => X"0000",
INIT_41 => X"20C7",
INIT_42 => X"0A00",
INIT_43 => X"0000",
INIT_44 => X"0000",
INIT_45 => X"0000",
INIT_46 => X"0000",
INIT_47 => X"0000",
INIT_48 => X"0301",
INIT_49 => X"0000",
INIT_4A => X"0000", -- Sequence register 2
INIT_4B => X"0000", -- Sequence register 3
INIT_4C => X"0000", -- Sequence register 4
INIT_4D => X"0000", -- Sequence register 5
INIT_4E => X"0000", -- Sequence register 6
INIT_4F => X"0000", -- Sequence register 7
INIT_50 => X"0000", -- Alarm limit register 0
INIT_51 => X"0000", -- Alarm limit register 1
INIT_52 => X"E000", -- Alarm limit register 2
INIT_53 => X"0000", -- Alarm limit register 3
INIT_54 => X"0000", -- Alarm limit register 4
INIT_55 => X"0000", -- Alarm limit register 5
INIT_56 => X"CAAA", -- Alarm limit register 6
INIT_57 => X"0000", -- Alarm limit register 7
SIM_MONITOR_FILE => "vccaux_alarm.txt" --Stimulus file for analog simulation
)
port map (
DCLK => clk,
DWE => '0',
DEN => eos,
DRDY => rdy,
DADDR => addr,
DO => dobus,
CHANNEL => open,
EOS => eos,
BUSY => busy,
ALM => alm,
RESET=> '0',
CONVST => '0',
CONVSTCLK => '0',
DI => "0000000000000000",
VAUXN => "0000000000000000",
VAUXP=> "0000000000000000",
VN => '0',
VP => '0'
);
end Behavioral;
