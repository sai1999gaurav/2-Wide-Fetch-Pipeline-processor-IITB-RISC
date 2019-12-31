-- fpga4student.com: FPGA projects, Verilog projects, VHDL projects
-- VHDL project: VHDL code for single-cycle MIPS Processor
library std;
use std.standard.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all; 
-- VHDL code for the register file of the MIPS Processor
entity scoreboard is
port (
   clk, rst, sb_en1, sb_en2: in std_logic;
 dest_reg1, dest_reg2, reg_read_addr1_x, reg_read_addr2_x, reg_read_addr1_y, reg_read_addr2_y, wr_reg1, wr_reg2: in std_logic_vector(2 downto 0);
 reg_status1_x, reg_status2_x, reg_status1_y, reg_status2_y: out std_logic
);
end scoreboard;

architecture Behavioral of scoreboard is
type reg_type is array (0 to 7 ) of std_logic;
type reg_type2 is array (0 to 7 ) of std_logic_vector(2 downto 0);
constant one: std_logic_vector(2 downto 0):= "001";
constant onec: std_logic_vector(2 downto 0):= "111";
signal reg_array: reg_type;
signal count: reg_type2;
begin
 process(clk, rst, dest_reg1, dest_reg2, reg_read_addr1_x, reg_read_addr2_x, reg_read_addr1_y, reg_read_addr2_y, wr_reg1, wr_reg2)
 variable wr_reg_status1, wr_reg_status2, reg_s1, reg_s2: std_logic; 
 variable count_wr1, count_wr2, count_dr1, count_dr2: std_logic_vector(2 downto 0);
 begin
 count_wr1:= count(to_integer(unsigned(wr_reg1)));
 count_wr2:= count(to_integer(unsigned(wr_reg2)));
 count_dr1:= count(to_integer(unsigned(dest_reg1)));
 count_dr2:= count(to_integer(unsigned(dest_reg2)));
 reg_s1:= reg_array(to_integer(unsigned(dest_reg1)));
 reg_s2:= reg_array(to_integer(unsigned(dest_reg2)));

 
   if (count(to_integer(unsigned(wr_reg1)))(0) = '1' and count(to_integer(unsigned(wr_reg1)))(1) = '0' and count(to_integer(unsigned(wr_reg1)))(2) = '0') then
    wr_reg_status1 := '0';
	 count_wr1 := "000";
	else
    count_wr1 := std_logic_vector(unsigned(count_wr1) + unsigned(onec));
   end if;
   if (count(to_integer(unsigned(wr_reg2)))(0) = '1' and count(to_integer(unsigned(wr_reg2)))(1) = '0' and count(to_integer(unsigned(wr_reg2)))(2) = '0') then
   wr_reg_status2 := '0';
	count_wr2 := "000";
	else
   count_wr2 := std_logic_vector(unsigned(count_wr2) + unsigned(onec));
   end if;
	
   if (reg_array(to_integer(unsigned(dest_reg1))) = '0') then
   reg_s1 := '1';
   count_dr1 := "001";
   else
   count_dr1 := std_logic_vector(unsigned(count_dr1) + unsigned(one));
   end if;

   if (reg_array(to_integer(unsigned(dest_reg2))) = '0') then
   reg_s2 := '1';
   count_dr2 := "001";
   else
   count_dr2 := std_logic_vector(unsigned(count_dr2) + unsigned(one));
   end if;

 
  if(falling_edge(clk)) then
   if(rst='1') then
   count(0) <= "000";
   count(1) <= "000";
   count(2) <= "000";
   count(3) <= "000";
   count(4) <= "000";
   count(5) <= "000";
   count(6) <= "000";
   count(7) <= "000";
   reg_array(0) <= '0';
   reg_array(1) <= '0';
   reg_array(2) <= '0';
   reg_array(3) <= '0';
   reg_array(4) <= '0';
   reg_array(5) <= '0';
   reg_array(6) <= '0';
   reg_array(7) <= '0';
 else
   reg_array(to_integer(unsigned(wr_reg1))) <= wr_reg_status1;
   reg_array(to_integer(unsigned(wr_reg2))) <= wr_reg_status2;
   count(to_integer(unsigned(wr_reg1))) <= count_wr1;
   count(to_integer(unsigned(wr_reg2))) <= count_wr2;
	if(sb_en1 = '1') then
	reg_array(to_integer(unsigned(dest_reg1))) <= reg_s1;
	count(to_integer(unsigned(dest_reg1))) <= count_dr1;
	end if;
	if(sb_en2 = '1') then
	count(to_integer(unsigned(dest_reg2))) <= count_dr2;
   reg_array(to_integer(unsigned(dest_reg2))) <= reg_s2;
	end if;
 end if;
 end if;
 end process;

 reg_status1_x <= reg_array(to_integer(unsigned(reg_read_addr1_x)));
 reg_status2_x <= reg_array(to_integer(unsigned(reg_read_addr2_x)));
 
 reg_status1_y <= reg_array(to_integer(unsigned(reg_read_addr1_y)));
 reg_status2_y <= reg_array(to_integer(unsigned(reg_read_addr2_y)));

end Behavioral;
