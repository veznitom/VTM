// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module Branch (
  input wire              [31:0] i_data_1,
  input wire              [31:0] i_data_2,
  input wire              [31:0] i_address,
  input wire              [31:0] i_immediate,
  input wire instr_name_e        i_instr_name,

  output reg [31:0] o_store_result,
  output reg [31:0] o_jump_result
);
  // ------------------------------- Behaviour -------------------------------
  /*
  always_comb begin
    case (i_instr_name)
      JAL: begin
        o_jump_result  = i_address + $signed(i_immediate);
        o_store_result = i_address + 4;
      end
      JALR: begin
        o_jump_result  = i_data_1 + $signed(i_immediate);
        o_store_result = i_address + 4;
      end
      BEQ: begin
        if (i_data_1 == i_data_2) o_jump_result = i_address + i_immediate;
        else o_jump_result = i_address + 4;
      end
      BNE: begin
        if (i_data_1 != i_data_2) o_jump_result = i_address + i_immediate;
        else o_jump_result = i_address + 4;
      end
      BLT: begin
        if ($signed(i_data_1) < $signed(i_data_2)) begin
          o_jump_result = i_address + i_immediate;
        end else o_jump_result = i_address + 4;
      end
      BGE: begin
        if (($signed(
                i_data_1
            ) == $signed(
                i_data_2
            )) || ($signed(
                i_data_1
            ) > $signed(
                i_data_2
            ))) begin
          o_jump_result = i_address + i_immediate;
        end else o_jump_result = i_address + 4;
      end
      BLTU: begin
        if (i_data_1 < i_data_2) o_jump_result = i_address + i_immediate;
        else o_jump_result = i_address + 4;
      end
      BGEU: begin
        if ((i_data_1 == i_data_2) || (i_data_1 > i_data_2)) begin
          o_jump_result = i_address + i_immediate;
        end else o_jump_result = i_address + 4;
      end
      default: begin
        o_jump_result  = {32{1'hz}};
        o_store_result = {32{1'hz}};
      end
    endcase
  end
  */
endmodule
