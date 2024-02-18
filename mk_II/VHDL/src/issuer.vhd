library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library vtm_types;
use vtm_types.vtm_enums.all;

entity issuer is
    port (
        clk           : in STD_LOGIC;
        reset         : in STD_LOGIC;
        delete_tag    : in STD_LOGIC;
        clear_tag     : in STD_LOGIC;
        stations_full : in STD_LOGIC_VECTOR(3 downto 0);
        shuffle_stop  : out STD_LOGIC;
        shuffle_cntr  : in STD_LOGIC;
        -- Input instruction info bus
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
        -- Outputs instruction info bus
        oib_address    : out STD_LOGIC_VECTOR(31 downto 0);
        oib_immediate  : out STD_LOGIC_VECTOR(31 downto 0);
        oib_instr_name : out INSTR_NAME_E;
        oib_instr_type : out INSTR_TYPE_E;
        oib_rd         : out STD_LOGIC_VECTOR(5 downto 0);
        oib_rs_1       : out STD_LOGIC_VECTOR(5 downto 0);
        oib_rs_2       : out STD_LOGIC_VECTOR(5 downto 0);
        oib_rn         : out STD_LOGIC_VECTOR(5 downto 0);
        oib_writes     : out STD_LOGIC;
        oib_jumps      : out STD_LOGIC;
        oib_imm        : out STD_LOGIC;
        oib_tag        : out STD_LOGIC;
        oib_mem        : out STD_LOGIC
    );
end entity;
