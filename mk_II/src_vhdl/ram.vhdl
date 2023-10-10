library IEEE;
use IEEE.STD_LOGIC_1164.all;

entity ram is
  port(
    clock   : in    std_logic;
    reset   : in    std_logic;
    -- Memory interface
    data    : inout std_logic_vector(255 downto 0);
    address : inout std_logic_vector(31 downto 0);
    read    : in    std_logic;
    write   : in    std_logic;
    ready   : out   std_logic;
    done    : out   std_logic
    );
end entity ram;
