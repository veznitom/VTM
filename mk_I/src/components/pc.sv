import CustomTypes::*;

module PC (
  GlobalSignals.rest global_signals,
  PCInterface.pc pc_control
);
  
  logic [31:0] pc;

  assign pc_control.address = pc;
    
  always @( posedge global_signals.reset or posedge pc_control.inc or posedge pc_control.inc2 or posedge pc_control.wr ) begin
    if (global_signals.reset)
      pc <= 32'h00000000;
    else begin
      if (pc_control.wr)
        pc <= pc_control.jump_address;
      else if (pc_control.inc)
        pc <= pc + 4;
      else if (pc_control.inc2)
        pc <= pc + 8;
      else
        pc <= pc;
    end
  end

endmodule