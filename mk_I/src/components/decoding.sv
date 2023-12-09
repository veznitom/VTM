import CustomTypes::*;

module DecodeSrc(
  input wire [31:0] instr,
  output reg [31:0] imm,
  output reg [4:0] rd, rs1, rs2
);

  always @(instr) begin
    case(instr[4:2])
      3'b000: begin : LSB// LOAD, STORE, BRANCH
        case(instr[6:5])
          2'b00: begin // LOAD
            imm = {{20{instr[31]}}, instr[31:20]};
            rd = instr[11:7];
            rs1 = instr[19:15];
            rs2 = 5'h00;
          end

          2'b01: begin // STORE
            imm = {{20{instr[31]}}, instr[31:25], instr[11:7]};
            rd = 5'h00;
            rs1 = instr[19:15];
            rs2 = instr[24:20];
          end

          2'b11: begin // BRANCH
            imm = {{21{instr[31]}},instr[7], instr[30:25], instr[11:8],1'b0};
            rd = 5'h00;
            rs1 = instr[19:15];
            rs2 = instr[24:20];
          end

          default: begin
            imm = 32'h00000000;
            rd = 5'h00;
            rs1 = 5'h00;
            rs2 = 5'h00;
          end
        endcase
      end 

      3'b001: begin // JALR
        case(instr[6:5])
          2'b11: begin // JALR
            imm = {{20{instr[31]}}, instr[31:20]};
            rd = instr[11:7];
            rs1 = instr[19:15];
            rs2 = 5'h00;
          end

          default: begin
            imm = 32'h00000000;
            rd = 5'h00;
            rs1 = 5'h00;
            rs2 = 5'h00;
          end
        endcase
      end

      3'b011: begin // MISC-MEM, JAL
        case(instr[6:5])
          2'b00: begin // MISC-MEM
            imm = 32'h00000000;
            rd = 5'h00;
            rs1 = 5'h00;
            rs2 = 5'h00;
          end

          2'b11: begin // JAL
            imm = {{13{instr[31]}},instr[19:12],instr[20],instr[30:21],1'b0};
            rd = instr[11:7];
            rs1 = 5'h00;
            rs2 = 5'h00;
          end

          default: begin
            imm = 32'h00000000;
            rd = 5'h00;
            rs1 = 5'h00;
            rs2 = 5'h00;
          end
        endcase
      end

      3'b100: begin : OPS // OP, OP-IMM, SYSTEM
        case(instr[6:5])
          2'b00: begin // OP-IMM
            if ((instr[14:12] == 3'b001) || (instr[14:12] == 3'b101)) begin 
              imm = {{27{1'b0}}, instr[24:20]};
            end else
              imm = {{20{instr[31]}}, instr[31:20]};
            rd = instr[11:7];
            rs1 = instr[19:15];
            rs2 = 5'h00;
          end

          2'b01: begin // OP
            imm = 32'h00000000;
            rd = instr[11:7];
            rs1 = instr[19:15];
            rs2 = instr[24:20];
          end

          2'b11: begin // ECALL, EBREAK
            imm = 32'h00000000;
            rd = 5'h00;
            rs1 = 5'h00;
            rs2 = 5'h00;
          end

          default: begin
            imm = 32'h00000000;
            rd = 5'h00;
            rs1 = 5'h00;
            rs2 = 5'h00;
          end
        endcase
      end

      3'b101: begin // AUIPC, LUI
        casez(instr[6:5])
          2'b0?: begin // AUIPC, LUI
            imm = {instr[31:12],{12{1'b0}}};
            rd = instr[11:7];
            rs1 = 5'h00;
            rs2 = 5'h00;
          end

          default: begin
            imm = 32'h00000000;
            rd = 5'h00;
            rs1 = 5'h00;
            rs2 = 5'h00;
          end
        endcase
      end

      default: begin
        imm = 32'h00000000;
        rd = 5'h00;
        rs1 = 5'h00;
        rs2 = 5'h00;
      end
    endcase
  end
endmodule

module ParseOp(
  input wire [31:0] instr,
  output PID pid,
  output Station station,
  output reg writes, jumps, opimms
);

  wire [11:0] system;
  wire [6:0] opcode, funct7;
  wire [2:0] funct3; 

  assign system = instr[31:20];
  assign opcode = instr[6:0];
  assign funct7 = instr[31:25];
  assign funct3 = instr[14:12];
  
  always @(instr) begin
    writes = 1'b0;
    jumps = 1'b0;
    opimms = 1'b0;
    station = NONE;
    if (instr == 32'h00000000)
      pid = UNKNOWN;
    else
      case(opcode[4:2])
        3'b000: begin : LSB // LOAD, STORE, BRANCH
          case(opcode[6:5])
            2'b00: begin : LD // LOAD
              writes = 1'b1;
              station = LS;
              case(funct3)
                3'b000: pid = LB; // LB
                3'b001: pid = LH; // LH
                3'b010: pid = LW; // LW
                3'b100: pid = LBU; // LBU
                3'b101: pid = LHU; // LHU
                default: pid = UNKNOWN;
              endcase
            end

            2'b01: begin : ST // STORE
              station = LS;
              case(funct3)
                3'b000: pid = SB; // SB
                3'b001: pid = SH; // SH
                3'b010: pid = SW; // SW
                default: pid = UNKNOWN;
              endcase
            end

            2'b11: begin : BR// BRANCH
              jumps = 1'b1;
              station = BRANCH;
              case(funct3)
                3'b000: pid = BEQ; // BEQ
                3'b001: pid = BNE; // BNE
                3'b100: pid = BLT; // BLT
                3'b101: pid = BGE; // BGE
                3'b110: pid = BLTU; // BLTU
                3'b111: pid = BGEU; // BGEU
                default: pid = UNKNOWN;
              endcase
            end

            default: pid = UNKNOWN;
          endcase
        end

        3'b001: begin // JALR
          writes = 1'b1;
          jumps = 1'b1;
          station = BRANCH;
          pid = JALR;
        end

        3'b011: begin // MISC-MEM, JAL 
          case(opcode[6:5])
            2'b00: begin
              station = ALU;
              pid = ADDI; // FENCE
            end

            2'b11: begin
              station = BRANCH;
              writes = 1'b1;
              jumps = 1'b1;
              pid = JAL; 
            end

            default: pid = UNKNOWN;
          endcase
        end

        3'b100: begin // OP, OP-IMM, SYSTEM 
          station = ALU;
          case(opcode[6:5])
            2'b00: begin
              writes = 1'b1;
              opimms = 1'b1;
              case(funct3)
                3'b000: pid = ADDI;
                3'b010: pid = SLTI;
                3'b011: pid = SLTIU; 
                3'b100: pid = XORI;
                3'b110: pid = ORI;
                3'b111: pid = ANDI;
                3'b001: pid = SLLI; 
                3'b101: pid = funct7[5] == 0 ? SRLI : SRAI;
                default: pid = UNKNOWN;
              endcase
            end

            2'b01: begin // OP
              writes = 1'b1;
              case(funct3)
                3'b000: pid = funct7[5] == 0 ? ADD : SUB;
                3'b001: pid = SLL;
                3'b010: pid = SLT;
                3'b011: pid = SLTU;
                3'b100: pid = XOR;
                3'b101: pid = funct7[5] == 1'b0 ? SRL : SRA;
                3'b110: pid = OR;
                3'b111: pid = AND;
                default: pid = UNKNOWN;
              endcase
            end

            2'b11: begin // SYSTEM
              pid = system[1] == 1'b0 ? ECALL : EBREAK;
            end

            default: pid = UNKNOWN;
          endcase
        end

        3'b101: begin // LUI, AUIPC
          writes = 1'b1;
          station = ALU;
          pid = opcode[5] == 1'b0 ? AUIPC : LUI;
        end

        default: pid = UNKNOWN;
      endcase
  end
endmodule

module ParseLS (
  input PID pid,
  output WordSelect word_select
);

  always @( pid ) begin
    case (pid)
      LB: word_select = BYTE;
      LH: word_select = HALFWORD;
      LW: word_select = WORD;
      LBU: word_select = BYTE;
      LHU: word_select = HALFWORD;
      SB: word_select = BYTE;
      SH: word_select = HALFWORD;
      SW: word_select = WORD;
      default: word_select = EMPTY;
    endcase
  end

endmodule

module Decoder (
  input wire [31:0] instr,
  output reg [31:0] imm,
  output PID pid,
  output Station station,
  output reg [4:0] rd, rs1, rs2,
  output reg writes, jumps, opimms
);
  DecodeSrc src (instr, imm, rd, rs1, rs2);
  ParseOp oper(instr, pid, station, writes, jumps, opimms);
endmodule