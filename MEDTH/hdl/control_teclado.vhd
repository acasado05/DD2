--CONTROL TECLADO
--Reloj del sistema 100MHz 10ns 
--Quiero filtrar los rebotes 
--Pulso largo 2 segundos

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity ctrl_tec is 
port( clk: 	     in std_logic;
      nRst:	     in std_logic;
      tic:  	     in std_logic;  --muestreo de 5 ms filtrar rebotes 
      columna: 	     in std_logic_vector(3 downto 0);   
      fila: 	     buffer std_logic_vector(3 downto 0);  --00 fila0  01 fila 1 10 fila 2 11 fila 3
      tecla:         buffer std_logic_vector(3 downto 0); --valor en hexadecimal de la  tecla pulsada
      tecla_pulsada: buffer std_logic; --indica que se ha pulsado una tecla     
      pulso_largo:   buffer std_logic);   --indica que se ha pulsado una tecla mas de 2s                          
end entity;

architecture rtl of ctrl_tec is
   signal col_x_reg : std_logic_vector(3 downto 0);
   signal col_x_sinrebotes: std_logic_vector(3 downto 0);
   signal mux: std_logic; --muestreo las filas, cuando se active una columna valdra 0 y se habra pulsado una tecla 
   signal contador: std_logic_vector(8 downto 0);   
   signal tecla_cd : std_logic_vector(3 downto 0);
begin

  process(clk, nRst)
    begin 
     if nRst = '0' then 
        col_x_reg <= (others => '1');
     elsif clk'event and clk = '1' then
      if tic = '1' then
        col_x_reg <= columna;
      end if;
     end if;
  end process;

--proceso para coger la columna sin rebotes
  process(clk, nRst)
    begin 
     if nRst = '0' then 
        col_x_sinrebotes <= (others => '1');
     elsif clk'event and clk = '1' then
      if tic = '1' then
        col_x_sinrebotes <= col_x_reg;
      end if;
     end if;
  end process;

  --Las filas son las que muestreo
  --Las columnas permanecen a 1 hasta que una se activa y pasa a valer 0
  --Conociento la fila y la columan que se activa sabremos la tecla pulsada   
 process(clk, nRst)
    begin
     if nRst = '0' then 
       fila <= "1110" ;      
     elsif clk'event and clk='1' then 

      if tic = '1' and mux = '1' then --muestreo
       case fila is
	when "1110" =>
    	    fila <= "1101";
	when "1101" =>
    	    fila <= "1011";
	when "1011" =>
    	    fila <= "0111";
 	when "0111" =>
            fila <= "1110";
 	when others =>
            fila <= "XXXX";
  	end case;	
      end if;
     end if;
   end process;

mux <= '1' when columna = "1111" else '0';

--DURACION DE LA PULSACION 
  process (clk, nRst)
   begin
    if nRst = '0' then
  	contador <= (others => '0');
    elsif clk'event and clk='1' then

  if col_x_sinrebotes = "1111" then  
	contador <= (others => '0');
   --La duracion de la pul_corta o pul_larga va en funcion de tic_5ms
  elsif tic = '1' and col_x_sinrebotes /="1111" then 
        contador <= contador + 1;
   end if;
 end if;
end process;

--QUE PULSACION ES
pulso_largo <= '1' when contador > 6 else    --es por el escalado
   	       '0';
----La salida de TECLA_PULSADA SOLO ESTA ACTIVA UN FLANCO DEL RELOJ
tecla_pulsada <= '1' when col_x_sinrebotes/= "1111" and columna = "1111" else
	 	 '0';

tecla_cd <=   X"0" when col_x_sinrebotes(1) = '0' and   fila(3) = '0' else
              X"1" when col_x_sinrebotes(0) = '0' and fila(0) = '0' else
              X"2" when col_x_sinrebotes(1) = '0' and fila(0) = '0' else
              X"3" when col_x_sinrebotes(2) = '0' and fila(0) = '0' else
              X"4" when col_x_sinrebotes(0) = '0' and fila(1) = '0' else
              X"5" when col_x_sinrebotes(1) = '0' and fila(1) = '0' else
              X"6" when col_x_sinrebotes(2) = '0' and fila(1) = '0' else
              X"7" when col_x_sinrebotes(0) = '0' and fila(2) = '0' else
              X"8" when col_x_sinrebotes(1) = '0' and fila(2) = '0' else
              X"9" when col_x_sinrebotes(2) = '0' and fila(2) = '0' else
              X"A" when col_x_sinrebotes(0) = '0' and fila(3) = '0' else
              X"B" when col_x_sinrebotes(2) = '0' and fila(3) = '0' else
              X"C" when col_x_sinrebotes(3) = '0' and fila(3) = '0' else
              X"D" when col_x_sinrebotes(3) = '0' and fila(2) = '0' else
              X"E" when col_x_sinrebotes(3) = '0' and fila(1) = '0' else
              X"F";    -- when columna(3) = '0' and fila(1) = '0' else

tecla <= tecla_cd when pulso_largo = '1' or tecla_pulsada = '1' else
         (others => 'X');
end rtl;
