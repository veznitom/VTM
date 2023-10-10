library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity cpu is
  port(
    clock       : in    std_logic;
    reset       : in    std_logic;
    -- Main memory connections
    mem_data    : inout std_logic_vector(255 downto 0);
    mem_address : inout std_logic_vector(31 downto 0);
    mem_ready   : in    std_logic;
    mem_done    : in    std_logic;
    mem_read    : out   std_logic;
    mem_write   : out   std_logic
    );
end entity cpu;
