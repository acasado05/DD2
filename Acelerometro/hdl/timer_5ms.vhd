--Timer de 5 ms

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity timer_5ms is
    generic(FDC_5ms: natural := 250000);
    port(nRst:	  in	std_logic;
	 clk:	  in	std_logic;
	 TIC_5ms: buffer std_logic);
		
end entity timer_5ms;

architecture rtl of timer_5ms is
  signal cnt_tim_5ms: std_logic_vector(17 downto 0);
	
begin

  CNT_TIMER: process(nRst, clk)
  begin
    if nRst = '0' then
      cnt_tim_5ms <= (0 => '1', others => '0');
			
    elsif clk'event and clk = '1' then
      if TIC_5ms = '1' then 
	cnt_tim_5ms <= (0 => '1', others => '0');
				
      else
	cnt_tim_5ms <= cnt_tim_5ms + 1;
				
      end if;
    end if;
  end process CNT_TIMER;
	
  TIC_5ms <= '1' when cnt_tim_5ms = FDC_5ms else
	     '0';

end rtl;