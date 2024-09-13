// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module CPU (
  input wire i_clock,
  input wire i_reset,

  input  wire         i_mem_ready,
  input  wire         i_mem_done,
  inout  wire [255:0] io_mem_data,
  output wire [ 31:0] o_mem_address,
  output wire         o_mem_read,
  output wire         o_mem_write
);
  IntfCSB u_common_signal_bus ();
  //IntfInstrCache u_intr_cache_bus[2] ();
  IntfDataCache u_data_cache_bus ();
  IntfCDB u_common_data_bus[2] ();
  IntfIssue u_issue[2] ();
  IntfRegQuery u_query[2] ();
  IntfRegValBus u_reg_val[2] ();
  IntfFull u_full ();

  wire [31:0] jmp_address;
  wire        jmp_write;

  wire [255:0] mmu_instr_data, mmu_data_data;
  wire [31:0] mmu_instr_address, mmu_data_address;
  wire mmu_instr_read, mmu_instr_ready;
  wire mmu_data_read, mmu_data_write, mmu_data_ready, mmu_data_done;


  wire [31:0] instr_cache_instr[2], instr_cache_address[2];
  wire instr_cache_hit[2], instr_cache_read[2];

  MemoryManagementUnit u_mmu (
    .cs             (u_common_signal_bus),
    .i_mem_ready    (i_mem_ready),
    .i_mem_done     (i_mem_done),
    .io_mem_data    (io_mem_data),
    .o_mem_address  (o_mem_address),
    .o_mem_read     (o_mem_read),
    .o_mem_write    (o_mem_write),
    .i_instr_address(mmu_instr_address),
    .i_instr_read   (mmu_instr_read),
    .o_instr_data   (mmu_instr_data),
    .o_instr_ready  (mmu_instr_ready),
    .i_data_address (mmu_data_address),
    .i_data_read    (mmu_data_read),
    .i_data_write   (mmu_data_write),
    .io_data_data   (mmu_data_data),
    .o_data_ready   (mmu_data_ready),
    .o_data_done    (mmu_data_done)
  );

  InstructionCache u_instr_cache (
    .cs           (u_common_signal_bus),
    .i_mem_data   (mmu_instr_data),
    .i_mem_ready  (mmu_instr_ready),
    .o_mem_address(mmu_instr_address),
    .o_mem_read   (mmu_instr_read),
    .i_address    (instr_cache_address),
    .i_read       (instr_cache_read),
    .o_instr      (instr_cache_instr),
    .o_hit        (instr_cache_hit)
  );

  DataCache u_data_cache (
    .cs           (u_common_signal_bus),
    .cache        (u_data_cache_bus),
    .data_bus     (u_common_data_bus),
    .i_mem_ready  (mmu_data_ready),
    .i_mem_done   (mmu_data_done),
    .io_mem_data  (mmu_data_data),
    .o_mem_address(mmu_data_address),
    .o_mem_read   (mmu_data_read),
    .o_mem_write  (mmu_data_write)
  );

  IPWrapper u_wrapper (
    .cs             (u_common_signal_bus),
    .i_cache_instr  (instr_cache_instr),
    .i_cache_hit    (instr_cache_hit),
    .o_cache_address(instr_cache_address),
    .o_cache_read   (instr_cache_read),
    .issue          (u_issue),
    .data           (u_common_data_bus),
    .query          (u_query),
    .reg_val        (u_reg_val),
    .full           (u_full),
    .i_jmp_address  (jmp_address),
    .i_jmp_write    (jmp_write)
  );

  RegisterFile u_reg_file (
    .cs     (u_common_signal_bus),
    .query  (u_query),
    .reg_val(u_reg_val),
    .data   (u_common_data_bus)
  );

  ReorderBuffer u_rob (
    .cs           (u_common_signal_bus),
    .data         (u_common_data_bus),
    .issue        (u_issue),
    .o_jmp_address(jmp_address),
    .o_jmp_write  (jmp_write),
    .o_full       (u_full.rob)
  );

  ComboALU u_combo_alu (
    .cs    (u_common_signal_bus),
    .data  (u_common_data_bus),
    .issue (u_issue),
    .o_full(u_full.alu)
  );

  ComboBranch u_combo_branch (
    .cs    (u_common_signal_bus),
    .data  (u_common_data_bus),
    .issue (u_issue),
    .o_full(u_full.branch)
  );

  ComboLoadStore u_combo_load_store (
    .cs    (u_common_signal_bus),
    .data  (u_common_data_bus),
    .issue (u_issue),
    .cache (u_data_cache_bus),
    .o_full(u_full.load_store)
  );

  ComboMulDiv u_combo_mul_div (
    .cs    (u_common_signal_bus),
    .data  (u_common_data_bus),
    .issue (u_issue),
    .o_full(u_full.mul_div)
  );

  // ------------------------------- Behaviour -------------------------------
  assign u_common_signal_bus.clock = i_clock;
  assign u_common_signal_bus.reset = i_reset;

endmodule
