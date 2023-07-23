module alu #(
    parameter int XLEN = 32
) (
    station_unit_if exec_feed,

    output logic [XLEN-1:0] result
);

  logic [XLEN-1:0] dump;

  always_comb begin
    case (exec_feed.instr_name)
      // Register-Immediate operations
      ADDI:  result = data_1 + immediate;
      SLTI:  result = ($signed(data_1) < $signed(immediate));
      SLTIU: result = data_1 < immediate;
      XORI:  result = data_1 ^ immediate;
      ORI:   result = data_1 | immediate;
      ANDI:  result = data_1 & immediate;
      SLLI:  {dump,result} = data_1 << immediate[4:0];
      SRLI:  result = data_1 >> immediate[4:0];
      SRAI:  result = $signed(data_1) >>> immediate[4:0];
      // Register-Register operations
      ADD:   result = data_1 + data_2;
      SUB:   result = data_1 - data_2;
      SLL:   {dump, result} = data_1 << data_2[4:0];
      SLT:   result = $signed(data_1) < $signed(data_2);
      SLTU:  result = data_1 < data_2;
      XOR:   result = data_1 ^ data_2;
      SRL:   result = data_1 >> data_2[4:0];
      SRA:   result = $signed(data_1) >>> data_2[4:0];
      OR:    result = data_1 | data_2;
      AND:   result = data_1 & data_2;
      // Special cases
      LUI:   result = immediate;
      AUIPC: result = address + immediate;
      default: res = {XLEN1{1'hz}};
    endcase
  end
endmodule
