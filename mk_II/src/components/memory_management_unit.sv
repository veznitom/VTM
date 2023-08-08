import structures::*;

module memory_management_unit (
    global_bus_if.rest global_bus,
    memory_bus_if.mmu  data_bus,
    memory_bus_if.mmu  instr_bus,
    memory_bus_if.cpu  memory_bus
);
  typedef enum logic [1:0] {
    FREE,
    INSTR,
    DATA
  } mmu_state_e;

  mmu_state_e lock;

  always_comb begin : access_management
    if (global_bus.reset) lock = FREE;
    else if (instr_bus.read && lock != DATA) begin : instructions_read
      lock = INSTR;
      if (memory_bus.ready) begin
        instr_bus.data  = memory_bus.data;
        instr_bus.ready = 1'h1;
      end else begin
        memory_bus.address = instr_bus.address;
        memory_bus.read = 1'h1;
        instr_bus.ready = 1'h0;
      end
    end else if (data_bus.read && lock != INSTR) begin : data_read
      lock = DATA;
      if (memory_bus.ready) begin
        data_bus.data  = memory_bus.data;
        data_bus.ready = 1'h1;
      end else begin
        memory_bus.address = data_bus.address;
        memory_bus.read = 1'h1;
        data_bus.ready = 1'h0;
      end
    end else if (data_bus.write && lock != INSTR) begin
      lock = DATA;
      if (memory_bus.done) begin
        data_bus.data = memory_bus.data;
        memory_bus.write = 1'b0;
        data_bus.done = 1'b1;
      end else begin
        memory_bus.address = data_bus.address;
        memory_bus.write = 1'b1;
        data_bus.done = 1'b0;
      end
    end else begin
      lock = FREE;
      memory_bus.address = 'z;
      memory_bus.read = 1'h0;
      memory_bus.write = 1'h0;
      instr_bus.ready = 1'h0;
      data_bus.ready = 1'h0;
      data_bus.done = 1'h0;
    end
  end
endmodule
