import CustomTypes::*;

module Dispatch (
  GlobalSignals.rest global_signals,
  PCInterface.dispatch pc_control,
  InstrCacheBus.dispatch instr_cache,
  CommonDataBus.dispatch data_bus1, data_bus2,
  RegisterQuery.dispatch query1, query2,
  InstrIssue.dispatch issue1, issue2,
  input wire [2:0][15:0] stations_capacity
);

  reg tag_active;

  DDState dd_state;
  InstrBehav instr_behav;
  DecodedInstr dec_instr1, dec_instr2;

  Decoder instr1_dec(
    .instr(dec_instr1.instr),
    .imm(dec_instr1.imm),
    .pid(dec_instr1.pid),
    .station(dec_instr1.stat_select),
    .rd(dec_instr1.rd), .rs1(dec_instr1.rs1), .rs2(dec_instr1.rs2),
    .writes(dec_instr1.writes), .jumps(dec_instr1.jumps), .opimms(dec_instr1.op_imm)
  );

  Decoder instr2_dec(
    .instr(dec_instr2.instr),
    .imm(dec_instr2.imm),
    .pid(dec_instr2.pid),
    .station(dec_instr2.stat_select),
    .rd(dec_instr2.rd), .rs1(dec_instr2.rs1), .rs2(dec_instr2.rs2),
    .writes(dec_instr2.writes), .jumps(dec_instr2.jumps), .opimms(dec_instr2.op_imm)
  );

  function get_stat(input Station station);
    case (station)
      BRANCH: return 0;
      ALU: return 1;
      LS: return 2;
      default: return 3;
    endcase
  endfunction

  function bit match_data_bus1(input [5:0] src);
    return (data_bus1.rrn != 6'h00 && (src == data_bus1.arn || src == data_bus1.rrn));
  endfunction

  function bit match_data_bus2(input [5:0] src);
    return (data_bus2.rrn != 6'h00 && (src == data_bus2.arn || src == data_bus2.rrn));
  endfunction

  function bit match_regs(input [4:0] rd,rs);
    return (rd != 5'h00 && rd == rs);
  endfunction

// Mathcing the data returned from query with CDB to ensure all data are up to date
// Checking dependencies between the two processed intructions to prevent hazards

  task automatic assemble();
    if (match_data_bus1(query1.reg1_ren)) begin
      issue1.data1 = data_bus1.data;
      issue1.valid1 = 1'b1;
    end else if (match_data_bus2(query1.reg1_ren)) begin
      issue1.data1 = data_bus2.data;
      issue1.valid1 = 1'b1;
    end else begin
      issue1.data1 = query1.reg1_data;
      issue1.valid1 = query1.reg1_valid;
    end
    
    if (match_data_bus1(query1.reg2_ren)) begin
      issue1.data2 = data_bus1.data;
      issue1.valid2 = 1'b1;
    end else if (match_data_bus2(query1.reg2_ren)) begin
      issue1.data2 = data_bus2.data;
      issue1.valid2 = 1'b1;
    end else begin
      issue1.data2 = query1.reg2_data;
      issue1.valid2 = (dec_instr1.op_imm ? 1'b1 : query1.reg2_valid);
    end
    
    issue1.address = pc_control.address;
    issue1.imm = dec_instr1.imm;
    issue1.pid = dec_instr1.pid;
    issue1.src1 = query1.reg1_ren;
    issue1.src2 = query1.reg2_ren;
    issue1.arn = {1'b0, dec_instr1.rd};
    issue1.rrn = (dec_instr1.writes && dec_instr1.rd != 4'h0) ? query1.ret_renamed : 1'b0;
    issue1.stat_select = NONE;
    issue1.jump = dec_instr1.jumps;
    issue1.tag = dec_instr1.jumps ? 1'b0 : tag_active;

    
    if (match_data_bus1(query2.reg1_ren)) begin
      issue2.data1 = data_bus1.data;
      issue2.valid1 = 1'b1;
    end else if (match_data_bus2(query2.reg1_ren)) begin
      issue2.data1 = data_bus2.data;
      issue2.valid1 = 1'b1;
    end else begin
      issue2.data1 = query2.reg1_data;
      if (match_regs(dec_instr1.rd, dec_instr2.rs1))
        issue2.valid1 = 1'b0;
      else
        issue2.valid1 = query2.reg1_valid;
    end
    
    if (match_data_bus1(query2.reg2_ren)) begin
      issue2.data2 = data_bus1.data;
      issue2.valid2 = 1'b1;
    end else if (match_data_bus2(query2.reg2_ren)) begin
      issue2.data2 = data_bus2.data;
      issue2.valid2 = 1'b1;
    end else begin
      issue2.data2 = query2.reg2_data;
      if (dec_instr2.op_imm)
        issue2.valid2 = 1'b1;
      else if (match_regs(dec_instr1.rd, dec_instr2.rs2))
        issue2.valid2 = 1'b0;
      else
        issue2.valid2 = query2.reg2_valid;
    end

    issue2.address = pc_control.address + 4;
    issue2.imm = dec_instr2.imm;
    issue2.pid = dec_instr2.pid;
    issue2.src1 = match_regs(dec_instr1.rd, dec_instr2.rs1) ? query1.ret_renamed : query2.reg1_ren;
    issue2.src2 = match_regs(dec_instr1.rd, dec_instr2.rs2) ? query1.ret_renamed : query2.reg2_ren;
    issue2.arn = {1'b0, dec_instr2.rd};
    issue2.rrn = (dec_instr2.writes && dec_instr2.rd != 4'h0) ? query2.ret_renamed : 1'b0;
    issue2.stat_select = NONE;
    issue2.jump = dec_instr2.jumps;
    issue2.tag = dec_instr2.jumps ? 1'b0 : (dec_instr1.jumps ? 1'b1 : tag_active);
  endtask

  task automatic compare();
    if (match_data_bus1(issue1.src1)) begin
      issue1.data1 <= data_bus1.data;
      issue1.valid1 <= 1'b1;
    end
    if (match_data_bus1(issue1.src2)) begin
      issue1.data2 <= data_bus1.data;
      issue1.valid2 <= 1'b1;
    end
    if (match_data_bus2(issue1.src1)) begin
      issue1.data1 <= data_bus2.data;
      issue1.valid1 <= 1'b1;
    end
    if (match_data_bus2(issue1.src2)) begin
      issue1.data2 <= data_bus2.data;
      issue1.valid2 <= 1'b1;
    end
    if (match_data_bus1(issue2.src1)) begin
      issue2.data1 <= data_bus1.data;
      issue2.valid1 <= 1'b1;
    end
    if (match_data_bus1(issue2.src2)) begin
      issue2.data2 <= data_bus1.data;
      issue2.valid2 <= 1'b1;
    end
    if (match_data_bus2(issue2.src1)) begin
      issue2.data1 <= data_bus2.data;
      issue2.valid1 <= 1'b1;
    end
    if (match_data_bus2(issue2.src2)) begin
      issue2.data2 <= data_bus2.data;
      issue2.valid2 <= 1'b1;
    end
  endtask

  always @(*) begin
    if (global_signals.reset) begin
      tag_active = 1'b0;

      instr_cache.read = 1'b0;
      pc_control.inc = 1'b0;
      pc_control.inc2 = 1'b0;

      dec_instr1.instr = 32'hzzzzzzzz;
      dec_instr1.address = 32'hzzzzzzzz;

      dec_instr2.instr = 32'hzzzzzzzz;
      dec_instr2.address = 32'hzzzzzzzz;

      query1.dd_clear();
      query2.dd_clear();
      
      issue1.clear();
      issue2.clear();

      dd_state = LOAD;
      instr_behav = NJ1NJ2;
    end
  end

  always @( posedge global_signals.clear_tags) begin
    tag_active <= 1'b0;
  end

  always @( posedge global_signals.clk ) begin
    if (global_signals.delete_tagged) begin
      tag_active <= 1'b0;

      instr_cache.read <= 1'b0;
      pc_control.inc <= 1'b0;
      pc_control.inc2 <= 1'b0;

      query1.dd_clear();
      query2.dd_clear();
      
      issue1.clear();
      issue2.clear();

      dd_state <= LOAD;
      instr_behav <= NJ1NJ2;
      
    end else begin
      case (dd_state)
        LOAD: begin
          pc_control.inc <= 1'b0;
          pc_control.inc2 <= 1'b0;
          
          query1.dd_clear();
          query2.dd_clear();
          
          issue1.clear();
          issue2.clear();
          
          query1.read(5'hzz, 5'hzz, 5'hzz, 1'b0, 1'b0);
          query2.read(5'hzz, 5'hzz, 5'hzz, 1'b0, 1'b0);

          if (instr_cache.hit && instr_cache.read == 1) begin
            instr_cache.read <= 1'b0;
            dec_instr1.instr <= instr_cache.instr1;
            dec_instr1.address <= pc_control.address;
            dec_instr2.instr <= instr_cache.instr2;
            dec_instr2.address <= pc_control.address + 4;
            
            dd_state <= FETCH;
          end else begin
            instr_cache.read  <= 1'b1;
            dd_state <= LOAD;
          end
        end
        
        FETCH: begin
          case({dec_instr1.jumps, dec_instr2.jumps})
            2'b00: instr_behav <= NJ1NJ2;
            2'b01: instr_behav <= NJ1J2;
            2'b10: instr_behav <= J1NJ2;
            2'b11: instr_behav <= J1J2;
            default: instr_behav <= ERROR;
          endcase
          if (dec_instr1.writes && dec_instr1.rd != 1'b0)
            query1.read(dec_instr1.rs1, dec_instr1.rs2, dec_instr1.rd, 1'b1, tag_active);
          else
            query1.read(dec_instr1.rs1, dec_instr1.rs2, 1'b0, 1'b0, tag_active);

          if (dec_instr2.writes && dec_instr2.rd != 1'b0)
            query2.read(dec_instr2.rs1, dec_instr2.rs2, dec_instr2.rd, 1'b1, dec_instr1.jumps ? 1'b1 : tag_active);
          else
            query2.read(dec_instr2.rs1, dec_instr2.rs2, 1'b0, 1'b0, dec_instr1.jumps ? 1'b1 : tag_active);

          if (dec_instr1.pid == UNKNOWN) begin
            query1.read(5'hzz, 5'hzz, 5'hzz, 1'b0, 1'b0);
            query2.read(5'hzz, 5'hzz, 5'hzz, 1'b0, 1'b0);
            dd_state <= STALL;
          end else 
            dd_state <= PREPARE;
        end

        PREPARE: begin
          query1.read(5'hzz, 5'hzz, 5'hzz, 1'b0, 1'b0);
          query2.read(5'hzz, 5'hzz, 5'hzz, 1'b0, 1'b0);

          assemble();
          dd_state <= ISSUE;
        end

        ISSUE: begin
          compare();
          case (instr_behav)
            NJ1NJ2: begin
              if (dec_instr1.stat_select == dec_instr2.stat_select) begin
                if (stations_capacity[get_stat(dec_instr1.stat_select)] >= 2) begin 
                  issue1.stat_select <= dec_instr1.stat_select;
                  issue2.stat_select <= dec_instr1.stat_select;
                  pc_control.inc2 <= 1'b1;
                  dd_state <= LOAD;
                end
              end else begin
                if (stations_capacity[get_stat(dec_instr1.stat_select)] >= 1 && stations_capacity[get_stat(dec_instr2.stat_select)] >= 1) begin
                  issue1.stat_select <= dec_instr1.stat_select;
                  issue2.stat_select <= dec_instr2.stat_select;
                  pc_control.inc2 <= 1'b1;
                  dd_state <= LOAD;
                end
              end
            end

            NJ1J2: begin
              if (!tag_active)
                if (stations_capacity[get_stat(dec_instr1.stat_select)] >= 1 && stations_capacity[get_stat(dec_instr2.stat_select)] >= 1) begin
                  issue1.stat_select <= dec_instr1.stat_select;
                  issue2.stat_select <= dec_instr2.stat_select;
                  pc_control.inc2 <= 1'b1;
                  tag_active <= 1'b1;
                  dd_state <= LOAD;
                end
              else
                if (stations_capacity[get_stat(dec_instr1.stat_select)] >= 1) begin
                  issue1.stat_select <= dec_instr1.stat_select;
                  pc_control.inc <= 1'b1;
                  dd_state <= LOAD;
                end
            end

            J1NJ2: begin
              if (!tag_active)
                if (stations_capacity[get_stat(dec_instr1.stat_select)] >= 1 && stations_capacity[get_stat(dec_instr2.stat_select)] >= 1) begin
                  issue1.stat_select <= dec_instr1.stat_select;
                  issue2.stat_select <= dec_instr2.stat_select;
                  pc_control.inc2 <= 1'b1;
                  tag_active <= 1'b1;
                  dd_state <= LOAD;
                end
              else
                dd_state <= STALL;
            end
            
            J1J2: begin
              if (!tag_active)
                if (stations_capacity[get_stat(dec_instr1.stat_select)] >= 1) begin
                  issue1.stat_select <= dec_instr1.stat_select;
                  pc_control.inc <= 1'b1;
                  tag_active <= 1'b1;
                  dd_state <= LOAD;
                end
              else
                dd_state <= STALL;
            end

            default: dd_state <= STALL;
          endcase
        end
        
        STALL: begin
          if (dec_instr1.pid == UNKNOWN)
            dd_state <= STALL;
          else if (dec_instr1.jumps && !tag_active)
            dd_state <= LOAD;
        end

        BREAK: begin
          dd_state <= BREAK;
        end

        default: begin
          dd_state <= BREAK;
        end
      endcase
    end
  end

endmodule
