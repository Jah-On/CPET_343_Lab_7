/* 

Author: John Schulz
Date:   07/24/2025

Finite state machine for Lab 7.

*/
library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity fsm is
    port (
        reset, clk     : in  std_logic;
        mr, ms, exec   : in  std_logic;
        alu_in, mem_in : in  std_logic_vector(7 downto 0);
        write_mode     : out std_logic                    := '0';
        addr           : out std_logic_vector(1 downto 0) := "00";
        data_out       : out std_logic_vector(7 downto 0);
        state_out      : out std_logic_vector(2 downto 0)
    );
end entity fsm;

architecture control_flow of fsm is
    type states_t is (
        IDLE,            MS_DATA_MEMORY,  MS_ADDRESS_SAVE, 
        DATA_ALU,        MR_ADDRESS_SAVE, MR_DATA_MEMORY, 
        ADDRESS_WORKING, ENABLE_WRITE
    );

    signal current_state, next_state : states_t := IDLE;
begin
    set_next_state: process(clk, reset)
    begin
        if reset = '1' then
            next_state <= IDLE; 
        elsif rising_edge(clk) then
            case current_state is
                when IDLE            => next_state <=   MR_ADDRESS_SAVE when mr   = '1' else
                                                        DATA_ALU        when exec = '1' else
                                                        MS_DATA_MEMORY  when ms   = '1';

                -- MR path
                when MR_ADDRESS_SAVE => next_state <=   MR_DATA_MEMORY;
                when MR_DATA_MEMORY  => next_state <=   ADDRESS_WORKING;
                when ADDRESS_WORKING => next_state <=   ENABLE_WRITE;

                -- EXEC path
                when DATA_ALU        => next_state <=   ENABLE_WRITE;

                -- MS path
                when MS_DATA_MEMORY  => next_state <=   MS_ADDRESS_SAVE;
                when MS_ADDRESS_SAVE => next_state <=   ENABLE_WRITE;

                -- All paths lead to ENABLE_WRITE
                when others          => next_state <=   IDLE;
            end case;
        end if;
    end process set_next_state;
    
    update_current_state: process(next_state)
    begin
        if current_state /= next_state then
            current_state <= next_state;
        end if;
    end process update_current_state;

    update_io: process(current_state)
        variable state_as_int : integer;
    begin
        state_as_int := states_t'pos(current_state);
        state_out    <= std_logic_vector(to_unsigned(state_as_int, state_out'length));
        case current_state is
            when IDLE            => 
                write_mode <= '0';
                addr       <= "00";
            when MR_ADDRESS_SAVE => 
                addr       <= "01";
            when MR_DATA_MEMORY  => 
                data_out   <= mem_in;
            when ADDRESS_WORKING => 
                addr       <= "00";
            when DATA_ALU        =>
                data_out   <= alu_in;
            when MS_DATA_MEMORY  => 
                data_out   <= mem_in;
            when MS_ADDRESS_SAVE =>
                addr       <= "01";
            when others          => 
                write_mode <= '1';
        end case;
    end process update_io;
    
end architecture control_flow;