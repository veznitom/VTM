library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library vtm_types;
use vtm_types.vtm_enums.all;
use vtm_types.vtm_types.all;

entity reg_file is
    port (
        clk   : in STD_LOGIC;
        reset : in STD_LOGIC;
        -- Input query registers
        iqr_rd   : in REG_PAIR;
        iqr_rs_1 : in REG_PAIR;
        iqr_rs_2 : in REG_PAIR;
        iqr_rn   : in REG_PAIR;
        -- Output query registers
        oqr_rd   : in REG_PAIR;
        oqr_rs_1 : in REG_PAIR;
        oqr_rs_2 : in REG_PAIR;
        oqr_rn   : in REG_PAIR;
        -- Query constol
        qc_0_rename : in STD_LOGIC;
        qc_0_tag    : in STD_LOGIC;
        qc_1_rename : in STD_LOGIC;
        qc_1_tag    : in STD_LOGIC;
        -- Data fetch bus
        rb_data_1  : out STD_LOGIC_VECTOR(31 downto 0);
        rb_data_2  : out STD_LOGIC_VECTOR(31 downto 0);
        rb_src_1   : in STD_LOGIC_VECTOR(5 downto 0);
        rb_src_2   : in STD_LOGIC_VECTOR(5 downto 0);
        rb_valid_1 : out STD_LOGIC;
        rb_valid_2 : out STD_LOGIC;
        -- Data bus
        db_result    : in STD_LOGIC_VECTOR(31 downto 0);
        db_address   : in STD_LOGIC_VECTOR(31 downto 0);
        db_arn       : in STD_LOGIC_VECTOR(5 downto 0);
        db_rrn       : in STD_LOGIC_VECTOR(5 downto 0);
        db_reg_write : in STD_LOGIC
    );
end entity reg_file;
