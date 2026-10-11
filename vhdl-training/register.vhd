library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;


entity register_32bit is
    port(

    data_in : in std_logic_vector(31 downto 0);
    clk : in std_logic;
    reset : in std_logic;
    data_out : out std_logic_vector(31 downto 0)

    );
end entity register_32bit;



architecture behavioral of register_32bit is
begin
    process(clk, reset)
begin
    if reset = '0' then
        data_out <= (others => '0');
    elsif rising_edge(clk) then
        data_out <= data_in;
    end if;
end process;
end behavioral;
