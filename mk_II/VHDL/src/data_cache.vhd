library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library vtm_types;
use vtm_types.vtm_enums.all;

entity data_cache is
    port (
        clk        : in STD_LOGIC;
        reset      : in STD_LOGIC;
        delete_tag : in STD_LOGIC;
        clear_tag  : in STD_LOGIC;
        -- Memory bus
        mb_address : out STD_LOGIC_VECTOR(31 downto 0);
        mb_data    : inout STD_LOGIC_VECTOR(31 downto 0);
        mb_read    : out STD_LOGIC;
        mb_write   : out STD_LOGIC;
        mb_ready   : in STD_LOGIC;
        mb_done    : in STD_LOGIC;
        -- Cache bus
        cb_address : in STD_LOGIC_VECTOR(31 downto 0);
        cb_data    : inout STD_LOGIC_VECTOR(31 downto 0);
        cb_read    : in STD_LOGIC;
        cb_write   : in STD_LOGIC;
        cb_hit     : out STD_LOGIC;
        cb_tag     : in STD_LOGIC;
        -- Data bus
        db_result      : in STD_LOGIC_VECTOR(31 downto 0);
        db_address     : in STD_LOGIC_VECTOR(31 downto 0);
        db_cache_write : in STD_LOGIC
    );
end entity data_cache;
