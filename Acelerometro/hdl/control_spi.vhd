--    Designer: Iván Isabel Sierra
--    Versi�n: 1.0
--    Fecha: 24-04-2024 (D.C.)

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity control_spi is
port( --RELOJ
     clk:        in         std_logic;
     nRst:       in         std_logic;                   
     tic_5ms:    in         std_logic;

     --CONTROL SPI
     rdy:        in         std_logic;
     ena_rd:     in         std_logic;
     start:      buffer     std_logic;                      -- Orden de ejecucion (si rdy = 1 ) => rdy  <= 0 hasta fin, cuando rdy <= 1
     nWR_RD:     buffer     std_logic;                      -- Escritura (0) o lectura (1)

     --BUS SPI
     dato_rd:    in         std_logic_vector(7 downto 0);
     dir_reg:    buffer     std_logic_vector(6 downto 0);   -- direccion de acceso; si bit 7 a 1 (autoincremento) y RD, se considera el valor de long
     dato_wr:    buffer     std_logic_vector(7 downto 0);   -- dato a escribir (solo escrituras de 1 bit)
     medida_x:   buffer     std_logic_vector(9 downto 0);

     --OFFSET
     fin_medida: buffer     std_logic                       --Segnal para informar cuando se realiza una medida
     );
	 
end entity;

architecture rtl of control_spi is

  type t_estado is (configuracion_REG4, configuracion_REG1, preparacion_Medidas, medidas);
  signal estado: t_estado;
	
  signal datos_leidos: std_logic_vector(15 downto 0);
  
  signal rdy_prev: std_logic;


begin

  PROC_STATE: process(clk, nRst)
  begin
    if nRst = '0' then
      start <= '0';
      nWR_RD <= '0';
      dir_reg <= (others => '0');
      dato_wr <= (others => '0');
      estado <= configuracion_REG4;
			
    elsif clk'event and clk = '1' then
      case estado is
        when configuracion_REG4 =>
          nWR_RD <= '0';
          dir_reg <= '0' & "100011"; --0x23
          dato_wr <= x"80";
          start <= '1';
		
          if rdy_prev = '0' and rdy = '1' then
            start <= '0';
            estado <= configuracion_REG1;
						
          end if;

        when configuracion_REG1 =>
          nWR_RD <= '0';
          dir_reg <= '0' & "100000"; --0x20
          dato_wr <= x"61";
          start <= '1';
					
          if rdy_prev = '0' and rdy = '1' then
            start <= '0';
            estado <= preparacion_Medidas;
						
          end if;
					
        when preparacion_Medidas =>
          start <= '0';
					
          if tic_5ms = '1' then
            nWR_RD <= '1';
            dir_reg <= '1' & "101000"; --Direccion 0x28 mas MS = '1' para que se realice el incremento directamente
            start <= '1';
            estado <= medidas;
					  
          end if;
                  
        when medidas =>
          start <= '0';
					
          if rdy_prev = '0' and rdy = '1' then
            estado <= preparacion_Medidas;    

          end if;
      end case;
    end if;
  end process;

  process(clk, nRst)
  begin
    if nRst = '0' then 
      rdy_prev <= '1';	
		
    elsif clk'event and clk = '1' then
      rdy_prev <= rdy;

    end if;
  end process;
	
  -- ALMACENAMIENTO DE LAS MEDIDAS
  process(clk, nRst)
  begin
    if nRst = '0' then 
      datos_leidos <= (others => '0');
			
    elsif clk'event and clk = '1' then
      if ena_rd = '1' then
        datos_leidos <= datos_leidos(7 downto 0) & dato_rd;
 
      end if;
    end if;
  end process;

  --PASAR DE LITTLE ENDIAN (COMO ENTREGA EL ACELEROMETRO) A LO QUE QUEREMOS
  medida_x <=	datos_leidos(7 downto 0) & datos_leidos(15 downto 14);
    
  --OFFSET
  --Informamos cuando realizamos una medida -> habilita el calculo del offset
  fin_medida <= '1' when estado = medidas and rdy_prev = '0' and rdy = '1' else
                '0';

end rtl;
