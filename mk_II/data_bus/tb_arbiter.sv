`timescale 1ns / 1ps

module tb_arbiter ();
  data_bus_if data_bus[2] ();
  logic clock;
  logic [2:0] get_bus, bus_granted;

  arbiter #(1) a (
      .data(1),
      .address(1),
      .jmp_address(1),
      .rd(1),
      .rn(1),
      .reg_write('0),
      .cache_write('0),
      .get_bus(get_bus[0]),
      .bus_granted(bus_granted[0]),
      .data_bus(data_bus)
  );
  arbiter #(2) b (
      .data(2),
      .address(2),
      .jmp_address(2),
      .rd(2),
      .rn(2),
      .reg_write(1),
      .cache_write(1),
      .get_bus(get_bus[1]),
      .bus_granted(bus_granted[1]),
      .data_bus(data_bus)
  );
  arbiter #(3) c (
      .data(3),
      .address(3),
      .jmp_address(3),
      .rd(3),
      .rn(3),
      .reg_write(1),
      .cache_write(0),
      .get_bus(get_bus[2]),
      .bus_granted(bus_granted[2]),
      .data_bus(data_bus)
  );

  always #10 clock = ~clock;

  initial begin
    clock   = 0;
    get_bus = '0;
    #20 get_bus = 3'h7;
    #200;
    $finish;
  end

  always @(posedge bus_granted[0]) begin
    #10 get_bus[0] = '0;
    #34 get_bus[0] = '1;
  end

  always @(posedge bus_granted[1]) begin
    #10 get_bus[1] = '0;
    #19 get_bus[1] = '1;
  end

  always @(posedge bus_granted[2]) begin
    #10 get_bus[2] = '0;
    #11 get_bus[2] = '1;
  end

endmodule
