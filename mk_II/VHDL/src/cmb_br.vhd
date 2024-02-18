library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library vtm_types;
use vtm_types.vtm_enums.all;

entity cmb_br is
  port (
    clk        : in STD_LOGIC;
    reset      : in STD_LOGIC;
    delete_tag : in STD_LOGIC;
    clear_tag  : in STD_LOGIC;
    -- Issue bus
    ib_data_1     : in STD_LOGIC_VECTOR(31 downto 0);
    ib_data_2     : in STD_LOGIC_VECTOR(31 downto 0);
    ib_address : in STD_LOGIC_VECTOR(31 downto 0);
    ib_immediate  : in STD_LOGIC_VECTOR(31 downto 0);
    ib_valid_1    : in STD_LOGIC;
    ib_valid_2    : in STD_LOGIC;
    ib_instr_name : in INSTR_NAME_E;
    ib_instr_type : in INSTR_TYPE_E;
    ib_rd         : in STD_LOGIC_VECTOR(5 downto 0);
    ib_rs_1       : in STD_LOGIC_VECTOR(5 downto 0);
    ib_rs_2       : in STD_LOGIC_VECTOR(5 downto 0);
    ib_rn         : in STD_LOGIC_VECTOR(5 downto 0);
    ib_fulll      : out STD_LOGIC;
    -- Data bus
    db_result  : out STD_LOGIC_VECTOR(31 downto 0);
    db_address : out STD_LOGIC_VECTOR(31 downto 0);
    db_arn     : out STD_LOGIC_VECTOR(5 downto 0);
    db_rrn     : out STD_LOGIC_VECTOR(5 downto 0);
    db_request : out STD_LOGIC;
    db_id      : in STD_LOGIC_VECTOR(1 downto 0)
  );
end entity cmb_br;
