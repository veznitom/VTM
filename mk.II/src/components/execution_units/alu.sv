import structures::*;

module alu #(
    parameter int XLEN = 32
) (
    station_unit_if.exec exec_feed,

    output logic [XLEN-1:0] result
);

  logic [XLEN-1:0] dump;

  always_comb begin
    case (exec_feed.instr_name)
      // Register-exec_feed.immediate operations
      ADDI:  result = exec_feed.data_1 + exec_feed.immediate;
      SLTI:  result = ($signed(exec_feed.data_1) < $signed(exec_feed.immediate));
      SLTIU: result = exec_feed.data_1 < exec_feed.immediate;
      XORI:  result = exec_feed.data_1 ^ exec_feed.immediate;
      ORI:   result = exec_feed.data_1 | exec_feed.immediate;
      ANDI:  result = exec_feed.data_1 & exec_feed.immediate;
      SLLI:  {dump,result} = exec_feed.data_1 << exec_feed.immediate[4:0];
      SRLI:  result = exec_feed.data_1 >> exec_feed.immediate[4:0];
      SRAI:  result = $signed(exec_feed.data_1) >>> exec_feed.immediate[4:0];
      // Register-Register operations
      ADD:   result = exec_feed.data_1 + exec_feed.data_2;
      SUB:   result = exec_feed.data_1 - exec_feed.data_2;
      SLL:   {dump, result} = exec_feed.data_1 << exec_feed.data_2[4:0];
      SLT:   result = $signed(exec_feed.data_1) < $signed(exec_feed.data_2);
      SLTU:  result = exec_feed.data_1 < exec_feed.data_2;
      XOR:   result = exec_feed.data_1 ^ exec_feed.data_2;
      SRL:   result = exec_feed.data_1 >> exec_feed.data_2[4:0];
      SRA:   result = $signed(exec_feed.data_1) >>> exec_feed.data_2[4:0];
      OR:    result = exec_feed.data_1 | exec_feed.data_2;
      AND:   result = exec_feed.data_1 & exec_feed.data_2;
      // Special cases
      LUI:   result = exec_feed.immediate;
      AUIPC: result = exec_feed.address + exec_feed.immediate;
      default: result = {XLEN{1'hz}};
    endcase
  end
endmodule
