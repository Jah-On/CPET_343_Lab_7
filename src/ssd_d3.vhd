/* 

Author: John Schulz
Date:   06/26/2025

SSD comversion entity for lab 6.

*/
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ssd_d3 is
    generic (
        num_bits : integer := 9
    );
    port (
        reset                : in  std_logic;
        val                  : in  std_logic_vector((num_bits - 1) downto 0);
        ones, tens, hundreds : out std_logic_vector(6 downto 0)
    );
end entity ssd_d3;

architecture display of ssd_d3 is
    type hex_arr_t is array (0 to 9) of std_logic_vector(6 downto 0);

    constant BCD_SSD_MAP : hex_arr_t := ( 
        "1000000", "1111001", "0100100", "0110000", "0011001", 
        "0010010", "0000010", "1111000", "0000000", "0011000"
    );

    constant BLANK : std_logic_vector(6 downto 0) := "1111111";
begin
    convert: process(reset, val)
        variable as_int : integer;
    begin
        if reset = '1' then
            ones     <= BLANK;
            tens     <= BLANK;
            hundreds <= BLANK;
        else
            as_int := to_integer(unsigned(val));

            ones     <= BCD_SSD_MAP(as_int mod 10);
            tens     <= BCD_SSD_MAP((as_int / 10) mod 10);
            hundreds <= BCD_SSD_MAP(as_int / 100);
        end if;
    end process convert;
end architecture display;