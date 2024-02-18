package vtm_enums is
  type INSTR_NAME_E is (TMP);
  type INSTR_TYPE_E is (AL);
  type MMU_LOCK_E is (FREE, INSTR, DATA);
end package vtm_enums;

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
package vtm_types is
  type WORD_PAIR is array (0 to 1) of STD_LOGIC_VECTOR(31 downto 0);
  type REG_PAIR is array (0 to 1) of STD_LOGIC_VECTOR(5 downto 0);

end package vtm_types;

package vtm_records is
end package vtm_records;
