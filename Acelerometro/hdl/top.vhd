library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity top is
port( clk:      in     std_logic;
      nRST:     in     std_logic; 
      nCS:      buffer std_logic;
      SDI:      in std_logic;
      SPC:      buffer std_logic;
      SDO:      buffer std_logic;
      leds:     buffer std_logic_vector(7 downto 0)
     );
end entity;

-- LO QUE ESTA EN EL MODULO => A DONDE LO ASOCIO DE ESTE .VHD
architecture estructural of top is                                                  
       
  signal   dato_rd:          std_logic_vector(7 downto 0);
  signal   rdy:              std_logic;
  signal   tic_5ms:          std_logic;
  signal   start:            std_logic;
  signal   dir_reg:          std_logic_vector(6 downto 0);
  signal   ena_rd:           std_logic;
  signal   dato_wr:          std_logic_vector(7 downto 0);
  signal   nWR_RD:           std_logic;
  signal   medida_x:         std_logic_vector(9 downto 0);
  signal   fin_medida:       std_logic; --Señal que se emplea para informar cuando se ha realizado una medida
  signal   ena_leds:         std_logic; --Señal para informar cuando se ha calculado el offset y se pueden encender los leds
  signal   offset:           std_logic_vector(9 downto 0);
  signal   medida_corregida: std_logic_vector(9 downto 0);
  signal   out_filtro:        std_logic_vector(9 downto 0);
  signal   out_offset:        std_logic_vector(9 downto 0);

 
begin 
  U0: entity work.control_spi(rtl)
      port map(clk          => clk,
               nRST         => nRST,
               tic_5ms      => tic_5ms,
               dato_rd      => dato_rd,
               ena_rd       => ena_rd,   
               rdy          => rdy,
               start        => start,
               nWR_RD       => nWR_RD,
               dir_reg      => dir_reg,
               dato_wr      => dato_wr,
               medida_x     => medida_x,
               fin_medida   => fin_medida);

  U1: entity work.timer_5ms(rtl)
      port map(clk         => clk,
               nRST        => nRST,
               tic_5ms     => tic_5ms);

  U2: entity work.leds_DECA(rtl)
      port map(clk              => clk, 
               nRst             => nRst,
	       ena_leds         => ena_leds,
               out_filtro       => out_filtro,
               leds             => leds);

  U3: entity work.master_spi_4_hilos(rtl)
      port map(clk          => clk,
               nRST         => nRST,
               start        => start,
               nWR_RD       => nWR_RD,
               dir_reg      => dir_reg,
               dato_wr      => dato_wr,
               dato_rd      => dato_rd,
               ena_rd       => ena_rd,   
               rdy          => rdy,
               nCS          => nCS,
               SPC          => SPC,
               SDI          => SDI,
               SDO          => SDO);
  
  U4: entity work.calculo_offset(rtl)
      port map(clk              => clk,
               nRst             => nRST,
               medida_acel      => medida_x,
               fin_medida       => fin_medida,
               ena_leds         => ena_leds,
               medida_corregida => medida_corregida,
               offset           => offset);

  U5: entity work.filtro_SPI(rtl)
      port map(clk              => clk,
               nRst             => nRST,
               fin_medida       => fin_medida,
               out_offset       => medida_corregida,
               out_filtro       => out_filtro);
             

end estructural;