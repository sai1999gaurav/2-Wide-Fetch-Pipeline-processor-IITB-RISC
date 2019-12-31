library std;
use std.standard.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use ieee.std_logic_arith.all;	 
use ieee.std_logic_unsigned.all;

-- since The Memory is asynchronous read, there is no read signal, but you can use it based on your preference.
-- this memory gives 16 Bit data in one clock cycle, so edit the file to your requirement.

entity imemory is 
	port (address: in std_logic_vector(15 downto 0); 
		  clk, Mem_read_en: in std_logic;
		  Mem_dataout1, Mem_dataout2: out std_logic_vector(15 downto 0));
end entity;

architecture Form of imemory is 
type regarray is array(255 downto 0) of std_logic_vector(15 downto 0);   -- defining a new type
signal Memory: regarray:=(
 0=>x"1481", 1=>x"16c2", 2=>x"1b41", 3=>x"04ca", 4=>x"1d81", 5=>x"31ff", 6=>x"33ff", --hazard at 3:ADC,
 others => "0000000000000000" );
-- you can use the above mentioned way to initialise the memory with the instructions and the data as required to test your processor
begin
process (Mem_read_en, address, clk)
 begin
 if(Mem_read_en = '1') then
 Mem_dataout1 <= Memory(conv_integer(address));
 Mem_dataout2 <= Memory(conv_integer(address) + 1);
end if;
end process;
--process (Mem_read_en,address,clk)
--begin
--if(Mem_read_en = '1') then
--if(rising_edge(clk)) then
--			Mem_dataout <= Memory(conv_integer(address));
--		end if;
--	end if;
--	end process;
end Form;
