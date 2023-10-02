library custom;
use custom.global_variables.XLEN;
use custom.structures.instr_name_e;

library IEEE;
use IEEE.std_logic_1164.all;

package interfaces is
	type feed_bus_if is record
		data_1		: std_logic_vector(XLEN-1 downto 0);
		data_2		: std_logic_vector(XLEN-1 downto 0);
		address		: std_logic_vector(XLEN-1 downto 0);
		immediate	: std_logic_vector(XLEN-1 downto 0);
		instr_name	: instr_name_e;
		rrn			: std_logic_vector(5 downto 0);
	end record feed_bus_if;
end package interfaces;