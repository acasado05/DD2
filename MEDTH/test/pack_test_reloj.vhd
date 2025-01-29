library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

use work.pack_test_teclado.all;

package pack_test_reloj is
  
  constant Tclk_50_MHz:       time := 20 ns; 

  -- Funcion auxiliar
  function hora_to_natural (hora: std_logic_vector(23 downto 0)) return natural;

    -- Parar el reloj cuando se alcanza un valor de hora especificado
  procedure esperar_hora	(signal   horas:       in  std_logic_vector(7 downto 0);
                             signal   minutos:     in  std_logic_vector(7 downto 0);   
                             signal   AM_PM:       in  std_logic;   
                             signal   clk:         in  std_logic;
                             constant periodo:     in  std_logic;
                             constant valor:       in  std_logic_vector(15 downto 0));

  -- cambiar de formato 12 a 24 horas y viceversa
  procedure cambiar_modo_12_24(signal   columna:   out std_logic_vector(3 downto 0); 
                               signal   fila: 	   in std_logic_vector(3 downto 0); 
                               signal   clk:       in  std_logic);

  -- Sostenimiento de tecla de entrada a programación
  procedure entrar_modo_prog(signal   columna:     out std_logic_vector(3 downto 0); 
                             signal   fila: 	   in std_logic_vector(3 downto 0); 
                             signal   clk:         in  std_logic;
							 constant duracion:    in  natural := 15);

  -- Salir del modo de programación
  procedure fin_prog(signal   columna:   out std_logic_vector(3 downto 0); 
                     signal   fila: 	 in std_logic_vector(3 downto 0); 
                     signal   clk:       in  std_logic);

  -- Dejar transcurrir el tiempo de time-out
  procedure time_out(signal   clk:       in  std_logic);


  -- Programar una hora con el comando de incremento de campo
  procedure programar_hora_inc_corto(signal   columna:   out std_logic_vector(3 downto 0); 
									 signal   fila: 	 in std_logic_vector(3 downto 0); 
									 signal   horas:     in  std_logic_vector(7 downto 0);
                                     signal   minutos:   in  std_logic_vector(7 downto 0);   
									 signal   AM_PM:     in  std_logic;   
                                     signal   clk:       in  std_logic;
									 constant periodo:   in  std_logic;
                                     constant valor:     in  std_logic_vector(15 downto 0));

  -- Programar un a hora con el comando de incremento continuo de campo
  procedure programar_hora_inc_largo (signal   pulso_largo: in std_logic; 
                                      signal   columna:     out std_logic_vector(3 downto 0); 
									  signal   fila: 	    in std_logic_vector(3 downto 0); 
									  signal   horas:       in  std_logic_vector(7 downto 0);
                                      signal   minutos:     in  std_logic_vector(7 downto 0);   
                                      signal   clk:         in  std_logic;
                                      constant valor:       in  std_logic_vector(15 downto 0));

  -- Programar una hora indicando el valor de cada campo por introduccion numerica
  procedure programar_hora_directa  (signal   columna:   out std_logic_vector(3 downto 0); 
									 signal   fila: 	   in std_logic_vector(3 downto 0); 
									 signal   clk:       in  std_logic;
                                     constant valor:     in  std_logic_vector(15 downto 0));



end package;

package body pack_test_reloj is
  -- Funciones auxiliares -----------------------------------------------------------------------------------
    function hora_to_natural (hora: std_logic_vector(23 downto 0)) return natural is
      variable resultado: natural := 0;

    begin
      resultado := 10*conv_integer(hora(23 downto 20));
      resultado := resultado + conv_integer(hora(19 downto 16));
      resultado := resultado * 3600;
      resultado := resultado + 600*conv_integer(hora(15 downto 12)); 
      resultado := resultado + 60*conv_integer(hora(11 downto 8));
      resultado := resultado + 10*conv_integer(hora(7 downto 4));
      resultado := resultado + conv_integer(hora(3 downto 0));
      return resultado;

    end function;

  -- Procedimientos de test -----------------------------------------------------------------------------------

  -- Parar el reloj cuando se alcanza un valor de hora especificado (ARREGLADA)
  procedure esperar_hora	(signal   horas:       in  std_logic_vector(7 downto 0);
                             signal   minutos:     in  std_logic_vector(7 downto 0);   
                             signal   AM_PM:       in  std_logic;   
                             signal   clk:         in  std_logic;
                             constant periodo:     in  std_logic;
                             constant valor:       in  std_logic_vector(15 downto 0)) is
  begin
    wait until (horas & minutos) = valor and AM_PM = periodo;

  end procedure;

  --*************************  CAMBIAR ARGUMENTOS CMD_TECKA ETC
  
  
  -- cambiar de formato 12 a 24 horas y viceversa 
  procedure cambiar_modo_12_24(signal   columna:   out std_logic_vector(3 downto 0); 
                               signal   fila: 	   in std_logic_vector(3 downto 0);
							   signal   clk:       in  std_logic) is
  begin
    pulsa_tecla(columna, clk, fila, X"D", pulsacion_corta);

  end procedure;

  -- Sostenimiento de tecla de entrada en programación 
  procedure entrar_modo_prog(signal   columna:     out std_logic_vector(3 downto 0); 
                             signal   fila: 	   in std_logic_vector(3 downto 0); 
                             signal   clk:         in  std_logic;
							 constant duracion:    in  natural := 15) is
  begin
	pulsa_tecla(columna, clk, fila, X"A", pulsacion_larga);

  end procedure;


  -- Salir del modo de programación 
  procedure fin_prog(signal   columna:   out std_logic_vector(3 downto 0); 
                     signal   fila: 	 in std_logic_vector(3 downto 0); 
                     signal   clk:       in  std_logic) is
  begin
    pulsa_tecla(columna, clk, fila, X"A", pulsacion_corta);

  end procedure;

  -- Dejar transcurrir el tiempo de time-out 
  procedure time_out(signal   clk:       in  std_logic) is
  begin
	  wait for 1 ms; -- Algo mas de 8 segundos
      wait until clk'event and clk = '1';
  end procedure;

  -- Programar una hora con el comando de incremento corto 
  procedure programar_hora_inc_corto (signal   columna:   out std_logic_vector(3 downto 0); 
									  signal   fila: 	 in std_logic_vector(3 downto 0); 
									  signal   horas:     in  std_logic_vector(7 downto 0);
                                      signal   minutos:   in  std_logic_vector(7 downto 0);   
									  signal   AM_PM:     in  std_logic;   
                                      signal   clk:       in  std_logic;
									  constant periodo:   in  std_logic;
                                      constant valor:     in  std_logic_vector(15 downto 0)) is

  begin

   while horas /= valor(15 downto 8) or AM_PM /= periodo loop
     pulsa_tecla(columna, clk, fila, X"C", pulsacion_corta);
   end loop;

   pulsa_tecla(columna, clk, fila, X"B", pulsacion_corta);

   while minutos /= valor(7 downto 0) loop
     pulsa_tecla(columna, clk, fila, X"C", pulsacion_corta);
   end loop;

   end procedure; 

  -- Programar un a hora con el comando de incremento continuo
  procedure programar_hora_inc_largo (signal   pulso_largo: in std_logic; 
                                      signal   columna:     out std_logic_vector(3 downto 0); 
									  signal   fila: 	    in std_logic_vector(3 downto 0); 
									  signal   horas:       in  std_logic_vector(7 downto 0);
                                      signal   minutos:     in  std_logic_vector(7 downto 0);   
                                      signal   clk:         in  std_logic;
                                      constant valor:       in  std_logic_vector(15 downto 0)) is

  begin

   wait until clk'event and clk = '1'; 
     pulsacion_larga_mantenida(columna, clk, fila, horas, valor(15 downto 8), pulso_largo, X"C");
     pulsa_tecla(columna, clk, fila, X"B", pulsacion_corta);
   
   wait until clk'event and clk = '1'; 
     pulsacion_larga_mantenida(columna, clk, fila, minutos, valor(7 downto 0), pulso_largo, X"C");
     
     wait until clk'event and clk = '1';

  end procedure; 

  -- Programar una hora indicando el valor de cada campo directamente 
  procedure programar_hora_directa  (signal   columna:   out std_logic_vector(3 downto 0); 
									 signal   fila: 	   in std_logic_vector(3 downto 0); 
									 signal   clk:       in  std_logic;
                                     constant valor:     in  std_logic_vector(15 downto 0)) is

  begin

    pulsa_tecla(columna, clk, fila, valor(15 downto 12), pulsacion_corta);
    pulsa_tecla(columna, clk, fila, valor(11 downto 8), pulsacion_corta);
    pulsa_tecla(columna, clk, fila, X"B", pulsacion_corta);

    pulsa_tecla(columna, clk, fila, valor(7 downto 4), pulsacion_corta);
    pulsa_tecla(columna, clk, fila, valor(3 downto 0), pulsacion_corta);

  end procedure;


end package body pack_test_reloj;