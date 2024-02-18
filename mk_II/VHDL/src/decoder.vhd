library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library vtm_types;
use vtm_types.vtm_enums.all;

entity decoder is
    port (
        clk          : in STD_LOGIC;
        reset        : in STD_LOGIC;
        address      : in STD_LOGIC_VECTOR(31 downto 0);
        instr        : in STD_LOGIC_VECTOR(31 downto 0);
        shuffle_cntr : in STD_LOGIC;
        -- Instruction info bus
        iib_address    : out STD_LOGIC_VECTOR(31 downto 0);
        iib_immediate  : out STD_LOGIC_VECTOR(31 downto 0);
        iib_instr_name : out INSTR_NAME_E;
        iib_instr_type : out INSTR_TYPE_E;
        iib_rd         : out STD_LOGIC_VECTOR(5 downto 0);
        iib_rs_1       : out STD_LOGIC_VECTOR(5 downto 0);
        iib_rs_2       : out STD_LOGIC_VECTOR(5 downto 0);
        iib_rn         : out STD_LOGIC_VECTOR(5 downto 0);
        iib_writes     : out STD_LOGIC;
        iib_jumps      : out STD_LOGIC;
        iib_imm        : out STD_LOGIC;
        iib_tag        : out STD_LOGIC;
        iib_mem        : out STD_LOGIC
    );
end entity;
