library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity i2s_transmitter is
    port (
        rst : in std_logic;
        bclk : in std_logic;
        lrclk : in std_logic;
        data_left : in signed(15 downto 0);
        data_right : in signed(15 downto 0);
        sdata : out std_logic
    );
end entity i2s_transmitter;

architecture behavioral of i2s_transmitter is
    signal daten_LR : std_logic_vector(31 downto 0);
    signal lrclk_d : std_logic;
    signal cnt : unsigned(4 downto 0);
begin
    process(bclk)
    begin
        if falling_edge(bclk) then
            if rst = '0' then
                daten_LR <= (others => '0');
                cnt <= (others => '0');
                lrclk_d <= '0';
                sdata <= '0';
            else
                lrclk_d <= lrclk;

                if lrclk_d /= lrclk then
                    cnt <= (others => '0');

                    if lrclk = '0' then
                        daten_LR <= std_logic_vector(data_left) & x"0000";
                    else
                        daten_LR <= std_logic_vector(data_right) & x"0000";
                    end if;
                else
                    sdata <= daten_LR(31);
                    daten_LR <= daten_LR(30 downto 0) & '0';

                    if cnt < 31 then
                        cnt <= cnt + 1;
                    end if;
                end if;
            end if;
        end if;
    end process;
end architecture behavioral;
