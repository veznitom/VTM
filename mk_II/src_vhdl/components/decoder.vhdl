library IEEE;
use IEEE.std_logic_1164.all;

library work;
use work.all;

entity decoder is
  port (
    clock            : in  std_logic;
    reset            : in  std_logic;
    addresses_in     : in  std_logic_vector(0 to 1, 31 downto 0);
    instructions_in : in  std_logic_vector(0 to 1, 31 downto 0);
    addresses_out    : out std_logic_vector(0 to 1, 31 downto 0);
    instructions_out : out std_logic_vector(0 to 1, 31 downto 0);
    instr_names : out instr_name_e(0 to 1);
    instr_type : out instr_type_e(0 to 1);
    registers : out registers_r
    );
end entity decoder;
