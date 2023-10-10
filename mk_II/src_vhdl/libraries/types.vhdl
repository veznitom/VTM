library IEEE;
use IEEE.std_logic_1164.all;

package types is

  type instr_name_e is (UNKNOWN, ADDI);

  type instr_type_e is (XX, ALU);

  type registers_r is record
    rs1 : std_logic_vector(5 downto 0);
    rs2 : std_logic_vector(5 downto 0);
    rd  : std_logic_vector(5 downto 0);
    rn  : std_logic_vector(5 downto 0);
  end record registers_r;

  type flags_r is record
    write : std_logic;
    jump  : std_logic;
    imm   : std_logic;
    tag   : std_logic;
    mem   : std_logic;
  end record flags_r;

  type instr_info_r is record
    address     : std_logic_vector(31 downto 0);
    instruction : std_logic_vector(31 downto 0);
    name        : instr_name_e;
    \type\      : instr_type_e;
    registers   : registers_r;
    flags       : flags_r;
  end record instr_info_r;

  type addr_instr_pack_r is record
    address     : std_logic_vector(31 downto 0);
    instruction : std_logic_vector (31 downto 0);
  end record addr_instr_pack_r;
end package types;
