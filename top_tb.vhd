-- Title : Testbench for neuron top level entity
-- Author : Jonathan Jennycloss
-- Description: Includes the code to calculate the differential equation for v every 1 ms.

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

library xil_defaultlib;
use xil_defaultlib.fixed_pkg.all;

entity top_tb is
end top_tb;

architecture tb of top_tb is
	signal clk  	: std_logic := '1';
	signal rst  	: std_logic := '0';
	
	--signal vo    	: sfixed(7 downto -10) := to_sfixed(-65, 7,-10);
	--signal uo      	: sfixed(6 downto -10) := to_sfixed(0, 6,-10);
	--signal spike  	: std_logic := '0';
	signal output1 : std_logic_vector(7 downto 0) := "00000000";
	constant clk_period : time := 5 ns;
	
begin
	clk <= not clk after clk_period /2; -- generate clock
	--DUT : entity work.top port map (clk => clk, rst => rst, vo => vo, uo => uo, spike => spike);
	--DUT : entity work.top port map (clk => clk, rst => rst, output1 => output1);
	DUT : entity work.top port map (clk => clk, rst => rst, output1 => output1);

	process
	begin
		rst <= '1';
		wait for clk_period;
		rst <='0';
		wait for clk_period;
	
		wait;
	end process;

end tb;