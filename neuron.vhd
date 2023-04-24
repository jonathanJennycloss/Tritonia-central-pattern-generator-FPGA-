
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

library xil_defaultlib;
use xil_defaultlib.fixed_pkg.all;

entity neuron is
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
end neuron;

architecture RTL of neuron is 

	constant vpeak  : sfixed(7 downto -10) 	:= to_sfixed(30, 7, -10);

	signal v_out	: sfixed(7 downto -10)  	:= to_sfixed(-65, 7, -10);
	signal u_out	: sfixed(6 downto -10)  	:= to_sfixed(0, 6, -10);
	
	signal update	: std_logic			   		:= '0';
	signal cnt		: integer 					:= 1;
	
	type FSM_States is (calc, spike_out1, spike_out2);
	signal current_state : FSM_States;
	
	component v_pipeline
		Port (
			clk		: in std_logic;
            rst 	: in std_logic;
            spike	: in std_logic;
            c       : in sfixed;
            I   	: in sfixed;
            u       : in sfixed;
            vout	: out sfixed
			);
	end component;
	
	component u_pipeline
		Port (
			clk		: in std_logic;
            rst		: in std_logic;
            spike	: in std_logic;
            a       : in sfixed;
            b       : in sfixed;
            d       : in sfixed;
            v		: in sfixed;
            uout	: out sfixed
			);
	end component;

begin
	
	v_calc : v_pipeline port map(clk => clk, rst => rst, spike => update, c => c, I => I_in, u => u_out, vout => v_out);
	u_calc : u_pipeline port map(clk => clk, rst => rst, spike => update, a => a, b => b, d => d, v => v_out, uout => u_out);
	
	
	process(clk, rst, v_out)
	begin
		if (rst = '1') then
			current_state <= calc;
		elsif (rising_edge(clk)) then
			case current_state is
				when calc =>
					if (v_out > vpeak) then
						update 	<= '1';
						cnt 	<= 1;
						current_state <= spike_out1;
					else
						current_state <= calc;
					end if;
				
				when spike_out1 =>
					if(cnt = delay) then
						update	   <= '0';
						current_state <= calc;
					else
						update 	<= '1';
						cnt <= cnt + 1;
						current_state <= spike_out2; 
					end if;
				
				when spike_out2 =>
					if(cnt = delay) then
						update	   <= '0';
						current_state <= calc;
					else
						update 	<= '1';
						cnt <= cnt + 1;
						current_state <= spike_out1; 
					end if;
				
				when others => 
					current_state <= calc;
			end case;
		end if;
	end process;
	v <= v_out;
	u <= u_out;
	spike <= update;
	
end RTL;