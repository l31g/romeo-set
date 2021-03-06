---------------------------------------------------------------------
--ramctrl.vhd
--
--A small RAM that interfaces a control signal between the Nios processor,
--and the rest of the viewer
--
--Author: Nathan Hwang
---------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ramctrl is
	port(
	clk						: in std_logic;
	reset_n					: in std_logic;
	write					: in std_logic;
	chipselect				: in std_logic;
	address					: in unsigned(0 downto 0);
	writedata				: in unsigned(7 downto 0);

	read_addr				: in unsigned(0 downto 0);
	read_data				: out unsigned(7 downto 0)
	);
end ramctrl;

architecture ramarch of ramctrl is

	type ram_type is array(1 downto 0) of unsigned(7 downto 0);
	signal RAM				: ram_type;
	signal read_data_hold	: unsigned(7 downto 0);

	begin

	read_data		<= read_data_hold;

	process(clk)
	begin
		if rising_edge(clk) then
			if chipselect = '1' and write = '1' then
				RAM(to_integer(address)) 	<= writedata;
				read_data_hold				<= read_data_hold;
			else
				read_data_hold				<= RAM(to_integer(read_addr));
			end if;
		end if;
	end process;
end ramarch;
