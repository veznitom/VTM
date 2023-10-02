import global_variables::XLEN;

module branch (
    feed_bus_if.exec feed_bus,

    output logic [XLEN-1:0] store_result,
    output logic [XLEN-1:0] jump_result
);
  always_comb begin
    case (feed_bus.instr_name)
      JAL: begin
        jump_result  = feed_bus.address + $signed(feed_bus.immediate);
        store_result = feed_bus.address + 4;
      end
      JALR: begin
        jump_result  = feed_bus.data_1 + $signed(feed_bus.immediate);
        store_result = feed_bus.address + 4;
      end
      BEQ: begin
        if (feed_bus.data_1 === feed_bus.data_2)
          jump_result = feed_bus.address + feed_bus.immediate;
        else jump_result = feed_bus.address + 4;
      end
      BNE: begin
        if (feed_bus.data_1 !== feed_bus.data_2)
          jump_result = feed_bus.address + feed_bus.immediate;
        else jump_result = feed_bus.address + 4;
      end
      BLT: begin
        if ($signed(feed_bus.data_1) < $signed(feed_bus.data_2))
          jump_result = feed_bus.address + feed_bus.immediate;
        else jump_result = feed_bus.address + 4;
      end
      BGE: begin
        if (($signed(
                feed_bus.data_1
            ) == $signed(
                feed_bus.data_2
            )) || ($signed(
                feed_bus.data_1
            ) > $signed(
                feed_bus.data_2
            )))
          jump_result = feed_bus.address + feed_bus.immediate;
        else jump_result = feed_bus.address + 4;
      end
      BLTU: begin
        if (feed_bus.data_1 < feed_bus.data_2) jump_result = feed_bus.address + feed_bus.immediate;
        else jump_result = feed_bus.address + 4;
      end
      BGEU: begin
        if ((feed_bus.data_1 == feed_bus.data_2) || (feed_bus.data_1 > feed_bus.data_2))
          jump_result = feed_bus.address + feed_bus.immediate;
        else jump_result = feed_bus.address + 4;
      end
      default: begin
        jump_result  = {XLEN{1'hz}};
        store_result = {XLEN{1'hz}};
      end
    endcase
  end
endmodule
