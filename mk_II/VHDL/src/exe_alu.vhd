library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library vtm_types;
use vtm_types.vtm_enums.all;

entity exe_alu is
  port (
    data_1     : in STD_LOGIC_VECTOR(31 downto 0);
    data_2     : in STD_LOGIC_VECTOR(31 downto 0);
    address    : in STD_LOGIC_VECTOR(31 downto 0);
    immediate  : in STD_LOGIC_VECTOR(31 downto 0);
    instr_name : in INSTR_NAME_E;

    result : out STD_LOGIC_VECTOR(31 downto 0)
  );
end entity exe_alu;
