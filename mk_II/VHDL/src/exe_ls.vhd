library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library vtm_types;
use vtm_types.vtm_enums.all;

entity exe_ls is
  port (
    data_1     : in STD_LOGIC_VECTOR(31 downto 0);
    data_2     : in STD_LOGIC_VECTOR(31 downto 0);
    address    : in STD_LOGIC_VECTOR(31 downto 0);
    immediate  : in STD_LOGIC_VECTOR(31 downto 0);
    instr_name : in INSTR_NAME_E;

    cache_address : out STD_LOGIC_VECTOR(31 downto 0);
    cache_data    : inout STD_LOGIC_VECTOR(31 downto 0);
    cache_read    : out STD_LOGIC;
    cache_write   : out STD_LOGIC;
    cache_ready   : in STD_LOGIC;
    cache_tag     : out STD_LOGIC;

    result : out STD_LOGIC_VECTOR(31 downto 0)
  );
end entity exe_ls;
