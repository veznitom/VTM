module arbiter #(
    parameter logic [7:0] PRIORITY = '0
) (
    input logic clock,

    input logic [31:0] data,
    input logic [31:0] address,
    input logic [31:0] jmp_address,
    input logic [5:0] rd,
    input logic [5:0] rn,
    input logic reg_write,
    input logic cache_write,

    input logic get_bus,
    output logic bus_granted,
    data_bus_if.arbiter data_bus[2]
);
  logic bus_free[2], bus_select[2], bus_aquired[2];

  assign bus_free[0] = data_bus[0].select == 8'hff ? '1 : '0;
  assign bus_free[1] = data_bus[1].select == 8'hff ? '1 : '0;

  assign bus_aquired[0] = data_bus[0].select == PRIORITY ? '1 : '0;
  assign bus_aquired[1] = data_bus[1].select == PRIORITY ? '1 : '0;

  assign (strong0, weak1) data_bus[0].select = bus_select[0] ? PRIORITY : '1;
  assign (strong0, weak1) data_bus[1].select = bus_select[1] ? PRIORITY : '1;

  always_comb begin
    if (get_bus)
      if (bus_aquired[0] || bus_aquired[1]) begin
        bus_granted = '1;
        if (bus_aquired[0]) begin
          bus_select[0] = '1;
          bus_select[1] = '0;
          data_bus[0].data = data;
          data_bus[0].address = address;
          data_bus[0].jmp_address = jmp_address;
          data_bus[0].rd = rd;
          data_bus[0].rn = rn;
          data_bus[0].reg_write = reg_write;
          data_bus[0].cache_write = cache_write;
        end else begin
          bus_select[0] = '0;
          bus_select[1] = '1;
          data_bus[1].data = data;
          data_bus[1].address = address;
          data_bus[1].jmp_address = jmp_address;
          data_bus[1].rd = rd;
          data_bus[1].rn = rn;
          data_bus[1].reg_write = reg_write;
          data_bus[1].cache_write = cache_write;
        end
      end else if (bus_free[0] || bus_free[1]) begin
        bus_granted = '1;
        if (bus_free[0]) begin
          bus_select[0] = '1;
          bus_select[1] = '0;
          data_bus[0].data = data;
          data_bus[0].address = address;
          data_bus[0].jmp_address = jmp_address;
          data_bus[0].rd = rd;
          data_bus[0].rn = rn;
          data_bus[0].reg_write = reg_write;
          data_bus[0].cache_write = cache_write;
        end else begin
          bus_select[0] = '0;
          bus_select[1] = '1;
          data_bus[1].data = data;
          data_bus[1].address = address;
          data_bus[1].jmp_address = jmp_address;
          data_bus[1].rd = rd;
          data_bus[1].rn = rn;
          data_bus[1].reg_write = reg_write;
          data_bus[1].cache_write = cache_write;
        end
      end else begin
        bus_granted = '0;
        if (data_bus[0].select > PRIORITY || data_bus[1].select > PRIORITY)
          if (data_bus[0].select > PRIORITY) bus_select[0] = '1;
          else bus_select[1] = '1;
      end
    else begin
      bus_select[0] = '0;
      bus_select[1] = '0;
      bus_granted   = '0;
    end
  end

endmodule

