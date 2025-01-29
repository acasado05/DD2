-- Test dirigido simple del tope de la jerarquia de MEDTH
--
-- Prueba los 4 modos de funcionamiento de la presentacion y
-- las distitas formas de programacion del reloj
-- La secuencia de operaciones es la siguiente:
--
-- Inicialmente el sistema arranca en modo 0 (los displays muestran el reloj)
--
-- Se programa el reloj en diversas formas: pulsacion corta y larga en 'C'
-- e introduciendo los valores numericamente.
-- Se prueba el cambio de modo 12h y 24h
-- Se prueba la salida programacion por timeout
--
-- Posteriormente se prueban los modos de funcionamiento del display
-- Se programa el modo 1 (los displays muestran la temperatura) 
-- Se programa el modo 2 (los displays muestran la humedad) 
-- Se programa el modo 3 (los displays muestran todo en secuencia) 
-- Vuelta al modo 0 (solo reloj)
--
-- Escalado: se utilizan los genericos del DUT para escalar los tics de 125 ms y 1 ms
-- del timer, asi como el numero de tics de 5 ms que cuenta el controlador de teclado para los dos segundos
--
-- PLL: para incrementar la velocidad de la simulacion se debe instanciar la arquitectura
-- sim del PLL (en lugar de syn)
--
--    Designer: DTE
--    Versión: 1.1
--    Fecha: 14-03-2019 

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

library modelsim_lib; -- spies
use modelsim_lib.util.all; 

use work.pack_test_teclado.all;
use work.pack_test_reloj.all;
use work.pack_agente_slave_i2c.all;

entity test_top is
end entity;

architecture test of test_top is

-- Segnales del DUT

  signal clk:              std_logic;
  signal nRst:             std_logic;
  signal columna:          std_logic_vector(3 downto 0);
  signal fila:             std_logic_vector(3 downto 0);
  signal SDA:              std_logic;
  signal SCL:              std_logic;
  signal mux_disp:         std_logic_vector(7 downto 0);
  signal disp:             std_logic_vector(7 downto 0);
  
  -- Segnales para el esclavo I2C
 
  signal transfer_i2c:     t_transfer_i2c;
  signal put_transfer_i2c: std_logic;

 -- Spies para dar visibilidad a nodos internos del reloj
 -- que son entradas de los procedimientos para programar el reloj
  
  signal horas:            std_logic_vector(7 downto 0);
  signal minutos:          std_logic_vector(7 downto 0);
  signal AM_PM:            std_logic;
  signal pulso_largo:      std_logic;

 -- Spies para dar visibilidad a nodos internos del reloj
 -- que son entradas de los procedimientos para monitorizar el reloj

  signal tic_1s:         std_logic;
  signal tic_025s:       std_logic;
  signal tecla_pulsada:  std_logic;
  signal tecla:          std_logic_vector(3 downto 0);
  signal modo_rel:       std_logic;
  signal info_rel:       std_logic_vector(1 downto 0);
  signal segundos:       std_logic_vector(7 downto 0);

 -- Constantes

  constant Tclk:           time := 20 ns; -- reloj de 50 MHz
  constant add_i2c:        std_logic_vector(6 downto 0) := "1000000"; -- direccion del esclavo I2C

-- Reloj de 100 MHz (para los monitores; es el mismo que genera el PLL)
  
  signal clk_100:          std_logic;
  
  begin

  -- Reloj de 50 MHz

  process
  begin
    clk <= '0';
    wait for Tclk/2;
    clk <= '1';
    wait for Tclk/2;
  end process;
 
  -- Reloj de 100 MHz (para los monitores)

  process
  begin
    clk_100 <= '1';
    wait for Tclk/4;
    clk_100 <= '0';
    wait for Tclk/4;
  end process;

  -- MEDTH

  dut: entity work.MEDTH(struct)
       generic map(DIV_125ms   => 2,   -- 1:25/3
                   DIV_1ms     => 99,  -- 1:1000
                   TICS_2s     => 48,  -- 48 tics de 5 ms para 2 tics de 1 s
		   PLL_ARCH    => "sim"-- version PLL para simulacion
                   )
       port map(clk           => clk,
                nRst          => nRst,
                columna       => columna,
                fila          => fila,
                SDA           => SDA,
                SCL           => SCL,
                mux_disp      => mux_disp,
                seg           => disp
                );

  -- Pull-ups para la interfaz I2C

  SDA <= 'H';  
  SCL <= 'H'; 

  codigo_autoverificacion_reloj: 
   entity work.test_monitor_reloj(test)
   port map(clk         => clk_100,
	    nRst        => nRst,
            tic_025s    => tic_025s,
            tic_1s      => tic_1s,
            ena_cmd     => tecla_pulsada,
            cmd_tecla   => tecla,
            pulso_largo => pulso_largo,
            modo        => modo_rel,
            segundos    => segundos,
            minutos     => minutos,
            horas       => horas,
            AM_PM       => AM_PM,
            info        => info_rel);

  
  -- Esclavo I2C

  esclavo_I2C: entity work.agente_slave_i2c(sim_struct)
    generic map(config_item => (slave_id => hdc_1000, add => add_i2c)) 
    port map(nRst           => nRst,
           SCL              => SCL,
           SDA              => SDA,
           transfer_i2c     => transfer_i2c,
           put_transfer_i2c => put_transfer_i2c); 
  
-- Secuencia de estimulos

  process
  begin
    -- Inicializacion de los spies para programar el reloj
    init_signal_spy("/test_top/dut/horas", "/horas");
    init_signal_spy("/test_top/dut/minutos", "/minutos");
    init_signal_spy("/test_top/dut/AM_PM", "/AM_PM");
    init_signal_spy("/test_top/dut/pulso_largo", "/pulso_largo");
    -- Inicializacion de los spies para la monitorizacion del reloj
    init_signal_spy("/test_top/dut/tic_025s", "/tic_025s");
    init_signal_spy("/test_top/dut/tic_1s", "/tic_1s");
    init_signal_spy("/test_top/dut/tecla_pulsada", "/tecla_pulsada");
    init_signal_spy("/test_top/dut/tecla", "/tecla");
    init_signal_spy("/test_top/dut/modo_rel", "/modo_rel");
    init_signal_spy("/test_top/dut/info_rel", "/info_rel");
    init_signal_spy("/test_top/dut/segundos", "/segundos");
	
	
    -- Reset
    wait until clk'event and clk = '1';
    wait until clk'event and clk = '1';
    nRst <= '1';
    wait until clk'event and clk = '1';
    wait until clk'event and clk = '1';
    nRst <= '0';
    wait until clk'event and clk = '1';
    wait until clk'event and clk = '1';
    columna <= (others => '1');
    wait until clk'event and clk = '1';
    wait until clk'event and clk = '1';
    nRst <= '1';
    -- Fin de reset
    wait for 10*Tclk;
    wait until clk'event and clk = '1';
    -- Funcionamiento por defecto: los displays muestran el reloj (modo 0)

    wait for 500 us;
    wait until clk'event and clk = '1';

    -- Programacion del reloj (08 hs 09 min PM)
    entrar_modo_prog(columna, fila,  clk, 5);
    programar_hora_inc_corto(columna, fila, horas, minutos, AM_PM, clk, '1', X"08"& X"09");   
    fin_prog(columna, fila, clk);

    wait for 500 us;
    wait until clk'event and clk = '1';

    cambiar_modo_12_24(columna, fila, clk);
	
    wait for 500 us;
    wait until clk'event and clk = '1';

    -- Programacion del reloj (05 hs 20 min AM)
    entrar_modo_prog(columna, fila,  clk, 5);
    programar_hora_inc_largo(pulso_largo, columna, fila, horas, minutos, clk, X"05"& X"20");   
    fin_prog(columna, fila, clk);
	
    wait for 500 us;
    wait until clk'event and clk = '1';

    -- Programacion del reloj (11 hs 59 min AM)
    entrar_modo_prog(columna, fila,  clk, 5);
    programar_hora_directa(columna, fila, clk, X"11"& X"59");   
    time_out(clk);

    cambiar_modo_12_24(columna, fila, clk);
	
    wait for 200 us;
    wait until clk'event and clk = '1';
    -- Los displays muestran la temperatura (modo 1)
    pulsa_tecla(columna, clk, fila, X"E", pulsacion_corta);
    wait for 200 us;
    wait until clk'event and clk = '1';
    -- Los displays muestran la humedad relativa (modo 2)
    pulsa_tecla(columna, clk, fila, X"E", pulsacion_corta);
    wait for 200 us;
    wait until clk'event and clk = '1';
    -- Los displays muestran todo (modo 3)
    pulsa_tecla(columna, clk, fila, X"E", pulsacion_corta);
    wait for 6 ms;
    wait until clk'event and clk = '1';
    -- Vuelve al modo por defecto (solo reloj)
    pulsa_tecla(columna, clk, fila, X"E", pulsacion_corta);
	
    wait for 200 us;
    wait until clk'event and clk = '1';
	
    -- Fin del test
    assert false
    report "fin del test de MEDTH"
    severity failure;

  end process;
end test;
