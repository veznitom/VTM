// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module ALU (
  input  wire              [31:0] i_data_1,
  input  wire              [31:0] i_data_2,
  input  wire              [31:0] i_address,
  input  wire              [31:0] i_immediate,
  input  wire instr_name_e        i_instr_name,
  output reg               [31:0] o_result
);
  // ------------------------------- Wires -------------------------------
  reg [31:0] dump;
  // ------------------------------- Behaviour -------------------------------
  always_comb begin
    case (i_instr_name)
      // Register-i_immediate operations
      ADDI:    o_result = i_data_1 + i_immediate;
      SLTI:    o_result = ($signed(i_data_1) < $signed(i_immediate));
      SLTIU:   o_result = i_data_1 < i_immediate;
      XORI:    o_result = i_data_1 ^ i_immediate;
      ORI:     o_result = i_data_1 | i_immediate;
      ANDI:    o_result = i_data_1 & i_immediate;
      SLLI:    {dump, o_result} = i_data_1 << i_immediate[4:0];
      SRLI:    o_result = i_data_1 >> i_immediate[4:0];
      SRAI:    o_result = $signed(i_data_1) >>> i_immediate[4:0];
      // Register-Register operations
      ADD:     o_result = i_data_1 + i_data_2;
      SUB:     o_result = i_data_1 - i_data_2;
      SLL:     {dump, o_result} = i_data_1 << i_data_2[4:0];
      SLT:     o_result = $signed(i_data_1) < $signed(i_data_2);
      SLTU:    o_result = i_data_1 < i_data_2;
      XOR:     o_result = i_data_1 ^ i_data_2;
      SRL:     o_result = i_data_1 >> i_data_2[4:0];
      SRA:     o_result = $signed(i_data_1) >>> i_data_2[4:0];
      OR:      o_result = i_data_1 | i_data_2;
      AND:     o_result = i_data_1 & i_data_2;
      // Special cases
      LUI:     o_result = i_immediate;
      AUIPC:   o_result = i_address + i_immediate;
      default: o_result = 'z;
    endcase
  end
endmodule
