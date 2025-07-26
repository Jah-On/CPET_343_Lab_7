--*****************************************************************************
--***************************  VHDL Source Code  ******************************
--*****************************************************************************
--
--  DESIGNER NAME:  Bruce Link
--
--       LAB NAME:  Lab5: Clock Synchronization
--
--      FILE NAME:  clock_synchronizer.vhd
--
-------------------------------------------------------------------------------
--
--  DESCRIPTION
--    This files contains the code that will take an input as a signal 
--    and a clock reference. The signal will then be registered 2 times 
--    and sent to the output port. This file is helpful in synchronizing 
--    asynchronous inputs (ie: user inputs from switches etc.). A generic
--    is provided to allow buses to be synchronized.
--
--    All variables that end with "_n" are low active.
--
--  REVISION HISTORY
--
--  _______________________________________________________________________
-- |  DATE    | USER | Ver |  Description                                  |
-- |==========+======+=====+================================================
-- |          |      |     |
-- | 03/01/19 | BAL  | 1.0 | Created
-- |          |      |     |
--
--*****************************************************************************
--*****************************************************************************

------------------------------------------------------------------------------
-- |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
-- ||||                                                                   ||||
-- ||||                    COMPONENT DESCRIPTION                          ||||
-- ||||                                                                   ||||
-- |||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||||
------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

entity clock_synchronizer is
    generic (
        bit_width : integer := 3
    );
    port (
        clk      : in  std_logic;
        reset    : in  std_logic;
        async_in : in  std_logic_vector(bit_width-1 downto 0);
        sync_out : out std_logic_vector(bit_width-1 downto 0)
    );
end clock_synchronizer;

architecture behav of clock_synchronizer is
    signal prev_data_1 : std_logic_vector(bit_width-1 downto 0);
    signal prev_data_2 : std_logic_vector(bit_width-1 downto 0);
begin
    double_flop : process(reset, clk)
    begin
        if (reset = '1') then
            prev_data_1 <= (others => '0');
            prev_data_2 <= (others => '0');
        elsif rising_edge(clk) then
            prev_data_1 <= async_in;
            prev_data_2 <= prev_data_1;
        end if;
    end process;

    sync_out <= prev_data_2;
end behav;
