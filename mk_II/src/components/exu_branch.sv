module exu_branch (
    input logic [31:0] data_1,
    input logic [31:0] data_2,
    input logic [31:0] address,
    input logic [31:0] immediate,
    input instr_name_e instr_name,

    output logic [31:0] store_result,
    output logic [31:0] jump_result
);
  // ------------------------------- Behaviour -------------------------------
  always_comb begin
    case (instr_name)
      JAL: begin
        jump_result  = address + $signed(immediate);
        store_result = address + 4;
      end
      JALR: begin
        jump_result  = data_1 + $signed(immediate);
        store_result = address + 4;
      end
      BEQ: begin
        if (data_1 === data_2) jump_result = address + immediate;
        else jump_result = address + 4;
      end
      BNE: begin
        if (data_1 !== data_2) jump_result = address + immediate;
        else jump_result = address + 4;
      end
      BLT: begin
        if ($signed(data_1) < $signed(data_2)) jump_result = address + immediate;
        else jump_result = address + 4;
      end
      BGE: begin
        if (($signed(data_1) == $signed(data_2)) || ($signed(data_1) > $signed(data_2)))
          jump_result = address + immediate;
        else jump_result = address + 4;
      end
      BLTU: begin
        if (data_1 < data_2) jump_result = address + immediate;
        else jump_result = address + 4;
      end
      BGEU: begin
        if ((data_1 == data_2) || (data_1 > data_2)) jump_result = address + immediate;
        else jump_result = address + 4;
      end
      default: begin
        jump_result  = {32{1'hz}};
        store_result = {32{1'hz}};
      end
    endcase
  end
endmodule
