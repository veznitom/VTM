module exu_mult_div (
    input logic [31:0] data_1,
    input logic [31:0] data_2,
    input logic [31:0] address,
    input logic [31:0] immediate,
    input instr_name_e instr_name,

    output logic [31:0] result
);
  // ------------------------------- Wires -------------------------------
  logic [31:0] upper_u, upper_s, upper_su;
  logic [31:0] lower_u, lower_s, lower_su;
  logic [31:0] divident_u, divident_s;
  logic [31:0] remainder_u, remainder_s;
  // ------------------------------- Behaviour -------------------------------
  always_comb begin
    {upper_u, lower_u} = data_1 * data_2;
    {upper_s, lower_s} = $signed(data_1) * $signed(data_2);
    {upper_su, lower_su} = $signed(data_1) * data_2;
    divident_u = data_1 / data_2;
    divident_s = $signed(data_1) / $signed(data_2);
    remainder_u = data_1 % data_2;
    remainder_s = $signed(data_1) % $signed(data_2);
  end

  always_comb begin
    case (instr_name)
      MUL: result = lower_s;
      MULH: result = upper_s;
      MULHSU: result = upper_su;
      MULHU: result = upper_u;
      DIV: result = divident_s;
      DIVU: result = divident_u;
      REM: result = remainder_s;
      REMU: result = remainder_u;
      default: result = {XLEN{1'hz}};
    endcase
  end
endmodule
