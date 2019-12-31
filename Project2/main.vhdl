library std;
use std.standard.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;  
use ieee.std_logic_unsigned.all;

entity main is
port (
 clk, rst: in std_logic --;output:out std_logic
);
end entity main;


architecture behave of main is

component lmsmblock is
port(
  clk: in std_logic;
  a: in std_logic_vector(7 downto 0); -- input
  pe_out: out std_logic_vector(2 downto 0);
  lmsmout: out std_logic_vector(7 downto 0) -- LM SM output
 );
end component lmsmblock;

component queue is
port(
clk, reset, push, pop, rf_a1_x_b1, rf_a2_x_b2, rf_a1_y_b1, rf_a2_y_b2: in std_logic;
data_in_x, data_in_y: in std_logic_vector(85 downto 0);
--index: in std_logic_vector(M-1 downto 0);
data_out_x: out std_logic_vector(85 downto 0);
data_out_y: out std_logic_vector(85 downto 0); 
elements: out std_logic_vector(3 downto 0);
rf_a1_x, rf_a2_x: out std_logic_vector(2 downto 0);
rf_a1_y, rf_a2_y: out std_logic_vector(2 downto 0)
);
end component queue;

component alu1 is
port(
 a : in std_logic_vector(15 downto 0); -- src1
 alu1_en: in std_logic;
 alu_result: out std_logic_vector(15 downto 0) -- ALU Output Result
 );
end component alu1;


component alu2 is
port(
 zero_prev, carry_prev : in std_logic_vector(0 downto 0);
 a,b : in std_logic_vector(15 downto 0); -- src1, src2
 alu_control : in std_logic_vector(1 downto 0); -- function select
 beq: in std_logic;
 alu_result: out std_logic_vector(15 downto 0); -- ALU Output Result
 zero_control, carry_control : in std_logic_vector(0 downto 0);
 zero, carry: out std_logic; -- Zero Flag
 beqZ_flag: out std_logic
 );
 end component alu2;
 
 
component alu3 is
port(
 a,b : in std_logic_vector(15 downto 0); -- src1
 alu_result: out std_logic_vector(15 downto 0) -- ALU Output Result
 );
end component alu3;


component alu4 is
port(
 a : in std_logic_vector(15 downto 0); -- src1
 alu_result: out std_logic_vector(15 downto 0) -- ALU Output Result
 );
end component alu4;


component imemory is 
	port (address: in std_logic_vector(15 downto 0); 
		  clk, Mem_read_en: in std_logic;
		  Mem_dataout1, Mem_dataout2: out std_logic_vector(15 downto 0));
end component imemory;


component dmemory is 
	port (address_x,address_y,Mem_datain_x,Mem_datain_y: in std_logic_vector(15 downto 0); clk,d_mem_wr_en_x,d_mem_wr_en_y: in std_logic;
				Mem_dataout_x, Mem_dataout_y: out std_logic_vector(15 downto 0));
end component;

component register_file_VHDL is
port (
 clk,rst: in std_logic;
 reg_write_en_x, reg_write_en_y, r7_write_en: in std_logic;
 r7_write_data: in std_logic_vector(15 downto 0);
 r7_read_data: out std_logic_vector(15 downto 0);
 reg_write_dest_x: in std_logic_vector(2 downto 0);
 reg_write_dest_y: in std_logic_vector(2 downto 0);
 reg_write_data_x: in std_logic_vector(15 downto 0);
 reg_write_data_y: in std_logic_vector(15 downto 0);
 reg_read_addr_x1: in std_logic_vector(2 downto 0);
 reg_read_data_x1: out std_logic_vector(15 downto 0);
 reg_read_addr_x2: in std_logic_vector(2 downto 0);
 reg_read_data_x2: out std_logic_vector(15 downto 0);
 reg_read_addr_y1: in std_logic_vector(2 downto 0);
 reg_read_data_y1: out std_logic_vector(15 downto 0);
 reg_read_addr_y2: in std_logic_vector(2 downto 0);
 reg_read_data_y2: out std_logic_vector(15 downto 0)
);
end component;

component scoreboard is
port (
   clk, rst: in std_logic;
 dest_reg1, dest_reg2, reg_read_addr1_x, reg_read_addr2_x, reg_read_addr1_y, reg_read_addr2_y, wr_reg1, wr_reg2: in std_logic_vector(2 downto 0);
 reg_status1_x, reg_status2_x, reg_status1_y, reg_status2_y: out std_logic
);
end component;

component opcodecontrol is
 port(a,b,c,d:in std_logic; 
		Cout1,Cout2,Cout3,Cout4,Cout5,Cout6,Cout7,Cout8,Cout9,Cout10,Cout11: out std_logic);
end component;


component IFID is
 port (PC, Mem_d: in std_logic_vector(15 downto 0); 
		clk,rst, IFID_en, flag, IFID_rst_flag: in std_logic;
		PC_out, Mem_d_out: out std_logic_vector(15 downto 0); 
		IFID_flag: out std_logic);
end component IFID;

 
component IDRR is
port (clk,rst, IDRR_en, IFID_flag, IDRR_rst_flag: in std_logic;
	      IFID_opcode: in std_logic_vector(3 downto 0);
	      inp11_9, inp8_6, inp5_3: in std_logic_vector(2 downto 0);
	      inp7_0: in std_logic_vector(7 downto 0);
		  se10_ir5_0, se7_ir8_0, ls7_ir8_0, inp_pc: in std_logic_vector(15 downto 0);
		  IDRR_flag: out std_logic;
		  IDRR_opcode: out std_logic_vector(3 downto 0);
		  IDRR11_9, IDRR8_6, IDRR5_3: out std_logic_vector(2 downto 0);
		  IDRR7_0: out std_logic_vector(7 downto 0);
		  IDRRse10_ir5_0, IDRRse7_ir8_0, IDRRls7_ir8_0, IDRRPC_out: out std_logic_vector(15 downto 0);
		  IDRR_data_out: out std_logic_vector(85 downto 0)	);
end component IDRR; 


component RREX is 
	port (clk, rst, RREX_en, IDRR_flag, RREX_rst_flag : in std_logic;
	        dest_reg, rf_a1, rf_a2: in std_logic_vector(2 downto 0);
	        r7_read_data, rf_d1, rf_d2: in std_logic_vector(15 downto 0);
			IDRR_opcode: in std_logic_vector(3 downto 0);
			IDRR11_9, IDRR8_6, IDRR5_3: in std_logic_vector(2 downto 0);
		    IDRR7_0: in std_logic_vector(7 downto 0);
			IDRRse10_ir5_0, IDRR_se7_ir8_0, IDRR_ls7_ir8_0, IDRR_PC_out: in std_logic_vector(15 downto 0);
			
			RREX_flag: out std_logic;
			RREX_dest_reg, RREX_rf_a1, RREX_rf_a2: out std_logic_vector(2 downto 0);
			RREX_r7_out, RREX_rf_d1, RREX_rf_d2: out std_logic_vector(15 downto 0);
			RREX_opcode: out std_logic_vector(3 downto 0);
			RREX11_9, RREX8_6, RREX5_3: out std_logic_vector(2 downto 0);
			RREX7_0: out std_logic_vector(7 downto 0);
			RREX_se10_ir5_0, RREX_se7_ir8_0, RREX_ls7_ir8_0, RREX_PC_out: out std_logic_vector(15 downto 0)
			);
end component;

--component RREX is
-- port(clk, rst, RREX_en, q_flag, RREX_rst_flag : in std_logic;
-- 	  q_dest_reg, q_rf_a1, q_rf_a2: in std_logic_vector(2 downto 0);
-- 	  r7_read_data, rf_d1, rf_d2: in std_logic_vector(15 downto 0);
-- 	  q_opcode: in std_logic_vector(3 downto 0);
-- 	  q11_9, q8_6, q5_3: in std_logic_vector(2 downto 0);
-- 	  q7_0: in std_logic_vector(7 downto 0);
-- 	  qse10_ir5_0, qse7_ir8_0, qls7_ir8_0, q_pc_out: in std_logic_vector(15 downto 0);
-- 	  RREX_flag: out std_logic;
--			RREX_dest_reg, RREX_rf_a1, RREX_rf_a2: out std_logic_vector(2 downto 0);
--			RREX_r7_out, RREX_rf_d1, RREX_rf_d2: out std_logic_vector(15 downto 0);
--			RREX_opcode: out std_logic_vector(3 downto 0);
--			RREX11_9, RREX8_6, RREX5_3: out std_logic_vector(2 downto 0);
--			RREX7_0: out std_logic_vector(7 downto 0);
--			RREX_se10_ir5_0, RREX_se7_ir8_0, RREX_ls7_ir8_0, RREX_PC_out: out std_logic_vector(15 downto 0) 	);
-- end component;



component EXMA is 
	port (clk, rst, EXMA_en, EXMA_rst_flag: in std_logic;
	      zero_prev, carry_prev: in std_logic_vector(0 downto 0);
	      RREX_opcode: in std_logic_vector(3 downto 0);
			RREX_dest_reg: in std_logic_vector(2 downto 0);
			RREX_r7_out, RREX_rf_d1, RREX_rf_d2: in std_logic_vector(15 downto 0);
			RREX11_9, RREX8_6, RREX5_3: in std_logic_vector(2 downto 0);
			RREX7_0: in std_logic_vector(7 downto 0);
			RREX_ls7_ir8_0, RREX_PC_out: in std_logic_vector(15 downto 0);
			--prev RREX output, RREX_dest, 
         alu_result_dummy, alu3_out: in std_logic_vector(15 downto 0);
			EXMA_zero_prev, EXMA_carry_prev: out std_logic_vector(0 downto 0);
			EXMA_opcode: out std_logic_vector(3 downto 0);
			EXMA_dest_reg: out std_logic_vector(2 downto 0);
			EXMA_r7_out, EXMA_rf_d1, EXMA_rf_d2: out std_logic_vector(15 downto 0);
			EXMA11_9, EXMA8_6, EXMA5_3: out std_logic_vector(2 downto 0);
			EXMA7_0: out std_logic_vector(7 downto 0);
			EXMA_ls7_ir8_0, EXMA_PC_out: out std_logic_vector(15 downto 0);
			--prev RREX output, RREX_dest, 
      	    EXMA_alu2_out, EXMA_alu3_out: out std_logic_vector(15 downto 0)
		   ); 
end component;


component MAWB is 
	port (clk, rst, MAWB_en, MAWB_rst_flag: in std_logic;
	EXMA_zero_prev, EXMA_carry_prev: in std_logic_vector(0 downto 0);
	      EXMA_dest_reg: in std_logic_vector(2 downto 0);
		  EXMA_opcode: in std_logic_vector(3 downto 0);	--mawb output:
 			EXMA11_9, EXMA8_6, EXMA5_3: in std_logic_vector(2 downto 0);
          EXMA7_0: in std_logic_vector(7 downto 0);
			 data_mem_out, EXMA_r7_out, EXMA_ls7_ir8_0, EXMA_rf_d1, EXMA_rf_d2, EXMA_alu2_out, EXMA_alu3_out, EXMA_PC_out:in std_logic_vector(15 downto 0);
		  MAWB_zero_prev, MAWB_carry_prev: out std_logic_vector(0 downto 0);
		  MAWB_dest_reg: out std_logic_vector(2 downto 0);
		  MAWB_opcode: out std_logic_vector(3 downto 0);	--mawb output:
		  	MAWB11_9, MAWB8_6, MAWB5_3: out std_logic_vector(2 downto 0);
			MAWB7_0: out std_logic_vector(7 downto 0);
		  MAWB_data_mem_out, MAWB_r7_out, MAWB_ls7_ir8_0, MAWB_rf_d1, MAWB_rf_d2, MAWB_alu2_out, MAWB_alu3_out, MAWB_PC_out: out std_logic_vector(15 downto 0)); 
end component;
 --fsm   
-- type FsmState is (inst_fetch, inst_decode, reg_read, execute, mem_access, write_back);--dummy1,dummy2,dummy3,dummy4,dummy5,dummy6,dummy7,dummy8,dummy9,dummy10,dummy11,dummy12,dummy13,dummy14,dummy15,dummy16,dummy17,dummy18,dummy19,dummy20,dummy21,dummy22,dummy23,dummy24,dummy25,dummy26);
 type FsmState is (s0, s1, s2, s3, s4, s5, s6, s7);
 signal fsm_state: FsmState;
 
 signal IFID_PC_out1, IFID_PC_out2, IFID_Mem_d_out1, IFID_Mem_d_out2: std_logic_vector(15 downto 0);
 signal IDRR11_9_1,IDRR11_9_2, IDRR8_6_1, IDRR8_6_2, IDRR5_3_1, IDRR5_3_2:  std_logic_vector(2 downto 0);
 signal IDRR7_0_1, IDRR7_0_2: std_logic_vector(7 downto 0);
 signal IDRRse10_ir5_0_1, IDRRse10_ir5_0_2, IDRR_se7_ir8_0_1, IDRR_se7_ir8_0_2, IDRR_ls7_ir8_0_1, IDRR_ls7_ir8_0_2, IDRRPC_out1, IDRRPC_out2: std_logic_vector(15 downto 0);
 signal RREX_r7_out, RREX_rf_d1_1, RREX_rf_d1_2, RREX_rf_d2_1, RREX_rf_d2_2, RREX_se10_ir5_0_1, RREX_se10_ir5_0_2, RREX_se7_ir8_0_1, RREX_se7_ir8_0_2, RREX_ls7_ir8_0_1, RREX_ls7_ir8_0_2, RREX_PC_out1, RREX_PC_out2: std_logic_vector(15 downto 0);
 signal RREX7_0_1, RREX7_0_2: std_logic_vector(7 downto 0);
 signal EXMA_PC_out1, EXMA_PC_out2, EXMA_r7_out, EXMA_ls7_ir8_0_1, EXMA_ls7_ir8_0_2, EXMA_rf_d1_1, EXMA_rf_d1_2, EXMA_rf_d2_1, EXMA_rf_d2_2, EXMA_alu2_out1, EXMA_alu2_out2, EXMA_alu3_out1, EXMA_alu3_out2: std_logic_vector(15 downto 0);
 signal MAWB_data_mem_out1, MAWB_data_mem_out2, MAWB_PC_out1, MAWB_PC_out2, MAWB_r7_out, MAWB_ls7_ir8_0_1, MAWB_ls7_ir8_0_2, MAWB_rf_d1_1, MAWB_rf_d1_2, MAWB_rf_d2_1, MAWB_rf_d2_2, MAWB_alu2_out1, MAWB_alu2_out2, MAWB_alu3_out1, MAWB_alu3_out2: std_logic_vector(15 downto 0);
 signal MAWB11_9_1, MAWB11_9_2, MAWB8_6_1, MAWB8_6_2, MAWB5_3_1, MAWB5_3_2: std_logic_vector(2 downto 0);
 signal MAWB7_0_1, MAWB7_0_2: std_logic_vector(7 downto 0);
 constant Z16:std_logic_vector(15 downto 0):=(others=>'0');
 signal next_IP_1, next_IP_2, T1: std_logic_vector(15 downto 0);
 signal  zero_prev_dummy, carry_prev_dummy : std_logic_vector(0 downto 0);
 signal a_dummy1,b_dummy1,a_dummy2,b_dummy2 :  std_logic_vector(15 downto 0); -- src1, src2
 signal alu_control_dummy1, alu_control_dummy2 : std_logic_vector(1 downto 0); -- function select
 signal alu_result_dummy1, alu_result_dummy2: std_logic_vector(15 downto 0); -- ALU Output Result
 signal zero_control_dummy1, zero_control_dummy2, carry_control_dummy1, carry_control_dummy2 :  std_logic_vector(0 downto 0);
 signal zero_dummy, carry_dummy: std_logic;
 signal alu3_a, alu3_b1, alu3_b2, alu3_out, alu3_out1, alu3_out2: std_logic_vector(15 downto 0);
 signal i_memd_out1, i_memd_out2: std_logic_vector(15 downto 0);
 signal i_mem_read_en: std_logic;
 signal ALU1_1en, ALU1_2en: std_logic;
 signal reg_write_en_x, reg_write_en_y, r7_write_en: std_logic;
 signal reg_write_dest_x, reg_write_dest_y: std_logic_vector(2 downto 0);
 signal reg_write_data_x, reg_write_data_y, r7_write_data, r7_read_data, r7_write1: std_logic_vector(15 downto 0);
 signal reg_read_addr_x1, reg_read_addr_x2: std_logic_vector(2 downto 0);
 signal reg_read_data_x1, reg_read_data_x2: std_logic_vector(15 downto 0);
 signal reg_read_addr_y1, reg_read_addr_y2: std_logic_vector(2 downto 0);
 signal reg_read_data_y1, reg_read_data_y2: std_logic_vector(15 downto 0);
 signal data_addr1, data_addr2, data_mem_in1, data_mem_in2, data_mem_out1, data_mem_out2: std_logic_vector(15 downto 0);
 signal d_mem_wr_en1, d_mem_wr_en2: std_logic;
 signal opcode1, opcode2: std_logic_vector(3 downto 0);
 signal se10_ir5_0_1, se10_ir5_0_2, se7_ir8_0_1, se7_ir8_0_2, ls7_ir8_0_1, ls7_ir8_0_2: std_logic_vector(15 downto 0);
 signal IFID_en1, IFID_en2, IDRR_en1, IDRR_en2, RREX_en1, RREX_en2, EXMA_en1, EXMA_en2, MAWB_en1, MAWB_en2: std_logic;
 signal s_rf_a1, s_rf_a2, s0_rf_a3, s1_rf_a3: std_logic;
 signal rf_a1_a, rf_a1_b, rf_a1: std_logic_vector(2 downto 0);
 signal rf_a2_a, rf_a2_b, rf_a2: std_logic_vector(2 downto 0);
 signal rf_a3_a, rf_a3_b, rf_a3_c, rf_a3_d, rf_a3: std_logic_vector(2 downto 0);
 signal beqZ_flag1, beqZ_flag2: std_logic;
 signal T2_in, T2_out: std_logic_vector(7 downto 0);
 signal T2_rst: std_logic;
 signal T2, lmsm_out: std_logic_vector(7 downto 0);
 signal pe_out: std_logic_vector(2 downto 0);
 signal opcodeaddCout, opcodeadiCout, opcodenduCout, opcodelwCout,opcodeswCout, opcodelhiCout, opcodelmCout, opcodesmCout, opcodebeqCout, opcodejalCout, opcodejlrCout : std_logic;
 signal s_t1, s_t2, s_alu2a, s0_alu2b, s1_alu2b, s_alu3b: std_logic;
 signal s_ma: std_logic;
 signal s_din, s0_r7in, s1_r7in, s0_rfd3, s1_rfd3: std_logic;
 --signal r7_write_data_mux: std_logic_vector(15 downto 0);
 signal RREX_rf_a1_1, RREX_rf_a1_2, RREX_rf_a2_1, RREX_rf_a2_2: std_logic_vector(2 downto 0);
 signal q_flag_1, q_flag_2: std_logic;
 signal q_dest_reg_1, q_dest_reg_2, q_rf_a1_1, q_rf_a2_1, q_rf_a1_2, q_rf_a2_2: std_logic_vector(2 downto 0);
 signal q_opcode_1, q_opcode_2: std_logic_vector(3 downto 0);
 signal q11_9_1, q11_9_2, q8_6_1, q8_6_2, q5_3_1, q5_3_2: std_logic_vector(2 downto 0);
 signal q7_0_1, q7_0_2: std_logic_vector(7 downto 0);
 signal qse10_ir5_0_1, qse10_ir5_0_2, qse7_ir8_0_1, qse7_ir8_0_2, qls7_ir8_0_1, qls7_ir8_0_2, q_pc_out_1, q_pc_out_2: std_logic_vector(15 downto 0);
 --signal EXMA_en1, EXMA_en2, MAWB_en1, MAWB_en2: std_logic;
 --type lmsmstate is (s0, s1);
 --signal lmsm_state: lmsmstate;
 signal flag1, flag2, IFID_rst_flag1, IFID_rst_flag2, IFID_flag1, IFID_flag2: std_logic;
 signal IDRR_rst_flag1, IDRR_rst_flag2, IDRR_flag1, IDRR_flag2: std_logic;
 signal IDRR_opcode1, IDRR_opcode2: std_logic_vector(3 downto 0);
 signal RREX_rst_flag1, RREX_rst_flag2, RREX_flag1, RREX_flag2: std_logic;
 signal dest_reg1, dest_reg2, RREX_dest_reg1, RREX_dest_reg2: std_logic_vector(2 downto 0);
 signal RREX_opcode1, RREX_opcode2: std_logic_vector(3 downto 0);
 signal RREX11_9_1, RREX11_9_2, RREX8_6_1, RREX8_6_2, RREX5_3_1, RREX5_3_2: std_logic_vector(2 downto 0);
 signal EXMA_rst_flag1, EXMA_rst_flag2, MAWB_rst_flag1, MAWB_rst_flag2: std_logic;
 signal EXMA_zero_prev, EXMA_carry_prev, MAWB_zero_prev, MAWB_carry_prev: std_logic_vector(0 downto 0);
 signal EXMA_opcode1, EXMA_opcode2: std_logic_vector(3 downto 0);
 signal EXMA_dest_reg1, EXMA_dest_reg2: std_logic_vector(2 downto 0); 
 signal EXMA11_9_1, EXMA11_9_2, EXMA8_6_1, EXMA8_6_2, EXMA5_3_1, EXMA5_3_2: std_logic_vector(2 downto 0);
 signal EXMA7_0_1, EXMA7_0_2: std_logic_vector(7 downto 0);
 signal MAWB_dest_reg1, MAWB_dest_reg2: std_logic_vector(2 downto 0);
 signal MAWB_opcode1, MAWB_opcode2: std_logic_vector(3 downto 0);
 signal opcodeaddCout1, opcodeadiCout1, opcodenduCout1, opcodelhiCout1, opcodelwCout1, opcodeswCout1, opcodelmCout1, opcodesmCout1, opcodebeqCout1, opcodejalCout1, opcodejlrCout1 : std_logic; --even for adc, adz
 signal IDRR_opcodeaddCout1, IDRR_opcodeadiCout1, IDRR_opcodenduCout1, IDRR_opcodelhiCout1, IDRR_opcodelwCout1, IDRR_opcodeswCout1, IDRR_opcodelmCout1, IDRR_opcodesmCout1, IDRR_opcodebeqCout1, IDRR_opcodejalCout1, IDRR_opcodejlrCout1 : std_logic;
 signal RREX_opcodeaddCout1, RREX_opcodeadiCout1, RREX_opcodenduCout1, RREX_opcodelhiCout1, RREX_opcodelwCout1, RREX_opcodeswCout1, RREX_opcodelmCout1, RREX_opcodesmCout1, RREX_opcodebeqCout1, RREX_opcodejalCout1, RREX_opcodejlrCout1: std_logic;
 signal EXMA_opcodeaddCout1, EXMA_opcodeadiCout1, EXMA_opcodenduCout1, EXMA_opcodelhiCout1, EXMA_opcodelwCout1, EXMA_opcodeswCout1, EXMA_opcodelmCout1, EXMA_opcodesmCout1, EXMA_opcodebeqCout1, EXMA_opcodejalCout1, EXMA_opcodejlrCout1: std_logic;
 signal MAWB_opcodeaddCout1, MAWB_opcodeadiCout1, MAWB_opcodenduCout1, MAWB_opcodelhiCout1, MAWB_opcodelwCout1, MAWB_opcodeswCout1, MAWB_opcodelmCout1, MAWB_opcodesmCout1, MAWB_opcodebeqCout1, MAWB_opcodejalCout1, MAWB_opcodejlrCout1: std_logic;
 signal opcodeaddCout2, opcodeadiCout2, opcodenduCout2, opcodelhiCout2, opcodelwCout2, opcodeswCout2, opcodelmCout2, opcodesmCout2, opcodebeqCout2, opcodejalCout2, opcodejlrCout2: std_logic; --even for adc, adz
 signal IDRR_opcodeaddCout2, IDRR_opcodeadiCout2, IDRR_opcodenduCout2, IDRR_opcodelhiCout2, IDRR_opcodelwCout2, IDRR_opcodeswCout2, IDRR_opcodelmCout2, IDRR_opcodesmCout2, IDRR_opcodebeqCout2, IDRR_opcodejalCout2, IDRR_opcodejlrCout2: std_logic;
 signal RREX_opcodeaddCout2, RREX_opcodeadiCout2, RREX_opcodenduCout2, RREX_opcodelhiCout2, RREX_opcodelwCout2, RREX_opcodeswCout2, RREX_opcodelmCout2, RREX_opcodesmCout2, RREX_opcodebeqCout2, RREX_opcodejalCout2, RREX_opcodejlrCout2: std_logic;
 signal EXMA_opcodeaddCout2, EXMA_opcodeadiCout2, EXMA_opcodenduCout2, EXMA_opcodelhiCout2, EXMA_opcodelwCout2, EXMA_opcodeswCout2, EXMA_opcodelmCout2, EXMA_opcodesmCout2, EXMA_opcodebeqCout2, EXMA_opcodejalCout2, EXMA_opcodejlrCout2: std_logic;
 signal MAWB_opcodeaddCout2, MAWB_opcodeadiCout2, MAWB_opcodenduCout2, MAWB_opcodelhiCout2, MAWB_opcodelwCout2, MAWB_opcodeswCout2, MAWB_opcodelmCout2, MAWB_opcodesmCout2, MAWB_opcodebeqCout2, MAWB_opcodejalCout2, MAWB_opcodejlrCout2: std_logic;
 signal rfd3_mux_out: std_logic_vector(15 downto 0);
 signal  s_rfd3_lmsm_mux: std_logic;
 signal alu4_in, alu4_out: std_logic_vector(15 downto 0);
 signal WB_forw_out, forw1_d1, forw2_d2: std_logic_vector(15 downto 0);
 signal s0_forw1, s1_forw1, s0_forw2, s1_forw2, s0_wb_forw, s1_wb_forw: std_logic;
 signal s_r7minimux: std_logic;
 signal reg_read_data_1, reg_read_data_2: std_logic_vector(15 downto 0);
 signal  wr_reg1, wr_reg2: std_logic_vector(2 downto 0);
 signal  push, pop, rf_a1_x_b1, rf_a2_x_b2, rf_a1_y_b1, rf_a2_y_b2: std_logic;
 signal data_in_x, data_in_y, data_out_x, data_out_y: std_logic_vector(85 downto 0);
 signal elements: std_logic_vector(3 downto 0);
 signal rf_a1_x, rf_a2_x, rf_a1_y, rf_a2_y: std_logic_vector(2 downto 0);
 begin
 alu1_1_block: alu1 port map(r7_read_data,ALU1_1en,next_IP_1);
 alu1_2_block: alu1 port map(next_IP_1, ALU1_2en, next_IP_2);
 inst_mem: imemory port map(r7_read_data, clk, i_mem_read_en, i_memd_out1, i_memd_out2);
 IFIDreg1: IFID port map(r7_read_data, i_memd_out1,clk, rst, IFID_en1, flag1, IFID_rst_flag1, IFID_PC_out1, IFID_Mem_d_out1, IFID_flag1);
 IFIDreg2: IFID port map(next_IP_1, i_memd_out2,clk, rst, IFID_en2, flag2, IFID_rst_flag2, IFID_PC_out2, IFID_Mem_d_out2, IFID_flag2);
 IDRRreg1: IDRR port map(clk, rst, IDRR_en1, IFID_flag1, IDRR_rst_flag1, opcode1, IFID_Mem_d_out1(11 downto 9), IFID_Mem_d_out1(8 downto 6), IFID_Mem_d_out1(5 downto 3), IFID_Mem_d_out1(7 downto 0),se10_ir5_0_1, se7_ir8_0_1, ls7_ir8_0_1, IFID_PC_out1,IDRR_flag1, IDRR_opcode1, IDRR11_9_1, IDRR8_6_1, IDRR5_3_1, IDRR7_0_1, IDRRse10_ir5_0_1, IDRR_se7_ir8_0_1, IDRR_ls7_ir8_0_1, IDRRPC_out1, data_in_x);
 IDRRreg2: IDRR port map(clk, rst, IDRR_en2, IFID_flag2, IDRR_rst_flag2, opcode2, IFID_Mem_d_out2(11 downto 9), IFID_Mem_d_out2(8 downto 6), IFID_Mem_d_out2(5 downto 3), IFID_Mem_d_out2(7 downto 0),se10_ir5_0_2, se7_ir8_0_2, ls7_ir8_0_2, IFID_PC_out2,IDRR_flag2, IDRR_opcode2, IDRR11_9_2, IDRR8_6_2, IDRR5_3_2, IDRR7_0_2, IDRRse10_ir5_0_2, IDRR_se7_ir8_0_2, IDRR_ls7_ir8_0_2, IDRRPC_out2, data_in_y);
 reg1: register_file_VHDL port map ( clk,rst, reg_write_en_x, reg_write_en_y, r7_write_en, r7_write_data, r7_read_data, reg_write_dest_x, reg_write_dest_y, reg_write_data_x, reg_write_data_y, 
 reg_read_addr_x1, reg_read_data_x1, reg_read_addr_x2, reg_read_data_x2, reg_read_addr_y1, reg_read_data_y1, reg_read_addr_y2, reg_read_data_y2);
 RREXreg1: RREX port map(clk, rst, RREX_en1, q_flag_1, RREX_rst_flag1, q_dest_reg_1, q_rf_a1_1, q_rf_a2_1, r7_read_data, reg_read_data_x1, reg_read_data_x2, q_opcode_1,
 q11_9_1, q8_6_1, q5_3_1, q7_0_1, qse10_ir5_0_1, qse7_ir8_0_1, qls7_ir8_0_1, q_pc_out_1, RREX_flag1, RREX_dest_reg1, RREX_rf_a1_1, RREX_rf_a2_1, RREX_r7_out, RREX_rf_d1_1, RREX_rf_d2_1, RREX_opcode1,RREX11_9_1, RREX8_6_1, RREX5_3_1, RREX7_0_1, RREX_se10_ir5_0_1, RREX_se7_ir8_0_1, RREX_ls7_ir8_0_1, RREX_PC_out1); 
 RREXreg2: RREX port map(clk, rst, RREX_en2, q_flag_2, RREX_rst_flag2, q_dest_reg_2, q_rf_a1_2, q_rf_a2_2, r7_read_data, reg_read_data_x1, reg_read_data_x2, q_opcode_2,
 q11_9_2, q8_6_2, q5_3_2, q7_0_2, qse10_ir5_0_2, qse7_ir8_0_2, qls7_ir8_0_2, q_pc_out_2, RREX_flag2, RREX_dest_reg2, RREX_rf_a1_2, RREX_rf_a2_2, RREX_r7_out, RREX_rf_d1_2, RREX_rf_d2_2, RREX_opcode2,RREX11_9_2, RREX8_6_2, RREX5_3_2, RREX7_0_2, RREX_se10_ir5_0_2, RREX_se7_ir8_0_2, RREX_ls7_ir8_0_2, RREX_PC_out2); 
 alu2_block1: alu2 port map (zero_prev_dummy, carry_prev_dummy,a_dummy1,b_dummy1 ,alu_control_dummy1 , RREX_opcodebeqCout1, alu_result_dummy1,zero_control_dummy1, carry_control_dummy1,zero_dummy, carry_dummy, beqZ_flag1);
 alu2_block2: alu2 port map (zero_prev_dummy, carry_prev_dummy,a_dummy2,b_dummy2 ,alu_control_dummy2 , RREX_opcodebeqCout2, alu_result_dummy2,zero_control_dummy2, carry_control_dummy2,zero_dummy, carry_dummy, beqZ_flag2);
 alu3_block1: alu3 port map(RREX_PC_out1, alu3_b1, alu3_out1);
 alu3_block2: alu3 port map(RREX_PC_out2, alu3_b2, alu3_out2);
 EXMAreg1: EXMA port map(clk, rst, EXMA_en1, EXMA_rst_flag1, zero_prev_dummy, carry_prev_dummy, RREX_opcode1, RREX_dest_reg1, RREX_r7_out, RREX_rf_d1_1, RREX_rf_d2_1, RREX11_9_1, RREX8_6_1, RREX5_3_1, RREX7_0_1, RREX_ls7_ir8_0_1, RREX_PC_out1, alu_result_dummy1, alu3_out1, EXMA_zero_prev, EXMA_carry_prev, EXMA_opcode1, EXMA_dest_reg1, EXMA_r7_out, EXMA_rf_d1_1, EXMA_rf_d2_1, EXMA11_9_1, EXMA8_6_1, EXMA5_3_1, EXMA7_0_1, EXMA_ls7_ir8_0_1, EXMA_PC_out1, EXMA_alu2_out1, EXMA_alu3_out1);
 EXMAreg2: EXMA port map(clk, rst, EXMA_en2, EXMA_rst_flag2, zero_prev_dummy, carry_prev_dummy, RREX_opcode2, RREX_dest_reg2, RREX_r7_out, RREX_rf_d1_2, RREX_rf_d2_2, RREX11_9_2, RREX8_6_2, RREX5_3_2, RREX7_0_2, RREX_ls7_ir8_0_2, RREX_PC_out2, alu_result_dummy2, alu3_out2, EXMA_zero_prev, EXMA_carry_prev, EXMA_opcode2, EXMA_dest_reg2, EXMA_r7_out, EXMA_rf_d1_2, EXMA_rf_d2_2, EXMA11_9_2, EXMA8_6_2, EXMA5_3_2, EXMA7_0_2, EXMA_ls7_ir8_0_2, EXMA_PC_out2, EXMA_alu2_out2, EXMA_alu3_out2);
 data_mem: dmemory port map(data_addr1, data_addr2, data_mem_in1, data_mem_in2, clk, d_mem_wr_en1, d_mem_wr_en2, data_mem_out1, data_mem_out2);
 lmsm_unit: lmsmblock port map(clk, T2, pe_out, lmsm_out); 
 MAWBreg1: MAWB port map(clk, rst, MAWB_en1, MAWB_rst_flag1, EXMA_zero_prev, EXMA_carry_prev, EXMA_dest_reg1, EXMA_opcode1,EXMA11_9_1, EXMA8_6_1, EXMA5_3_1, EXMA7_0_1, data_mem_out1, EXMA_r7_out, EXMA_ls7_ir8_0_1, EXMA_rf_d1_1, EXMA_rf_d2_1, EXMA_alu2_out1, EXMA_alu3_out1, EXMA_PC_out1, MAWB_zero_prev, MAWB_carry_prev, MAWB_dest_reg1, MAWB_opcode1, MAWB11_9_1, MAWB8_6_1, MAWB5_3_1,MAWB7_0_1, MAWB_data_mem_out1, MAWB_r7_out, MAWB_ls7_ir8_0_1, MAWB_rf_d1_1, MAWB_rf_d2_1, MAWB_alu2_out1, MAWB_alu3_out1, MAWB_PC_out1); 
 MAWBreg2: MAWB port map(clk, rst, MAWB_en2, MAWB_rst_flag2, EXMA_zero_prev, EXMA_carry_prev, EXMA_dest_reg2, EXMA_opcode2,EXMA11_9_2, EXMA8_6_2, EXMA5_3_2, EXMA7_0_2, data_mem_out2, EXMA_r7_out, EXMA_ls7_ir8_0_2, EXMA_rf_d1_2, EXMA_rf_d2_2, EXMA_alu2_out2, EXMA_alu3_out2, EXMA_PC_out2, MAWB_zero_prev, MAWB_carry_prev, MAWB_dest_reg2, MAWB_opcode2, MAWB11_9_2, MAWB8_6_2, MAWB5_3_2,MAWB7_0_2, MAWB_data_mem_out2, MAWB_r7_out, MAWB_ls7_ir8_0_2, MAWB_rf_d1_2, MAWB_rf_d2_2, MAWB_alu2_out2, MAWB_alu3_out2, MAWB_PC_out2); 
 alu4_block: alu4 port map(alu4_in, alu4_out);
 sb: scoreboard port map(clk, rst, dest_reg1, dest_reg2, rf_a1_x, rf_a2_x, rf_a1_y, rf_a2_y, wr_reg1, wr_reg2,
 rf_a1_x_b1, rf_a2_x_b2, rf_a1_y_b1, rf_a2_y_b2);
 queueue: queue port map(clk, rst, push, pop, rf_a1_x_b1, rf_a2_x_b2, rf_a1_y_b1, rf_a2_y_b2, data_in_x, data_in_y, data_out_x, data_out_y, elements,
 rf_a1_x, rf_a2_x, rf_a1_y, rf_a2_y);
 q_flag_1 <= data_out_x(85);
 q_opcode_1 <= data_out_x(84 downto 81);
 q11_9_1 <= data_out_x(80 downto 78);
 q8_6_1 <= data_out_x(77 downto 75);
 q5_3_1 <= data_out_x(74 downto 72);
 q7_0_1 <= data_out_x(71 downto 64);
 qse10_ir5_0_1 <= data_out_y(63 downto 48);
 qse7_ir8_0_1 <= data_out_y(47 downto 32);
 qls7_ir8_0_1 <= data_out_y(31 downto 16);
 q_pc_out_1 <= data_out_y(15 downto 0);
 q_flag_2 <= data_out_y(85);
 q_opcode_2 <= data_out_y(84 downto 81);
 q11_9_2 <= data_out_y(80 downto 78);
 q8_6_2 <= data_out_y(77 downto 75);
 q5_3_2 <= data_out_y(74 downto 72);
 q7_0_2 <= data_out_y(71 downto 64);
 qse10_ir5_0_2 <= data_out_y(63 downto 48);
 qse7_ir8_0_2 <= data_out_y(47 downto 32);
 qls7_ir8_0_2 <= data_out_y(31 downto 16);
 q_pc_out_2 <= data_out_y(15 downto 0);
  --IDRR_data_out(80 downto 78)<=inp11_9;
 --IDRR8_6<=inp8_6;
 --IDRR_data_out(77 downto 75)<=inp8_6;
 --IDRR5_3<=inp5_3;
 --IDRR_data_out(74 downto 72)<=inp5_3;
 --IDRR7_0<=inp7_0;
 --IDRR_data_out(71 downto 64)<=inp7_0;
 --IDRRse10_ir5_0<=se10_ir5_0; 
 --IDRR_data_out(63 downto 48)<= se10_ir5_0;
 --IDRRse7_ir8_0<=se7_ir8_0;
 --IDRR_data_out(47 downto 32)<= se7_ir8_0;
 --IDRRls7_ir8_0<=ls7_ir8_0;
 --IDRR_data_out(31 downto 16)<= ls7_ir8_0;
 --IDRRPC_out<=inp_pc; 
 --IDRR_data_out(15 downto 0)<=inp_pc;
 --rfa1mux: mux3bit2to1 port map(IDRR11_9, IDRR8_6, s_rf_a1, reg_read_addr_1_dummy); --done
 --rfa2mux: mux3bit2to1 port map(IDRR8_6, pe_out, s_rf_a2, reg_read_addr_2_dummy);
 --rfa3mux: mux3bit4to1 port map(MAWB11_9, MAWB8_6, MAWB5_3, pe_out, s0_rf_a3, s1_rf_a3, reg_write_dest_dummy); 
 --r7inmux: mux16bit4to1 port map(r7_write_data_mux, r7_write1, reg_read_data_2_dummy, data_mem_out , s0_r7in, s1_r7in, r7_write_data); --alu1_out
 --r7minimux: mux16bit2to1 port map(alu3_out1,alu_result_dummy, s_r7minimux, r7_write1); 
 --forwardingmux1: mux16bit4to1 port map(alu_result_dummy, data_mem_out,WB_forw_out,reg_read_data_1_dummy, s0_forw1, s1_forw1, forw1_d1); 
 --forwardingmux2: mux16bit4to1 port map(alu_result_dummy, data_mem_out,WB_forw_out,reg_read_data_2_dummy, s0_forw2, s1_forw2, forw2_d2); 
 --alu2amux: mux16bit2to1 port map(RREX_rf_d1, RREX_rf_d2, s_alu2a, a_dummy);
 --alu2bmux: mux16bit2to1 port map(RREX_rf_d2, RREX_se10_ir5_0, s0_alu2b, b_dummy);
 --alu3bmux: mux16bit2to1 port map(RREX_se10_ir5_0, RREX_se7_ir8_0, s_alu3b, alu3_b);
 --EXMAreg: EXMA port map(clk, rst, EXMA_en, EXMA_rst_flag, zero_prev_dummy, carry_prev_dummy, RREX_opcode, RREX_dest_reg, RREX_r7_out, RREX_rf_d1, RREX_rf_d2, RREX11_9, RREX8_6, RREX5_3, RREX7_0, RREX_ls7_ir8_0, RREX_PC_out, alu_result_dummy, alu3_out, EXMA_zero_prev, EXMA_carry_prev, EXMA_opcode, EXMA_dest_reg, EXMA_r7_out, EXMA_rf_d1, EXMA_rf_d2, EXMA11_9, EXMA8_6, EXMA5_3, EXMA7_0, EXMA_ls7_ir8_0, EXMA_PC_out, EXMA_alu2_out, EXMA_alu3_out);
 --maaddrmux: mux16bit2to1 port map(T1, EXMA_alu2_out, s_ma, data_addr);
 
 --madinmux: mux16bit2to1 port map(MAWB_rf_d2, MAWB_rf_d1, s_din, data_mem_in); 
 --rfd3mux: mux16bit4to1 port map(MAWB_alu2_out, MAWB_r7_out, MAWB_data_mem_out, MAWB_ls7_ir8_0, s0_rfd3, s1_rfd3, rfd3_mux_out);
 --rfd3_lmsm_mux: mux16bit2to1 port map(rfd3_mux_out, data_mem_out, s_rfd3_lmsm_mux,reg_write_data_dummy); 
 --wb_forwarding_mux: mux16bit4to1 port map(MAWB_data_mem_out, MAWB_alu2_out, MAWB_alu3_out, Z16, s0_wb_forw, s1_wb_forw, WB_forw_out);
 
 --t2mux: mux8bit2to1 port map(IFID_Mem_d_out(7 downto 0), lmsm_out,s_t2, T2);
 --t1mux: mux16bit2to1 port map(RREX_rf_d1, alu4_out, s_t1, T1);
 --T2_register: T2_reg port map(T2_in, clk, T2_rst, T2_out);
 
 ID_opcode_logic1: opcodecontrol port map(opcode1(3), opcode1(2), opcode1(1), opcode1(0), opcodeaddCout1, opcodeadiCout1, opcodenduCout1, opcodelhiCout1, opcodelwCout1, opcodeswCout1, opcodelmCout1, opcodesmCout1, opcodebeqCout1, opcodejalCout1, opcodejlrCout1); --even for adc, adz
 RR_opcode_logic1: opcodecontrol port map(q_opcode_1(3), q_opcode_1(2), q_opcode_1(1), q_opcode_1(0), IDRR_opcodeaddCout1, IDRR_opcodeadiCout1, IDRR_opcodenduCout1, IDRR_opcodelhiCout1, IDRR_opcodelwCout1, IDRR_opcodeswCout1, IDRR_opcodelmCout1, IDRR_opcodesmCout1, IDRR_opcodebeqCout1, IDRR_opcodejalCout1, IDRR_opcodejlrCout1);
 EX_opcode_logic1: opcodecontrol port map(RREX_opcode1(3), RREX_opcode1(2), RREX_opcode1(1), RREX_opcode1(0), RREX_opcodeaddCout1, RREX_opcodeadiCout1, RREX_opcodenduCout1, RREX_opcodelhiCout1, RREX_opcodelwCout1, RREX_opcodeswCout1, RREX_opcodelmCout1, RREX_opcodesmCout1, RREX_opcodebeqCout1, RREX_opcodejalCout1, RREX_opcodejlrCout1);
 MA_opcode_logic1: opcodecontrol port map(EXMA_opcode1(3), EXMA_opcode1(2), EXMA_opcode1(1), EXMA_opcode1(0), EXMA_opcodeaddCout1, EXMA_opcodeadiCout1, EXMA_opcodenduCout1, EXMA_opcodelhiCout1, EXMA_opcodelwCout1, EXMA_opcodeswCout1, EXMA_opcodelmCout1, EXMA_opcodesmCout1, EXMA_opcodebeqCout1, EXMA_opcodejalCout1, EXMA_opcodejlrCout1);
 WB_opcode_logic1: opcodecontrol port map(MAWB_opcode1(3), MAWB_opcode1(2), MAWB_opcode1(1), MAWB_opcode1(0), MAWB_opcodeaddCout1, MAWB_opcodeadiCout1, MAWB_opcodenduCout1, MAWB_opcodelhiCout1, MAWB_opcodelwCout1, MAWB_opcodeswCout1, MAWB_opcodelmCout1, MAWB_opcodesmCout1, MAWB_opcodebeqCout1, MAWB_opcodejalCout1, MAWB_opcodejlrCout1);
 ID_opcode_logic2: opcodecontrol port map(opcode2(3), opcode2(2), opcode2(1), opcode2(0), opcodeaddCout2, opcodeadiCout2, opcodenduCout2, opcodelhiCout2, opcodelwCout2, opcodeswCout2, opcodelmCout2, opcodesmCout2, opcodebeqCout2, opcodejalCout2, opcodejlrCout2); --even for adc, adz
 RR_opcode_logic2: opcodecontrol port map(q_opcode_2(3), q_opcode_2(2), q_opcode_2(1), q_opcode_2(0), IDRR_opcodeaddCout2, IDRR_opcodeadiCout2, IDRR_opcodenduCout2, IDRR_opcodelhiCout2, IDRR_opcodelwCout2, IDRR_opcodeswCout2, IDRR_opcodelmCout2, IDRR_opcodesmCout2, IDRR_opcodebeqCout2, IDRR_opcodejalCout2, IDRR_opcodejlrCout2);
 EX_opcode_logic2: opcodecontrol port map(RREX_opcode2(3), RREX_opcode2(2), RREX_opcode2(1), RREX_opcode2(0), RREX_opcodeaddCout2, RREX_opcodeadiCout2, RREX_opcodenduCout2, RREX_opcodelhiCout2, RREX_opcodelwCout2, RREX_opcodeswCout2, RREX_opcodelmCout2, RREX_opcodesmCout2, RREX_opcodebeqCout2, RREX_opcodejalCout2, RREX_opcodejlrCout2);
 MA_opcode_logic2: opcodecontrol port map(EXMA_opcode2(3), EXMA_opcode2(2), EXMA_opcode2(1), EXMA_opcode2(0), EXMA_opcodeaddCout2, EXMA_opcodeadiCout2, EXMA_opcodenduCout2, EXMA_opcodelhiCout2, EXMA_opcodelwCout2, EXMA_opcodeswCout2, EXMA_opcodelmCout2, EXMA_opcodesmCout2, EXMA_opcodebeqCout2, EXMA_opcodejalCout2, EXMA_opcodejlrCout2);
 WB_opcode_logic2: opcodecontrol port map(MAWB_opcode2(3), MAWB_opcode2(2), MAWB_opcode2(1), MAWB_opcode2(0), MAWB_opcodeaddCout2, MAWB_opcodeadiCout2, MAWB_opcodenduCout2, MAWB_opcodelhiCout2, MAWB_opcodelwCout2, MAWB_opcodeswCout2, MAWB_opcodelmCout2, MAWB_opcodesmCout2, MAWB_opcodebeqCout2, MAWB_opcodejalCout2, MAWB_opcodejlrCout2);
 --zero_prev_dummy(0 downto 0)<="0"
 --carry_prev_dummy(0 downto 0)<="0";
-- output<=alu_result_dummy(0);
 process(clk, rst)
 variable next_IP_var: std_logic_vector(15 downto 0);
 variable next_fsm_state:FsmState;
 variable T1var: std_logic_vector(15 downto 0);
 variable z_prev_dummy_var, c_prev_dummy_var: std_logic_vector(0 downto 0);
 variable z_flag: std_logic;
 variable s_t1_var, s_t2_var: std_logic;
 variable alu4_in_var: std_logic_vector(15 downto 0);
 variable s_alu2a_var, s0_alu2b_var, s_alu3b_var, carry_control_var, zero_control_var, RREX_rst_flag_var,
 EXMA_rst_flag_var, s_ma_var, s_din_var, s0_rfd3_var, s1_rfd3_var, d_mem_wr_en_var, s0_rf_a3_var, s1_rf_a3_var,
 reg_write_en_var: std_logic;
 variable alu_control_var: std_logic_vector(1 downto 0);



 variable i_mem_read_en_var, ALU1_1en_var, ALU1_2en_var, IDRR_en1_var, IDRR_en2_var, RREX_en1_var, RREX_en2_var, IFID_en1_var, IFID_en2_var, EXMA_en1_var, EXMA_en2_var, MAWB_en1_var, MAWB_en2_var: std_logic;
 variable dest_reg1_var, dest_reg2_var : std_logic_vector(2 downto 0);
 variable reg_read_addr_x1_var, reg_read_addr_x2_var, reg_read_addr_y1_var, reg_read_addr_y2_var, reg_write_dest_x_var, reg_write_dest_y_var: std_logic_vector(2 downto 0);
 variable reg_write_en_x_var, reg_write_en_y_var, r7_write_en_var: std_logic;
 variable a_dummy1_var, a_dummy2_var, b_dummy1_var, b_dummy2_var, alu3_b1_var, alu3_b2_var: std_logic_vector(15 downto 0);
 variable alu_control_dummy1_var, alu_control_dummy2_var: std_logic_vector (1 downto 0);
 variable carry_control_dummy1_var, carry_control_dummy2_var, zero_control_dummy1_var, zero_control_dummy2_var : std_logic;
 variable data_addr1_var, data_addr2_var, reg_write_data_x_var, reg_write_data_y_var, r7_write_data_var: std_logic_vector(15 downto 0);
 variable d_mem_wr_en1_var, d_mem_wr_en2_var: std_logic;
 
 --variable rrex_rst_var, exma_rst_var: std_logic;
 --variable var_s_rf_a2: std_logic;
 --variable 
 begin
 next_fsm_state := fsm_state;
 --s_t1_var := '1';
 --s_t2_var := '1';
 --s_alu2a_var:= '1';
 --s0_alu2b_var:='1';
 --rrex_rst_var := '1';
 --exma_rst_var := '1';
 --z_prev_dummy_var(0) := '0';
 --c_prev_dummy_var(0) := '0';
 --z_flag := '0';
 case next_fsm_state is
    when s0=>
	  --next_IP_var := next_IP;
	  
	  if((IDRR_opcodelmCout1 = '1' or IDRR_opcodesmCout1 = '1')) then
	  IDRR_rst_flag1<='1';
	 IDRR_en1<='0';
	  ALU1_1en<='0';
	  --RREX_en<='0';
	  IFID_en1<='0';
	--       s_alu2a<= RREX_opcodeaddCout or RREX_opcodenduCout or RREX_opcodeadiCout or RREX_opcodelwCout or RREX_opcodebeqCout;
 --s0_alu2b<= RREX_opcodeaddCout or RREX_opcodenduCout or RREX_opcodebeqCout; --or RREX_opcodeadiCout or RREX_opcodelwCout or RREX_opcodeswCout or RREX_opcodebeqCout;
 ----s1_alu2b<= RREX_opcodeaddCout or RREX_opcodenduCout or RREX_opcodelwCout or RREX_opcodebeqCout or not(RREX_opcodelmCout) or not(RREX_opcodesmCout);
 --s_alu3b<= RREX_opcodebeqCout;
 --if(RREX_opcodeaddCout = '1' or RREX_opcodeadiCout = '1' or RREX_opcodelwCout='1' or RREX_opcodeswCout = '1') then
 --alu_control_dummy<="00";
 --if (RREX_opcodeaddCout = '1' or RREX_opcodeadiCout = '1') then
 --carry_control_dummy(0)<='1';
 --zero_control_dummy(0)<='1';
 --elsif(RREX_opcodelwCout='1') then
 --carry_control_dummy(0)<='0';
 --zero_control_dummy(0)<='1';
 --else
 --carry_control_dummy(0)<='0';
 --zero_control_dummy(0)<='0';
 --end if; 
 --elsif (RREX_opcodenduCout = '1') then
 --alu_control_dummy<="01";
 --carry_control_dummy(0)<='0';
 --zero_control_dummy(0)<='1';
 --elsif (RREX_opcodebeqCout = '1') then
 --alu_control_dummy<="10";
 --carry_control_dummy(0)<='0';
 --zero_control_dummy(0)<='1';  --changed later
 --end if;
    
	  next_fsm_state := s1;

	  elsif ((IDRR_opcodelmCout1 = '1' or IDRR_opcodesmCout1 = '1')) then
	  IDRR_rst_flag2<='1';
	 IDRR_en2<='0';
	  ALU1_2en<='0';
	  --RREX_en<='0';
	  IFID_en2<='0';
	  	
	  --s_rfd3_lmsm_mux<='1';

	  else


	  next_fsm_state := s0;
	  i_mem_read_en_var:='1';
	  --RREX_rst_flag<='0';
	  --EXMA_rst_flag<='0';
	  ALU1_1en_var:='1';
	  ALU1_2en_var:='1';
	  IDRR_en1_var:='1';
	  RREX_en1_var:='1';
	  IFID_en1_var:='1';
	  IDRR_en2_var:='1';
	  RREX_en2_var:='1';
	  IFID_en2_var:='1';
	  EXMA_en1_var:='1';
	  EXMA_en2_var:='1';
	  MAWB_en1_var:='1';
	  MAWB_en2_var:='1';
                 
      --Destination Register Logic, CHANGE wrt QUEUE, may bE DIRECTLY OBTAINED FROM QUEUE
	  if (opcodeaddCout1 = '1' or opcodenduCout1 = '1') then
	   dest_reg1_var := IDRR5_3_1;
	  elsif (opcodeadiCout1 = '1' or opcodelhiCout1 = '1') then
	   dest_reg1_var := IDRR8_6_1;
	  elsif (opcodelwCout1 = '1' or opcodejalCout1 = '1' or opcodejlrCout1='1') then
	   dest_reg1_var := IDRR11_9_1;
	  end if;           
      
      if (opcodeaddCout2 = '1' or opcodenduCout2 = '1') then
	   dest_reg2_var := IDRR5_3_2;
	  elsif (opcodeadiCout2 = '1' or opcodelhiCout2 = '1') then
	   dest_reg2_var := IDRR8_6_2;
	  elsif (opcodelwCout2 = '1' or opcodejalCout2 = '1' or opcodejlrCout2='1') then
	   dest_reg2_var := IDRR11_9_2;
	  end if;
       


      -- RF_A1, RF_A2, CHANGE wrt QUEUE, REQUIRED HERE
      if (IDRR_opcodeaddCout1 = '1' or IDRR_opcodeadiCout1 = '1' or IDRR_opcodenduCout1 = '1' or IDRR_opcodeswCout1 = '1' or IDRR_opcodebeqCout1 = '1' or IDRR_opcodelmCout1 = '1' or IDRR_opcodesmCout1 = '1') then -- same mux for lm_sm
      reg_read_addr_x1_var := IDRR11_9_1;
      else
      reg_read_addr_x1_var := IDRR8_6_1; 
      end if;
      if (IDRR_opcodeaddCout1 = '1' or IDRR_opcodenduCout1 = '1' or IDRR_opcodeswCout1 = '1' or IDRR_opcodebeqCout1 = '1' or IDRR_opcodejlrCout1 = '1') then
      reg_read_addr_x2_var := IDRR8_6_2;
      else
      reg_read_addr_x2_var := pe_out;
      end if;

      if (IDRR_opcodeaddCout2 = '1' or IDRR_opcodeadiCout2 = '1' or IDRR_opcodenduCout2 = '1' or IDRR_opcodeswCout2 = '1' or IDRR_opcodebeqCout2 = '1' or IDRR_opcodelmCout2 = '1' or IDRR_opcodesmCout2 = '1') then -- same mux for lm_sm
      reg_read_addr_y1_var := IDRR11_9_1;
      else
      reg_read_addr_y1_var := IDRR8_6_1; 
      end if;
      if (IDRR_opcodeaddCout2 = '1' or IDRR_opcodenduCout2 = '1' or IDRR_opcodeswCout2 = '1' or IDRR_opcodebeqCout2 = '1' or IDRR_opcodejlrCout2 = '1') then
      reg_read_addr_y2_var := IDRR8_6_2;
      else
      reg_read_addr_y2_var := pe_out;
      end if;

	  
      

	  --s_rfd3_lmsm_mux<='1';

	  if(MAWB_opcodeaddCout1 = '1' or  MAWB_opcodenduCout1 = '1') then
       reg_write_dest_x_var:= MAWB5_3_1;
      elsif (MAWB_opcodelwCout1 = '1' or (MAWB_opcodejalCout1 = '1' and ((not(MAWB_dest_reg1(2)) = '1') or (not(MAWB_dest_reg1(1)) = '1') or (not(MAWB_dest_reg1(0)) = '1')) ) or (MAWB_opcodejlrCout1 = '1' and  ((not(MAWB_dest_reg1(2)) = '1') or (not(MAWB_dest_reg1(1)) = '1') or (not(MAWB_dest_reg1(0)) = '1')) ) or MAWB_opcodelhiCout1 = '1') then--probably shift in wb stage
       reg_write_dest_x_var:= MAWB11_9_1;
      elsif(MAWB_opcodeadiCout1 = '1') then
       reg_write_dest_x_var:= MAWB8_6_1;
      else
       reg_write_dest_x_var:= pe_out;       
	  end if;
      if(MAWB_opcodeaddCout2 = '1' or  MAWB_opcodenduCout2 = '1') then
       reg_write_dest_y_var:= MAWB5_3_2;
      elsif (MAWB_opcodelwCout2 = '1' or (MAWB_opcodejalCout2 = '1' and ((not(MAWB_dest_reg2(2)) = '1') or (not(MAWB_dest_reg2(1)) = '1') or (not(MAWB_dest_reg1(0)) = '1')) ) or (MAWB_opcodejlrCout1 = '1' and  ((not(MAWB_dest_reg1(2)) = '1') or (not(MAWB_dest_reg1(1)) = '1') or (not(MAWB_dest_reg1(0)) = '1')) ) or MAWB_opcodelhiCout1 = '1') then--probably shift in wb stage
       reg_write_dest_y_var:= MAWB11_9_2;
      elsif(MAWB_opcodeadiCout2 = '1') then
       reg_write_dest_y_var:= MAWB8_6_2;
      else
       reg_write_dest_y_var:= pe_out;       
	  end if;

      reg_write_en_x_var :=(MAWB_opcodeaddCout1 and ((not(MAWB7_0_1(0)) and not(MAWB7_0_1(1))) or ((MAWB7_0_1(1)) and not(MAWB7_0_1(0)) and MAWB_carry_prev(0)) or (not(MAWB7_0_1(1)) and (MAWB7_0_1(0)) and MAWB_zero_prev(0)) )) or  (MAWB_opcodenduCout1 and ((not(MAWB7_0_1(0)) and not(MAWB7_0_1(1))) or ((MAWB7_0_1(1)) and not(MAWB7_0_1(0)) and MAWB_carry_prev(0)) or (not(MAWB7_0_1(1)) and (MAWB7_0_1(0)) and MAWB_zero_prev(0)) )) or MAWB_opcodeadiCout1 or MAWB_opcodelwCout1 or MAWB_opcodejalCout1 or MAWB_opcodejlrCout1 or MAWB_opcodelhiCout1 or MAWB_opcodelmCout1;
      reg_write_en_y_var :=(MAWB_opcodeaddCout2 and ((not(MAWB7_0_2(0)) and not(MAWB7_0_2(1))) or ((MAWB7_0_2(1)) and not(MAWB7_0_2(0)) and MAWB_carry_prev(0)) or (not(MAWB7_0_2(1)) and (MAWB7_0_2(0)) and MAWB_zero_prev(0)) )) or  (MAWB_opcodenduCout2 and ((not(MAWB7_0_2(0)) and not(MAWB7_0_2(1))) or ((MAWB7_0_2(1)) and not(MAWB7_0_2(0)) and MAWB_carry_prev(0)) or (not(MAWB7_0_2(1)) and (MAWB7_0_2(0)) and MAWB_zero_prev(0)) )) or MAWB_opcodeadiCout2 or MAWB_opcodelwCout2 or MAWB_opcodejalCout2 or MAWB_opcodejlrCout2 or MAWB_opcodelhiCout2 or MAWB_opcodelmCout2;
      r7_write_en_var := not (EXMA_opcodebeqCout1 or EXMA_opcodebeqCout2);

       se10_ir5_0_1 <= IFID_Mem_d_out1(5) & IFID_Mem_d_out1(5) & IFID_Mem_d_out1(5) & IFID_Mem_d_out1(5) & IFID_Mem_d_out1(5) & IFID_Mem_d_out1(5) & IFID_Mem_d_out1(5) & IFID_Mem_d_out1(5) & IFID_Mem_d_out1(5) & IFID_Mem_d_out1(5) & IFID_Mem_d_out1(5 downto 0);
 	   se7_ir8_0_1 <= IFID_Mem_d_out1(8) & IFID_Mem_d_out1(8) & IFID_Mem_d_out1(8) & IFID_Mem_d_out1(8) & IFID_Mem_d_out1(8) & IFID_Mem_d_out1(8) & IFID_Mem_d_out1(8) & IFID_Mem_d_out1(8 downto 0);
 	   ls7_ir8_0_1(15 downto 7) <= IFID_Mem_d_out1(8 downto 0);
	   ls7_ir8_0_1(6 downto 0) <= "0000000";
	   opcode1 <= IFID_Mem_d_out1(15 downto 12);
       
       se10_ir5_0_2 <= IFID_Mem_d_out2(5) & IFID_Mem_d_out2(5) & IFID_Mem_d_out2(5) & IFID_Mem_d_out2(5) & IFID_Mem_d_out2(5) & IFID_Mem_d_out2(5) & IFID_Mem_d_out2(5) & IFID_Mem_d_out2(5) & IFID_Mem_d_out2(5) & IFID_Mem_d_out2(5) & IFID_Mem_d_out2(5 downto 0);
 	   se7_ir8_0_2 <= IFID_Mem_d_out2(8) & IFID_Mem_d_out2(8) & IFID_Mem_d_out2(8) & IFID_Mem_d_out2(8) & IFID_Mem_d_out2(8) & IFID_Mem_d_out2(8) & IFID_Mem_d_out2(8) & IFID_Mem_d_out2(8 downto 0);
 	   ls7_ir8_0_2(15 downto 7) <= IFID_Mem_d_out2(8 downto 0);
	   ls7_ir8_0_2(6 downto 0) <= "0000000";
	   opcode2 <= IFID_Mem_d_out2(15 downto 12);

       if(RREX_opcodeaddCout1 = '1' or RREX_opcodenduCout1 = '1' or RREX_opcodeadiCout1 = '1' or RREX_opcodelwCout1 ='1' or RREX_opcodebeqCout1 = '1') then
       a_dummy1_var := RREX_rf_d1_1;
       else
       a_dummy1_var := RREX_rf_d2_1;
       end if;
       if (RREX_opcodeaddCout1 = '1' or RREX_opcodenduCout1 = '1' or RREX_opcodebeqCout1 = '1') then
       b_dummy1_var := RREX_rf_d2_1;
       else
       b_dummy1_var := RREX_se10_ir5_0_1;
       end if;

       if(RREX_opcodeaddCout1 = '1' or RREX_opcodenduCout1 = '1' or RREX_opcodeadiCout1 = '1' or RREX_opcodelwCout1 ='1' or RREX_opcodebeqCout1 = '1') then
       a_dummy1_var := RREX_rf_d1_1;
       else
       a_dummy1_var := RREX_rf_d2_1;
       end if;
       if (RREX_opcodeaddCout1 = '1' or RREX_opcodenduCout1 = '1' or RREX_opcodebeqCout1 = '1') then
       b_dummy1_var := RREX_rf_d2_1;
       else
       b_dummy1_var := RREX_se10_ir5_0_1;
       end if;


       if(RREX_opcodeaddCout2 = '1' or RREX_opcodenduCout2 = '1' or RREX_opcodeadiCout2 = '1' or RREX_opcodelwCout2 ='1' or RREX_opcodebeqCout2 = '1') then
       a_dummy2_var := RREX_rf_d1_2;
       else
       a_dummy2_var := RREX_rf_d2_2;
       end if;
       if (RREX_opcodeaddCout2 = '1' or RREX_opcodenduCout2 = '1' or RREX_opcodebeqCout2 = '1') then
       b_dummy2_var := RREX_rf_d2_2;
       else
       b_dummy2_var := RREX_se10_ir5_0_2;
       end if;

       if(RREX_opcodeaddCout2 = '1' or RREX_opcodenduCout2 = '1' or RREX_opcodeadiCout2 = '1' or RREX_opcodelwCout2 ='1' or RREX_opcodebeqCout2 = '1') then
       a_dummy2_var := RREX_rf_d1_2;
       else
       a_dummy2_var := RREX_rf_d2_2;
       end if;
       if (RREX_opcodeaddCout2 = '1' or RREX_opcodenduCout2 = '1' or RREX_opcodebeqCout2 = '1') then
       b_dummy2_var := RREX_rf_d2_2;
       else
       b_dummy2_var := RREX_se10_ir5_0_2;
       end if;
       
       
       if (RREX_opcodebeqCout1 = '1' and beqZ_flag1 = '1') then
       alu3_b1_var:= RREX_se10_ir5_0_1;
       else
       alu3_b1_var:= RREX_se7_ir8_0_1;
       end if;

       if (RREX_opcodebeqCout2 = '1' and beqZ_flag2 = '1') then
       alu3_b2_var:= RREX_se10_ir5_0_2;
       else
       alu3_b2_var:= RREX_se7_ir8_0_2;
       end if;
       
       if(RREX_opcodeaddCout1 = '1' or RREX_opcodeadiCout1 = '1' or RREX_opcodelwCout1 ='1' or RREX_opcodeswCout1 = '1') then
		alu_control_dummy1_var :="00";
		if (RREX_opcodeaddCout1 = '1' or RREX_opcodeadiCout1 = '1') then
		carry_control_dummy1_var :='1';
 		zero_control_dummy1_var :='1';
 		elsif(RREX_opcodelwCout1='1') then
 		carry_control_dummy1_var :='0';
 		zero_control_dummy1_var :='1';
 		else
 		carry_control_dummy1_var :='0';
 		zero_control_dummy1_var :='0';
 		end if; 
 		elsif (RREX_opcodenduCout1 = '1') then
 		alu_control_dummy1_var :="01";
 		carry_control_dummy1_var :='0';
 		zero_control_dummy1_var :='1';
 		elsif (RREX_opcodebeqCout1 = '1') then
 		alu_control_dummy1_var :="10";
 		carry_control_dummy1_var :='0';
		zero_control_dummy1_var :='0';  --changed later
 		end if;

 		if(RREX_opcodeaddCout2 = '1' or RREX_opcodeadiCout2 = '1' or RREX_opcodelwCout2 ='1' or RREX_opcodeswCout2 = '1') then
		alu_control_dummy2_var :="00";
		if (RREX_opcodeaddCout2 = '1' or RREX_opcodeadiCout2 = '1') then
		carry_control_dummy2_var :='1';
 		zero_control_dummy2_var :='1';
 		elsif(RREX_opcodelwCout2='1') then
 		carry_control_dummy2_var :='0';
 		zero_control_dummy2_var :='1';
 		else
 		carry_control_dummy2_var :='0';
 		zero_control_dummy2_var :='0';
 		end if; 
 		elsif (RREX_opcodenduCout2 = '1') then
 		alu_control_dummy2_var :="01";
 		carry_control_dummy2_var :='0';
 		zero_control_dummy2_var :='1';
 		elsif (RREX_opcodebeqCout2 = '1') then
 		alu_control_dummy2_var :="10";
 		carry_control_dummy2_var :='0';
		zero_control_dummy2_var :='0';  --changed later
 		end if;

        --if(EXMA_opcodelmCout1 = '1') then
        --data_addr1_var := T1;
        --else
        --data_addr1_var : =EXMA_alu2_out;
        --end if;
        
        --if(EXMA_opcodelmCout2 = '1') then
        --data_addr2_var := T1;
        --else
        --data_addr2_var : =EXMA_alu2_out;
        --end if;

       

        --s_din<=MAWB_opcodesmCout;
         --rfd3mux: mux16bit4to1 port map(MAWB_alu2_out, MAWB_r7_out, MAWB_data_mem_out, MAWB_ls7_ir8_0, s0_rfd3, s1_rfd3, rfd3_mux_out);

        if (MAWB_opcodeaddCout1= '1' or MAWB_opcodeadiCout1= '1' or MAWB_opcodenduCout1= '1') then
        reg_write_data_x_var := MAWB_alu2_out1;
        elsif (MAWB_opcodelwCout1 = '1' or MAWB_opcodelmCout1 = '1') then
        reg_write_data_x_var := MAWB_data_mem_out1; 	
        elsif (MAWB_opcodejalCout1= '1' or MAWB_opcodejlrCout1 = '1') then
        reg_write_data_x_var := MAWB_r7_out;
        else
        reg_write_data_x_var := MAWB_ls7_ir8_0_1;
        end if;

        if (MAWB_opcodeaddCout2= '1' or MAWB_opcodeadiCout2= '1' or MAWB_opcodenduCout2= '1') then
        reg_write_data_y_var := MAWB_alu2_out2;
        elsif (MAWB_opcodelwCout2 = '1' or MAWB_opcodelmCout2 = '1') then
        reg_write_data_y_var := MAWB_data_mem_out2; 	
        elsif (MAWB_opcodejalCout2= '1' or MAWB_opcodejlrCout2 = '1') then
        reg_write_data_y_var := MAWB_r7_out;
        else
        reg_write_data_y_var := MAWB_ls7_ir8_0_2;
        end if;
       
        d_mem_wr_en1_var := MAWB_opcodeswCout1 or MAWB_opcodesmCout1;
        d_mem_wr_en2_var := MAWB_opcodeswCout2 or MAWB_opcodesmCout2;

 --r7inmux: mux16bit4to1 port map(r7_write_data_mux, r7_write1, reg_read_data_2_dummy, data_mem_out , s0_r7in, s1_r7in, r7_write_data); --alu1_out
 --r7minimux: mux16bit2to1 port map(alu3_out1,alu_result_dummy, s_r7minimux, r7_write1); 


        --R7 write back logic !!!!!!!!!!!!!!!!!!!@@@@@@@@@@@@@@@@@@@########################$$$$$$$$$$$$$$$$$$%%%^%%%%%%%%%%%%%%%%%%%^^^^^^^^^^^^^^^^^***********

        if (EXMA_dest_reg1 = "111" and EXMA_opcodelwCout1 = '1') then
        r7_write_data_var := r7_write_data;
        elsif  (IDRR_opcodejlrCout1 = '1') then
        r7_write_data_var := reg_read_data_x2;
        elsif ((((RREX_opcodeaddCout1 = '1' and ((RREX7_0_1(1 downto 0) = "00") or (RREX7_0_1(1 downto 0) = "10" and carry_prev_dummy(0) = '1') or (RREX7_0_1(1 downto 0) = "01" and zero_prev_dummy(0) = '1') ) ) or 
	  (RREX_opcodenduCout1 = '1' and ((RREX7_0_1(1 downto 0) = "00") or (RREX7_0_1(1 downto 0) = "10" and carry_prev_dummy(0) = '1') or (RREX7_0_1(1 downto 0) = "01" and zero_prev_dummy(0) = '1') ) ) or
	   RREX_opcodelhiCout1 = '1') and RREX_dest_reg1 = "111") or (RREX_opcodebeqCout1 = '1' and beqZ_flag1 = '1')
		 or (RREX_opcodejalCout1 = '1'))  then
           if ((RREX_opcodebeqCout1 = '1' and beqZ_flag1 = '1') or (RREX_opcodejalCout1 = '1' )) then
           r7_write_data_var := alu3_out1;
           else
           r7_write_data_var := alu_result_dummy1;
           end if;
        else
        r7_write_data_var := next_IP_2;	
        end if;

        if (EXMA_dest_reg2 = "111" and EXMA_opcodelwCout2 = '1') then
        r7_write_data_var := r7_write_data;
        elsif  (IDRR_opcodejlrCout2 = '1') then
        r7_write_data_var := reg_read_data_y2;
        elsif ((((RREX_opcodeaddCout2 = '1' and ((RREX7_0_2(1 downto 0) = "00") or (RREX7_0_2(1 downto 0) = "10" and carry_prev_dummy(0) = '1') or (RREX7_0_2(1 downto 0) = "01" and zero_prev_dummy(0) = '1') ) ) or 
	  (RREX_opcodenduCout2 = '1' and ((RREX7_0_2(1 downto 0) = "00") or (RREX7_0_2(1 downto 0) = "10" and carry_prev_dummy(0) = '1') or (RREX7_0_2(1 downto 0) = "01" and zero_prev_dummy(0) = '1') ) ) or
	   RREX_opcodelhiCout2 = '1') and RREX_dest_reg2 = "111") or (RREX_opcodebeqCout2 = '1' and beqZ_flag2 = '1')
		 or (RREX_opcodejalCout2 = '1'))  then
           if ((RREX_opcodebeqCout2 = '1' and beqZ_flag2 = '1') or (RREX_opcodejalCout2 = '1' )) then
           r7_write_data_var := alu3_out2;
           else
           r7_write_data_var := alu_result_dummy2;
           end if;
        else
        r7_write_data_var := next_IP_2;	
        end if;

  	 -- if (EXMA_dest_reg = "111" and EXMA_opcodelwCout = '1') then
	 --  s0_r7in<='0';
		--s1_r7in<='0';
	 -- elsif  (IDRR_opcodejlrCout = '1') then
	 --  s0_r7in<='0'; 
		--s1_r7in<='1';
		--elsif((((RREX_opcodeaddCout = '1' and ((RREX7_0(1 downto 0) = "00") or (RREX7_0(1 downto 0) = "10" and carry_prev_dummy(0) = '1') or (RREX7_0(1 downto 0) = "01" and zero_prev_dummy(0) = '1') ) ) or 
	 -- (RREX_opcodenduCout = '1' and ((RREX7_0(1 downto 0) = "00") or (RREX7_0(1 downto 0) = "10" and carry_prev_dummy(0) = '1') or (RREX7_0(1 downto 0) = "01" and zero_prev_dummy(0) = '1') ) ) or
	 --  RREX_opcodelhiCout = '1') and RREX_dest_reg = "111") or (RREX_opcodebeqCout = '1' and beqZ_flag = '1')
		-- or (RREX_opcodejalCout = '1')) then
		-- s_r7minimux<= (RREX_opcodebeqCout and beqZ_flag) or (RREX_opcodejalCout ) ;--) then
		-- -- 1'; --alu3out
		-- --else
		--  --s_r7minimux<='0'; --alu2out
		---- end if;
		-- s0_r7in<='1'; 
		--s1_r7in<='0';
		
	 -- else
	 --  s0_r7in<='1';
		--s1_r7in<='1';
	    
	 -- end if;
	 --s0_r7in<=opcodeaddCout or opcodeadiCout or opcodenduCout or opcodelwCout or opcodeswCout or (MAWB_opcodebeqCout and not(beqZflag)) or (not(MAWB_opcodebeqCout and beqZflag)) or (not MAWB_opcodejalCout) or MAWB_opcodejlrCout or opcodelhiCout or opcodelmCout or opcodesmCout or opcodejalCout or opcodejlrCout or opcodebeqCout;
 	 --s1_r7in<=opcodeaddCout or opcodeadiCout or opcodenduCout or opcodelwCout or opcodeswCout or (MAWB_opcodebeqCout and not(beqZflag)) or (MAWB_opcodebeqCout and beqZflag) or MAWB_opcodejalCout or not(MAWB_opcodejlrCout) or opcodelhiCout or opcodelmCout or opcodesmCout or opcodejalCout or opcodejlrCout or opcodebeqCout;
 
 --s0_rfd3<=MAWB_opcodeaddCout or MAWB_opcodeadiCout or MAWB_opcodenduCout or MAWB_opcodejalCOut or MAWB_opcodejlrCout;
 --s1_rfd3<=MAWB_opcodeaddCout or MAWB_opcodeadiCout or MAWB_opcodenduCout or MAWB_opcodelwCout or MAWB_opcodelmCout;
 

 		--s_ma<=EXMA_opcodelmCout;
       --s_alu3b<= RREX_opcodebeqCout;
    -- s_alu2a<= RREX_opcodeaddCout or RREX_opcodenduCout or RREX_opcodeadiCout or RREX_opcodelwCout or RREX_opcodebeqCout;
    -- s0_alu2b<= RREX_opcodeaddCout or RREX_opcodenduCout or RREX_opcodebeqCout; 
 
	  --s0_rf_a3<= MAWB_opcodeadiCout or MAWB_opcodelwCout or (MAWB_opcodejalCout and (not(MAWB_dest_reg(2)) or not(MAWB_dest_reg(1)) or not(MAWB_dest_reg(0))) ) or (MAWB_opcodejlrCout and (not(MAWB_dest_reg(2)) or not(MAWB_dest_reg(1)) or not(MAWB_dest_reg(0)))) or MAWB_opcodelhiCout ; --probably shift in wb stage
     --s1_rf_a3<= MAWB_opcodeaddCout or  MAWB_opcodenduCout or  MAWB_opcodelwCout or MAWB_opcodejalCout or MAWB_opcodejlrCout or MAWB_opcodelhiCout;
     

	 -- r7_write_en<= not(EXMA_opcodebeqCout);
	  
	  

	  
	  --alu3_out1<=alu3_out;
	  
	  
	  
--     if ((opcode(0) and opcode(1) and opcode(2) and opcode(3)) = '0') then
--      if ((reg_read_addr_1_dummy(0) and reg_read_addr_1_dummy(1) and reg_read_addr_1_dummy(2)) = '1') then
--       reg_read_data_1<=IDRRPC_out;
--      else
--      	reg_read_data_1<=reg_read_data_1_dummy;
--       end if;
--       if ((reg_read_addr_2_dummy(0) and reg_read_addr_2_dummy(1) and reg_read_addr_2_dummy(2)) = '1') then
--       reg_read_data_2<=IDRRPC_out;
--       else
--       	reg_read_data_2<=reg_read_data_2_dummy;
--       end if;
--     end if;
	   
	  
 --IFID_en<='1';
 

 --IDRR_en<='1';
 
 
 --RREX_en<='1';
 
 --s_t1<='1';
 --s_t2<='1' ;1
 --or RREX_opcodeadiCout or RREX_opcodelwCout or RREX_opcodeswCout or RREX_opcodebeqCout;
 --s1_alu2b<= RREX_opcodeaddCout or RREX_opcodenduCout or RREX_opcodelwCout or RREX_opcodebeqCout or not(RREX_opcodelmCout) or not(RREX_opcodesmCout);
 
 
 --z_prev_dummy_var(0) := zero_dummy;
 --c_prev_dummy_var(0) := carry_dummy;
 --z_flag := zero_dummy;
-- if(RREX_opcodebeqCout = '1') then
-- beqZflag<=zero_dummy_dummy;
-- zero_dummy <= zero_prev_dummy(0);
-- else
-- beqZflag<='0';
-- zero_dummy <= zero_dummy_dummy;
-- end if;
 --EXMA_en<='1';
 
 
 --MAWB_en<='1';
 

-- if (MAWB_opcodelwCout = '1' and MAWB_data_mem_out = Z16) then
--  lm_zero<= '1';
-- end if;
 
 
 end if;
  when s4=>  
      s_t1_var:='1';
	  s_t2_var:='1';
	 if(opcode(0) = '0') then
	  next_fsm_state :=s5;
	 else
	  next_fsm_state :=s6;
	  end if;
	  when s5=>
     alu4_in_var:=T1;
	  s_t1_var:='0';
	  s_t2_var:='0';
	  s0_rf_a3<='0';
	  s1_rf_a3<='0';
	  s_rfd3_lmsm_mux<='0';
	 if(T2 = "00000000") then
	   next_fsm_state:=s7;
		else
		next_fsm_state:= s5;
		end if;
	  
		when s6=>
	   alu4_in_var:=T1;
		s_rf_a2<='0';
		s_din<='1';
	   s_t1_var:='0';
		s_t2_var:='0';
	  if(T2 = "00000000") then
	   next_fsm_state:= s7;
		else
		next_fsm_state:= s6;	
		end if; 
	when s7=>
	  IDRR_en<='1';
	  IFID_en<='1';
	  ALU1_en<='1';
	  RREX_en<='1';
	  IDRR_rst_flag<='0';
	  RREX_rst_flag<='0';
	  EXMA_rst_flag<='0';
	  next_fsm_state:= s0;
	  opcode <= IFID_Mem_d_out(15 downto 12);
	  if(opcode(3) = '0' and opcode(2) = '1' and opcode(1) = '1') then
	  IDRR_en<='0';
	  ALU1_en<='0';
	  --RREX_en<='0';
	  IFID_en<='0';
	  next_fsm_state := s1;
	  s_rfd3_lmsm_mux<='1';
	  end if;
	--when s8=>
	  --RREX_en<='1';
	  --next_fsm_state:= s0;
 end case;
	  
 --var_s_rf_a2:= (IDRR_opcodeaddCout and ((not(IDRR7_0(0)) and not(IDRR7_0(1))) or (IDRR7_0(0) and not(IDRR7_0(1)) and c_flag(0)) or (not(IDRR7_0(0)) and IDRR7_0(1) and z_flag(0)))) or (IDRR_opcodenduCout and ((not(IDRR7_0(0)) and not(IDRR7_0(1))) or (IDRR7_0(0) and not(IDRR7_0(1)) and c_flag(0)) or (not(IDRR7_0(0)) and IDRR7_0(1) and z_flag(0)))) or IDRR_opcodeswCout or IDRR_opcodebeqCout or IDRR_opcodejlrCout ;
 
 --r7_write_data<=next_IP;
 if (rising_edge(clk)) then
 if(rst = '1') then
 r7_write_data<=Z16;
 fsm_state<=s0;
 --T2_rst<='1';
 --alu4_in<=Z16;
 else
 fsm_state<=next_fsm_state;
 i_mem_read_en<= i_mem_read_en_var;
 ALU1_1en<= ALU1_1en_var;
 ALU1_2en<=	  ALU1_2en_var;
 IDRR_en1<=	  IDRR_en1_var;
 RREX_en1<=	  RREX_en1_var;
 IFID_en1<=	  IFID_en1_var;
 IDRR_en2<=	  IDRR_en2_var;
 RREX_en2<=	  RREX_en2_var;
 IFID_en2<=	  IFID_en2_var;
 dest_reg1 <= dest_reg1_var;
 dest_reg2 <= dest_reg2_var;
 reg_read_addr_x1 <= reg_read_addr_x1_var;
 reg_read_addr_x2 <= reg_read_addr_x2_var;
 reg_read_addr_y1 <= reg_read_addr_y1_var;
 reg_read_addr_y2 <= reg_read_addr_y2_var;
 reg_write_dest_x <= reg_write_dest_x_var;
 reg_write_dest_y <= reg_write_dest_y_var;
 reg_write_en_x_var <= reg_write_en_x;
 reg_write_en_y_var <= reg_write_en_y;
 r7_write_en<= r7_write_en_var;
 a_dummy1<= a_dummy1_var;
 a_dummy2<= a_dummy2_var;
 b_dummy1<= b_dummy1_var;
 b_dummy2<= b_dummy2_var;
 alu_control_dummy1 <= alu_control_dummy1_var;
 alu_control_dummy2 <= alu_control_dummy2_var;
 carry_control_dummy1(0) <= carry_control_dummy1_var;
 carry_control_dummy2(0) <= carry_control_dummy2_var;
 zero_control_dummy1_var(0) <= zero_control_dummy1_var;
 zero_control_dummy2_var(0) <= zero_control_dummy2_var;
 reg_write_data_x<=reg_write_data_x_var;
 reg_write_data_y<=reg_write_data_y_var;
 r7_write_data<= r7_write_data_var;
-- s_rf_a1<=s_rf_a1_var;
-- s_rf_a2<=s_rf_a2_var;
-- s_alu2a<=s_alu2a_var;
-- s0_alu2b<=s0_alu2b_var;
-- s_alu3b<=s_alu3b_var;
-- carry_control_dummy(0)<=carry_control_var;
-- zero_control_dummy(0)<=zero_control_var;
-- RREX_rst_flag<=RREX_rst_flag_var;
-- EXMA_rst_flag<=EXMA_rst_flag_var;
-- s_ma<=s_ma_var;
-- s_din<=s_din_var;
-- s0_rfd3<=s0_rfd3_var;
-- s1_rfd3<=s1_rfd3_var;
-- d_mem_wr_en<=d_mem_wr_en_var;
-- s0_rf_a3<=s0_rf_a3_var;
-- s1_rf_a3<=s1_rf_a3_var;
-- reg_write_en_dummy<=reg_write_en_var;
-- alu_control_dummy<=alu_control_var;
 
 --T2_rst<='0';
 alu4_in<=alu4_in_var;
--s_t1<= s_t1_var;
--s_t2<= s_t2_var;
 zero_prev_dummy(0)<=zero_dummy;
 carry_prev_dummy(0)<=carry_dummy;
 zero_dummy<=z_flag;
 --r7_write_data_mux<=next_IP_var;
 
 end if;
 end if;
 --if(IDRR_opcodelmCout = '0' and IDRR_opcodesmCout = '0') then

 --end if;
 --end process;
 --process(IFID_Mem_d_out, IFID_PC_out, clk)
 --begin
 
 --end process;
 --process(IDRR11_9, IDRR8_6, IDRR5_3, IDRR7_0, IDRRse10_ir5_0, IDRR_se7_ir8_0, IDRR_ls7_ir8_0, IDRRPC_out, clk)
 --begin
 --rf_a1_a<= IDRR11_9;
 --rf_a1_b<= IDRR8_6;
 --rf_a2_a<= IDRR8_6;
 --rf_a2_b<= pe_out;
 --rf_a3_a<= IDRR11_9; -- 11
 --rf_a3_b<= IDRR8_6; -- 01
 --rf_a3_c<= IDRR5_3; -- 10
 --rf_a3_d<= pe_out;  --00
 --s0_rf_a3<= opcodeaddCout or opcodenduCout or (not opcodeadiCout) or opcodelwCout or opcodejalCout or opcodejlrCout or opcodelhiCout or opcodelmCout; --probably shift in wb stage
 --s1_rf_a3<= (not opcodeaddCout) or (not opcodenduCout) or opcodeadiCout or opcodelwCout or opcodejalCout or opcodejlrCout or opcodelhiCout or opcodelmCout;
 --s0_rf_a3<= '1';
 --s1_rf_a3<= '0';
 --reg_write_dest_dummy<=rf_a3;
 --reg_read_addr_1_dummy<=rf_a1;
 --reg_read_addr_2_dummy<=rf_a2;

 --end process;
 --process(RREX_rf_d1, RREX_rf_d2, RREX7_0, RREX_se10_ir5_0, RREX_se7_ir8_0, RREX_ls7_ir8_0, RREX_PC_out, clk)
 --begin
 
 --end process;
 --process(EXMA_r7_out, EXMA_ls7_ir8_0, EXMA_T1, EXMA_rf_d1, EXMA_rf_d2, EXMA_alu2_out, EXMA_alu3_out, clk)
 --variable next_lmsm_state: lmsmstate;
 --begin

 --next_lmsm_state:= lmsm_state;
 --case next_lmsm_state:
 -- when s0=>

 --end process;
 --process(MAWB_r7_out, MAWB_ls7_ir8_0, MAWB_rf_d1, MAWB_rf_d2, MAWB_alu2_out, MAWB_alu3_out, MAWB_PC_out, clk)
 --begin
 
 
 
 end process;
 end behave;