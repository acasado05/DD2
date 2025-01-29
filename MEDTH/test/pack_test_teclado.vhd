-- Paquete para simulacion del teclado hexadecimal
--
--    Designer: DTE
--    Versión: 1.0
--    Fecha: 08-01-2018

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

package pack_test_teclado is

constant Tclk_100_MHz : time := 10 ns;
constant pulsacion_corta:     time := 30 us; -- 1 tic de 250 ms
constant pulsacion_larga:     time := 300 us; -- 2 1/2 tics de 1 s
  
 -- Procedimientos de test
  
  -- Pulsación de una tecla del teclado
  procedure pulsa_tecla(signal   columna:   out std_logic_vector(3 downto 0); 
                        signal   clk:       in  std_logic;
						signal   fila:      in  std_logic_vector(3 downto 0);
                        constant tecla_test:     in  std_logic_vector(3 downto 0);
                        constant duracion:  in  time -- duracion de la pulsacion en ms
                        ); 
						
						
  -- Pulsacion larga mantenida mientras dure una condicion
  procedure pulsacion_larga_mantenida(signal   columna:       out std_logic_vector(3 downto 0); 
                        signal   clk:           in  std_logic;
						signal   fila:          in  std_logic_vector(3 downto 0);
                        signal   tiempo:        in  std_logic_vector(7 downto 0);
                        constant valor:         in  std_logic_vector(7 downto 0);
                        signal   pulso_largo:   in std_logic;
                        constant tecla_test:    in  std_logic_vector(3 downto 0));
						
end package;


package body pack_test_teclado is
  
  -- Procedimientos de test
  -- Pulsacion de una tecla del teclado
  procedure pulsa_tecla(signal   columna:   out std_logic_vector(3 downto 0); 
                        signal   clk:       in  std_logic;
						signal   fila:      in  std_logic_vector(3 downto 0);
                        constant tecla_test:     in  std_logic_vector(3 downto 0);
                        constant duracion:  in  time -- duracion de la pulsacion en ms
                        ) is
  begin
   case(tecla_test) is
     when X"0" =>
       wait until fila'event and fila = "0111";
       columna <= "1101";
     when X"1" =>
       wait until fila'event and fila = "1110";
       columna <= "1110";
     when X"2" =>
       wait until fila'event and fila = "1110";
       columna <= "1101";
     when X"3" =>
       wait until fila'event and fila = "1110";
       columna <= "1011";
     when X"4" =>
       wait until fila'event and fila = "1101";
       columna <= "1110";
     when X"5" =>
       wait until fila'event and fila = "1101";
       columna <= "1101";
     when X"6" =>
       wait until fila'event and fila = "1101";
       columna <= "1011";
     when X"7" =>
       wait until fila'event and fila = "1011";
       columna <= "1110";
     when X"8" =>
       wait until fila'event and fila = "1011";
       columna <= "1101";
     when X"9" =>
       wait until fila'event and fila = "1011";
       columna <= "1011";
     when X"A" =>
       wait until fila'event and fila = "0111";
       columna <= "1110";
     when X"B" =>
       wait until fila'event and fila = "0111";
       columna <= "1011";
     when X"C" =>
       wait until fila'event and fila = "0111";
       columna <= "0111";
     when X"D" =>
       wait until fila'event and fila = "1011";
       columna <= "0111";
     when X"E" =>
       wait until fila'event and fila = "1101";
       columna <= "0111";
     when X"F" =>
       wait until fila'event and fila = "1110";
       columna <= "0111";  
     when others => null; 
   end case;
   wait for duracion;
   columna <= "1111";
   wait for 2000*Tclk_100_MHz;
   wait until clk'event and clk = '1';
   wait until clk'event and clk = '1';
 end procedure;
 
 
   -- Pulsacion larga mantenida mientras dure una condicion
  procedure pulsacion_larga_mantenida(signal   columna:       out std_logic_vector(3 downto 0); 
                        signal   clk:           in  std_logic;
						signal   fila:          in  std_logic_vector(3 downto 0);
                        signal   tiempo:        in  std_logic_vector(7 downto 0);
                        constant valor:         in  std_logic_vector(7 downto 0);
                        signal   pulso_largo:   in  std_logic;
                        constant tecla_test:    in  std_logic_vector(3 downto 0)
                        ) is
  begin
   case(tecla_test) is
     when X"0" =>
       wait until fila'event and fila = "0111";
       columna <= "1101";
     when X"1" =>
       wait until fila'event and fila = "1110";
       columna <= "1110";
     when X"2" =>
       wait until fila'event and fila = "1110";
       columna <= "1101";
     when X"3" =>
       wait until fila'event and fila = "1110";
       columna <= "1011";
     when X"4" =>
       wait until fila'event and fila = "1101";
       columna <= "1110";
     when X"5" =>
       wait until fila'event and fila = "1101";
       columna <= "1101";
     when X"6" =>
       wait until fila'event and fila = "1101";
       columna <= "1011";
     when X"7" =>
       wait until fila'event and fila = "1011";
       columna <= "1110";
     when X"8" =>
       wait until fila'event and fila = "1011";
       columna <= "1101";
     when X"9" =>
       wait until fila'event and fila = "1011";
       columna <= "1011";
     when X"A" =>
       wait until fila'event and fila = "0111";
       columna <= "1110";
     when X"B" =>
       wait until fila'event and fila = "0111";
       columna <= "1011";
     when X"C" =>
       wait until fila'event and fila = "0111";
       columna <= "0111";
     when X"D" =>
       wait until fila'event and fila = "1011";
       columna <= "0111";
     when X"E" =>
       wait until fila'event and fila = "1101";
       columna <= "0111";
     when X"F" =>
       wait until fila'event and fila = "1110";
       columna <= "0111";  
     when others => null; 
   end case;
   wait until pulso_largo'event and pulso_largo = '1';
   wait until tiempo = valor;
   columna <= "1111";
   wait for 60*Tclk_100_MHz;
   wait until clk'event and clk = '1';
 end procedure;

 
 end package body pack_test_teclado;