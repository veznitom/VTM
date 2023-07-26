import structures::*;

module mult_div #(
    parameter int XLEN = 32
) (
    station_unit_if exec_feed,

    output logic [XLEN-1:0] result
);

  logic [XLEN-1:0] upper_u, upper_s, upper_su, lower_u, lower_s, lower_su;
  logic [XLEN-1:0] divident_u, divident_s, remainder_u, remainder_s;

  always_comb begin
    {upper_u, lower_u} = exec_feed.data_1 * exec_feed.data_2;
    {upper_s, lower_s} = $signed(exec_feed.data_1) * $signed(exec_feed.data_2);
    {upper_su, lower_su} = $signed(exec_feed.data_1) * exec_feed.data_2;
    divident_u = exec_feed.data_1 / exec_feed.data_2;
    divident_s = $signed(exec_feed.data_1) / $signed(exec_feed.data_2);
    remainder_u = exec_feed.data_1 % exec_feed.data_2;
    remainder_s = $signed(exec_feed.data_1) % $signed(exec_feed.data_2);
  end

  always_comb begin
    case (exec_feed.instr_name)
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
