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
  function automatic integer is_load_store(input instr_name_e instr_name);
    case (instr_name)
      LB: return 1;
      LBU: return 1;
      LH: return 1;
      LHU: return 1;
      LW: return 1;
      SB: return 2;
      SH: return 2;
      SW: return 2;
      default: return 0;
    endcase
  endfunction

  // ------------------------------- Behaviour -------------------------------
  always_comb begin
    // For some to me unknown reason function identifiaing is f*cking broken >:(
    if (feed_bus.instr_name == LB ||
        feed_bus.instr_name == LBU ||
        feed_bus.instr_name == LH ||
        feed_bus.instr_name == LHU ||
        feed_bus.instr_name == LW) begin
      if (cache_bus.hit) begin
        case (feed_bus.instr_name)
          LB: result = {{XLEN - 8{cache_bus.data[7]}}, cache_bus.data[7:0]};
          LBU: result = {{XLEN - 8{1'h0}}, cache_bus.data[7:0]};
          LH: result = {{XLEN - 16{cache_bus.data[15]}}, cache_bus.data[15:0]};
          LHU: result = {{XLEN - 8{1'h0}}, cache_bus.data[15:0]};
          default: result = cache_bus.data;
        endcase
      end else begin
        cache_bus.read = 1'h1;
        cache_bus.address = feed_bus.data_1 + feed_bus.immediate;
      end
    end else
    if (feed_bus.instr_name == SB ||
        feed_bus.instr_name == SH ||
        feed_bus.instr_name == SW) begin
      cache_bus.write = 1'h1;
      cache_bus.address = feed_bus.data_1 + feed_bus.immediate;
      cache_bus.data = feed_bus.data_2;
      result = feed_bus.data_2;
    end else begin
      cache_bus.read = 1'h0;
      cache_bus.write = 1'h0;
      result = {XLEN{1'hz}};
    end
  end
endmodule

