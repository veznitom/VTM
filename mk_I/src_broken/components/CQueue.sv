module CQueue #(
    parameter type RECORD,
    parameter int  SIZE   = 16
) (
    input  RECORD din,
    input  logic  read,
    write,
    clk,
    reset,
    output RECORD dout,
    output logic  full,
    empty
);

  RECORD records[SIZE];

  always_comb begin : Queue_reset
    if (reset) begin
      foreach (records[i]) begin
        records[i] = '{};
      end
    end
  end

endmodule


