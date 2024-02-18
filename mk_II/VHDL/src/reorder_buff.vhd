library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library vtm_types;
use vtm_types.vtm_enums.all;
use vtm_types.vtm_types.all;

entity reorder_buff is
    port (
        clk         : in STD_LOGIC;
        reset       : in STD_LOGIC;
        delete_tag  : out STD_LOGIC;
        clear_tag   : out STD_LOGIC;
        jmp_address : out STD_LOGIC_VECTOR(31 downto 0);
        jmp_write   : out STD_LOGIC;
        -- Issue bus
        ib_address    : in STD_LOGIC_VECTOR(31 downto 0);
        ib_instr_name : in INSTR_NAME_E;
        ib_instr_type : in INSTR_TYPE_E;
        ib_rd         : in STD_LOGIC_VECTOR(5 downto 0);
        ib_rs_1       : in STD_LOGIC_VECTOR(5 downto 0);
        ib_rs_2       : in STD_LOGIC_VECTOR(5 downto 0);
        ib_rn         : in STD_LOGIC_VECTOR(5 downto 0);
        ib_full       : out STD_LOGIC;
        -- Data bus
        db_result      : inout STD_LOGIC_VECTOR(31 downto 0);
        db_address     : inout STD_LOGIC_VECTOR(31 downto 0);
        db_jmp_address : inout STD_LOGIC_VECTOR(31 downto 0);
        db_arn         : inout STD_LOGIC_VECTOR(5 downto 0);
        db_rrn         : inout STD_LOGIC_VECTOR(5 downto 0);
        db_reg_write   : out STD_LOGIC;
        db_cache_write : out STD_LOGIC;
        db_request     : out STD_LOGIC;
        db_id          : in STD_LOGIC_VECTOR(1 downto 0)
    );
end entity reorder_buff;
