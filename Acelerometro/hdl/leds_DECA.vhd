-- Implementacion: se toman las 10 muestras mas significativas. El acelerometro
-- entrega el dato en dos bytes, mediante little endian, por lo que es necesario
-- hacer las modificaciones necesarias para pasarlo a 10 bits de la manera correcta.
-- Estos 10 bits son 1024 valores, pero al estar en CA2, iran de -512 a 511. El valores
-- de los escalones va de 1 a 5, por lo que cada escalon tiene un rango de 1024/15. No sale
-- un numero entero, por lo que ampliamos el escalon central.

-- *NOTA*: los leds de la DECA son de catodo comun, se encienden con un cero 

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all; --Tenemos que tener en cuenta que las medidas pueden ser tanto positivas como negativas

entity leds_DECA is
port(clk:              in std_logic;
     nRst:             in std_logic;
     ena_leds:	       in std_logic;
     out_filtro:       in std_logic_vector(9 downto 0);
     leds:             buffer std_logic_vector(7 downto 0) );

end entity;

architecture rtl of leds_DECA is
  signal leds_aux: std_logic_vector(7 downto 0); --Señal auxiliar para sincronizar la salida de los leds

begin
  
  --Salida sincrona de los leds
  process(clk, nRst)
  begin
    if nRst = '0' then
      leds <= (others => '1');

    elsif clk'event and clk = '1' then
      if ena_leds = '0' then --Se esta realizando el calculo del offset
        leds <= (others => '1');
		
      else
	leds <= leds_aux;
		
      end if;
    end if;
  end process;

  --Calculo del valor de los leds: para -1g y 1g
  leds_aux <= "11111110"  when out_filtro < -222                          else
	      "11111100"  when out_filtro >= -222 and  out_filtro < -188  else
	      "11111000"  when out_filtro >= -188 and  out_filtro < -154  else
	      "11110000"  when out_filtro >= -154 and  out_filtro < -120  else
	      "11100000"  when out_filtro >= -120 and  out_filtro < -86   else
	      "11000000"  when out_filtro >= -86  and  out_filtro < -52   else
	      "10000000"  when out_filtro >= -52  and  out_filtro < -18   else
              "00000000"  when out_filtro >= -18  and  out_filtro <  18   else --Horizontal
	      "00000001"  when out_filtro >= 18   and  out_filtro <  52   else
	      "00000011"  when out_filtro >= 52   and  out_filtro <  86   else
	      "00000111"  when out_filtro >= 86   and  out_filtro <  120  else
	      "00001111"  when out_filtro >= 120  and  out_filtro <  154  else
              "00011111"  when out_filtro >= 154  and  out_filtro <  188  else
              "00111111"  when out_filtro >= 188  and  out_filtro <  222  else
	      "01111111"  when out_filtro > 222;

 
		   
end rtl;