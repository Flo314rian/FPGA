library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;



entity  clk_divider is
    port(
        rst : in std_logic;
        clk_24_576m : in std_logic;
        bclk : out std_logic;
        lrclk : out std_logic

    );
end entity clk_divider;



architecture behavioral of clk_divider is
        signal counter_bclk : unsigned(3 downto 0);
        signal counter_lrclk : unsigned(7 downto 0);
        signal bclk_i : std_logic;
        signal lrclk_i : std_logic;
    begin

        process(clk_24_576m) is
        begin
        if rising_edge(clk_24_576m) then
            counter_bclk <= counter_bclk + 1;
            counter_lrclk <= counter_lrclk + 1;

            if rst = '0' then
                bclk_i <= '0';
                lrclk_i <= '0';
                counter_bclk <= (others => '0');
                counter_lrclk <= (others => '0');

            else
                if counter_bclk = 3 then
                    counter_bclk <= (others => '0');
                    bclk_i <= not bclk_i;
                end if;

                if counter_lrclk = 255 then
                  lrclk_i <= not lrclk_i;

                  counter_lrclk <= (others => '0');
                end if;
            end if;

        end if;
end process;

bclk <= bclk_i;
lrclk <= lrclk_i;
end behavioral;
