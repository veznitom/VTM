module branch #(
    parameter int XLEN = 32
) (
    station_unit_if exec_feed,

    output logic [XLEN-1:0] store_result,
    jump_result
);
  always_comb begin
    case (exec_feed.instr_name)
      JAL: begin
        jump_result  = exec_feed.address + $signed(exec_feed.immediate);
        store_result = exec_feed.address + 4;
      end
      JALR: begin
        jump_result  = exec_feed.data_1 + $signed(exec_feed.immediate);
        store_result = exec_feed.address + 4;
      end
      BEQ: begin
        if (exec_feed.data_1 === exec_feed.data_2)
          jump_result = exec_feed.address + exec_feed.immediate;
        else jump_result = exec_feed.address + 4;
      end
      BNE: begin
        if (exec_feed.data_1 !== exec_feed.data_2)
          jump_result = exec_feed.address + exec_feed.immediate;
        else jump_result = exec_feed.address + 4;
      end
      BLT: begin
        if ($signed(exec_feed.data_1) < $signed(exec_feed.data_2))
          jump_result = exec_feed.address + exec_feed.immediate;
        else jump_result = exec_feed.address + 4;
      end
      BGE: begin
        if (($signed(
                exec_feed.data_1
            ) == $signed(
                exec_feed.data_2
            )) || ($signed(
                exec_feed.data_1
            ) > $signed(
                exec_feed.data_2
            )))
          jump_result = exec_feed.address + exec_feed.immediate;
        else jump_result = exec_feed.address + 4;
      end
      BLTU: begin
        if (exec_feed.data_1 < exec_feed.data_2)
          jump_result = exec_feed.address + exec_feed.immediate;
        else jump_result = exec_feed.address + 4;
      end
      BGEU: begin
        if ((exec_feed.data_1 == exec_feed.data_2) || (exec_feed.data_1 > exec_feed.data_2))
          jump_result = exec_feed.address + exec_feed.immediate;
        else jump_result = exec_feed.address + 4;
      end
      default: begin
        jump_result  = {XLEN{1'hz}};
        store_result = {XLEN{1'hz}};
      end
    endcase
  end
endmodule
