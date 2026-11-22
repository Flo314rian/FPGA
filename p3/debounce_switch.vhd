library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debounce_switch is
    generic (
        CLK_FREQ_HZ      : integer := 24_576_000;
        DEBOUNCE_TIME_MS : integer := 10
    );
    port (
        i_clk    : in  std_logic;
        i_switch : in  std_logic;
        o_switch : out std_logic
    );
end entity debounce_switch;

architecture debounce of debounce_switch is
    constant c_debounce_limit : integer := (CLK_FREQ_HZ / 1000) * DEBOUNCE_TIME_MS;
    signal cntr    : integer range 0 to c_debounce_limit := 0;
    signal r_state : std_logic := '0';

begin
    process(i_clk)
    begin
        if rising_edge(i_clk) then
            
            if i_switch /= r_state and cntr < c_debounce_limit then
                cntr <= cntr + 1;
            elsif cntr = c_debounce_limit then

                r_state <= i_switch;
                cntr <= 0;
            else
                cntr <= 0;
            end if;
        end if;
    end process;

    o_switch <= r_state;
end architecture debounce;

