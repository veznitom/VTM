// Copyright (c) 2024 veznitom

`default_nettype none
module MemoryManagementUnit (
  input  wire         i_reset,
  // Memory
  input  wire         i_mem_ready,
  input  wire         i_mem_done,
  inout  wire [255:0] io_mem_data,
  output reg  [ 31:0] o_mem_address,
  output reg          o_mem_read,
  output reg          o_mem_write,
  // Instruction cache
  input  wire [ 31:0] i_instr_address,
  input  wire         i_instr_read,
  output reg  [255:0] o_instr_data,
  output reg          o_instr_ready,
  // Data cache
  input  wire [ 31:0] i_data_address,
  input  wire         i_data_read,
  input  wire         i_data_write,
  inout  wire [255:0] io_data_data,
  output reg          o_data_ready,
  output reg          o_data_done
);
  // ------------------------------- Strucutres -------------------------------
  typedef enum bit [1:0] {
    FREE,
    INSTR,
    DATA
  } mmu_state_e;

  // ------------------------------- Wires -------------------------------
  mmu_state_e lock;

  assign io_data_data = (i_data_read && !i_data_write) ? io_mem_data : 'z;
  assign io_mem_data  = (i_data_write && !i_data_read) ? io_data_data : 'z;

  // ------------------------------- Behaviour -------------------------------
  always_comb begin : access_management
    if (i_reset) begin
      lock          = FREE;
      o_instr_ready = '0;
      o_data_ready  = '0;
      o_data_done   = '0;
    end else if (i_instr_read && lock != DATA) begin : instructions_read
      lock = INSTR;
      if (i_mem_ready) begin
        o_instr_data  = io_mem_data;
        o_instr_ready = 1'h1;
        lock          = FREE;
      end else begin
        o_mem_address = i_instr_address;
        o_mem_read    = 1'h1;
        o_instr_ready = 1'h0;
      end
    end else if (i_data_read && lock != INSTR) begin : data_read
      lock = DATA;
      if (i_mem_ready) begin
        //io_data_data = io_mem_data;
        o_data_ready = 1'h1;
        lock         = FREE;
      end else begin
        o_mem_address = i_data_address;
        o_mem_read    = 1'h1;
        o_data_ready  = 1'h0;
      end
    end else if (i_data_write && lock != INSTR) begin
      lock = DATA;
      if (i_mem_done) begin
        //io_data_data       = memory.data[data.BUS_WIDTH_BITS-1:0];
        o_mem_write = 1'b0;
        o_data_done = 1'b1;
        lock        = FREE;
      end else begin
        o_mem_address = i_data_address;
        o_mem_write   = 1'b1;
        o_data_done   = 1'b0;
      end
    end else begin
      o_mem_address = '0;
      o_mem_read    = '0;
      o_mem_write   = '0;
      o_instr_data  = '0;
      o_instr_ready = '0;
      o_data_ready  = '0;
      o_data_done   = '0;
    end
  end

endmodule
