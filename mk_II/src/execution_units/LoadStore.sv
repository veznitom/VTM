// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module LoadStore (
  input wire              [31:0] i_data_1,
  input wire              [31:0] i_data_2,
  input wire              [31:0] i_address,
  input wire              [31:0] i_immediate,
  input wire instr_name_e        i_instr_name,

  input  wire        i_cache_hit,
  inout  wire [31:0] io_cache_data,
  output reg  [31:0] o_cache_address,
  output reg         o_cache_read,
  output wire        o_cache_write,

  output reg [31:0] o_result
);
  // ------------------------------- Wires -------------------------------
  reg [31:0] cache_data;
  reg        write;

  // ------------------------------- Functions -------------------------------
  function automatic integer is_load_store(input instr_name_e i_instr_name);
    case (i_instr_name)
      LB:      return 1;
      LBU:     return 1;
      LH:      return 1;
      LHU:     return 1;
      LW:      return 1;
      SB:      return 2;
      SH:      return 2;
      SW:      return 2;
      default: return 0;
    endcase
  endfunction

  // ------------------------------- Behaviour -------------------------------
  assign io_cache_data = write ? cache_data : 'z;
  assign o_cache_write = write;

  always_comb begin
    // For some to me unknown reason function identifiaing is f*cking broken >:(
    if (i_instr_name == LB ||
        i_instr_name == LBU ||
        i_instr_name == LH ||
        i_instr_name == LHU ||
        i_instr_name == LW) begin
      if (i_cache_hit) begin
        case (i_instr_name)
          LB: o_result = {{32 - 8{io_cache_data[7]}}, io_cache_data[7:0]};
          LBU: o_result = {{32 - 8{1'h0}}, io_cache_data[7:0]};
          LH: o_result = {{32 - 16{io_cache_data[15]}}, io_cache_data[15:0]};
          LHU: o_result = {{32 - 8{1'h0}}, io_cache_data[15:0]};
          default: o_result = io_cache_data;
        endcase
      end else begin
        o_cache_read    = 1'h1;
        o_cache_address = i_data_1 + i_immediate;
      end
    end else if
      (i_instr_name == SB || i_instr_name == SH || i_instr_name == SW) begin
      write           = 1'h1;
      o_cache_address = i_data_1 + i_immediate;
      cache_data      = i_data_2;
      o_result        = i_data_2;
    end else begin
      o_cache_read = 1'h0;
      write        = 1'h0;
      o_result     = 'z;
    end
  end
endmodule

