import structures::*;

module alu #(
    parameter int XLEN = 32
) (
    feed_bus_if.exec feed_bus,

    output logic [XLEN-1:0] result
);

  logic [XLEN-1:0] dump;

  always_comb begin
    case (feed_bus.instr_name)
      // Register-feed_bus.immediate operations
      ADDI:  result = feed_bus.data_1 + feed_bus.immediate;
      SLTI:  result = ($signed(feed_bus.data_1) < $signed(feed_bus.immediate));
      SLTIU: result = feed_bus.data_1 < feed_bus.immediate;
      XORI:  result = feed_bus.data_1 ^ feed_bus.immediate;
      ORI:   result = feed_bus.data_1 | feed_bus.immediate;
      ANDI:  result = feed_bus.data_1 & feed_bus.immediate;
      SLLI:  {dump,result} = feed_bus.data_1 << feed_bus.immediate[4:0];
      SRLI:  result = feed_bus.data_1 >> feed_bus.immediate[4:0];
      SRAI:  result = $signed(feed_bus.data_1) >>> feed_bus.immediate[4:0];
      // Register-Register operations
      ADD:   result = feed_bus.data_1 + feed_bus.data_2;
      SUB:   result = feed_bus.data_1 - feed_bus.data_2;
      SLL:   {dump, result} = feed_bus.data_1 << feed_bus.data_2[4:0];
      SLT:   result = $signed(feed_bus.data_1) < $signed(feed_bus.data_2);
      SLTU:  result = feed_bus.data_1 < feed_bus.data_2;
      XOR:   result = feed_bus.data_1 ^ feed_bus.data_2;
      SRL:   result = feed_bus.data_1 >> feed_bus.data_2[4:0];
      SRA:   result = $signed(feed_bus.data_1) >>> feed_bus.data_2[4:0];
      OR:    result = feed_bus.data_1 | feed_bus.data_2;
      AND:   result = feed_bus.data_1 & feed_bus.data_2;
      // Special cases
      LUI:   result = feed_bus.immediate;
      AUIPC: result = feed_bus.address + feed_bus.immediate;
      default: result = {XLEN{1'hz}};
    endcase
  end
endmodule
