import CustomTypes::*;

module ALU (
    input logic [31:0] data1,
    data2,
    address,
    imm,
    input PID pid,
    output logic [31:0] res
);
  reg [31:0] dump;

  always @(data1 or data2 or address or imm or pid) begin
    case (pid)
      ADDI:  res = data1 + imm;
      SLTI:  res = ($signed(data1) < $signed(imm));
      SLTIU: res = data1 < imm;
      XORI:  res = data1 ^ imm;
      ORI:   res = data1 | imm;
      ANDI:  res = data1 & imm;
      SLLI:  {dump,res} = (data1 << (imm & 32'h0000001f));
      SRLI:  res = data1 >> (imm & 32'h0000001f);
      SRAI:  res = $signed(data1) >>> (imm & 32'h0000001f);
      ADD:   res = data1 + data2;
      SUB:   res = data1 - data2;
      SLL:   {dump, res} = (data1 << (data2 & 32'h0000001f));
      SLT:   res = ($signed(data1) < $signed(data2));
      SLTU:  res = data1 < data2;
      XOR:   res = data1 ^ data2;
      SRL:   res = data1 >> (data2 & 32'h0000001f);
      SRA:   res = $signed(data1) >>> (data2 & 32'h0000001f);
      OR:    res = data1 | data2;
      AND:   res = data1 & data2;
      LUI:   res = imm;
      AUIPC: res = address + imm;
      default: res = 32'hzzzzzzzz;
    endcase
  end
endmodule

module Branch (
    input logic [31:0] data1,
    data2,
    address,
    offset,
    input PID pid,
    output logic [31:0] pc,
    rd
);
  always @(data1 or data2 or address or offset or pid) begin
    case (pid)
      JAL: begin
        pc = address + $signed(offset);
        rd = address + 4;
      end

      JALR: begin
        pc = data1 + $signed(offset);
        rd = address + 4;
      end

      BEQ: pc = (data1 === data2) ? (address + offset) : (address + 4);
      BNE: pc = (data1 !== data2) ? (address + offset) : (address + 4);
      BLT: pc = ($signed(data1) < $signed(data2)) ? (address + offset) : (address + 4);
      BGE:
      pc = (($signed(data1) == $signed(data2)) || ($signed(data1) > $signed(data2))) ?
          (address + offset) : (address + 4);
      BLTU: pc = (data1 < data2) ? (address + offset) : (address + 4);
      BGEU: pc = ((data1 == data2) || (data1 > data2)) ? (address + offset) : (address + 4);

      default: begin
        pc = 32'hzzzzzzzz;
        rd = 32'hzzzzzzzz;
      end
    endcase
  end
endmodule

module LoadStore (
    GlobalSignals global_signals,
    // Station
    input logic [31:0] base,
    data,
    offset,
    instr,
    input PID pid,
    input wire tag,
    // Combo
    input logic done,
    output logic [31:0] result,
    output logic finished,
    // Memory
    DataCacheBus data_cache
);

  wire load, store;
  WordSelect ws;

  ParseLS parse (
      pid,
      ws
  );

  assign load = (pid == LB || pid == LH || pid == LW || pid == LBU || pid == LHU);
  assign store = (pid == SB || pid == SH || pid == SW);

  assign data_cache.data = store ? data : 32'hzzzzzzzz;

  always @(posedge global_signals.clk) begin
    if (load) begin
      if (done) finished <= 1'b0;
      if (finished) begin
        data_cache.address <= 32'hzzzzzzzz;
        data_cache.write <= 1'b0;
        data_cache.tag <= 1'b0;
      end else if (data_cache.hit) begin
        case (ws)
          BYTE:
          result <= {(pid == LB ? {24{data_cache.data[7]}} : {24{1'b0}}), data_cache.data[7:0]};
          HALFWORD:
          result <= {(pid == LH ? {16{data_cache.data[15]}} : {16{1'b0}}), data_cache.data[15:0]};
          WORD: result <= data_cache.data;
          default: result = 32'hzzzzzzzz;
        endcase
        data_cache.read <= 1'b0;
        finished <= 1'b1;
      end else begin
        data_cache.address <= base + offset;
        data_cache.read <= 1'b1;
      end
    end else if (store && !data_cache.write) begin
      data_cache.address <= base + offset;
      data_cache.instr <= instr;
      data_cache.write <= 1'b1;
      data_cache.ws <= ws;
      data_cache.tag <= tag;

      result = 32'hzzzzzzzz;
      finished <= 1;
    end else begin
      data_cache.address <= 32'hzzzzzzzz;
      data_cache.instr <= 32'hzzzzzzzz;
      data_cache.read <= 1'b0;
      data_cache.write <= 1'b0;
      data_cache.tag <= 1'b0;
      data_cache.ws <= EMPTY;

      result = 32'hzzzzzzzz;
      finished <= 1'b0;
    end
  end

endmodule
