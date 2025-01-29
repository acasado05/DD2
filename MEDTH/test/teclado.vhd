--------------------------------------------------------------------------------------------------
-- Autor: DTE
-- Version:3.0
-- Fecha: 17-02-2021
--------------------------------------------------------------------------------------------------
-- Modulo simulador del teclado hexadecimal para test
-- Su entrada pulsar_tecla debe activarse durante el tiempo que dure la pulsacion
-- En la entrada tecla_test debe introducirse la tecla que se desea pulsar al mismo tiempo que se
-- activa pulsar_tecla
-- El modulo toma como entrada las filas del teclado (fila) y genera como salida las columnas
-- (columna) en funcion del estado de las filas.
-- Las columnas responden con un retardo DELAY_PULLUPS que se ha fijado en 20 ns. Este retardo
-- modela el que realmente se produce en el teclado por estar las columnas conectadas a sendas
-- resistencias de pull-up.
-- Cuando no se activa pulsar_tecla el teclado permanece en reposo con las salidas de columnas
-- a nivel alto.
--------------------------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

entity teclado is port(
  pulsar_tecla: in std_logic;
  tecla_test: in std_logic_vector(3 downto 0);
  fila: in std_logic_vector(3 downto 0);
  columna: buffer std_logic_vector(3 downto 0)
  );
end entity;

architecture test of teclado is

begin
  teclado: process(pulsar_tecla, tecla_test, fila)
    variable columna_i : std_logic_vector(3 downto 0);
    constant DELAY_PULLUPS : time := 20 ns;
    begin
    if pulsar_tecla = '1' then
      case(tecla_test) is
       when X"0" => columna_i(1) := fila(3);
       when X"1" => columna_i(0) := fila(0);
       when X"2" => columna_i(1) := fila(0);
       when X"3" => columna_i(2) := fila(0);
       when X"4" => columna_i(0) := fila(1);
       when X"5" => columna_i(1) := fila(1);
       when X"6" => columna_i(2) := fila(1);
       when X"7" => columna_i(0) := fila(2);
       when X"8" => columna_i(1) := fila(2);
       when X"9" => columna_i(2) := fila(2);
       when X"A" => columna_i(0) := fila(3);
       when X"B" => columna_i(2) := fila(3);
       when X"C" => columna_i(3) := fila(3);
       when X"D" => columna_i(3) := fila(2);
       when X"E" => columna_i(3) := fila(1);
       when X"F" => columna_i(3) := fila(0);
       when others => null; 
     end case;
    else
      columna_i := (others =>'1');
    end if;
      columna <= columna_i after DELAY_PULLUPS;
  end process;
end test;
