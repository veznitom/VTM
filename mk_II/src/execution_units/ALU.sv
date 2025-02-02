// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module ALU (
  IntfExtFeed.ALU feed
);
  // ------------------------------- Wires -------------------------------
  reg [31:0] dump;
  // ------------------------------- Behaviour -------------------------------
  always_comb begin
    case (feed.instr_name)
      // Register-feed.immediate operations
      ADDI:  feed.result = feed.data_1 + feed.immediate;
      SLTI:  feed.result = ($signed(feed.data_1) < $signed(feed.immediate));
      SLTIU: feed.result = feed.data_1 < feed.immediate;
      XORI:  feed.result = feed.data_1 ^ feed.immediate;
      ORI:   feed.result = feed.data_1 | feed.immediate;
      ANDI:  feed.result = feed.data_1 & feed.immediate;
      SLLI:  {dump, feed.result} = feed.data_1 << feed.immediate[4:0];
      SRLI:  feed.result = feed.data_1 >> feed.immediate[4:0];
      SRAI:  feed.result = $signed(feed.data_1) >>> feed.immediate[4:0];
      // Register-Register operations
      ADD:   feed.result = feed.data_1 + feed.data_2;
      SUB:   feed.result = feed.data_1 - feed.data_2;
      SLL:   {dump, feed.result} = feed.data_1 << feed.data_2[4:0];
      SLT:   feed.result = $signed(feed.data_1) < $signed(feed.data_2);
      SLTU:  feed.result = feed.data_1 < feed.data_2;
      XOR:   feed.result = feed.data_1 ^ feed.data_2;
      SRL:   feed.result = feed.data_1 >> feed.data_2[4:0];
      SRA:   feed.result = $signed(feed.data_1) >>> feed.data_2[4:0];
      OR:    feed.result = feed.data_1 | feed.data_2;
      AND:   feed.result = feed.data_1 & feed.data_2;
      // Special cases
      LUI:   feed.result = feed.immediate;
      AUIPC: feed.result = feed.address + feed.immediate;
      default: begin
        feed.result = 'z;
        dump        = 'z;
      end
    endcase
  end
endmodule
