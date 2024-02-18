library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library vtm_types;
use vtm_types.vtm_enums.all;

entity memory_management_unit is
    port (
        reset : in STD_LOGIC;
        -- Memory bus
        mb_address : out STD_LOGIC_VECTOR(31 downto 0);
        mb_data    : inout STD_LOGIC_VECTOR(31 downto 0);
        mb_read    : out STD_LOGIC;
        mb_write   : out STD_LOGIC;
        mb_ready   : in STD_LOGIC;
        mb_done    : in STD_LOGIC;
        -- Instruction cache bus
        icb_address : in STD_LOGIC_VECTOR(31 downto 0);
        icb_data    : inout STD_LOGIC_VECTOR(31 downto 0);
        icb_read    : in STD_LOGIC;
        icb_ready   : out STD_LOGIC;
        -- Data cache bus
        dcb_address : in STD_LOGIC_VECTOR(31 downto 0);
        dcb_data    : inout STD_LOGIC_VECTOR(31 downto 0);
        dcb_read    : in STD_LOGIC;
        dcb_write   : in STD_LOGIC;
        dcb_ready   : out STD_LOGIC;
        dcb_done    : out STD_LOGIC
    );
end entity memory_management_unit;
