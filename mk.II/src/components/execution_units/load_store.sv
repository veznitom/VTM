module load_store #(
    parameter int XLEN = 32
) (
    station_unit_if exec_feed,
    cache_bus_if data_bus,

    output logic [XLEN-1:0] result
);
  logic load;

  function automatic logic [1:0] is_load_store(input instr_name_e instr_name);
    case (instr_name)
      LB: return 2'h1;
      LBU: return 2'h1;
      LH: return 2'h1;
      LHU: return 2'h1;
      LW: return 2'h1;
      SB: return 2'h2;
      SH: return 2'h2;
      SW: return 2'h2;
      default: return 1'h0;
    endcase
  endfunction

  always_comb begin
    case (is_load_store(
        exec_feed.instr_name
    ))
      2'h1: begin
        if (data_bus.hit)
          case (exec_feed.instr_name)
            LB: result = {{XLEN - 8{data_bus.data[7]}}, data_bus.data[7:0]};
            LBU: result = {{XLEN - 8{1'h0}}, data_bus.data[7:0]};
            LH: result = {{XLEN - 16{data_bus.data[15]}}, data_bus.data[15:0]};
            LHU: result = {{XLEN - 8{1'h0}}, data_bus.data[15:0]};
            default: result = data_bus.data;
          endcase
        else begin
          data_bus.read = 1'h1;
          data_bus.address = exec_feed.data_1 + exec_feed.immediate;
        end
      end
      2'h2: begin
        data_bus.write = 1'h1;
        data_bus.address = exec_feed.data_1 + exec_feed.immediate;
        data_bus.data = exec_feed.data_2;
        result = exec_feed.data_2;
      end
      default: begin
        data_bus.read = 1'h0;
        data_bus.write = 1'h0;
        result = {XLEN{1'hz}};
      end
    endcase
  end
endmodule

