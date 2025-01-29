library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

entity filtro_SPI is
 port(clk:              in std_logic;
      nRst:             in std_logic;
      fin_medida:       in std_logic;
      out_offset:       in std_logic_vector(9 downto 0);
      out_filtro:       buffer std_logic_vector(9 downto 0));
end entity filtro_SPI;

architecture rtl of filtro_SPI is
  signal medidaT_0: std_logic_vector(9 downto 0);
  signal medidaT_1: std_logic_vector(9 downto 0);
  signal medidaT_2: std_logic_vector(9 downto 0);
  signal medidaT_3: std_logic_vector(9 downto 0);
  signal medidaT_4: std_logic_vector(9 downto 0);
  signal medidaT_5: std_logic_vector(9 downto 0);
  signal medidaT_6: std_logic_vector(9 downto 0);
  signal medidaT_7: std_logic_vector(9 downto 0);
  
  signal aux_sum:   std_logic_vector(17 downto 0);
  
begin

  PROC_REG: process(clk, nRst)
  begin
    if nRst = '0' then
      medidaT_0 <= (others => '0');
      medidaT_1 <= (others => '0');
      medidaT_2 <= (others => '0');
      medidaT_3 <= (others => '0');
      medidaT_4 <= (others => '0');
      medidaT_5 <= (others => '0');
      medidaT_6 <= (others => '0');
      medidaT_7 <= (others => '0');

    elsif clk'event and clk = '1' then
      if fin_medida = '1' then
        medidaT_0 <= out_offset;
        medidaT_1 <= medidaT_0;
	medidaT_2 <= medidaT_1;
	medidaT_3 <= medidaT_2;
	medidaT_4 <= medidaT_3;
	medidaT_5 <= medidaT_4;
	medidaT_6 <= medidaT_5;
	medidaT_7 <= medidaT_6;
		
      end if;
    end if;
  end process PROC_REG;

  aux_sum <= ((medidaT_0(9) & medidaT_0 & "0000000") + medidaT_0) + (medidaT_1 & "000000") + (medidaT_2 & "00000") + (medidaT_3 & "0000") + (medidaT_4 & "000") + (medidaT_5 & "00") + (medidaT_6 & "0") + medidaT_7;

  out_filtro <= aux_sum(17 downto 8);
 
end rtl;