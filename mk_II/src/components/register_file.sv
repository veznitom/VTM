import global_variables::XLEN;
import structures::*;

module register_file (
    global_bus_if.rest global_bus,
    reg_query_bus_if.reg_file query_bus[2],
    reg_val_bus_if.reg_file reg_val_bus[2],
    common_data_bus_if.reg_file data_bus[2],
    cpu_debug_if debug
);
  // ------------------------------- Structures -------------------------------
  typedef struct packed {
    logic [XLEN-1:0] value;
    bit [5:0] rrn;
    bit valid, tag;
  } register_t;

  // ------------------------------- Wires -------------------------------
  register_t registers[64];
  logic [31:0] ren_free;
  logic [5:0] query_rename[2], rd_sync[2];
  logic query_ren_en[2];
  // ------------------------------- Modules -------------------------------
  rename_lookup ren_look (
      .clock(global_bus.clock),
      .reset(global_bus.reset),
      .ren_enable(query_ren_en),
      .ren_free(ren_free),
      .rd_sync(rd_sync),
      .ren_num(query_rename)
  );

  // ------------------------------- Behaviour -------------------------------
  always_comb begin : reset
    if (global_bus.reset) begin
      foreach (registers[j]) begin
        registers[j] = '{0, 0, 0, 0};
      end
      ren_free = 32'h00000000;
    end
  end

  genvar i;
  generate
    for (i = 0; i < 2; i++) begin : gen_q_rn_clear
      assign query_bus[i].outputs.rd = 6'h0;

      assign query_bus[i].outputs.rn = query_rename[i];
      assign query_ren_en[i] = query_bus[i].rename;
      assign rd_sync[i] = query_bus[i].inputs.rd;

      always_comb begin : data_return
        reg_val_bus[i].data_1  = registers[reg_val_bus[i].src_1].value;
        reg_val_bus[i].valid_1 = registers[reg_val_bus[i].src_1].valid;
        reg_val_bus[i].data_2  = registers[reg_val_bus[i].src_2].value;
        reg_val_bus[i].valid_2 = registers[reg_val_bus[i].src_2].valid;
      end

      always_comb begin
        if (registers[query_bus[i].inputs.rs_1].rrn != 00)
          query_bus[i].outputs.rs_1 = registers[query_bus[i].inputs.rs_1];
        else query_bus[i].outputs.rs_1 = query_bus[i].inputs.rs_1;

        if (registers[query_bus[i].inputs.rs_2].rrn != 00)
          query_bus[i].outputs.rs_2 = registers[query_bus[i].inputs.rs_2];
        else query_bus[i].outputs.rs_2 = query_bus[i].inputs.rs_2;
      end

      always_comb begin : renaming
        if (query_bus[i].rename) begin
          registers[query_bus[i].inputs.rd].rrn = query_bus[i].outputs.rn;
          registers[query_bus[i].outputs.rn] = '{0, 0, 0, query_bus[i].tag};
          if (!query_bus[i].tag) registers[query_bus[i].inputs.rd].valid = 1'h0;
          registers[query_bus[i].inputs.rd].tag = query_bus[i].tag;
        end
      end

      always_ff @(posedge global_bus.clock) begin : data_update
        if (data_bus[i].reg_write) begin
          if (data_bus[i].arn == 6'h00) begin : from_exec
            registers[data_bus[i].rrn].value <= data_bus[i].result;
            registers[data_bus[i].rrn].valid <= 1'h1;
          end else if (data_bus[i].arn != 6'h00) begin : from_rob
            if (data_bus[i].rrn == registers[data_bus[i].arn].rrn) begin : not_re_renamed
              registers[data_bus[i].arn].value <= data_bus[i].result;
              registers[data_bus[i].arn].valid <= 1'h1;
              registers[data_bus[i].arn].tag   <= 1'h0;
              registers[data_bus[i].arn].rrn   <= 6'h00;
            end else begin : was_re_renamed
              registers[data_bus[i].arn].value <= data_bus[i].result;
              registers[data_bus[i].arn].valid <= 1'h1;
            end
            registers[data_bus[i].rrn] <= '{0, 0, 0, 0};
            ren_free[registers[data_bus[i].arn].rrn-32] <= 1'h1;  // might need zeroing
          end
        end
      end
    end
  endgenerate

  always_ff @(posedge global_bus.clock) begin : clear_tagged
    if (global_bus.clear_tag)
      foreach (registers[i]) begin
        if (registers[i].tag) registers[i].tag <= 1'h0;
      end
  end

  always_ff @(posedge global_bus.clock) begin : delete_tagged
    if (global_bus.delete_tag)
      for (int i = 0; i < 32; i++) begin
        if (registers[i].tag) begin
          registers[i].tag <= 1'h0;
          registers[i].rrn <= 1'h0;
        end
      end

    for (int i = 32; i < 64; i++) begin
      if (registers[i].tag) begin
        registers[i]   <= '{0, 0, 0, 0};
        ren_free[i-32] <= 1'h1;  // might need zeroing
      end
    end
  end
endmodule
