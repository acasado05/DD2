library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_signed.all; --Tenemos que tener en cuenta que las medidas pueden ser tanto positivas como negativas

entity calculo_offset is
port(clk:              in std_logic;
     nRst:             in std_logic;
     medida_acel:      in std_logic_vector(9 downto 0);
     fin_medida:       in std_logic;                         --Segnal que informa cuando se termina de realizar una medida
     ena_leds:         buffer std_logic;                     --Segnal que informa cuando hemos calcula el offset
     medida_corregida: buffer std_logic_vector(9 downto 0);
     offset:           buffer std_logic_vector(9 downto 0)   --Offset calculado
    );

end entity;

architecture rtl of calculo_offset is

  --PROMEDIO
  signal suma_medidas: std_logic_vector(14 downto 0);    --Sumador para realizar el promedio del offset
  signal aux_medida_acel: std_logic_vector(14 downto 0);

  --CONTADOR
  signal cnt: std_logic_vector(5 downto 0); --Cuenta del contador
  signal fin_cnt: std_logic;                --Fin de cuenta del contador

begin

  --Contador de modulo 32 con entrada de habilitacion: fin_medida, 
  --que medira un total de 32 lecturas para calcular el offset, y entrada de reset: fin_cnt

  PROC_CNT_MEDIDAS: process(clk, nRst)
  begin
    if nRst = '0' then
      cnt <= (0 => '1', others => '0');
			
    elsif clk'event and clk = '1' then
      if fin_cnt = '1' then         --Reseteamos, ya hemos realizado las 32 medidas
        cnt <= (others => '0');
				
      elsif fin_medida = '1' then   --Se ha realizado una medida
        cnt <= cnt + 1;
				
      end if;
    end if;
  end process PROC_CNT_MEDIDAS;

  --Fin de cuenta del contador
  --Tendremos en cuenta cuando cnt sea 0 ya que cuando se llegue a realizar las 32 medidas(se deben completar totalmente, 
  --entonces debemos esperar a que el contador sea 33), resetearemos el contador a 0 
  --y no volveremos a realizar más cuentas ya que ya hemos obtenido las medidas necesarias para calcular el offset
  fin_cnt <= '1' when cnt = 33 or cnt = 0 else  --No tendria que ser cnt = 32 o cnt = 31, si empiezas en cero
             '0';

  --Extendemos el signo de la señal medida para realizar la suma correctamente teniendo en cuenta que medida_acel
  --tambien puede ser negativa
  aux_medida_acel <= "00000" & medida_acel when medida_acel(9) = '0' else
                     "11111" & medida_acel; --medida_acel(9) = '1'

  --Acumulador de las medidas que realizamos para calcular el offset con entradas de habilitacion: 
  --fin_medida/ena_leds(negado ya que cuando terminemos de calcular el offset no sumaremos mas medidas)
  process(nRst, clk)
  begin
    if nRst = '0' then
      suma_medidas <= (others => '0');
			
    elsif clk'event and clk = '1' then
      if fin_medida = '1' and ena_leds = '0' then
        suma_medidas <= suma_medidas +  aux_medida_acel;  --Cuando ya hemos recibido las 32 medidas, 
                                                          --dejamos de sumar mas medidas ya que con el 
                                                          --valor obtenido ya podemos calcular el 
                                                          --offset del acelerometro
				
      end if;
    end if;
  end process;

  --Calculamos el offset
  offset <= suma_medidas(14 downto 5); --Dividimos por 32 desplazando 5 posiciones de la suma de las medidas

  --Calculo de la medida del acelerometro teniendo en cuenta el offset
  medida_corregida <= medida_acel - offset;

  --Informamos cuando se pueden encender los leds ya que ya hemos realizado el calculo del offset
  ena_leds <= '1' when cnt = 0 else
              '0';

end rtl;
      
