library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library vtm_types;
use vtm_types.vtm_enums.all;
use vtm_types.vtm_types.all;

entity loader is
    port (
        clk          : in STD_LOGIC;
        reset        : in STD_LOGIC;
        shuffle_cntr : in STD_LOGIC;
        address      : out WORD_PAIR;
        instr        : out WORD_PAIR;
        -- Cache bus
        cb_address : in STD_LOGIC_VECTOR(31 downto 0);
        cb_data    : in STD_LOGIC_VECTOR(31 downto 0);
        cb_read    : out STD_LOGIC;
        cb_hit     : in STD_LOGIC
    );
    signal pc : STD_LOGIC_VECTOR(31 downto 0);
end entity;
