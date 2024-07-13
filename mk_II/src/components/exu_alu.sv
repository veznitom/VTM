import pkg_structures::*;

module exu_alu (
    input logic [31:0] data_1,
    input logic [31:0] data_2,
    input logic [31:0] address,
    input logic [31:0] immediate,
    input instr_name_e instr_name,

    output logic [31:0] result
);
  // ------------------------------- Wires -------------------------------
  logic [31:0] dump;

  // ------------------------------- Behaviour -------------------------------
  always_comb begin
    case (instr_name)
      // Register-immediate operations
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
      default: result = 'z;
    endcase
  end
endmodule
