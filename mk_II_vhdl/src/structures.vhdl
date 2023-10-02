library IEEE;
use IEEE.std_logic_1164.all;

package structures is
	type instr_name_e is (
		-- Memory instructions
		E_LB,
		E_LH,
		E_LW,
		E_LBU,
		E_LHU,
		E_SB,
		E_SH,
		E_SW,
		-- Bracnh and jump insructions
		E_BEQ,
		E_BNE,
		E_BLT,
		E_BGE,
		E_BLTU,
		E_BGEU,
		E_JAL,
		E_JALR,
		-- Arithmetic and logic instructions
		E_ADDI,
		E_SLTI,
		E_SLTIU,
		E_XORI,
		E_ORI,
		E_ANDI,
		E_SLLI,
		E_SRLI,
		E_SRAI,
		E_ADD,
		E_SUB,
		E_SLL,
		E_SLT,
		E_SLTU,
		E_XOR,
		E_SRL,
		E_SRA,
		E_OR,
		E_AND,
		E_LUI,
		E_AUIPC,
		-- Multiplication and division instructions
		E_MUL,
		E_MULH,
		E_MULHSU,
		E_MULHU,
		E_DIV,
		E_DIVU,
		E_REM,
		E_REMU,
		-- Zircsr instructions
		E_CSRRW,
		E_CSRRS,
		E_CSRRC,
		E_CSRRWI,
		E_CSRRSI,
		E_CSRRCI,
		-- System instructions
		E_ECALL,
		E_EBREAK,
		E_FENCE,
		-- Custom value
		E_UNKNOWN);
    
	type jmp_relation_e is (NN,NJ,JN,JJ);
	
	type cache_state_e is (VALID, INVALID, MODIFIED);
	
	type mmu_state_e is (IDLE, READ, WRITE);
	
	type instr_type_e is (BRANCH, ALU, LOAD_STORE, MULT_DIV, RDR_BUFF, INVALID);
	
	type record_status_e is (WAITING, COMPLETED, IGNORE);
	
	type flag_vector_t is record
		writes	: std_logic; 
		jumps		: std_logic; 
		uses_imm	: std_logic; 
		tag		: std_logic; 
		mem 		: std_logic;
	end record flag_vector_t;
	
	type registers_t is record
		rd		: std_logic_vector(4 downto 0);
		rs_1	: std_logic_vector(4 downto 0);
		rs_2	: std_logic_vector(4 downto 0);
		rn		: std_logic_vector(4 downto 0);
	end record registers_t;
end package structures;