--------------------------------------------------------------------------------------------------
-- Autor: DTE
-- Version:3.0
-- Fecha: 17-02-2021
--------------------------------------------------------------------------------------------------
-- Monitor simple para el test del controlador de teclado. 
-- Para cada pulsacion, este monitor indica, en orden sucesivo:
---- si lo que se pretende es realizar una pulsacion larga o corta
---- la tecla que se pretende pulsar
---- la tecla que realmente se detecta (solo cuando hay error)
---- si la pulsacion realmente es larga o corta (solo cuando hay error)
--------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;
use work.pack_test_teclado.all;

entity monitor is port(
  clk: in std_logic;
  pulsar_tecla: in std_logic;
  duracion_test: in time;
  tecla_pulsada : in std_logic;
  pulso_largo : in std_logic;
  tecla_test: in std_logic_vector(3 downto 0);
  tecla: in std_logic_vector(3 downto 0)
  );
end entity;

architecture test of monitor is

begin

monitor: process
  begin
    wait until pulsar_tecla'event and pulsar_tecla = '1';
    if duracion_test <= pulsacion_corta_limite_sup then -- la pulsacion real es corta
      report("Monitor (info): se esta realizando una pulsacion CORTA");
    elsif duracion_test >= pulsacion_larga_limite_inf then -- la pulsacion real es larga
      report("Monitor (info): se esta realizando una pulsacion LARGA:");
    else
      report("Monitor (warning): incertidumbre en la deteccion de pulsacion CORTA o LARGA");
    end if;
    report("Monitor (info): Se ha pulsado la tecla:" & integer'image(conv_integer(tecla_test))); -- tecla real pulsada
    wait until (tecla_pulsada = '1' or pulso_largo = '1') and clk'event and clk = '1';
    -- chequeo de la tecla detectada por el controlador de teclado
    assert(tecla = tecla_test)
    report("Monitor (info): Se ha detectado la tecla:" & integer'image(conv_integer(tecla_test)))
    severity error;
    -- chequeo del tipo de pulsacion detectada por el controlador de teclado: larga o corta
    if tecla_pulsada = '1' then -- se ha detectado pulsacion corta
      assert(duracion_test <= pulsacion_larga_limite_inf)
      report("Monitor: Se ha detectado pulso corto en lugar de largo")
      severity error;
    else
      assert(duracion_test >= pulsacion_corta_limite_sup) -- se ha detectado pulsacion larga
      report("Monitor: Se ha detectado pulso largo en lugar de corto")
      severity error;
    end if;
  end process;
end test;
