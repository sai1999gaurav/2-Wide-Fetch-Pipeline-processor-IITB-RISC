library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.all;
  

entity queue is
port(
clk, reset, queue_reset, push, pop, rf_a1_x_b1, rf_a2_x_b2, rf_a1_y_b1, rf_a2_y_b2, LM_SM_stall: in std_logic;
data_in_x, data_in_y: in std_logic_vector(85 downto 0);
--index: in std_logic_vector(M-1 downto 0);
data_out_x: out std_logic_vector(85 downto 0);
data_out_y: out std_logic_vector(85 downto 0); 
elements: out std_logic_vector(3 downto 0);
rf_a1_x, rf_a2_x: out std_logic_vector(2 downto 0);
rf_a1_y, rf_a2_y: out std_logic_vector(2 downto 0);
q_flag1: out std_logic
);
end queue;

architecture behave of queue is
--generic k: integer := 6;
--generic l: integer := 4;
--generic size: integer := 200;
type queue_type is array (0 to 200) of std_logic_vector (85 downto 0);
--define signals here
signal queue: queue_type;
signal s_top, s_index, s_elements: std_logic_vector(3 downto 0);
signal s_data_in_x, s_data_in_y, s_data_out_x, s_data_out_y: std_logic_vector(85 downto 0);
signal s_rf_a1_x, s_rf_a2_x, s_rf_dest_x_pop: std_logic_vector(2 downto 0);
signal s_rf_a1_y, s_rf_a2_y, s_rf_dest_y_pop: std_logic_vector(2 downto 0);
signal opcode_x, opcode_y:std_logic_vector(3 downto 0);
signal opcode_x_in, opcode_y_in, opcode_x_out, opcode_y_out:std_logic_vector(3 downto 0);
signal s_dest_reg_x: std_logic_vector(2 downto 0);
signal s_cz_y: std_logic_vector(1 downto 0);
signal ra, rb, rc, ra_x, rb_x, rc_x, ra_y, rb_y, rc_y: std_logic_vector(2 downto 0);
constant zero : std_logic_vector(85 downto 0) := (84 => '1', 83 => '1', 82 => '1', 81 => '1', others => '0');
signal s_push : std_logic := '1'; 
signal s_q_flag1 : std_logic;
--signal s: unsigned;

begin

--push <= '1';

s_data_in_x <= data_in_x;
s_data_in_y <= data_in_y;
--data_out <= s_data_out;
elements <=  s_elements;

data_out_x <= s_data_out_x;
data_out_y <= s_data_out_y;
q_flag1 <= s_q_flag1;

with s_elements select
s_rf_a1_x <= data_in_x(80 downto 78) when "0000",
				 queue(to_integer(unsigned(s_top)))(80 downto 78) when others;
--s_rf_a1_x <= queue(to_integer(unsigned(s_top)))(80 downto 78);
--s_rf_a2_x <= queue(to_integer(unsigned(s_top)))(77 downto 75);
with s_elements select
s_rf_a2_x <= data_in_x(77 downto 75) when "0000",
			    queue(to_integer(unsigned(s_top)))(77 downto 75) when others;


--s_rf_a1_y <= queue(to_integer(unsigned(s_top) + 1))(80 downto 78);
--s_rf_a2_y <= queue(to_integer(unsigned(s_top) + 1))(77 downto 75);
with s_elements select
s_rf_a1_y <= data_in_y(80 downto 78) when "0000",
			    queue(to_integer(unsigned(s_top) + 1))(80 downto 78) when others;

with s_elements select
s_rf_a2_y <= data_in_y(77 downto 75) when "0000",
			    queue(to_integer(unsigned(s_top) + 1))(77 downto 75) when others;

--s_rf_a1_x_pop <= data_out_x(80 downto 78);
--s_rf_a2_x_pop <= data_out_x(77 downto 75);
--s_rf_a1_y_pop <= data_out_y(80 downto 78);
--s_rf_a2_y_pop <= data_out_y(77 downto 75);
				 

rf_a1_x <= s_rf_a1_x;
rf_a2_x <= s_rf_a2_x;
rf_a1_y <= s_rf_a1_y;
rf_a2_y <= s_rf_a2_y;

with s_elements select
opcode_x <= data_in_x(84 downto 81) when "0000",
				queue(to_integer(unsigned(s_top)))(84 downto 81) when others;

with s_elements select
opcode_y <= data_in_y(84 downto 81) when "0000",
				queue(to_integer(unsigned(s_top) + 1))(84 downto 81) when others;

with s_elements select
s_cz_y <= data_in_y(65 downto 64) when "0000",
			 queue(to_integer(unsigned(s_top) + 1))(65 downto 64) when others;

opcode_x_in <= s_data_in_x(84 downto 81);
opcode_y_in <= s_data_in_y(84 downto 81);

opcode_x_out <= s_data_out_x(84 downto 81);
opcode_y_out <= s_data_out_y(84 downto 81);

--assign value to signal czwhich will be cz bits corresponding to 

--with push select queue(unsigned(s_elements))
--					<= data_in when '1';
--					
--with push select s_elements

--Destination Register Logic wrt QUEUE
-- if (opcodeaddCout1 = '1' or opcodenduCout1 = '1') then
--  dest_reg1_var := IDRR5_3_1;
-- elsif (opcodeadiCout1 = '1' or opcodelhiCout1 = '1') then
--  dest_reg1_var := IDRR8_6_1;
-- elsif (opcodelwCout1 = '1' or opcodejalCout1 = '1' or opcodejlrCout1='1') then
--  dest_reg1_var := IDRR11_9_1;
-- end if;          
--     
--      if (opcodeaddCout2 = '1' or opcodenduCout2 = '1') then
--  dest_reg2_var := IDRR5_3_2;
-- elsif (opcodeadiCout2 = '1' or opcodelhiCout2 = '1') then
--  dest_reg2_var := IDRR8_6_2;
-- elsif (opcodelwCout2 = '1' or opcodejalCout2 = '1' or opcodejlrCout2='1') then
--  dest_reg2_var := IDRR11_9_2;
-- end if;
with s_elements select
		ra <= data_in_x(80 downto 78) when "0000",
				queue(to_integer(unsigned(s_top)))(80 downto 78) when others;
with s_elements select
		rb <= data_in_x(77 downto 75) when "0000",		
		      queue(to_integer(unsigned(s_top)))(77 downto 75) when others;
with s_elements select
		rc <= data_in_x(74 downto 72) when "0000",		
		      queue(to_integer(unsigned(s_top)))(74 downto 72) when others;

ra_x <= s_data_out_x(80 downto 78);
rb_x <= s_data_out_x(77 downto 75);
rc_x <= s_data_out_x(74 downto 72);

ra_y <= s_data_out_y(80 downto 78);
rb_y <= s_data_out_y(77 downto 75);
rc_y <= s_data_out_y(74 downto 72);

with opcode_x select
		s_dest_reg_x <= rc when "0000"|"0010",
							 rb when "0001",
						    ra when "0011"|"0100"|"1000"|"1001",
							 "111" when others;

with opcode_x_out select
		s_rf_dest_x_pop <= rc_x when "0000"|"0010",
							    rb_x when "0001",
						       ra_x when "0011"|"0100"|"1000"|"1001",
							    "111" when others;

with opcode_y_out select
		s_rf_dest_y_pop <= rc_y when "0000"|"0010",
							    rb_y when "0001",
						       ra_y when "0011"|"0100"|"1000"|"1001",
							    "111" when others;
							 

process(clk, reset, s_data_in_x, s_data_in_y, s_push, s_elements, pop, s_top, rf_a1_x_b1, rf_a2_x_b2, rf_a1_y_b1, rf_a2_y_b2, queue, opcode_x, opcode_y,
s_rf_a1_x, s_rf_a2_x, s_rf_a1_y, s_rf_a2_y, s_cz_y, s_dest_reg_x, opcode_x_in, opcode_y_in, s_q_flag1)

variable var_data_in_x : std_logic_vector (85 downto 0);
variable var_data_in_y : std_logic_vector (85 downto 0);
--variable var_data_out : std_logic_vector (85 downto 0);
variable var_data_out_x : std_logic_vector (85 downto 0);
variable var_data_out_y : std_logic_vector (85 downto 0);
variable var_s_elements: std_logic_vector(3 downto 0);
variable var_queue: queue_type;
variable var_top : std_logic_vector(3 downto 0);
variable var_s: unsigned(3 downto 0); 
variable i,k : integer;
variable var_q_flag1 : std_logic;

begin
var_data_in_x := s_data_in_x;
var_data_in_y := s_data_in_y;
var_s_elements := s_elements;
var_queue := queue;
var_top := s_top;
var_q_flag1 := s_q_flag1;

var_data_out_x := zero;
var_data_out_y := zero; 

if((reset = '1') or (queue_reset = '1')) then
for i in 0 to 200 loop
var_queue(i) := zero;
end loop;
var_data_out_x := zero;
var_data_out_y := zero;
var_s_elements := "0000";
var_top := "0000";
var_q_flag1 := '0';
end if;

if((not((opcode_x_in(3)='1')and(opcode_x_in(2)='1')and(opcode_x_in(1)='1')and(opcode_x_in(0)='1'))) or (not((opcode_y_in(3)='1')and(opcode_y_in(2)='1')and(opcode_y_in(1)='1')and(opcode_y_in(0)='1')))) then 

if((LM_SM_stall = '0')) then

if(s_push = '1') then
--	i := to_integer(std_logic_vector(unsigned(var_s_elements) + unsigned(var_top)));
	--i := 5;
	var_s := unsigned(var_s_elements) + unsigned(var_top);
	var_queue(to_integer(var_s)) := var_data_in_x;
	var_s_elements := var_s_elements + 1;
	var_s := unsigned(var_s_elements) + unsigned(var_top);
	var_queue(to_integer(var_s)) := var_data_in_y;
	var_s_elements := var_s_elements + 1;
end if;

--if(pop = '1') then
--	--k := to_integer(var_top);
--	var_data_out := var_queue(to_integer(unsigned(var_top)));
--	var_top := var_top + 1;
--	var_s_elements := var_s_elements - 1;
--end if;



if(not(((opcode_y(3)='0')and(opcode_y(2)='1')and(opcode_y(1)='1')and(opcode_y(0)='0'))or((opcode_y(3)='0')and(opcode_y(2)='1')and(opcode_y(1)='1')and(opcode_y(0)='1')))) then
var_q_flag1 := not(var_q_flag1);
case(opcode_x) is 
	when "0000"|"0010"|"1100" =>
									if((rf_a1_x_b1 = '0') and (rf_a2_x_b2 = '0') and (s_rf_a1_x /= s_rf_dest_x_pop) and (s_rf_a1_x /= s_rf_dest_y_pop) and (s_rf_a2_x /= s_rf_dest_x_pop) and (s_rf_a2_x /= s_rf_dest_y_pop)) then
									var_data_out_x := var_queue(to_integer(unsigned(var_top)));
									var_top := var_top + 1;
									var_s_elements := var_s_elements - 1;
									end if;
	when "0001"|"0110"|"0111" =>
									if((rf_a1_x_b1 = '0') and (s_rf_a1_x /= s_rf_dest_x_pop) and (s_rf_a1_x /= s_rf_dest_y_pop)) then
									var_data_out_x := var_queue(to_integer(unsigned(var_top)));
									var_top := var_top + 1;
									var_s_elements := var_s_elements - 1;
									--var_q_flag1 := '1';
									end if;
	when "0100"|"0101"|"1001"=>
									if((rf_a2_x_b2 = '0') and (s_rf_a2_x /= s_rf_dest_x_pop) and (s_rf_a2_x /= s_rf_dest_y_pop)) then
									var_data_out_x := var_queue(to_integer(unsigned(var_top)));
									var_top := var_top + 1;
									var_s_elements := var_s_elements - 1;
									end if;
									
	when others => 			var_data_out_x := var_queue(to_integer(unsigned(var_top)));
									var_top := var_top + 1;
									var_s_elements := var_s_elements - 1;
									--var_q_flag1 := '1';
end case;					

--assign value to signal cz which will be cz bits in y
--assign value to s_dest_reg_x
if(var_top /= s_top) then


if(not(((opcode_x(3)='0')and(opcode_x(2)='1')and(opcode_x(1)='1')and(opcode_x(0)='0'))or((opcode_x(3)='0')and(opcode_x(2)='1')and(opcode_x(1)='1')and(opcode_x(0)='1')))) then
--if(not((opcode_x = "0000"|"0001"|"0010"|"0100") and (opcode_y = "0000"|"0010") and (s_cz_y = "01"|"10"))) then
 if(not((((opcode_x(3) = '0')and(opcode_x(2) = '0')and(opcode_x(1)='0')and(opcode_x(0)='0')) or ((opcode_x(3) = '0')and(opcode_x(2) = '0')and(opcode_x(1)='0')and(opcode_x(0)='1'))
 or ((opcode_x(3) = '0')and(opcode_x(2) = '0')and(opcode_x(1)='1')and(opcode_x(0)='0')) or ((opcode_x(3) = '0')and(opcode_x(2) = '1')and(opcode_x(1)='0')and(opcode_x(0)='0')))
 and (((opcode_y(3) = '0')and(opcode_y(2) = '0')and(opcode_y(1)='0')and(opcode_y(0)='0')) or ((opcode_y(3) = '0')and(opcode_y(2) = '0')and(opcode_y(1)='1')and(opcode_y(0)='0')))
 and (((s_cz_y(1) = '0')and(s_cz_y(0) = '1'))or((s_cz_y(1) = '1')and(s_cz_y(0) = '0'))))) then 

case(opcode_y) is 
	when "0000"|"0010"|"1100" =>
									if((rf_a1_y_b1 = '0') and (rf_a2_y_b2 = '0') and (s_dest_reg_x /= s_rf_a1_y) and (s_dest_reg_x /= s_rf_a2_y) and (s_rf_a1_y /= s_rf_dest_x_pop) and (s_rf_a1_y /= s_rf_dest_y_pop) and (s_rf_a2_y /= s_rf_dest_x_pop) and (s_rf_a2_y /= s_rf_dest_y_pop)) then
									var_data_out_y := var_queue(to_integer(unsigned(var_top)));
									var_top := var_top + 1;
									var_s_elements := var_s_elements - 1;
									--var_q_flag1 := '1';
									end if;
	when "0001"|"0110"|"0111" =>
									if((rf_a1_y_b1 = '0') and (s_dest_reg_x /= s_rf_a1_y) and (s_rf_a1_y /= s_rf_dest_x_pop) and (s_rf_a1_y /= s_rf_dest_y_pop)) then
									var_data_out_y := var_queue(to_integer(unsigned(var_top)));
									var_top := var_top + 1;
									var_s_elements := var_s_elements - 1;
									end if;
	when "0100"|"0101"|"1001"=>
									if((rf_a2_y_b2 = '0') and (s_dest_reg_x /= s_rf_a2_y) and (s_rf_a2_y /= s_rf_dest_x_pop) and (s_rf_a2_y /= s_rf_dest_y_pop)) then
									var_data_out_y := var_queue(to_integer(unsigned(var_top)));
									var_top := var_top + 1;
									var_s_elements := var_s_elements - 1;
									end if;
									
	when others => 			var_data_out_y := var_queue(to_integer(unsigned(var_top)));
									var_top := var_top + 1;
									var_s_elements := var_s_elements - 1;
									--var_q_flag1 := '1';
end case;
end if;					
end if;		
end if;

else

case(opcode_x) is 
	when "0000"|"0010"|"1100" =>
									if((rf_a1_x_b1 = '0') and (rf_a2_x_b2 = '0') and (s_rf_a1_x /= s_rf_dest_x_pop) and (s_rf_a1_x /= s_rf_dest_y_pop) and (s_rf_a2_x /= s_rf_dest_x_pop) and (s_rf_a2_x /= s_rf_dest_y_pop)) then
									var_data_out_x := var_queue(to_integer(unsigned(var_top)));
									var_top := var_top + 1;
									var_s_elements := var_s_elements - 1;
									end if;
	when "0001"|"0110"|"0111" =>
									if((rf_a1_x_b1 = '0') and (s_rf_a1_x /= s_rf_dest_x_pop) and (s_rf_a1_x /= s_rf_dest_y_pop)) then
									var_data_out_x := var_queue(to_integer(unsigned(var_top)));
									var_top := var_top + 1;
									var_s_elements := var_s_elements - 1;
									--var_q_flag1 := '1';
									end if;
	when "0100"|"0101"|"1001"=>
									if((rf_a2_x_b2 = '0') and (s_rf_a2_x /= s_rf_dest_x_pop) and (s_rf_a2_x /= s_rf_dest_y_pop)) then
									var_data_out_x := var_queue(to_integer(unsigned(var_top)));
									var_top := var_top + 1;
									var_s_elements := var_s_elements - 1;
									end if;
									
	when others => 			var_data_out_x := var_queue(to_integer(unsigned(var_top)));
									var_top := var_top + 1;
									var_s_elements := var_s_elements - 1;
									--var_q_flag1 := '1';
end case;					

 
--case(opcode_x) is 
--	when "0000"|"0010"|"1100" =>
--									if(rf_a1_x_b1 = '0' and rf_a2_x_b2 = '0') then
--									var_data_out_x := var_queue(to_integer(unsigned(var_top)));
--									var_top := var_top + 1;
--									var_s_elements := var_s_elements - 1;
--									end if;
--	when "0001"|"0110"|"0111" =>
--									if(rf_a1_x_b1 = '0') then
--									var_data_out_x := var_queue(to_integer(unsigned(var_top)));
--									var_top := var_top + 1;
--									var_s_elements := var_s_elements - 1;
--									end if;
--	when "0100"|"0101"|"1001"=>
--									if(rf_a2_x_b2 = '0') then
--									var_data_out_x := var_queue(to_integer(unsigned(var_top)));
--									var_top := var_top + 1;
--									var_s_elements := var_s_elements - 1;
--									end if;
--									
--	when others => 			var_data_out_x := var_queue(to_integer(unsigned(var_top)));
--									var_top := var_top + 1;
--									var_s_elements := var_s_elements - 1;
--end case;					
end if;
end if;
end if;

if(rising_edge(clk)) then
queue <= var_queue;
s_elements <= var_s_elements;
s_top <= var_top;
s_data_out_x <= var_data_out_x;
s_data_out_y <= var_data_out_y;
s_q_flag1 <= var_q_flag1;
end if;

end process; 

--process(clk, reset)
----define variables here
--variable var_queue: queue_type;
--
--begin
--if(reset = '1') then
--for i in 0 to 200 loop
--	var_queue(i) := "000000";
--end loop;
--end if;
--s_top <= "0000";
--s_elements <= "0000";
--s_index <= "0000"; 
--queue <= var_queue;
--
--end process;

end behave;


--2 data_out from queue 

