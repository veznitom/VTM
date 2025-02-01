// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module LoadStore (
  input wire                     i_clock,
  input wire                     i_reset,
  input wire              [31:0] i_data_1,
  input wire              [31:0] i_data_2,
  input wire              [31:0] i_address,
  input wire              [31:0] i_immediate,
  input wire instr_name_e        i_instr_name,
  input wire                     i_tag,

  IntfDataCache.LoadStore cache,

  output logic [31:0] o_result,
  output logic [31:0] o_store_address,
  output logic        o_ready
);
  // ------------------------------- Behaviour -------------------------------

  always_ff @(posedge i_clock) begin
    if (i_reset) begin
      o_result        <= '0;
      o_store_address <= '0;
      o_ready         <= '0;
      cache.address   <= '0;
      cache.dout      <= '0;
      cache.read      <= '0;
      cache.write     <= '0;
    end else begin
      if (i_instr_name == LB ||
        i_instr_name == LBU ||
        i_instr_name == LH ||
        i_instr_name == LHU ||
        i_instr_name == LW) begin
        if (cache.hit) begin
          case (i_instr_name)
            LB:      o_result <= {{32 - 8{cache.din[7]}}, cache.din[7:0]};
            LBU:     o_result <= {{32 - 8{1'h0}}, cache.din[7:0]};
            LH:      o_result <= {{32 - 16{cache.din[15]}}, cache.din[15:0]};
            LHU:     o_result <= {{32 - 8{1'h0}}, cache.din[15:0]};
            default: o_result <= cache.din;
          endcase
          o_store_address <= '0;
          o_ready         <= '1;

          cache.address   <= '0;
          cache.read      <= '0;
          cache.tag       <= '0;
        end else begin
          cache.read    <= '1;
          cache.tag     <= i_tag;
          cache.address <= i_data_1 + i_immediate;
          cache.write   <= '0;
          cache.dout    <= '0;
        end
      end else if
      (i_instr_name == SB || i_instr_name == SH || i_instr_name == SW) begin
        if (cache.ready) begin
          o_result         <= i_data_2;
          o_store_address  <= i_data_1 + i_immediate;
          o_ready          <= '1;

          cache.address    <= '0;
          cache.dout       <= '0;
          cache.write      <= '0;
          cache.tag        <= '0;
          cache.store_type <= '0;
        end else begin
          cache.address <= i_data_1 + i_immediate;
          cache.dout    <= i_data_2;
          cache.write   <= '1;
          cache.tag     <= i_tag;
          case (i_instr_name)
            SW:      cache.store_type <= 0;
            SH:      cache.store_type <= 1;
            SB:      cache.store_type <= 2;
            default: cache.store_type <= 0;
          endcase

          o_ready <= '0;
        end
      end else begin
        cache.address   <= '0;
        cache.dout      <= '0;
        cache.read      <= '0;
        cache.write     <= '0;
        cache.tag       <= '0;
        o_result        <= '0;
        o_store_address <= '0;
        o_ready         <= '0;
      end
    end
  end

endmodule

