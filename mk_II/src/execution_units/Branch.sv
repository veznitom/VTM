// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module Branch (
  IntfExtFeed.Branch feed
);
  // ------------------------------- Behaviour -------------------------------
  always_comb begin
    case (feed.instr_name)
      JAL: begin
        feed.result_address = feed.address + $signed(feed.immediate);
        feed.result         = feed.address + 4;
      end
      JALR: begin
        feed.result_address = feed.data_1 + $signed(feed.immediate);
        feed.result         = feed.address + 4;
      end
      BEQ: begin
        if (feed.data_1 == feed.data_2) begin
          feed.result_address = feed.address + feed.immediate;
        end else feed.result_address = feed.address + 4;
      end
      BNE: begin
        if (feed.data_1 != feed.data_2) begin
          feed.result_address = feed.address + feed.immediate;
        end else feed.result_address = feed.address + 4;
      end
      BLT: begin
        if ($signed(feed.data_1) < $signed(feed.data_2)) begin
          feed.result_address = feed.address + feed.immediate;
        end else feed.result_address = feed.address + 4;
      end
      BGE: begin
        if (($signed(
                feed.data_1
            ) == $signed(
                feed.data_2
            )) || ($signed(
                feed.data_1
            ) > $signed(
                feed.data_2
            ))) begin
          feed.result_address = feed.address + feed.immediate;
        end else feed.result_address = feed.address + 4;
      end
      BLTU: begin
        if (feed.data_1 < feed.data_2) begin
          feed.result_address = feed.address + feed.immediate;
        end else feed.result_address = feed.address + 4;
      end
      BGEU: begin
        if ((feed.data_1 == feed.data_2) || (feed.data_1 > feed.data_2)) begin
          feed.result_address = feed.address + feed.immediate;
        end else feed.result_address = feed.address + 4;
      end
      default: begin
        feed.result_address = {32{1'hz}};
        feed.result         = {32{1'hz}};
      end
    endcase
  end
endmodule
