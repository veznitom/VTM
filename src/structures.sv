package CustomTypes;

  typedef enum reg [7:0] { LB,LH,LW,LBU,LHU,SB,SH,SW,BEQ,BNE,BLT,BGE,BLTU,BGEU,JAL,JALR,ADDI,SLTI,SLTIU,XORI,ORI,ANDI,SLLI,SRLI,SRAI,ADD,SUB,SLL,SLT,SLTU,XOR,SRL,SRA,OR,AND,LUI,AUIPC,ECALL,EBREAK,FENCE,UNKNOWN} PID;
  typedef enum reg [1:0] { NONE, ALU, BRANCH, LS } Station;
  typedef enum reg [2:0] { LOAD, PREPARE, RENAME , FETCH, ISSUE, STALL, BREAK} DDState;
  typedef enum reg [2:0] { NJ1NJ2, NJ1J2, J1NJ2, J1J2, ERROR} InstrBehav;
  typedef enum reg [1:0] { BYTE, HALFWORD, WORD, EMPTY } WordSelect;
  typedef enum reg [1:0] { VALID, WAITING, INVALID , MODIFIED} CacheState;
  typedef enum reg [1:0] { IDLE, READ, WRITE } MMUState;

  typedef struct packed {
    reg [31:0] instr, address, imm;
    PID pid;
    reg [4:0] rs1, rs2, rd;
    Station stat_select;
    reg writes, jumps, op_imm; 
  } DecodedInstr;

  typedef struct packed {
    reg [31:0] data1, data2, address, imm;
    PID pid;
    reg [5:0] src1, src2, rrn;
    reg valid1, valid2, tag, ignore;
  } StationRecord;

  typedef struct packed {
    reg [31:0] value;
    reg [5:0] rrn;
    reg valid, tag;
  } RegisterData;

  typedef struct packed {
    reg [31:0] data, address, instr; 
    reg tag;
    CacheState state;
    WordSelect ws;
  } DataCacheRecord;

  typedef struct packed {
    reg [31:0] address, instr;
  } InstrCacheRecord;

  typedef struct packed{
    reg [31:0] data, address, jump_address;
    reg [5:0] arn, rrn;
    reg finished, jump, tag, ignore;
  } ROBRecord;
endpackage



