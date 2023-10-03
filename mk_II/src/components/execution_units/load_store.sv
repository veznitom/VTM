import global_variables::XLEN;
import structures::instr_name_e;

module load_store (
    feed_bus_if.exec feed_bus,
    data_cache_bus_if.load_store cache_bus,

    output logic [XLEN-1:0] result
);
  // ------------------------------- Wires -------------------------------
  logic load;

  // ------------------------------- Functions -------------------------------
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

  // ------------------------------- Behaviour -------------------------------
  always_comb begin
    case (is_load_store(
        feed_bus.instr_name
    ))
      2'h1: begin
        if (cache_bus.hit)
          case (feed_bus.instr_name)
            LB: result = {{XLEN - 8{cache_bus.data[7]}}, cache_bus.data[7:0]};
            LBU: result = {{XLEN - 8{1'h0}}, cache_bus.data[7:0]};
            LH: result = {{XLEN - 16{cache_bus.data[15]}}, cache_bus.data[15:0]};
            LHU: result = {{XLEN - 8{1'h0}}, cache_bus.data[15:0]};
            default: result = cache_bus.data;
          endcase
        else begin
          cache_bus.read = 1'h1;
          cache_bus.address = feed_bus.data_1 + feed_bus.immediate;
        end
      end
      2'h2: begin
        cache_bus.write = 1'h1;
        cache_bus.address = feed_bus.data_1 + feed_bus.immediate;
        cache_bus.data = feed_bus.data_2;
        result = feed_bus.data_2;
      end
      default: begin
        cache_bus.read = 1'h0;
        cache_bus.write = 1'h0;
        result = {XLEN{1'hz}};
      end
    endcase
  end
endmodule

