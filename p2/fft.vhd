library ieee;
      use ieee.std_logic_1164.all;
      use ieee.numeric_std.all;

      entity fft16_core is
        port (
          clk       : in std_logic; 
          rst       : in std_logic;
          in_valid  : in std_logic;
          in_re     : in std_logic;
          in_im     : in std_logic;
          out_valid : out std_logic;
          bin_idx   : 
          out_re    : out std_logic;
          out_im    : out std_logic  
        );
      end entity fft16_core;