library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library vtm_types;
use vtm_types.vtm_enums.all;
use vtm_types.vtm_types.all;

entity res_station is
    port (
        clk        : in STD_LOGIC;
        reset      : in STD_LOGIC;
        delete_tag : out STD_LOGIC;
        clear_tag  : out STD_LOGIC;
        result_reg : out STD_LOGIC_VECTOR(5 downto 0);
        next_rec   : in STD_LOGIC;
        -- Issue bus
        ib_data_1     : in STD_LOGIC_VECTOR(31 downto 0);
        ib_data_2     : in STD_LOGIC_VECTOR(31 downto 0);
        ib_address    : in STD_LOGIC_VECTOR(31 downto 0);
        ib_immediate  : in STD_LOGIC_VECTOR(31 downto 0);
        ib_valid_1    : in STD_LOGIC;
        ib_valid_2    : in STD_LOGIC;
        ib_instr_name : in INSTR_NAME_E;
        ib_instr_type : in INSTR_TYPE_E;
        ib_rd         : in STD_LOGIC_VECTOR(5 downto 0);
        ib_rs_1       : in STD_LOGIC_VECTOR(5 downto 0);
        ib_rs_2       : in STD_LOGIC_VECTOR(5 downto 0);
        ib_rn         : in STD_LOGIC_VECTOR(5 downto 0);
        ib_full       : out STD_LOGIC;
        -- Data bus
        db_result : in STD_LOGIC_VECTOR(31 downto 0);
        db_arn    : in STD_LOGIC_VECTOR(5 downto 0);
        db_rrn    : in STD_LOGIC_VECTOR(5 downto 0);
        -- Feed bus
        fb_data_1     : out STD_LOGIC_VECTOR(31 downto 0);
        fb_data_2     : out STD_LOGIC_VECTOR(31 downto 0);
        fb_address    : out STD_LOGIC_VECTOR(31 downto 0);
        fb_immediate  : out STD_LOGIC_VECTOR(31 downto 0);
        fb_instr_name : out INSTR_NAME_E
    );
end entity;
