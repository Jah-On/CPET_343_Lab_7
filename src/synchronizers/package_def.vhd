/* 

Author: John Schulz
Date:   07/25/2025

Package delaration for synchronizers.

*/
library ieee;
use ieee.std_logic_1164.all;

package synchronizers is
    component clock_synchronizer is
        generic (
            bit_width : integer := 3
        );
        port (
            clk      : in  std_logic;
            reset    : in  std_logic;
            async_in : in  std_logic_vector(bit_width-1 downto 0);
            sync_out : out std_logic_vector(bit_width-1 downto 0)
        );
    end component clock_synchronizer;

    component rising_edge_synchronizer is 
        port (
            clk               : in  std_logic;
            reset             : in  std_logic;
            input             : in  std_logic;
            edge              : out std_logic
        );
    end component rising_edge_synchronizer;
end package synchronizers;