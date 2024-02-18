library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library vtm_types;
use vtm_types.vtm_enums.all;

entity comparator is
    port (
        -- Instruction info bus
        iib_address    : in STD_LOGIC_VECTOR(31 downto 0);
        iib_immediate  : in STD_LOGIC_VECTOR(31 downto 0);
        iib_instr_name : in INSTR_NAME_E;
        iib_instr_type : in INSTR_TYPE_E;
        iib_rd         : in STD_LOGIC_VECTOR(5 downto 0);
        iib_rs_1       : in STD_LOGIC_VECTOR(5 downto 0);
        iib_rs_2       : in STD_LOGIC_VECTOR(5 downto 0);
        iib_rn         : in STD_LOGIC_VECTOR(5 downto 0);
        iib_writes     : in STD_LOGIC;
        iib_jumps      : in STD_LOGIC;
        iib_imm        : in STD_LOGIC;
        iib_tag        : in STD_LOGIC;
        iib_mem        : in STD_LOGIC;
        -- Issue bus
        ib_data_1     : out STD_LOGIC_VECTOR(31 downto 0);
        ib_data_2     : out STD_LOGIC_VECTOR(31 downto 0);
        ib_address : out STD_LOGIC_VECTOR(31 downto 0);
        ib_immediate  : out STD_LOGIC_VECTOR(31 downto 0);
        ib_valid_1    : out STD_LOGIC;
        ib_valid_2    : out STD_LOGIC;
        ib_instr_name : out INSTR_NAME_E;
        ib_instr_type : out INSTR_TYPE_E;
        ib_rd         : out STD_LOGIC_VECTOR(5 downto 0);
        ib_rs_1       : out STD_LOGIC_VECTOR(5 downto 0);
        ib_rs_2       : out STD_LOGIC_VECTOR(5 downto 0);
        ib_rn         : out STD_LOGIC_VECTOR(5 downto 0);
        -- Register bus
        rb_data_1  : in STD_LOGIC_VECTOR(31 downto 0);
        rb_data_2  : in STD_LOGIC_VECTOR(31 downto 0);
        rb_src_1   : out STD_LOGIC_VECTOR(5 downto 0);
        rb_src_2   : out STD_LOGIC_VECTOR(5 downto 0);
        rb_valid_1 : in STD_LOGIC;
        rb_valid_2 : in STD_LOGIC;
        -- Data bus
        db_result : in STD_LOGIC_VECTOR(31 downto 0);
        db_arn    : in STD_LOGIC_VECTOR(5 downto 0);
        db_rrn    : in STD_LOGIC_VECTOR(5 downto 0)
    );
end entity;
