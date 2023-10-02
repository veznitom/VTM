library custom;
use custom.structures.all;
use custom.interfaces.feed_bus_if;
use custom.global_variables.all;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity alu is 
	generic (XLEN : integer := 32);
	port (
		feed_bus : feed_bus_if;
		result : out std_logic_vector(XLEN-1 downto 0)
	);
end entity ALU;

architecture def_alu_bhv of alu is
	signal dump: std_logic_vector(XLEN-1 downto 0);
begin
	alu_ops:
	process begin
		case feed_bus.instr_name is
			-- Register-Immediate operations
			when E_ADDI => result <= std_logic_vector(signed(feed_bus.data_1) + signed(feed_bus.immediate));
			when E_SLTI => 
				if signed(feed_bus.data_1) < signed(feed_bus.immediate) then
				 result <= "1";
				else
			 		result <= (others => '0');
			 	end if;
			when E_SLTI => 
				if unsigned(feed_bus.data_1) < unsigned(feed_bus.immediate) then
					result <= "1";
				else
			 		result <= (others => '0');
			 	end if;			
			when E_XORI => result <= std_logic_vector(signed(feed_bus.data_1) xor signed(feed_bus.immediate));
			when E_ORI => result <= std_logic_vector(signed(feed_bus.data_1) or signed(feed_bus.immediate));
			when E_ANDI => result <= std_logic_vector(signed(feed_bus.data_1) and signed(feed_bus.immediate));
			when E_SLLI => result <= std_logic_vector(shift_left(unsigned(feed_bus.data_1),TO_INTEGER(unsigned(feed_bus.immediate))));
			when E_SRLI => result <= std_logic_vector(signed(feed_bus.data_1) + signed(feed_bus.immediate));
			when E_SRAI => result <= std_logic_vector(signed(feed_bus.data_1) + signed(feed_bus.immediate));
			-- Register-Register operations
			when E_ADD => result <= std_logic_vector(signed(feed_bus.data_1) + signed(feed_bus.data_2));
			when E_SUB => result <= std_logic_vector(signed(feed_bus.data_1) + signed(feed_bus.data_2));
			when E_SLL => result <= std_logic_vector(signed(feed_bus.data_1) + signed(feed_bus.data_2));
			when E_SLT => result <= std_logic_vector(signed(feed_bus.data_1) + signed(feed_bus.data_2));
			when E_SLTU => result <= std_logic_vector(signed(feed_bus.data_1) + signed(feed_bus.data_2));
			when E_XOR => result <= std_logic_vector(signed(feed_bus.data_1) + signed(feed_bus.data_2));
			when E_SRL => result <= std_logic_vector(signed(feed_bus.data_1) + signed(feed_bus.data_2));
			when E_SRA => result <= std_logic_vector(signed(feed_bus.data_1) + signed(feed_bus.data_2));
			when E_OR => result <= std_logic_vector(signed(feed_bus.data_1) + signed(feed_bus.data_2));
			when E_AND => result <= std_logic_vector(signed(feed_bus.data_1) + signed(feed_bus.data_2));
			-- Special operations
			when E_LUI => result <= std_logic_vector(signed(feed_bus.data_1) + signed(feed_bus.data_2));
			when E_AUIPC => result <= std_logic_vector(signed(feed_bus.data_1) + signed(feed_bus.data_2));
			when others => result <= (others => '0');
		end case;
	end process;
end def_alu_bhv;