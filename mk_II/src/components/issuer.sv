/*  Controls if destination stations or reorder buffer has enough space to hold another instructions, if they do then the instructions are issued otherwise,
    issuer halts and waits for them to free up (halt also stops loader, decoder, resolver unless there is bubble in the form of zero instruction).
*/

module issuer #(
    parameter int XLEN = 32
) (
    global_signals_if gsi,
    instr_issue_if instr_info_in[2],
    instr_info_out[2],
    input logic st_fullness[4],
    output logic stop
);

  always_ff @(posedge gsi.clk) begin : issue
    if (instr_info[0].instr_name != UNKNOWN && instr_info[1].instr_name != UNKNOWN) begin
      if (!st_fullness[instr_info[0].st_type] && !st_fullness[instr_info[1].st_type]) begin
        for (int i = 0; i < 2; i++) begin
          instr_info_out[i].address <= instr_info_in[i].address;
          instr_info_out[i].immediate <= instr_info_in[i].immediate;
          instr_info_out[i].instr_name <= instr_info_in[i].instr_name;
          instr_info_out[i].st_type <= instr_info_in[i].st_type;
          instr_info_out[i].regs <= instr_info_in[i].regs;
          instr_info_out[i].flags <= instr_info_in[i].flags;
        end
        stop <= 1'h0;
      end else stop <= 1'h1;
    end
  end
endmodule
