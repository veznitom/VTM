library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity instr_cache is
  port(
    clock         : in    std_logic;
    reset         : in    std_logic;
    -- Main memory interface
    mem_data      : inout std_logic_vector(255 downto 0);
    mem_address   : inout std_logic_vector (31 downto 0);
    mem_ready     : in    std_logic;
    mem_read      : out   std_logic;
    -- CPU interface
    addresses_in  : in    std_logic_vector(0 to 1, 31 downto 0);
    read          : in    std_logic;
    addresses_out : out   std_logic_vector(0 to 1, 31 downto 0);
    instructions  : out   std_logic_vector(0 to 1, 31 downto 0);
    hits          : out   std_logic_vector(0 to 1)
    );
end entity instr_cache;
