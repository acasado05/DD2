library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all;

entity test_Filtro is
end entity;

architecture test of test_Filtro is
  signal nRst:     std_logic;
  signal clk:      std_logic;                                                         
  signal fin_medida:  std_logic;
  signal medida_corregida:  std_logic_vector(9 downto 0);
  signal out_filtro: std_logic_vector(9 downto 0);
  constant T_clk: time := 20 ns;

begin

 dut: entity work.filtro_SPI(rtl)

 port map (nRst => nRst,
           clk => clk,
           fin_medida => fin_medida,
           out_offset => medida_corregida,
           out_filtro => out_filtro
 );

RELOJ:process
begin
  clk <= '0';
  wait for T_clk/2;

  clk <= '1';
  wait for T_clk/2;

end process RELOJ;

process
begin
  nRst <= '1';
  fin_medida <= '0';
  medida_corregida <= (others => '0');
  wait until clk'event and clk = '1';
  wait until clk'event and clk = '1';
  nRst <= '0';
  wait until clk'event and clk = '1';
  wait until clk'event and clk = '1';
  nRst <= '1';
  wait until clk'event and clk = '1';
  fin_medida <= '1';
  wait until clk'event and clk = '1';
  medida_corregida <= "1100000110";	-- -250
  wait for 50*T_clk;
  medida_corregida <= "1100111000";	-- -200
  wait for 50*T_clk;
  medida_corregida <= "1101101010";	-- -150
  wait for 50*T_clk;
  medida_corregida <= "1110011100";	-- -100
  wait for 50*T_clk;
  medida_corregida <= "1111001110";	-- 50
  wait for 50*T_clk;
  medida_corregida <= "0000000000";	-- 0
  wait for 50*T_clk;
  medida_corregida <= "0000110010";	-- 50
  wait for 50*T_clk;
  medida_corregida <= "0001100100";	-- 100
  wait for 50*T_clk;
  medida_corregida <= "0010010110";	-- 150
  wait for 50*T_clk;
  medida_corregida <= "0011001000";	-- 200
  wait for 50*T_clk;
  medida_corregida <= "0011111010";	-- 250
  wait for 50*T_clk;

  assert false
  report "Fone"
  severity failure;

end process;
end test;