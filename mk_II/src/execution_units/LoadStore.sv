// Copyright (c) 2024 veznitom

`default_nettype none
import pkg_defines::*;
module LoadStore (
    IntfCSB.notag           cs,
    IntfExtFeed.LoadStore   feed,
    IntfDataCache.LoadStore cache
);
    // ------------------------------- Behaviour -------------------------------
    always_comb begin
        if (cs.reset) begin
            feed.result         = '0;
            feed.result_address = '0;
            feed.done           = '0;

            cache.address       = '0;
            cache.wr_data       = '0;
            cache.read          = '0;
            cache.write         = '0;
            cache.tag           = '0;
            cache.write_select  = '0;
        end else begin
            if (feed.instr_name == LB || feed.instr_name == LBU ||
                feed.instr_name == LH || feed.instr_name == LHU ||
                feed.instr_name == LW) begin
                case (feed.instr_name)
                    LB:
                    feed.result = {{24{cache.rd_data[0][7]}}, cache.rd_data[0]};
                    LBU: feed.result = {{24{1'h0}}, cache.rd_data[0]};
                    LH:
                    feed.result = {
                        {16{cache.rd_data[2][7]}},
                        cache.rd_data[1],
                        cache.rd_data[0]
                    };
                    LHU:
                    feed.result = {
                        {16{1'h0}}, cache.rd_data[1], cache.rd_data[0]
                    };
                    default: feed.result = cache.rd_data;
                endcase
                feed.result_address = '0;
                feed.done           = cache.hit;

                cache.address       = feed.data_1 + feed.immediate;
                cache.wr_data       = '0;
                cache.read          = '1;
                cache.write         = '0;
                cache.tag           = '0;
                cache.write_select  = '0;
            end else if (feed.instr_name == SB || feed.instr_name == SH ||
                         feed.instr_name == SW) begin
                if (cache.done) begin
                    feed.result         = feed.data_2;
                    feed.result_address = feed.data_1 + feed.immediate;
                    feed.done           = '1;

                    cache.address       = '0;
                    cache.wr_data       = '0;
                    cache.read          = '0;
                    cache.write         = '0;
                    cache.tag           = '0;
                    cache.write_select  = '0;
                end else begin
                    feed.result         = '0;
                    feed.result_address = '0;
                    feed.done           = '0;

                    cache.address       = feed.data_1 + feed.immediate;
                    cache.wr_data       = feed.data_2;
                    cache.read          = '0;
                    cache.write         = '1;
                    cache.tag           = feed.tag;
                    case (feed.instr_name)
                        SW:      cache.write_select = 4'hf;
                        SH:      cache.write_select = 4'h3;
                        SB:      cache.write_select = 4'h1;
                        default: cache.write_select = '0;
                    endcase
                end
            end else begin
                feed.result         = '0;
                feed.result_address = '0;
                feed.done           = '0;

                cache.address       = '0;
                cache.wr_data       = '0;
                cache.read          = '0;
                cache.write         = '0;
                cache.tag           = '0;
                cache.write_select  = '0;
            end
        end
    end
endmodule

