`timescale 1ps/1ps
import CustomTypes::*;

module FakeRam #(
  parameter file_path = "",
  parameter size_b = 128
)(
  input wire clk, reset,
  MemoryBus.ram mem_bus
);

  int file, instr_load, index;

  reg [mem_bus.width-1:0] tmp_data;
  reg [size_b-1:0][7:0] ram;

  assign mem_bus.data = (mem_bus.read) ? tmp_data : {mem_bus.width{1'hz}};

  always @(*) begin
    if(reset) begin
      file = $fopen(file_path,"r");
      index = 0;
      tmp_data = 0;
      foreach(ram[i])
        ram[i] = 0;
      while ($fscanf(file,"%h",instr_load) == 1) begin
        ram[index] = instr_load[7:0];
        ram[index+1] = instr_load[15:8];
        ram[index+2] = instr_load[23:16];
        ram[index+3] = instr_load[31:24];
        index += 4;
      end
    end
  end

  always @( posedge clk ) begin
    if (mem_bus.read) begin
      case(mem_bus.source)
        1'b0: tmp_data <= {ram[mem_bus.address+:mem_bus.width/8]};
        1'b1: tmp_data <= {{mem_bus.width-32{1'bz}},ram[mem_bus.address+:4]};
        default: tmp_data <= {mem_bus.width{1'bz}};
      endcase
      mem_bus.ready <= 1;
    end else begin
      tmp_data <= {mem_bus.width{1'hz}};      
      mem_bus.ready <= 0;
    end
  end

  always @( posedge clk ) begin
    if (mem_bus.write) begin
      case(mem_bus.ws)
        BYTE: ram[mem_bus.address+:8] <= mem_bus.data[7:0];
        HALFWORD: ram[mem_bus.address+:16] <= mem_bus.data[15:0];
        WORD: ram[mem_bus.address+:32] <= mem_bus.data;
        default:;
      endcase
      mem_bus.done <= 1;
    end else
      mem_bus.done <= 0;
  end

endmodule