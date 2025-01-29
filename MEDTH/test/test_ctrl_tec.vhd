--------------------------------------------------------------------------------------------------
-- Autor: DTE
-- Version:3.0
-- Fecha: 17-02-2021
--------------------------------------------------------------------------------------------------
-- Test para el controlador de teclado hexadecimal de 16 teclas
-- 
-- Este test instancia los siguientes modulos:
---- ctrl_tec: controlador de teclado (RTL). Es el DUT.
---- teclado: simulador del teclado hexadecimal. Utiliza el genérico TIC_2s.
---- estimulos: pulsacion de teclas; el reloj y el reset asincrono se generan fuera de este modulo.
---- monitor: chequeo simple del funcionamiento del teclado.
-- Este test utiliza el paquete pack_test_teclado en el quie se definen:
---- Una serie de constantes necesarias para el proceso de simulacion
---- El procedimiento pulsa_tecla que permite simular la pulsacion de una tecla junto con el modulo
---- simulador de teclado. Este procedimiento esta pensado para ser utilizado dentro del modulo de
---- estimulos
---- El procedimiento espera_TIC que permite esperar el numero de tics de 5 ms que se indiquen en 
---- su tercer argumento. Este procedimiento esta pensado para ser utilizado dentro del modulo de
---- estimulos
--
-- Genericos: TIC_2s. Es el numero de tics de 5 ms que hay que contar para medir 2 segundos.
-- El valor por defecto (400) es para sintesis.
--
-- Escalado: en este test se realiza una simulacion a escala:
---- El valor del generico que se le pasa al controlador de teclado es de 10, de manera que 
---- el modelo cuenta 10 tics de 5 ms en lugar de 400 para medir 2 segundos
---- Las siguientes constantes definidas en el paquete pack_test_teclado tienen valores escalados:
---- N_CLK_5ms : numero de ciclos de reloj que hay en un periodo del tic de 5 ms.  Para un reloj 
---- de 100 MHz deberian ser 500000; el valor escalado es 50
---- pulsacion_corta. Tiempo simulado para una pulsacion corta. El valor escalado es 3000 ns,
---- equivalente a 6 tics de 5 ms (escalados) 
---- pulsacion_larga. Tiempo simulado para una pulsacion larga. 8000 ns (16 tics escalados) 
---- constant pulsacion_corta_limite_sup. Pulsacion corta mas larga. 5000 ns; (10 tics)
---- constant pulsacion_larga_limite_inf. Pulsacion larga mas corta. 7000 ns (14 tics)
--
-- Debido al muestreo con el tic de 5 ms puede haber una incertidumbre en la deteccion del pulso
-- largo o corto de 4 tics. Por ese motivo en el test la duracion de las pulsaciones cortas no 
-- deben superar el limite establecido por pulsacion_corta_limite_sup y la duracion de las
-- pulsaciones largas no debe ser inferior a limite estableciso por pulsacion_larga_limite_inf.
--------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

use ieee.std_logic_unsigned.all;
use work.pack_test_teclado.all;

entity test_ctrl_tec is
end entity;

architecture test of test_ctrl_tec is
  signal clk           : std_logic;
  signal nRst          : std_logic;
  signal tic           : std_logic;
  signal columna       : std_logic_vector(3 downto 0);
  signal fila          : std_logic_vector(3 downto 0);
  signal tecla_pulsada : std_logic;
  signal tecla         : std_logic_vector(3 downto 0);
  signal pulso_largo   : std_logic;  
  
  signal tecla_test    : std_logic_vector(3 downto 0);
  signal tecla_id      : std_logic_vector(3 downto 0);
  signal pulsar_tecla  : std_logic;
  signal duracion_test : time;

 begin

  -- Bloque que simula el teclado hexadecimal
  sim_teclado: entity work.teclado(test) port map(
  pulsar_tecla => pulsar_tecla,
  tecla_test   => tecla_test,
  fila         => fila,
  columna      => columna);
  -- Controlador de teclado
  dut: entity work.ctrl_tec(rtl) 
  generic map(
    TICS_2s => 10 -- escalado
  )
  port map(
	clk           => clk,
    	nRst          => nRst,
    	tic           => tic,
    	columna       => columna,
    	fila          => fila,
    	tecla_pulsada => tecla_pulsada,
    	tecla         => tecla,
    	pulso_largo   => pulso_largo
  );
  -- Estimulos (pulsacion de teclas)
  estim: entity work.estimulos(test) port map(
    clk           => clk,
    tic           => tic,
    duracion_test => duracion_test,
    tecla_test    => tecla_test,
    tecla_id      => tecla_id,
    pulsar_tecla  => pulsar_tecla
  );
  -- Monitor
  mon: entity work.monitor(test) port map(
    clk           => clk,
    pulsar_tecla  => pulsar_tecla,
    duracion_test => duracion_test,
    tecla_pulsada => tecla_pulsada,
    pulso_largo   => pulso_largo,
    tecla_test    => tecla_test,
    tecla         => tecla
  );
  -- Reloj (100 MHz)
  clock: process
  begin
    clk <= '0';
    wait for T_CLK/2;
    clk <= '1';
    wait for T_CLK/2;
  end process;
  -- Tic de 5 ms (escalado)
  tic_5ms: process
  begin
    tic <= '0';
    wait for (N_CLK_5ms-1)*T_CLK;
    wait until clk'event and clk = '1';
    tic <= '1';
    wait for T_CLK;
    wait until clk'event and clk = '1';
  end process;  
  -- Reset asincrono
  reset: process
  begin
    nRst <= '0';
    wait for 3*T_CLK;
    wait until clk'event and clk = '1';
    nRst <= '1';
    wait;
  end process;
end test;