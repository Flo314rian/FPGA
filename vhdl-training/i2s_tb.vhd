library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

-- Diese Testbench verwendet deinen vorhandenen Divider und I2S-Sender.
-- Sie liest die gesendeten Bits wie ein Empfaenger zurueck.
entity i2s_tb is
end entity i2s_tb;

architecture simulation of i2s_tb is
    constant CLOCK_PERIOD : time := 1 sec / 24_576_000;
    constant LEFT_SAMPLE  : signed(15 downto 0) := to_signed(16#1234#, 16);
    constant RIGHT_SAMPLE : signed(15 downto 0) := to_signed(16#5678#, 16);

    signal clk        : std_logic := '0';
    signal rst        : std_logic := '0';
    signal bclk       : std_logic;
    signal lrclk      : std_logic;
    signal sdata      : std_logic;
    signal data_left  : signed(15 downto 0) := LEFT_SAMPLE;
    signal data_right : signed(15 downto 0) := RIGHT_SAMPLE;
begin
    -- 1. Die Testbench stellt den Basistakt bereit.
    clk <= not clk after CLOCK_PERIOD / 2;

    -- 2. Hier werden die beiden echten Schaltungen eingebunden.
    divider : entity work.clk_divider
        port map (
            rst         => rst,
            clk_24_576m  => clk,
            bclk        => bclk,
            lrclk       => lrclk
        );

    sender : entity work.i2s_transmitter
        port map (
            rst        => rst,
            bclk       => bclk,
            lrclk      => lrclk,
            data_left  => data_left,
            data_right => data_right,
            sdata      => sdata
        );

    -- 3. Bekannte Eingaben vorgeben und den Reset freigeben.
    stimulus : process
    begin
        report "Vorgegeben: LINKS = 0x1234, RECHTS = 0x5678";
        wait for 5 * CLOCK_PERIOD;
        rst <= '1';
        report "Reset freigegeben. Der Sender uebertraegt die Zahlen als einzelne Bits.";
        wait;
    end process;

    -- 4. Die Ausgabe der Schaltung unabhaengig zuruecklesen und pruefen.
    pruefung : process
        variable empfangen : std_logic_vector(15 downto 0);
        variable kanal     : std_logic;
    begin
        wait until rst = '1';

        -- Die Startphase ueberspringen: erst am Kanalwechsel beginnen.
        -- Mit deinem Divider kommt das erste vollstaendige rechte Wort zuerst.
        for wort in 1 to 2 loop
            wait until lrclk'event;
            kanal := lrclk;

            -- I2S hat nach dem Kanalwechsel ein Verzogerungsbit.
            wait until rising_edge(bclk);

            -- Die naechsten 16 Bits ergeben die gesendete Zahl, MSB zuerst.
            for bit_index in empfangen'range loop
                wait until rising_edge(bclk);
                assert sdata = '0' or sdata = '1'
                    report "Fehler: sdata enthaelt ein undefiniertes Bit."
                    severity failure;
                empfangen(bit_index) := sdata;
            end loop;

            if kanal = '0' then
                assert empfangen = std_logic_vector(LEFT_SAMPLE)
                    report "LINKS falsch: erwartet 0x1234, empfangen 0x"
                        & to_hstring(empfangen)
                    severity failure;
                report "Zurueckgelesen: LINKS = 0x" & to_hstring(empfangen) & " -> OK";
            else
                assert empfangen = std_logic_vector(RIGHT_SAMPLE)
                    report "RECHTS falsch: erwartet 0x5678, empfangen 0x"
                        & to_hstring(empfangen)
                    severity failure;
                report "Zurueckgelesen: RECHTS = 0x" & to_hstring(empfangen) & " -> OK";
            end if;
        end loop;

        report "Fertig: beide Kanaele korrekt uebertragen und automatisch geprueft.";
        std.env.stop;
        wait;
    end process;

    -- Bei einem fehlenden Takt/Kanalwechsel endet der Test mit einem Fehler.
    timeout_pruefung : process
    begin
        wait for 100 us;
        assert false report "Zeitlimit: beide Woerter wurden nicht empfangen."
            severity failure;
        wait;
    end process;
end architecture simulation;
