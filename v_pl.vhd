-- Title : v-pipeline
-- Author : Jonathan Jennycloss
-- Description: Includes the code to calculate the differential equation for v every 1 ms.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library xil_defaultlib;
use xil_defaultlib.fixed_pkg.all;

entity v_pipeline is
	port (
		clk		: in std_logic;
		rst 	: in std_logic;
		spike	: in std_logic;
        c       : in sfixed;
		I   	: in sfixed;
        u       : in sfixed;
		vout	: out sfixed
	);
end v_pipeline;

architecture RTL of v_pipeline is
	
	constant five   : sfixed(3 downto -10)   := to_sfixed(5, 3, -10);
	constant c140   : sfixed(8 downto -10)   := to_sfixed(140, 8, -10);
	constant c004	: sfixed(0 downto -10)   := to_sfixed(0.04, 0, -10);	

	signal v        : sfixed(7 downto -10)   := to_sfixed(-65, 7,  -10);
    signal v2       : sfixed(15 downto -20)  := to_sfixed(0, 15,  -20);
    signal v5       : sfixed(11 downto -20)  := to_sfixed(0, 11,  -20);
    signal adder1   : sfixed(9 downto -10)   := to_sfixed(0, 9,  -10); -- I will probably be (7,-10)

    signal v22      : sfixed(15 downto -10)  := to_sfixed(0, 15,  -10);
    signal v52      : sfixed(11 downto -10)  := to_sfixed(0, 11,  -10);
    signal adder2   : sfixed(10 downto -10)   := to_sfixed(0, 10,  -10);

    signal adder3   : sfixed(12 downto -10)  := to_sfixed(0, 12,  -10);
	signal v24      : sfixed(16 downto -20) := to_sfixed(0, 16,  -20);

	signal v242     : sfixed(16 downto -10) := to_sfixed(0, 16,  -10);
    signal adder4   : sfixed(17 downto -10)  := to_sfixed(0, 17,  -10);
    signal v_final  : sfixed(18 downto -10)  := to_sfixed(0, 18,  -10);

	type FSM_States is (update, update2, first, second, third, fourth, fifth, sixth, seventh, eighth);
	signal current_state : FSM_States;

begin
	process(clk, rst, spike)
	begin
		if (rst = '1') then
			current_state <= first;
		elsif (rising_edge(clk)) then
			case current_state is			
				when update =>
					v <= c;
					if (spike = '1') then
						current_state <= update;
					else
						current_state <= update2;
					end if;
					
				when update2 =>
					if (spike = '1') then
						current_state <= update;
					else
						current_state <= first;
					end if;

				when first =>
					v2      <= v*v;
					v5      <= five*v;
					adder1  <= c140 + I; 
					if (spike = '1') then
						current_state <= update;
					else
						current_state <= second;
					end if;

				when second =>
					v22 	<= v2(15 downto -10);
					v52		<= v5(11 downto -10);
					adder2	<= adder1 - u;
					if (spike = '1') then
						current_state <= update;
					else
						current_state <= third;
					end if;

				when third =>
					adder3	<= adder2 + v52;
					v24		<= v22*c004;
					if (spike = '1') then
						current_state <= update;
					else
						current_state <= fourth;
					end if;

				when fourth =>
					v242	<= v24(16 downto -10);
					if (spike = '1') then
						current_state <= update;
					else
						current_state <= fifth;
					end if;

				when fifth =>
					adder4	<= adder3 + v242;
					if (spike = '1') then
						current_state <= update;
					else
						current_state <= sixth;
					end if;

				when sixth =>
					v_final <= v + adder4;
					if (spike = '1') then
						current_state <= update;
					else
						current_state <= seventh;
					end if;

				when seventh =>
					if (spike = '1') then
						current_state <= update;
					else
						current_state <= eighth;
					end if;

				when eighth =>
					v       <= v_final(7 downto -10);
					if (spike = '1') then
						current_state <= update;
					else
						current_state <= first;
					end if;

				when others =>
					if (spike = '1') then
						current_state <= update;
					else
						current_state <= first;
					end if;
			end case;
		end if;
	end process;
	vout <= v;
	
end RTL;