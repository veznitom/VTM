// Copyright (c) 2024 veznitom

`default_nettype none
module MemoryManagementUnit (
  IntfCSB.notag  cs,
  IntfMemory.CPU memory,
  IntfMemory.MMU instr,
  IntfMemory.MMU data
);
  // ------------------------------- Strucutres -------------------------------
  typedef enum bit [1:0] {
    FREE,
    INSTR,
    DATA
  } mmu_state_e;

  // ------------------------------- Wires -------------------------------
  mmu_state_e lock;

  // ------------------------------- Behaviour -------------------------------
  always_comb begin : access_management
    if (cs.reset) begin
      lock        = FREE;
      instr.done  = 1'h0;
      memory.data = '0;
    end else if (instr.read && lock != DATA) begin : instructions_read
      lock = INSTR;
      if (memory.ready) begin
        instr.data  = memory.data[instr.BUS_WIDTH_BITS-1:0];
        instr.ready = 1'h1;
        lock        = FREE;
      end else begin
        memory.address = instr.address;
        memory.read    = 1'h1;
        instr.ready    = 1'h0;
      end
    end else if (data.read && lock != INSTR) begin : data_read
      lock = DATA;
      if (memory.ready) begin
        data.data  = memory.data[data.BUS_WIDTH_BITS-1:0];
        data.ready = 1'h1;
        lock       = FREE;
      end else begin
        memory.address = data.address;
        memory.read    = 1'h1;
        data.ready     = 1'h0;
      end
    end else if (data.write && lock != INSTR) begin
      lock = DATA;
      if (memory.done) begin
        data.data    = memory.data[data.BUS_WIDTH_BITS-1:0];
        memory.write = 1'b0;
        data.done    = 1'b1;
        lock         = FREE;
      end else begin
        memory.address = data.address;
        memory.write   = 1'b1;
        data.done      = 1'b0;
      end
    end else begin
      memory.address = 'z;
      memory.read    = 1'h0;
      memory.write   = 1'h0;
      instr.ready    = 1'h0;
      data.ready     = 1'h0;
      data.done      = 1'h0;
    end
  end
endmodule
