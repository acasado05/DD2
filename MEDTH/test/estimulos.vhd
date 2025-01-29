--------------------------------------------------------------------------------------------------
-- Autor: DTE
-- Version:3.0
-- Fecha: 17-02-2021
--------------------------------------------------------------------------------------------------
-- Estimulos para el test del controlador de teclado.
-- El reloj y el reset asíncrono se aplican directamente en elnivel superior de la jerarquia del
-- test
-------------------------------------------------------------------------------------------------
-- PLANIFICACION DEL TEST:
--   1. Pasear un nivel bajo por todas las filas. 64 tics de N_clk_5ms
--   2. Pulsacion corta en todas las teclas       10 tics de N_clk_5ms
--   3. Pulsacion larga en todas las teclas       16 tics de N_clk_5ms 
--------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.pack_test_teclado.all;

entity estimulos is port(
  clk: in std_logic;
  tic: in std_logic;
  duracion_test: buffer time;
  tecla_test: buffer std_logic_vector(3 downto 0);
  tecla_id: buffer std_logic_vector(3 downto 0);
  pulsar_tecla: buffer std_logic
  );
end entity;

architecture test of estimulos is

begin

stim: process
  begin
    tecla_id <= (others => '0');
    pulsar_tecla <= '0';
    wait for 30*T_CLK;
    wait until clk'event and clk = '1';
    -- Para completar por los estudiantes (inicio)
    -- ...
    
    espera_TIC(clk, tic, 64);                 -- MAXIMO RETARDO 64 tics

-- PULSACION CORTA DE TODAS LAS TECLAS 

    pulsa_tecla(clk, X"1", pulsacion_corta, tecla_test, duracion_test, pulsar_tecla);
    espera_TIC(clk, tic, 5);   --espero 5 tick de 5 ms

    -- HAY QUE PONER espera_TIC, ENTRE pulsa_tecla,     REBOTES??

    pulsa_tecla(clk, X"2", pulsacion_corta, tecla_test, duracion_test, pulsar_tecla);
    espera_TIC(clk, tic, 5);   --espero 5 tick de 5 ms
    pulsa_tecla(clk, X"3", pulsacion_corta, tecla_test, duracion_test, pulsar_tecla);
    espera_TIC(clk, tic, 5);   --espero 5 tick de 5 ms
    pulsa_tecla(clk, X"4", pulsacion_corta, tecla_test, duracion_test, pulsar_tecla);
    espera_TIC(clk, tic, 5);   --espero 5 tick de 5 ms
    pulsa_tecla(clk, X"5", pulsacion_corta, tecla_test, duracion_test, pulsar_tecla);
    espera_TIC(clk, tic, 5);   --espero 5 tick de 5 ms
    pulsa_tecla(clk, X"6", pulsacion_corta, tecla_test, duracion_test, pulsar_tecla);
    espera_TIC(clk, tic, 5);   --espero 5 tick de 5 ms
    pulsa_tecla(clk, X"7", pulsacion_corta, tecla_test, duracion_test, pulsar_tecla);
    espera_TIC(clk, tic, 5);   --espero 5 tick de 5 ms
    pulsa_tecla(clk, X"8", pulsacion_corta, tecla_test, duracion_test, pulsar_tecla);
    espera_TIC(clk, tic, 5);   --espero 5 tick de 5 ms
    pulsa_tecla(clk, X"9", pulsacion_corta, tecla_test, duracion_test, pulsar_tecla);
    espera_TIC(clk, tic, 5);   --espero 5 tick de 5 ms
    pulsa_tecla(clk, X"0", pulsacion_corta, tecla_test, duracion_test, pulsar_tecla);
    espera_TIC(clk, tic, 5);   --espero 5 tick de 5 ms
    pulsa_tecla(clk, X"A", pulsacion_corta, tecla_test, duracion_test, pulsar_tecla);
    espera_TIC(clk, tic, 5);   --espero 5 tick de 5 ms
    pulsa_tecla(clk, X"B", pulsacion_corta, tecla_test, duracion_test, pulsar_tecla);
    espera_TIC(clk, tic, 5);   --espero 5 tick de 5 ms
    pulsa_tecla(clk, X"C", pulsacion_corta, tecla_test, duracion_test, pulsar_tecla);
    espera_TIC(clk, tic, 5);   --espero 5 tick de 5 ms
    pulsa_tecla(clk, X"D", pulsacion_corta, tecla_test, duracion_test, pulsar_tecla);
    espera_TIC(clk, tic, 5);   --espero 5 tick de 5 ms
    pulsa_tecla(clk, X"E", pulsacion_corta, tecla_test, duracion_test, pulsar_tecla);
    espera_TIC(clk, tic, 5);   --espero 5 tick de 5 ms
    pulsa_tecla(clk, X"F", pulsacion_corta, tecla_test, duracion_test, pulsar_tecla);

-- PULSACION LARGA DE TODAS LAS TECLAS

    pulsa_tecla(clk, X"1", pulsacion_larga, tecla_test, duracion_test, pulsar_tecla);
    espera_TIC(clk, tic, 5);   --espero 5 tick de 5 ms

    -- HAY QUE PONER espera_TIC, ENTRE pulsa_tecla,     REBOTES??

    pulsa_tecla(clk, X"2", pulsacion_larga, tecla_test, duracion_test, pulsar_tecla);
    espera_TIC(clk, tic, 5);   --espero 5 tick de 5 ms
    pulsa_tecla(clk, X"3", pulsacion_larga, tecla_test, duracion_test, pulsar_tecla);
    espera_TIC(clk, tic, 5);   --espero 5 tick de 5 ms
    pulsa_tecla(clk, X"4", pulsacion_larga, tecla_test, duracion_test, pulsar_tecla);
    espera_TIC(clk, tic, 5);   --espero 5 tick de 5 ms
    pulsa_tecla(clk, X"5", pulsacion_larga, tecla_test, duracion_test, pulsar_tecla);
    espera_TIC(clk, tic, 5);   --espero 5 tick de 5 ms
    pulsa_tecla(clk, X"6", pulsacion_larga, tecla_test, duracion_test, pulsar_tecla);
    espera_TIC(clk, tic, 5);   --espero 5 tick de 5 ms
    pulsa_tecla(clk, X"7", pulsacion_larga, tecla_test, duracion_test, pulsar_tecla);
    espera_TIC(clk, tic, 5);   --espero 5 tick de 5 ms
    pulsa_tecla(clk, X"8", pulsacion_larga, tecla_test, duracion_test, pulsar_tecla);
    espera_TIC(clk, tic, 5);   --espero 5 tick de 5 ms
    pulsa_tecla(clk, X"9", pulsacion_larga, tecla_test, duracion_test, pulsar_tecla);
    espera_TIC(clk, tic, 5);   --espero 5 tick de 5 ms
    pulsa_tecla(clk, X"0", pulsacion_larga, tecla_test, duracion_test, pulsar_tecla);
    espera_TIC(clk, tic, 5);   --espero 5 tick de 5 ms
    pulsa_tecla(clk, X"A", pulsacion_larga, tecla_test, duracion_test, pulsar_tecla);
    espera_TIC(clk, tic, 5);   --espero 5 tick de 5 ms
    pulsa_tecla(clk, X"B", pulsacion_larga, tecla_test, duracion_test, pulsar_tecla);
    espera_TIC(clk, tic, 5);   --espero 5 tick de 5 ms
    pulsa_tecla(clk, X"C", pulsacion_larga, tecla_test, duracion_test, pulsar_tecla);
    espera_TIC(clk, tic, 5);   --espero 5 tick de 5 ms
    pulsa_tecla(clk, X"D", pulsacion_larga, tecla_test, duracion_test, pulsar_tecla);
    espera_TIC(clk, tic, 5);   --espero 5 tick de 5 ms
    pulsa_tecla(clk, X"E", pulsacion_larga, tecla_test, duracion_test, pulsar_tecla);
    espera_TIC(clk, tic, 5);   --espero 5 tick de 5 ms
    pulsa_tecla(clk, X"F", pulsacion_larga, tecla_test, duracion_test, pulsar_tecla);
    espera_TIC(clk, tic, 5);   --espero 5 tick de 5 ms
       
    -- Para completar por los estudiantes (fin) 
    assert(false) report "******************************Fin del test************************" severity failure;
  end process;

end test;