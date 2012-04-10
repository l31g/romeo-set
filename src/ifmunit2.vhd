library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity ifmunitd is

	port(
	clk			: in std_logic;
	reset		: in std_logic;
	data		: in std_logic;								--Asserted high when data is ready to be read
	xin			: in std_logic_vector(9 downto 0);
	yin			: in std_logic_vector(8 downto 0);
	ain			: in std_logic_vector(35 downto 0);
	bin			: in std_logic_vector(35 downto 0);
	xout		: out std_logic_vector(9 downto 0);
	yout		: out std_logic_vector(8 downto 0);
	count		: out unsigned(7 downto 0);					--Data to be written in memory
	full		: out std_logic;
	done		: out unsigned(3 downto 0);
	compute		: out unsigned(3 downto 0);
	we			: out std_logic								-- Write enable
	);
end ifmunitd;

architecture qq of ifmunitd is

--Input buses
type inRecord is record
	d			: std_logic;
	a			: std_logic_vector(35 downto 0);
	b			: std_logic_vector(35 downto 0);
	x			: std_logic_vector(9 downto 0);
	y			: std_logic_vector(8 downto 0);
end record;
type inArray	is array (0 to 1) of inRecord;

--Buses connecting to the IFMs
type bxifm		is array (0 to 3) of std_logic_vector(9 downto 0);
type byifm		is array (0 to 3) of std_logic_vector(8 downto 0);
type bcount		is array (0 to 3) of unsigned(7 downto 0);
type bdon		is array (0 to 3) of std_logic;
type bread		is array (0 to 3) of std_logic;
type bclr		is array (0 to 3) of std_logic;
type bcompute	is array (0 to 3) of std_logic;
type bstat		is array (0 to 3) of std_logic;

--Buses for the output buffer Currently one output stage
type owb		is array (0 to 0) of std_logic;
type ocb		is array (0 to 0) of unsigned(7 downto 0);
type oxb		is array (0 to 0) of std_logic_vector(9 downto 0);
type oyb		is array (0 to 0) of std_logic_vector(8 downto 0);

signal ia			: inArray;
signal rd			: unsigned(3 downto 0);			-- Signal representing the IFM being read from
signal odd			: std_logic;

signal bx			: bxifm;
signal by			: byifm;
signal bc			: bcount;
signal bdone		: bdon;
signal bready		: bread;
signal bclear		: bclr;
signal bcomp		: bcompute;
signal bstate		: bstat;

signal ow			: owb;
signal oc			: ocb;
signal ox			: oxb;
signal oy			: oyb;

	begin
	full			<= ia(1).d;
	xout			<= ox(0);
	yout			<= oy(0);
	we				<= ow(0);
	count			<= oc(0);

	done			<= unsigned(bdone);
	compute			<= unsigned(bcomp);

	process(clk)
	begin
	if rising_edge(clk) then

	if reset = '1' then

		rd					<= "0000";

		init0:	for idx in 0 to 1 loop
			ia(idx).d		<= '0';
			ia(idx).a		<= (others => '0');
			ia(idx).b		<= (others => '0');
			ia(idx).x		<= (others => '0');
			ia(idx).y		<= (others => '0');
			end loop init0;
		
		init1:	for m in 0 to 0 loop
			ow(m)			<= '0';
			oc(m)			<= (others => '0');
			end loop init1;
			
		init2:	for n in 0 to 3 loop
			bclear(n)		<= '1';
			bcomp(n)		<= '0';
			bstate(n)		<= '0';
			end loop init2;

	else

---- OUTPUT BUFFER:
--	ob:	for idx in 0 to 0 loop
--		ox(idx)			<= ox(idx-1);
--		oy(idx)			<= oy(idx-1);
--		oc(idx)			<= oc(idx-1);
--		ow(idx)			<= ow(idx-1);
--	end loop ob;
---- END OUTPUT BUFFER:

-- INPUT BUFFER:
	if ia(1).d = '0' then
	if data = '1' then
	ia(1).a			<= ain;
	ia(1).b			<= bin;
	ia(1).x			<= xin;
	ia(1).y			<= yin;
	ia(1).d			<= '1';
	else
	ia(1).d			<= '0';
	end if;
	end if;

	if ia(0).d = '0' then
	if ia(1).d = '1' then
	ia(0).a			<= ia(1).a;
	ia(0).b			<= ia(1).b;
	ia(0).x			<= ia(1).x;
	ia(0).y			<= ia(1).y;
	ia(0).d			<= ia(1).d;
	ia(1).d			<= '0';
	else
	ia(0).d			<= '0';
	end if;
	end if;
-- END INPUT BUFFER

-- Ready available IFMs
clear:	for idx in 0 to 3 loop
	if bclear(idx) = '1' then		-- Availability check
		bclear(idx)			<= '0';
	end if;						-- End availability check
	end loop clear;
-- End readying available IFMs

-- Feed ready IFMs
	if ia(0).d = '1' then		-- Data validation
	if bready(0) = '1' then -- Ready check
		bcomp(0)			<= '1';
		ia(0).d				<= '0';
	elsif bready(1) = '1' then
		bcomp(1)			<= '1';
		ia(0).d				<= '0';
	elsif bready(2) = '1' then
		bcomp(2)			<= '1';
		ia(0).d				<= '0';
	elsif bready(3) = '1' then 
		bcomp(3)			<= '1';
		ia(0).d				<= '0';
	end if;						-- End ready check
	end if;						-- End data validation
-- End feeding ready IFMs

-- Check done IFMs
	if bdone(0) = '1' then
		ox(0)				<= bx(0);
		oy(0)				<= by(0);
		oc(0)				<= bc(0);
		ow(0)				<= '1';
		bclear(0)			<= '1';
		bcomp(0)			<= '0';
	elsif bdone(1) = '1' then
		ox(0)				<= bx(1);
		oy(0)				<= by(1);
		oc(0)				<= bc(1);
		ow(0)				<= '1';
		bclear(1)			<= '1';
		bcomp(1)			<= '0';
	elsif bdone(2) = '1' then
		ox(0)				<= bx(2);
		oy(0)				<= by(2);
		oc(0)				<= bc(2);
		ow(0)				<= '1';
		bclear(2)			<= '1';
		bcomp(2)			<= '0';
	elsif bdone(3) = '1' then
		ox(0)				<= bx(3);
		oy(0)				<= by(3);
		oc(0)				<= bc(3);
		ow(0)				<= '1';
		bclear(3)			<= '1';
		bcomp(3)			<= '0';
	else
		ox(0)				<= (others => '0');
		oy(0)				<= (others => '0');
		oc(0)				<= (others => '0');
		ow(0)				<= '0';
	end if;
-- End checking for done IFMs

	end if;			-- reset = 1
	end if;			-- rising edge
	end process;

	g1:		for I in 0 to 3 generate
		ifm:	entity work.ifmd port map(
		clock		=> clk,
		clr			=> bclear(I),
		compute		=> bcomp(I),
		xin			=> ia(0).x,
		yin			=> ia(0).y,
		a			=> ia(0).a,
		b			=> ia(0).b,
		xout		=> bx(I),
		yout		=> by(I),
		count		=> bc(I),
		don			=> bdone(I),
		ready		=> bready(I)
		);
	end generate;

end qq;