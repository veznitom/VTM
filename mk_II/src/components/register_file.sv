import structures::*;

module register_file #(
    parameter int XLEN = 32
) (
    global_bus_if.rest global_bus,
    reg_query_bus_if.reg_file query[2],
    reg_val_bus_if.reg_file reg_val[2],
    cpu_debug_if debug
);
  typedef struct packed {
    logic [XLEN-1:0] value;
    logic [5:0] rrn;
    logic valid, tag;
  } register_t;

  register_t registers[64];
  logic [5:0] ren_queue[$:32];

  always_comb begin : reset
    if (global_bus.reset) begin
      foreach (registers[j]) begin
        registers[j] = '{0, 0, 0, 0};
      end
      ren_queue.delete();
      for (int i = 32; i < 64; i++) begin
        ren_queue.push_back(i);
      end
    end
  end

  genvar i;
  generate
    for (i = 0; i < 2; i++) begin : gen_q_rn_clear
      assign query[i].outputs.rd = 6'h0;
    end
  endgenerate

  generate
    for (i = 0; i < 2; i++) begin : gen_reg_val
      always_comb begin : data_return
        reg_val[i].data_1  = registers[reg_val[i].src_1].value;
        reg_val[i].valid_1 = registers[reg_val[i].src_1].valid;
        reg_val[i].data_2  = registers[reg_val[i].src_2].value;
        reg_val[i].valid_2 = registers[reg_val[i].src_2].valid;
      end
    end
  endgenerate

  generate
    for (i = 0; i < 2; i++) begin : gen_reg_nums
      always_comb begin
        if (registers[query[i].inputs.rs_1].rrn != 00)
          query[i].outputs.rs_1 = registers[query[i].inputs.rs_1];
        else query[i].outputs.rs_1 = query[i].inputs.rs_1;

        if (registers[query[i].inputs.rs_2].rrn != 00)
          query[i].outputs.rs_2 = registers[query[i].inputs.rs_2];
        else query[i].outputs.rs_2 = query[i].inputs.rs_2;
      end
    end
  endgenerate

  generate
    for (i = 0; i < 2; i++) begin : gen_rename
      always_ff @(posedge query[i].rename) begin : renaming
        if (ren_queue.size() >= 2) begin
          if (query[i].rename) begin
            query[i].outputs.rn <= ren_queue[0];
            registers[query[i].inputs.rd].rrn <= ren_queue[0];
            registers[ren_queue[0]] <= '{0, 0, 0, query[i].tag};
            if (!query[i].tag) registers[query[i].inputs.rd].valid <= 1'h0;
            registers[query[i].inputs.rd].tag <= query[i].tag;
            ren_queue.pop_front();
          end else query[i].outputs.rn <= 6'h00;
        end else query[i].outputs.rn <= 6'h00;
      end
    end
  endgenerate

  generate
    for (i = 0; i < 2; i++) begin : gen_data_bus
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
            ren_queue.push_back(registers[data_bus[i].arn].rrn);
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
        registers[i] <= '{0, 0, 0, 0};
        ren_queue.push_back(i);
      end
    end
  end

endmodule
