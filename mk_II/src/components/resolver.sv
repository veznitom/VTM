/*  Resolver checks for dependencies between loaded instructions and requests register renaming if instructions writes,
if there is no free register for rename then it stalls the loader and decoder
*/
import structures::*;

module resolver #(
    parameter int XLEN = 32
) (
    global_bus_if.rest global_bus,
    reg_query_bus_if.resolver query[2],
    instr_info_bus_if.in instr_info_in[2],
    instr_info_bus_if.out instr_info_out[2],

    input  logic stop_in,
    output logic stop_out
);
  typedef struct packed {
    logic [XLEN-1:0] address, immediate;
    instr_name_e instr_name;
    instr_type_e instr_type;
    registers_t regs;
    flag_vector_t flags;
  } instr_info_buffer_t;

  function automatic bit match_regs(input logic [5:0] rd, input logic [5:0] rs);
    return (rd != 6'h00 && rd == rs);
  endfunction

  instr_info_buffer_t instr_buff[2];
  jmp_relation_e instr_type;

  logic tag_active;

  always_comb begin : reset
    if (global_bus.reset) tag_active = 1'h0;
  end

  genvar i;
  generate
    for (i = 0; i < 2; i++) begin : gen_q_rn_clear
      assign query[i].inputs.rn = 6'h0;


      always_comb begin : buff_reset
        if (global_bus.reset) begin
          instr_buff[i].address = {XLEN{1'h0}};
          instr_buff[i].immediate = {XLEN{1'h0}};
          instr_buff[i].instr_name = UNKNOWN;
          instr_buff[i].instr_type = XX;
          instr_buff[i].regs = '{6'h0, 6'h0, 6'h0, 6'h0};
          instr_buff[i].flags = '{1'h0, 1'h0, 1'h0, 1'h0, 1'h0};
        end
      end

      always_ff @(posedge global_bus.clock) begin : dec_delay
        if (!stop_in && instr_info_in[0].instr_name != UNKNOWN
    && instr_info_in[1].instr_name != UNKNOWN) begin
          instr_buff[i].address <= instr_info_in[i].address;
          instr_buff[i].immediate <= instr_info_in[i].immediate;
          instr_buff[i].instr_name <= instr_info_in[i].instr_name;
          instr_buff[i].instr_type <= instr_info_in[i].instr_type;
          instr_buff[i].regs <= instr_info_in[i].regs;
          instr_buff[i].flags <= instr_info_in[i].flags;
        end
      end
    end
  endgenerate

  always_ff @(posedge global_bus.clock) begin : fetch
    if (!stop_in && instr_info_in[0].instr_name != UNKNOWN
    && instr_info_in[1].instr_name != UNKNOWN) begin
      case ({
        instr_info_in[0].flags.jumps, instr_info_in[1].flags.jumps
      })
        2'b00:   instr_type <= NJ1NJ2;
        2'b01:   instr_type <= NJ1J2;
        2'b10:   instr_type <= J1NJ2;
        2'b11:   instr_type <= J1J2;
        default: instr_type <= ERROR;
      endcase

      query[0].inputs.rs_1 <= instr_info_in[0].regs.rs_1;
      query[0].inputs.rs_2 <= instr_info_in[0].regs.rs_2;
      query[0].inputs.rd   <= instr_info_in[0].regs.rd;
      if (instr_info_in[0].flags.writes) query[0].rename <= 1'h1;
      else query[0].rename <= 1'h0;
      query[0].tag <= tag_active;

      query[1].inputs.rs_1 <= instr_info_in[1].regs.rs_1;
      query[1].inputs.rs_2 <= instr_info_in[1].regs.rs_2;
      query[1].inputs.rd <= instr_info_in[1].regs.rd;
      if (instr_info_in[1].flags.writes) query[1].rename <= 1'h1;
      else query[1].rename <= 1'h0;
      query[1].tag <= tag_active;

      stop_out <= 1'h1;
    end else begin
      instr_type <= ERROR;
      stop_out   <= 1'h0;
    end

    if (stop_out) begin
      query[0].rename <= 1'h0;
      query[1].rename <= 1'h0;

      instr_info_out[0].address <= instr_buff[0].address;
      instr_info_out[0].immediate <= instr_buff[0].immediate;
      instr_info_out[0].instr_name <= instr_buff[0].instr_name;
      instr_info_out[0].regs.rs_1 <= query[0].outputs.rs_1;
      instr_info_out[0].regs.rs_2 <= query[0].outputs.rs_2;
      instr_info_out[0].regs.rd <= instr_buff[0].regs.rd;
      if (instr_buff[0].flags.writes && instr_buff[0].regs.rd != 5'h0)
        instr_info_out[0].regs.rn <= query[0].outputs.rn;
      else instr_info_out[0].regs.rn <= 6'h00;
      instr_info_out[0].instr_type <= instr_buff[0].instr_type;
      instr_info_out[0].flags <= instr_buff[0].flags;
      instr_info_out[0].flags.tag <= instr_buff[0].flags.jumps ? 1'b0 : tag_active;

      instr_info_out[1].address <= instr_buff[1].address;
      instr_info_out[1].immediate <= instr_buff[1].immediate;
      instr_info_out[1].instr_name <= instr_buff[1].instr_name;
      if (match_regs(instr_buff[0].regs.rd, instr_buff[1].regs.rs_1))
        instr_info_out[1].regs.rs_1 <= query[0].outputs.rn;
      else instr_info_out[1].regs.rs_1 <= query[1].outputs.rs_1;
      if (match_regs(instr_buff[0].regs.rd, instr_buff[1].regs.rs_2))
        instr_info_out[1].regs.rs_2 <= query[0].outputs.rn;
      else instr_info_out[1].regs.rs_2 <= query[1].outputs.rs_2;
      instr_info_out[1].regs.rd <= instr_buff[1].regs.rd;
      if (instr_buff[1].flags.writes && instr_buff[1].regs.rd != 6'h00)
        instr_info_out[1].regs.rn <= query[1].outputs.rn;
      else instr_info_out[1].regs.rn <= 6'h00;
      instr_info_out[1].instr_type <= instr_buff[1].instr_type;
      instr_info_out[1].flags <= instr_buff[1].flags;
      if (instr_buff[1].flags.jumps) instr_info_out[1].flags.tag <= 1'b0;
      else if (instr_buff[0].flags.jumps) instr_info_out[1].flags.tag <= 1'b1;
      else instr_info_out[1].flags.tag <= tag_active;

      stop_out <= 1'h0;
    end
  end
endmodule

