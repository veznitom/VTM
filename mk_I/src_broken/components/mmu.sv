import CustomTypes::*;

module MemoryManagementUnit(
  GlobalSignals.rest global_signals,
  MemoryBus.cpu mem_bus,
  InstrMemoryBus.mmu instr_bus,
  DataMemoryBus.mmu data_bus
);

  reg [1:0] lock;

  assign data_bus.data = data_bus.ready ? mem_bus.data[data_bus.width-1:0] : {data_bus.width{1'bz}};
  assign mem_bus.data[data_bus.width-1:0] = data_bus.write && !(instr_bus.read || data_bus.read) ? data_bus.data : {data_bus.width{1'bz}};

  always @(*) begin
    if (global_signals.reset)
      lock <= 2'b00;
  end

  always @( posedge global_signals.clk ) begin
    if (!mem_bus.ready && !mem_bus.done)
      lock <= 2'b00;

    if(instr_bus.read && !lock[1] && !global_signals.delete_tagged) begin
      lock <= 2'b01;
      if (mem_bus.ready) begin
        instr_bus.data <= mem_bus.data[instr_bus.width-1:0];
        instr_bus.ready <= 1'b1;
      end else begin
        mem_bus.address <= instr_bus.address;
        mem_bus.read <= 1'b1;
        mem_bus.source <= 1'b0;
        instr_bus.ready <= 1'b0;
      end
    end else if (data_bus.read && !lock[0]) begin
      lock <= 2'b10;
      if (mem_bus.ready) begin
        data_bus.ready <= 1'b1;
      end else begin
        mem_bus.address <= data_bus.address;
        mem_bus.read <= 1'b1;
        mem_bus.source <= 1'b1;
        data_bus.ready <= 1'b0;
      end
    end else if (data_bus.write && !lock[0]) begin
      lock <= 2'b10;
      if (mem_bus.done) begin
        mem_bus.write <= 1'b0;
        data_bus.done <= 1'b1;
      end else begin
        mem_bus.write <= 1'b1;
        mem_bus.ws <= data_bus.ws;
        data_bus.done <= 1'b0;
      end
    end else begin
      mem_bus.address <= 32'hzzzzzzzz;
      mem_bus.read <= 1'b0;
      mem_bus.write <= 1'b0;
      mem_bus.source <= 1'b0;
      mem_bus.ws <= EMPTY;
      instr_bus.ready <= 1'b0;
      data_bus.ready <= 1'b0;
      data_bus.done <= 1'b0;
      data_bus.ws <= EMPTY;
    end
  end
endmodule