library ieee;
      use ieee.std_logic_1164.all;
      use ieee.numeric_std.all;

      entity button_duration_detector is
          generic (
              CLK_FREQ_HZ : integer := 24_576_000
          );
          port (
              i_clk         : in  std_logic;
              i_reset_n     : in  std_logic;
              i_switch      : in  std_logic; -- Entprelltes Tastersignal
              o_pulse_short : out std_logic; -- 1 Takt Impuls: Druck < 1 s
              o_pulse_long  : out std_logic  -- 1 Takt Impuls: Druck >= 1 s
          );
      end entity button_duration_detector;

architecture stuff of button_duration_detector is
    constant ONE_SEC_TICKS : integer := CLK_FREQ_HZ;
    signal btn_prev : std_logic := '0';
    signal counter :natural := 0;
    signal long_triggered : std_logic := '0';
begin
    process(i_clk, i_reset_n)
        begin

           
           
            if i_reset_n = '0' then
                o_pulse_short <= '0';
                o_pulse_long <= '0';
                counter <= 0;
                long_triggered <= '0';
                btn_prev <= '0';

              


            elsif rising_edge(i_clk ) then
                o_pulse_short <= '0';
                o_pulse_long  <= '0';
      

                if i_switch= '1' then
                    counter <= counter + 1;


                elsif counter = ONE_SEC_TICKS and i_switch = '1' and btn_prev = '1' then     -- nach 60s einen puls von btn_prev senden
                 
                    long_triggered <= '1';
                    o_pulse_long<= '1';
                  

                elsif counter < ONE_SEC_TICKS  and i_switch = '1' and btn_prev = '1' and long_triggered /= '1'  then
                 
                    o_pulse_short <= '1';
                    counter <= 0;

                elsif i_switch = '0' then
                    counter <= 0;
                    long_triggered <= '0';


                end if;
                
                btn_prev <= i_switch;
            end if;


    end process;

end architecture;


                
