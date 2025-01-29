library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity master_spi_4_hilos is
port(nRst:     in     std_logic;
     clk:      in     std_logic;                       -- 50 MHz
     -- Ctrl_SPI
     start:    in     std_logic;                       -- Orden de ejecucion (si rdy = 1 ) => rdy  <= 0 hasta fin, cuando rdy <= 1
     nWR_RD:   in     std_logic;                       -- Escritura (0) o lectura (1)
     dir_reg:  in     std_logic_vector(6 downto 0);    -- direccion de acceso; si bit 7 a 1 (autoincremento) y RD, se considera el valor de long
     dato_wr:  in     std_logic_vector(7 downto 0);    -- dato a escribir (solo escrituras de 1 bit
     dato_rd:  buffer std_logic_vector(7 downto 0);    -- valor del byte leido
     ena_rd:   buffer std_logic;                       -- valida a nivel alto a dato_rd -> Ignorar en operacion de escritura
     rdy:      buffer std_logic;                       -- unidad preparada para aceptar start
     -- bus SPI
     nCS:      buffer std_logic;                       -- chip select
     SPC:      buffer std_logic;                       -- clock SPI
     SDI:      in     std_logic;                       -- Master Data input (connected to slave SDO)
     SDO:      buffer std_logic);                      -- Master Data Output (connected to slave SDI)
     
end entity;

architecture rtl of master_spi_4_hilos is
 --Reloj del bus
 signal cnt_SPC:      std_logic_vector(2 downto 0);
 signal fdc_cnt_SPC:  std_logic;
 signal SPC_posedge:  std_logic;
 signal SPC_negedge:  std_logic;

 constant SPC_LH: natural := 5; -- 50MHz(reloj sistema)/10MHz(frec. SPC) = 5
 
 -- Contador de bits y bytes transmitidos
 signal cnt_bits_SPC: std_logic_vector(5 downto 0);

 -- Sincro SDI y Registro de transmision y recepcion
 signal SDI_meta, SDI_syn: std_logic;
 signal reg_SPI: std_logic_vector(16 downto 0);

 -- Para el control
 signal no_bytes: std_logic_vector(2 downto 0);
 signal fin: std_logic;

begin
  -- Generacion de nCS:
  process(nRst, clk)
  begin
    if nRst = '0' then
      nCS <= '1';

    elsif clk'event and clk = '1' then
      if start = '1' and nCS = '1' then
        nCS <= '0';

      elsif fin = '1' then
        nCS <= '1';

      end if;
    end if;
  end process;
  
  rdy <= nCS;

  -- Generacion de SPC:
  process(nRst, clk)
  begin
    if nRst = '0' then
      cnt_SPC <= (1 => '1', others => '0');
      SPC <= '1';

    elsif clk'event and clk = '1' then
      if nCS = '1' then 
        cnt_SPC <= (1 => '1', others => '0');
        SPC <= '1';

      elsif fdc_cnt_SPC = '1' then 
        SPC <= not SPC;
        cnt_SPC <= (0 => '1', others => '0');

      else
        cnt_SPC <= cnt_SPC + 1;

      end if;
    end if;
  end process;

  fdc_cnt_SPC <= '1' when cnt_SPC = SPC_LH else
                 '0';

  SPC_posedge <= SPC when cnt_SPC = 1 else --Cuenta pulsos a nivel alto 
                 '0'; 

  SPC_negedge <= not SPC when cnt_SPC = 1 else --Cuenta pulsos a nivel bajo
                 '0'; 

  -- Cuenta bits y bytes:
  process(nRst, clk)
  begin
    if nRst = '0' then
      cnt_bits_SPC <= (others => '0');
      
    elsif clk'event and clk = '1' then  
      if SPC_posedge = '1' then --Cuenta los niveles altos (bit y bytes)
        cnt_bits_SPC <= cnt_bits_SPC + 1;

      elsif nCS = '1' then
        cnt_bits_SPC <= (others => '0');

      end if;
    end if;
  end process;

  -- Registro de DESPLAZAMIENTO !!!! -> Cuando neg_edge = 1 -> Desplaza hacia izquierda y cuando pos_edge = 1 -> Cmbia el bit LSB por el que le llega
  -- Controla la info que llega desde el SDO slave al SDI master
  process(nRst, clk)
  begin
    if nRst = '0' then
      reg_SPI <= (others => '0');
      SDI_syn <= '0';
      SDI_meta <= '0';

    elsif clk'event and clk = '1' then  
      SDI_meta <= SDI; --Este SDI es el SDO del esclavo, por lo que se le pasa por un FF para evitar la metaestabilidad y cumplir con las reglas de diseño sincrono
      SDI_syn <= SDI_meta; -- Para que la segnal SDI no tenga metaestabilidad (el agente carrece de CLK)
      
      if start = '1' and nCS = '1' then
        reg_SPI <= '0'& nWR_RD & dir_reg & dato_wr; --Esto es el SDO del master -> Se envía al slave, dentro de dir_reg, ya esta incluido el MS y dato_wr es lo que quieres escribir en el registro
 
      elsif SPC_negedge = '1' then --Flanco de bajada, desplaza hacia izquierda el bit para enviarlo por SDO
        reg_SPI(16 downto 1) <= reg_SPI(15 downto 0); 

      elsif SPC_posedge = '1' then --Flanco de subida, escribe el bit del SDO del sensor por el LSB del registro
        reg_SPI(0) <= SDI_syn; 

      end if;
    end if;
  end process;


  --La primera condicion es para leer si o si cuando termina el tercer byte (=3) ya que en la lectura enviamos máximo dos bytes de lectura
  --sin contar con el primer byte de configuracion y necesitamos habilitar la lectura una evz finalizada la transaccion para asi poder leer
  --el ultimo byte enviado ya que tras el ultimo bit no hay flanco de bajada para la señal SPC para poder habilitar la lectura como
  --indica la siguiente condicion. La siguiente condicion habilita la lectura transcurridos 16 flancos de bajada que es el momento 
  --en el que se termina de enviar el primer bit (foto captura salva). Con la segunda sentencia habilitamos leer el primer byte en SDO y con al 
  --primera sentencia habilitamos leer el tercer byte de SDO (que le llega al amster del esclavo)
  ena_rd <= (not nCS and fin) when cnt_bits_SPC(5 downto 3) = "011"                              else  --COMPLETAR
            SPC_negedge       when cnt_bits_SPC(5 downto 3) > 1 and cnt_bits_SPC(2 downto 0) = 0 else  --COMPLETAR
            '0';

  dato_rd <= reg_SPI(7 downto 0);

  SDO <= reg_SPI(16);

  -- Control heuristico
  process(nRst, clk)
  begin
    if nRst = '0' then
      no_bytes <= (others => '0');

    elsif clk'event and clk = '1' then  
      if start = '1' and nCS = '1' then
        if nWR_RD = '0' then --Op. escritura, 1 byte + primer byte
          no_bytes <= "010";                --COMPLETAR

        else --Op. lectura, 2 bytes + primer byte
          no_bytes <= "011";                --COMPLETAR

        end if;
      end if;
    end if;
  end process;

  fin <= '1' when cnt_bits_SPC(5 downto 3) = no_bytes else  --COMPLETAR
         '0';
 
end rtl;
