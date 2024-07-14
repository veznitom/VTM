import pkg_structures::instr_name_e;

module exu_load_store (
    input logic [31:0] data_1,
    input logic [31:0] data_2,
    input logic [31:0] address,
    input logic [31:0] immediate,
    input instr_name_e instr_name,

    input cache_hit,
    inout wire [31:0] cache_data,
    output logic [31:0] cache_address,
    output logic cache_read,
    output logic cache_write,

    output logic [31:0] result
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
    if (instr_name == LB ||
        instr_name == LBU ||
        instr_name == LH ||
        instr_name == LHU ||
        instr_name == LW) begin
      if (cache_hit) begin
        case (instr_name)
          LB: result = {{32 - 8{cache_data[7]}}, cache_data[7:0]};
          LBU: result = {{32 - 8{1'h0}}, cache_data[7:0]};
          LH: result = {{32 - 16{cache_data[15]}}, cache_data[15:0]};
          LHU: result = {{32 - 8{1'h0}}, cache_data[15:0]};
          default: result = cache_data;
        endcase
      end else begin
        cache_read = 1'h1;
        cache_address = data_1 + immediate;
      end
    end else if (instr_name == SB || instr_name == SH || instr_name == SW) begin
      cache_write = 1'h1;
      cache_address = data_1 + immediate;
      cache_data = data_2;
      result = data_2;
    end else begin
      cache_read = 1'h0;
      cache_write = 1'h0;
      result = 'z;
    end
  end
endmodule

