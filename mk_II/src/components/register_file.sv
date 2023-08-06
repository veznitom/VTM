module register_file #(
    parameter int XLEN = 32
) (
    global_signals_if gsi,
    register_query_if.regs query[2],
    register_values_if reg_val[2],
    debug_interface_if debug
);
  typedef struct packed {
    logic [XLEN-1:0] value;
    logic [5:0] rrn;
    logic valid, tag;
  } register_t;

  register_t registers[64];
  logic [5:0] ren_queue[$:32];

  always_comb begin : reset
    if (gsi.reset) begin
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
    for (i = 0; i < 2; i++) begin : gen_rename
      always_ff @(posedge gsi.clk) begin : renaming
        if ((32 - ren_queue.size()) >= 2) begin
          if (query[i].rename) begin
            query[i].outputs.rn <= ren_queue[0];
            registers[query.inputs.rd].rrn <= ren_queue[0];
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
    for (i = 0; i < 2; i++) begin : gen_cdb
      always_ff @(posedge gsi.clk) begin : data_update
        if (cdb[i].reg_file_we) begin
          if (cdb[i].arn == 6'h00) begin : from_exec
            registers[cdb[i].rrn].value <= cdb[i].result;
            registers[cdb[i].rrn].valid <= 1'h1;
          end else if (cdb[i].arn != 6'h00) begin : from_rob
            if (cdb[i].rrn == registers[cdb[i].arn].rrn) begin : not_re_renamed
              registers[cdb[i].arn].value <= cdb[i].result;
              registers[cdb[i].arn].valid <= 1'h1;
              registers[cdb[i].arn].tag   <= 1'h0;
              registers[cdb[i].arn].rrn   <= 6'h00;
            end else begin : was_re_renamed
              registers[cdb[i].arn].value <= cdb[i].result;
              registers[cdb[i].arn].valid <= 1'h1;
            end
            registers[cdb[i].rrn] <= '{0, 0, 0, 0};
            ren_queue.push_back(registers[cdb[i].arn].rrn);
          end
        end
      end
    end
  endgenerate

  always_ff @(posedge gsi.clk) begin : clear_tagged
    if (gsi.clear_tagged)
      foreach (registers[i]) begin
        if (registers[i].tag) registers[i].tag <= 1'h0;
      end
  end

  always_ff @(posedge gsi.clk) begin : delete_tagged
    if (gsi.delete_tagged)
      for (int i = 0; i < 32; i++) begin
        if (registers[i].tag) begin
          registers[i].tag <= 1'h0;
          registers[i].rrn <= 1'h0;
        end
      end

    for (int i = 32; i < 64; i++) begin
      if (registers[i].tag) begin
        registers[i] <= '{0, 0, 0, 0};
        append_ren(i[5:0]);
      end
    end
  end

endmodule
