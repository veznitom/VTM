import global_variables::XLEN;

module mult_div (
    feed_bus_if.exec feed_bus,

    output logic [XLEN-1:0] result
);
  // ------------------------------- Wires -------------------------------
  logic [XLEN-1:0] upper_u, upper_s, upper_su;
  logic [XLEN-1:0] lower_u, lower_s, lower_su;
  logic [XLEN-1:0] divident_u, divident_s;
  logic [XLEN-1:0] remainder_u, remainder_s;
  // ------------------------------- Behaviour -------------------------------
  always_comb begin
    {upper_u, lower_u} = feed_bus.data_1 * feed_bus.data_2;
    {upper_s, lower_s} = $signed(feed_bus.data_1) * $signed(feed_bus.data_2);
    {upper_su, lower_su} = $signed(feed_bus.data_1) * feed_bus.data_2;
    divident_u = feed_bus.data_1 / feed_bus.data_2;
    divident_s = $signed(feed_bus.data_1) / $signed(feed_bus.data_2);
    remainder_u = feed_bus.data_1 % feed_bus.data_2;
    remainder_s = $signed(feed_bus.data_1) % $signed(feed_bus.data_2);
  end

  always_comb begin
    case (feed_bus.instr_name)
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
