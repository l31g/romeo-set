library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity two is

	port(

	clock		: in std_logic;								-- Global clock
--	clken		: in std_logic;								-- Clock enable
	aclr		: in std_logic;								-- Asynchronous clear
	compute		: in std_logic;								-- Controls when IFM starts iterating. Set high to start iterations
	xin			: in std_logic_vector(9 downto 0);			-- The x coordinate input
	yin			: in std_logic_vector(8 downto 0);			-- The y coordinate input
	a			: in std_logic_vector(17 downto 0);			-- Real part of input
	b			: in std_logic_vector(17 downto 0);			-- Imaginary part of input
	xout		: out std_logic_vector(9 downto 0);			-- The x coordinate output
	yout		: out std_logic_vector(8 downto 0);			-- The y coordinate output
--	rr			: out std_logic_vector(17 downto 0);		-- New z real part
--	ri			: out std_logic_vector(17 downto 0);		-- New Z imaginary part
--	m2			: out std_logic_vector(17 downto 0);		-- Magnitude squared
	count		: out unsigned(6 downto 0);					-- Iteration count
	don			: out std_logic							-- Becomes high when the iterator is done iterating

	);

end two;

architecture first of two is

signal		cr		: signed(17 downto 0)	:= "000000000000000000";	-- Real part of the constant		1
signal		ci		: signed(17 downto 0)	:= "000000000000000000";	-- Imaginary part of the constant	1

signal		proda	: std_logic_vector(35 downto 0);
signal		prodb	: std_logic_vector(35 downto 0);
signal		prodc	: std_logic_vector(35 downto 0);
signal		x		: std_logic_vector(9 downto 0);						-- The x coordinate
signal  	y		: std_logic_vector(8 downto 0);						-- The y coordinate
signal		spa		: signed(17 downto 0);								-- proda "trimmed" to 18 bits
signal		spb		: signed(17 downto 0);								-- prodb "trimmed" to 18 bits
signal		spc		: signed(17 downto 0);								-- prodc "trimmed" to 18 bits
signal		sumr	: signed(17 downto 0);								-- Difference of the squares
signal		sumi	: signed(17 downto 0);								-- Product multiplied by two
signal		newr	: signed(17 downto 0);								-- Newly computed Re{z} before flip flop  
signal		newi	: signed(17 downto 0);								-- Newly computed Im{z} before flip flop  
signal		oldr	: std_logic_vector(17 downto 0);					-- Re{z} after flip flop  
signal		oldi	: std_logic_vector(17 downto 0);					-- Im{z} after flip flop  
signal		mag2	: signed(17 downto 0);								-- Magnitude squared of current a & b
signal		counter	: unsigned(6 downto 0)	:= (others => '0');			-- Counter for iterations
signal		done	: std_logic				:= '1';						-- Indicates if IFM is done iterating


	begin

	spa		<= signed(proda(29 downto 12));		--Change range depending on radix. Assuming 6-bit & 12-bit
	spb		<= signed(prodb(29 downto 12));
	spc		<= signed(prodc(29 downto 12));

	sumr	<= spa - spb;
	sumi	<= spc + spc;
	mag2	<= spa + spb;

	newr	<= sumr + cr;						-- Add Re{c}
	newi	<= sumi + ci;						-- Add Im{c}

--	rr		<= oldr;
--	ri		<= oldi;
--	m2		<= std_logic_vector(mag2);

	count	<= counter;
	don		<= done;
	xout	<= x;
	yout	<= y;

	process(clock)
	begin
	if rising_edge(clock) then
--		if counter = "1111111" or mag2 > "000010000000000000" then			-- More than 127 iterations or more than 4 mag squared? FIX FIX
		if counter = "1111111" then			-- More than 127 iterations or more than 4 mag squared?
			done <= '1';
		else
			if compute = '1' then						-- Are we iterating?
				oldr	<= std_logic_vector(newr);		-- Store Re{z}
				oldi	<= std_logic_vector(newi);		-- Store Im{z}
				counter	<= counter + 1;
			else
				oldr	<= a;							-- Get value from outsie
				oldi	<= b;							-- Get value from outside
				x		<= xin;
				y		<= yin;
			end if;
		end if;
		if aclr = '1' then
			done 		<= '0';
			counter		<= (others => '0');
			oldr		<= (others => '0');
			oldi		<= (others => '0');
			x			<= (others => '0');
			y			<= (others => '0');
		end if;
	end if;
	end process;

	multa:	entity	work.mult port map(

		dataa		=> oldr,
		datab		=> oldr,
		result		=> proda

	);
	
		multb:	entity	work.mult port map(

		dataa		=> oldi,
		datab		=> oldi,
		result		=> prodb

	);
	
		multc:	entity	work.mult port map(

		dataa		=> oldr,
		datab		=> oldi,
		result		=> prodc

	);

end first;