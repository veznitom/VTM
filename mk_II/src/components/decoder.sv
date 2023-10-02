// Translates instructions based on RISC-V instruction encoding
import global_variables::XLEN;
import structures::*;

module decoder (
    global_bus_if.rest global_bus,
    instr_info_bus_if.out instr_info,

    input logic [XLEN-1:0] address,
    input logic [31:0] instr,
    input logic stop
);
  logic [11:0] system;
  logic [ 6:0] opcode;
  logic [ 6:0] funct7;
  logic [ 2:0] funct3;

  assign system = instr[31:20];
  assign opcode = instr[6:0];
  assign funct7 = instr[31:25];
  assign funct3 = instr[14:12];

  always_ff @(posedge global_bus.clock) begin : value_sources
    if (!stop) instr_info.address <= address;
    case (instr[4:2])
      3'b000: begin : LSB  // LOAD, STORE, BRANCH
        case (instr[6:5])
          2'b00: begin  // LOAD
            instr_info.immediate <= {{20{instr[31]}}, instr[31:20]};
            instr_info.regs.rd   <= instr[11:7];
            instr_info.regs.rs_1 <= instr[19:15];
            instr_info.regs.rs_2 <= 5'h00;
          end

          2'b01: begin  // STORE
            instr_info.immediate <= {{20{instr[31]}}, instr[31:25], instr[11:7]};
            instr_info.regs.rd   <= 5'h00;
            instr_info.regs.rs_1 <= instr[19:15];
            instr_info.regs.rs_2 <= instr[24:20];
          end

          2'b11: begin  // BRANCH
            instr_info.immediate <= {{21{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
            instr_info.regs.rd   <= 5'h00;
            instr_info.regs.rs_1 <= instr[19:15];
            instr_info.regs.rs_2 <= instr[24:20];
          end

          default: begin
            instr_info.immediate <= 32'h0000;
            instr_info.regs.rd   <= 5'h00;
            instr_info.regs.rs_1 <= 5'h00;
            instr_info.regs.rs_2 <= 5'h00;
          end
        endcase
      end

      3'b001: begin  // JALR
        case (instr[6:5])
          2'b11: begin  // JALR
            instr_info.immediate <= {{20{instr[31]}}, instr[31:20]};
            instr_info.regs.rd   <= instr[11:7];
            instr_info.regs.rs_1 <= instr[19:15];
            instr_info.regs.rs_2 <= 5'h00;
          end

          default: begin
            instr_info.immediate <= 32'h0000;
            instr_info.regs.rd   <= 5'h00;
            instr_info.regs.rs_1 <= 5'h00;
            instr_info.regs.rs_2 <= 5'h00;
          end
        endcase
      end

      3'b011: begin  // MISC-MEM, JAL
        case (instr[6:5])
          2'b00: begin  // MISC-MEM
            instr_info.immediate <= 32'h0000;
            instr_info.regs.rd   <= 5'h00;
            instr_info.regs.rs_1 <= 5'h00;
            instr_info.regs.rs_2 <= 5'h00;
          end

          2'b11: begin  // JAL
            instr_info.immediate <= {{13{instr[31]}}, instr[19:12], instr[20], instr[30:21], 1'b0};
            instr_info.regs.rd   <= instr[11:7];
            instr_info.regs.rs_1 <= 5'h00;
            instr_info.regs.rs_2 <= 5'h00;
          end

          default: begin
            instr_info.immediate <= 32'h0000;
            instr_info.regs.rd   <= 5'h00;
            instr_info.regs.rs_1 <= 5'h00;
            instr_info.regs.rs_2 <= 5'h00;
          end
        endcase
      end

      3'b100: begin : OPS  // OP, OP-IMM, SYSTEM
        case (instr[6:5])
          2'b00: begin  // OP-IMM
            if ((instr[14:12] == 3'b001) || (instr[14:12] == 3'b101)) begin
              instr_info.immediate <= {{27{1'b0}}, instr[24:20]};
            end else instr_info.immediate <= {{20{instr[31]}}, instr[31:20]};
            instr_info.regs.rd   <= instr[11:7];
            instr_info.regs.rs_1 <= instr[19:15];
            instr_info.regs.rs_2 <= 5'h00;
          end

          2'b01: begin  // OP
            instr_info.immediate <= 32'h0000;
            instr_info.regs.rd   <= instr[11:7];
            instr_info.regs.rs_1 <= instr[19:15];
            instr_info.regs.rs_2 <= instr[24:20];
          end

          2'b11: begin  // ECALL, EBREAK
            instr_info.immediate <= 32'h0000;
            instr_info.regs.rd   <= 5'h00;
            instr_info.regs.rs_1 <= 5'h00;
            instr_info.regs.rs_2 <= 5'h00;
          end

          default: begin
            instr_info.immediate <= 32'h0000;
            instr_info.regs.rd   <= 5'h00;
            instr_info.regs.rs_1 <= 5'h00;
            instr_info.regs.rs_2 <= 5'h00;
          end
        endcase
      end

      3'b101: begin  // AUIPC, LUI
        casez (instr[6:5])
          2'b0?: begin  // AUIPC, LUI
            instr_info.immediate <= {instr[31:12], {12{1'b0}}};
            instr_info.regs.rd   <= instr[11:7];
            instr_info.regs.rs_1 <= 5'h00;
            instr_info.regs.rs_2 <= 5'h00;
          end

          default: begin
            instr_info.immediate <= 32'h0000;
            instr_info.regs.rd   <= 5'h00;
            instr_info.regs.rs_1 <= 5'h00;
            instr_info.regs.rs_2 <= 5'h00;
          end
        endcase
      end

      default: begin
        instr_info.immediate <= 32'h0000;
        instr_info.regs.rd   <= 5'h00;
        instr_info.regs.rs_1 <= 5'h00;
        instr_info.regs.rs_2 <= 5'h00;
      end
    endcase
  end

  always_ff @(posedge global_bus.clock) begin : instr_name
    if (!stop)
      if (instr == 32'h0000) instr_info.instr_name <= UNKNOWN;
      else
        case (opcode[4:2])
          3'b000: begin : LSB  // LOAD, STORE, BRANCH
            case (opcode[6:5])
              2'b00: begin : LD  // LOAD
                instr_info.flags.writes <= 1'b1;
                instr_info.instr_type   <= LS;
                case (funct3)
                  3'b000:  instr_info.instr_name <= LB;  // LB
                  3'b001:  instr_info.instr_name <= LH;  // LH
                  3'b010:  instr_info.instr_name <= LW;  // LW
                  3'b100:  instr_info.instr_name <= LBU;  // LBU
                  3'b101:  instr_info.instr_name <= LHU;  // LHU
                  default: instr_info.instr_name <= UNKNOWN;
                endcase
              end

              2'b01: begin : ST  // STORE
                instr_info.instr_type <= LS;
                case (funct3)
                  3'b000:  instr_info.instr_name <= SB;  // SB
                  3'b001:  instr_info.instr_name <= SH;  // SH
                  3'b010:  instr_info.instr_name <= SW;  // SW
                  default: instr_info.instr_name <= UNKNOWN;
                endcase
              end

              2'b11: begin : BR_  // BRANCH
                instr_info.flags.jumps <= 1'b1;
                instr_info.instr_type  <= BR;
                case (funct3)
                  3'b000:  instr_info.instr_name <= BEQ;  // BEQ
                  3'b001:  instr_info.instr_name <= BNE;  // BNE
                  3'b100:  instr_info.instr_name <= BLT;  // BLT
                  3'b101:  instr_info.instr_name <= BGE;  // BGE
                  3'b110:  instr_info.instr_name <= BLTU;  // BLTU
                  3'b111:  instr_info.instr_name <= BGEU;  // BGEU
                  default: instr_info.instr_name <= UNKNOWN;
                endcase
              end

              default: instr_info.instr_name <= UNKNOWN;
            endcase
          end

          3'b001: begin  // JALR
            instr_info.flags.writes <= 1'b1;
            instr_info.flags.jumps  <= 1'b1;
            instr_info.instr_type   <= BR;
            instr_info.instr_name   <= JALR;
          end

          3'b011: begin  // MISC-MEM, JAL
            case (opcode[6:5])
              2'b00: begin
                instr_info.instr_type <= AL;
                instr_info.instr_name <= ADDI;  // FENCE
              end

              2'b11: begin
                instr_info.instr_type   <= BR;
                instr_info.flags.writes <= 1'b1;
                instr_info.flags.jumps  <= 1'b1;
                instr_info.instr_name   <= JAL;
              end

              default: instr_info.instr_name <= UNKNOWN;
            endcase
          end

          3'b100: begin  // OP, OP-IMM, SYSTEM
            instr_info.instr_type <= AL;
            case (opcode[6:5])
              2'b00: begin
                instr_info.flags.writes   <= 1'b1;
                instr_info.flags.uses_imm <= 1'b1;
                case (funct3)
                  3'b000:  instr_info.instr_name <= ADDI;
                  3'b010:  instr_info.instr_name <= SLTI;
                  3'b011:  instr_info.instr_name <= SLTIU;
                  3'b100:  instr_info.instr_name <= XORI;
                  3'b110:  instr_info.instr_name <= ORI;
                  3'b111:  instr_info.instr_name <= ANDI;
                  3'b001:  instr_info.instr_name <= SLLI;
                  3'b101:  instr_info.instr_name <= funct7[5] == 0 ? SRLI : SRAI;
                  default: instr_info.instr_name <= UNKNOWN;
                endcase
              end

              2'b01: begin  // OP
                instr_info.flags.writes <= 1'b1;
                case (funct3)
                  3'b000:  instr_info.instr_name <= funct7[5] == 0 ? ADD : SUB;
                  3'b001:  instr_info.instr_name <= SLL;
                  3'b010:  instr_info.instr_name <= SLT;
                  3'b011:  instr_info.instr_name <= SLTU;
                  3'b100:  instr_info.instr_name <= XOR;
                  3'b101:  instr_info.instr_name <= funct7[5] == 1'b0 ? SRL : SRA;
                  3'b110:  instr_info.instr_name <= OR;
                  3'b111:  instr_info.instr_name <= AND;
                  default: instr_info.instr_name <= UNKNOWN;
                endcase
              end

              2'b11: begin  // SYSTEM
                instr_info.instr_name <= system[1] == 1'b0 ? ECALL : EBREAK;
              end

              default: instr_info.instr_name <= UNKNOWN;
            endcase
          end

          3'b101: begin  // LUI, AUIPC
            instr_info.flags.writes <= 1'b1;
            instr_info.instr_type   <= AL;
            instr_info.instr_name   <= opcode[5] == 1'b0 ? AUIPC : LUI;
          end

          default: instr_info.instr_name <= UNKNOWN;
        endcase
  end
endmodule
