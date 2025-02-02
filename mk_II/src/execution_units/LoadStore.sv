// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module LoadStore (
  IntfCSB.notag           cs,
  IntfExtFeed.LoadStore   feed,
  IntfDataCache.LoadStore cache
);
  // ------------------------------- Wires -------------------------------
  logic [31:0] dout;
  logic        write;

  // ------------------------------- Behaviour -------------------------------
  assign cache.data = write ? dout : 'z;

  always_comb begin
    if (cs.reset) begin
      feed.result         = '0;
      feed.result_address = '0;
      feed.done           = '0;

      cache.address       = '0;
      cache.read          = '0;
      cache.write         = '0;
      cache.tag           = '0;
      cache.store_type    = '0;

      dout                = '0;
      write               = '0;
    end else begin
      if (feed.instr_name == LB ||
        feed.instr_name == LBU ||
        feed.instr_name == LH ||
        feed.instr_name == LHU ||
        feed.instr_name == LW) begin
        if (cache.hit) begin
          case (feed.instr_name)
            LB: feed.result = {{32 - 8{cache.data[7]}}, cache.data[7:0]};
            LBU: feed.result = {{32 - 8{1'h0}}, cache.data[7:0]};
            LH: feed.result = {{32 - 16{cache.data[15]}}, cache.data[15:0]};
            LHU: feed.result = {{32 - 8{1'h0}}, cache.data[15:0]};
            default: feed.result = cache.data;
          endcase
          feed.result_address = '0;
          feed.done           = '1;

          cache.address       = '0;
          cache.read          = '0;
          cache.write         = '0;
          cache.store_type    = '0;
          cache.tag           = '0;

          write               = '0;
          dout                = '0;
        end else begin
          feed.result         = '0;
          feed.result_address = '0;
          feed.done           = '0;

          cache.address       = feed.data_1 + feed.immediate;
          cache.read          = '1;
          cache.write         = '0;
          cache.store_type    = '0;
          cache.tag           = feed.tag;

          write               = '0;
          dout                = '0;
        end
      end else if
      (feed.instr_name == SB || feed.instr_name == SH || feed.instr_name == SW) begin
        if (cache.done) begin
          feed.result         = feed.data_2;
          feed.result_address = feed.data_1 + feed.immediate;
          feed.done           = '1;

          cache.address       = '0;
          cache.read          = '0;
          cache.write         = '0;
          cache.tag           = '0;
          cache.store_type    = '0;

          write               = '0;
          dout                = '0;
        end else begin
          feed.result         = '0;
          feed.result_address = '0;
          feed.done           = '0;

          cache.address       = feed.data_1 + feed.immediate;
          cache.read          = '0;
          cache.write         = '1;
          cache.tag           = feed.tag;
          case (feed.instr_name)
            SW:      cache.store_type = 0;
            SH:      cache.store_type = 1;
            SB:      cache.store_type = 2;
            default: cache.store_type = 0;
          endcase

          write = '1;
          dout  = feed.data_2;
        end
      end else begin
        feed.result         = '0;
        feed.result_address = '0;
        feed.done           = '0;

        cache.address       = '0;
        cache.read          = '0;
        cache.write         = '0;
        cache.tag           = '0;
        cache.store_type    = '0;

        write               = '0;
        dout                = '0;
      end
    end
  end

endmodule

