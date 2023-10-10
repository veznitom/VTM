library IEEE;
use IEEE.std_logic_1164.all;

entity loader is
  port (
    clock            : in  std_logic;
    reset            : in  std_logic;
    -- Cache interface
    instructions_in  : in  std_logic_vector(0 to 1, 31 downto 0);
    addresses_in     : in  std_logic_vector(0 to 1, 31 downto 0);
    hits             : in  std_logic_vector(0 to 1);
    stop             : in  std_logic;
    instructions_out : out std_logic_vector(1 to 1, 31 downto 0);
    addresses_out    : out std_logic_vector(0 to 1, 31 downto 0);
    pc_incerement    : out std_logic
    );
end entity;
