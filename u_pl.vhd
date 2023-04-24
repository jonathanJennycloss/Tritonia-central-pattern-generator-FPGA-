-- Title : u-pipeline
-- Author : Jonathan Jennycloss
-- Description: Includes the code to calculate the differential equation for u every 1 ms.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library xil_defaultlib;
use xil_defaultlib.fixed_pkg.all;

entity u_pipeline is
	port (
		clk		: in std_logic;
		rst		: in std_logic;
		spike	: in std_logic;
        a       : in sfixed;
        b       : in sfixed;
        d       : in sfixed;
		v		: in sfixed;
		uout	: out sfixed
	);
end u_pipeline;

architecture RTL of u_pipeline is

	signal u 		: sfixed(6 downto -10) 	:= to_sfixed(0, 6, -10);
	signal u1 		: sfixed(7 downto -10) 	:= to_sfixed(0, 7, -10);

    signal bv 		: sfixed(8 downto -20) 	:= to_sfixed(0, 8, -20); 
    signal bv2 		: sfixed(8 downto -10) 	:= to_sfixed(0, 8, -10);  

    signal part1    : sfixed(9 downto -10) 	:= to_sfixed(0, 9, -10); 
    signal part2    : sfixed(10 downto -20) := to_sfixed(0, 10, -20); 
    signal part3    : sfixed(10 downto -10) := to_sfixed(0, 10, -10); 
    signal u_final  : sfixed(11 downto -10) := to_sfixed(0, 11, -10);  
	
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
					u1 <= u + d;
					if (spike = '1') then
						current_state <= update;
					else
						current_state <= update2;
					end if;

				when update2 =>
					u <= u1(6 downto -10);
					if (spike = '1') then
						current_state <= update;
					else
						current_state <= first;
					end if;

				when first =>
					bv      <= b*v;
					if (spike = '1') then
						current_state <= update;
					else
						current_state <= second;
					end if;
				
				when second =>
					bv2	    <= bv(8 downto -10);
					if (spike = '1') then
						current_state <= update;
					else
						current_state <= third;
					end if;
				
				when third =>
					part1      <= bv2 - u;
					if (spike = '1') then
						current_state <= update;
					else
						current_state <= fourth;
					end if;
				
				when fourth =>
					part2      <= a*part1; 
					if (spike = '1') then
						current_state <= update;
					else
						current_state <= fifth;
					end if;
				
				when fifth =>
					part3      <= part2(10 downto -10);
					if (spike = '1') then
						current_state <= update;
					else
						current_state <= sixth;
					end if;
				
				when sixth =>
					u_final		<= u + part3;
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
					u          <= u_final(6 downto -10);
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

	uout <= u;
	
end RTL;