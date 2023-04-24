-- Title : Top level of neuron.
-- Author : Jonathan Jennycloss
-- Description: Feeds current into the neuron

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library xil_defaultlib;
use xil_defaultlib.fixed_pkg.all;

entity top is
	port(
		clk		: in std_logic;
		rst		: in std_logic;
		
		--vo		: out sfixed;
		--uo		: out sfixed;
		--spike	: out std_logic;
		output1 : out std_logic_vector(7 downto 0)
		--output1 : out std_logic_vector(8 downto 0)
	);
end top;

architecture RTL of top is

    constant a 		: sfixed(0 downto -10) 	:= to_sfixed(0.01953125, 0, -10); -- ~0.02
    constant b 		: sfixed(0 downto -10) 	:= to_sfixed(0.2, 0, -10); 
    constant c      : sfixed(7 downto -10)  := to_sfixed(-65, 7, -10);
	constant d		: sfixed(3 downto -10) 	:= to_sfixed(8, 3, -10);
    constant delay  : integer 				:= 5;
	
    constant zero			: sfixed(7 downto -10) := to_sfixed(0, 7, -10);
	constant weight30		: sfixed(7 downto -10) := to_sfixed(30, 7, -10);
	
	signal I 				: sfixed(7 downto -10) := to_sfixed(0, 7, -10);
	signal j 				: integer range 0 to 2400 := 0; --300*8clk cycles for one update
	signal clk2				: std_logic			   := '0';
	signal clk_u			: std_logic			   := '0';
	
	signal sp				: std_logic			   := '0';
	signal v_out	: sfixed(7 downto -10)  	:= to_sfixed(-65, 7, -10);
	signal u_out	: sfixed(6 downto -10)  	:= to_sfixed(0, 6, -10);

	signal o1				: std_logic			   := '0';
	signal o2				: std_logic			   := '0';
	signal o3				: std_logic			   := '0';
	signal o4				: std_logic			   := '0';
	signal o5				: std_logic			   := '0';
	signal o6				: std_logic			   := '0';
	signal o7				: std_logic			   := '0';
	signal o8				: std_logic			   := '0';

	type FSM_States is (reset, in_I, no_I, no_I2);
	signal current_state : FSM_States;
	
	component neuron is
		Port(
			clk		: in std_logic;
            rst		: in std_logic;
            I_in	: in sfixed;
            a       : in sfixed;
            b       : in sfixed;
            c       : in sfixed;
            d       : in sfixed;
            delay   : in integer;

            v 		: out sfixed;
            u 		: out sfixed;
            spike	: out std_logic
		);
	end component;

	component clk_div is
		port (
            clk         : in std_logic;
            rst         : in std_logic;
            clk_out     : out std_logic
        );
	end component;
	
begin

	clock 	: clk_div port map(clk => clk, rst => rst, clk_out => clk2);
	n1		: neuron port map (clk => clk2, rst => rst, I_in => I, a => a, b => b, c => c, d => d, delay => delay, v => v_out, u => u_out, spike => sp);

	process(clk2, rst)
	begin
		if (rst = '1') then
			current_state <= reset;
		elsif(rising_edge(clk2)) then
			case current_state is
				when reset =>
					j <= 0;
					current_state <= no_I;

				when no_I =>
					I	<= zero;
					if (j = 4000) then
						current_state <= in_I;
					else 
						j 	<= j + 1;
						current_state <= no_I2;
					end if;
				
				when no_I2 =>
					I	<= zero;
					if (j = 4000) then
						current_state <= in_I;
					else 
						j 	<= j + 1;
						current_state <= no_I;
					end if;
				
				when in_I =>
					I <= weight30;
					current_state <= in_I;
				
				when others =>
					current_state <= reset;
			end case;
		end if;
	end process;

	process(clk)
	begin
		o1 <= v_out(0);
		o2 <= v_out(1);
		o3 <= v_out(2);
		o4 <= v_out(3);
		o5 <= v_out(4);
		o6 <= v_out(5);
		o7 <= v_out(6);
		o8 <= v_out(7);
	end process;
	
									
	--vo 	<= v_out;
	--uo 	<= u_out;
	--output1(7 downto 0) <= v_out(7 downto 0);
	output1(0) <= o1;
	output1(1) <= o2;
	output1(2) <= o3;
	output1(3) <= o4;
	output1(4) <= o5;
	output1(5) <= o6;
	output1(6) <= o7;
	output1(7) <= o8;

end RTL;