library ieee;
      use ieee.std_logic_1164.all;
      use ieee.numeric_std.all;

      entity hearing_test_controller is
          generic (
              CLK_FREQ_HZ     : integer := 24_576_000;
              RAMP_TIME_S     : integer := 10;
              NUM_FREQUENCIES : integer := 10
          );
          port (
              i_clk         : in  std_logic;
              i_reset_n     : in  std_logic;
              i_pulse_short : in  std_logic;
              i_pulse_long  : in  std_logic;
              
              o_fcw_addr    : out std_logic_vector(3 downto 0); -- Geht direkt an BRAM addra
              o_volume      : out std_logic_vector(15 downto 0); -- Geht an Multiplier IP
              o_is_running  : out std_logic                      -- Status-LED
          );
      end entity hearing_test_controller;


architecture hearing of hearing_test_controller is
    constant TICKS_PER_STEP : positive := (CLK_FREQ_HZ * RAMP_TIME_S) / 65536;
    signal clk_cnt : natural range 0 to TICKS_PER_STEP - 1;
    signal fcw_addr : unsigned(o_fcw_addr'range);
    signal volume : unsigned(o_volume'range);
    signal is_running : std_logic;
begin
    o_fcw_addr <= std_logic_vector(fcw_addr);
    o_volume <= std_logic_vector(volume);
    o_is_running <= is_running;

    process(i_clk, i_reset_n)
    begin
        if i_reset_n = '0' then
            fcw_addr <= (others => '0');
            volume <= (others => '0');
            is_running <= '0';
            clk_cnt <= 0;
        elsif rising_edge(i_clk) then
            if i_pulse_long = '1' and i_pulse_short = '0' then
                is_running <= '0';
                volume <= (others => '0');
                clk_cnt <= 0;
                if fcw_addr = NUM_FREQUENCIES - 1 then
                    fcw_addr <= (others => '0');
                else
                    fcw_addr <= fcw_addr + 1;
                end if;
            elsif i_pulse_short = '1' and i_pulse_long = '0' then
                clk_cnt <= 0;
                is_running <= not is_running;
            elsif is_running = '1' then
                if clk_cnt = TICKS_PER_STEP - 1 then
                    clk_cnt <= 0;
                    if volume = x"FFFF" then
                        is_running <= '0';
                    else
                        volume <= volume + 1;
                    end if;
                else
                    clk_cnt <= clk_cnt + 1;
                end if;
            end if;
        end if;
    end process;
end architecture;
