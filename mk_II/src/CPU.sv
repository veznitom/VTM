// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module CPU (
    input wire i_clock,
    input wire i_reset,

    IntfMemory memory_bus
);
    IntfCSB u_common_signal_bus ();

    IntfMemory u_instr_memory_bus ();
    IntfMemory u_data_memory_bus ();
    IntfDataCache u_data_cache_bus ();

    IntfCDB u_common_data_bus[2] ();
    IntfIssue u_issue[2] ();
    IntfRegQuery u_query ();
    IntfRegValBus u_reg_val[2] ();

    wire [31:0] jmp_address;
    wire        jmp_write;

    wire [31:0] instr_cache_instr[2], instr_cache_address[2];
    wire instr_cache_hit[2], instr_cache_read[2];

    wire clear_tag, delete_tag;

    wire [1:0] ren_capacity;

    wire full_alu, full_branch, full_load_store, full_mul_div, full_rob, full;

    MemoryManagementUnit u_mmu (
        .memory     (memory_bus),
        .instr_cache(u_instr_memory_bus),
        .data_cache (u_data_memory_bus)
    );

    InstructionCache u_instr_cache (
        .cs       (u_common_signal_bus),
        .memory   (u_instr_memory_bus),
        .i_address(instr_cache_address),
        .i_read   (instr_cache_read),
        .o_instr  (instr_cache_instr),
        .o_hit    (instr_cache_hit)
    );

    DataCache u_data_cache (
        .cs    (u_common_signal_bus),
        .cache (u_data_cache_bus),
        .memory(u_data_memory_bus)
    );

    IPWrapper u_wrapper (
        .cs(u_common_signal_bus),

        .i_cache_instr  (instr_cache_instr),
        .i_cache_hit    (instr_cache_hit),
        .i_jmp_address  (jmp_address),
        .i_jmp_write    (jmp_write),
        .o_cache_address(instr_cache_address),
        .o_cache_read   (instr_cache_read),

        .i_ren_capacity(ren_capacity),

        .query  (u_query),
        .i_full (full),
        .issue  (u_issue),
        .data   (u_common_data_bus),
        .reg_val(u_reg_val)
    );

    RegisterFile u_reg_file (
        .i_clock     (i_clock),
        .i_reset     (i_reset),
        .i_clear_tag (clear_tag),
        .i_delete_tag(delete_tag),

        .o_ren_capacity(ren_capacity),

        .query  (u_query),
        .reg_val(u_reg_val),
        .data   (u_common_data_bus)
    );

    ReorderBuffer #(
        .ARBITER_ADDRESS(1),
        .SIZE_BITS      (5)
    ) u_rob (
        .cs           (u_common_signal_bus),
        .data         (u_common_data_bus),
        .issue        (u_issue),
        .o_jmp_address(jmp_address),
        .o_jmp_write  (jmp_write),
        .o_full       (full_rob)
    );

    ComboALU #(
        .ARBITER_ADDRESS(5),
        .SIZE_BITS      (4)
    ) u_combo_alu (
        .cs    (u_common_signal_bus),
        .data  (u_common_data_bus),
        .issue (u_issue),
        .o_full(full_alu)
    );

    ComboBranch #(
        .ARBITER_ADDRESS(3),
        .SIZE_BITS      (3)
    ) u_combo_branch (
        .cs    (u_common_signal_bus),
        .data  (u_common_data_bus),
        .issue (u_issue),
        .o_full(full_branch)
    );

    ComboLoadStore #(
        .ARBITER_ADDRESS(7),
        .SIZE_BITS      (3)
    ) u_combo_load_store (
        .cs    (u_common_signal_bus),
        .data  (u_common_data_bus),
        .issue (u_issue),
        .cache (u_data_cache_bus),
        .o_full(full_load_store)
    );

    ComboMulDiv #(
        .ARBITER_ADDRESS(9),
        .SIZE_BITS      (3)
    ) u_combo_mul_div (
        .cs    (u_common_signal_bus),
        .data  (u_common_data_bus),
        .issue (u_issue),
        .o_full(full_mul_div)
    );

    // ------------------------------- Behaviour -------------------------------
    assign u_common_signal_bus.clock = i_clock;
    assign u_common_signal_bus.reset = i_reset;

    // if at least one thing is full halt,
    // simpler design than to do it on individual basis
    assign full = full_alu | full_branch | full_load_store | full_mul_div |
        full_rob;

endmodule
