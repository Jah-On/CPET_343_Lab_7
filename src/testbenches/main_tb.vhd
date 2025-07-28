library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity main is
end entity main;

architecture stim of main is
    component tlde is
        port (
            reset, clk              : in  std_logic;
            op                      : in  std_logic_vector(1 downto 0);
            number                  : in  std_logic_vector(7 downto 0);
            exec, mr, ms            : in  std_logic;
            hex0, hex1, hex2        : out std_logic_vector(6 downto 0);
            state                   : out std_logic_vector(2 downto 0)
        );
    end component tlde;

    type ssd_arr_t     is array (2 downto 0) of std_logic_vector(6 downto 0);
    type ssd_res_arr_t is array (natural range<>) of ssd_arr_t;

    constant CYCLE_INTERVAL : time := 10ns;

    constant DSP_VALS    : ssd_res_arr_t := (
        ("1000000", "1000000", "1000000"),
        ("1000000", "1000000", "0011001"),
        ("1000000", "0110000", "0100100"),
        ("1000000", "0100100", "0011001"),
        ("1000000", "1111001", "0100100"),
        ("1000000", "0110000", "0100100"),
        ("1000000", "1111001", "0000010")
    );

    signal done                         : std_logic                    := '0';

    signal reset                        : std_logic                    := '0';
    signal clk, exec, mr, ms            : std_logic                    := '1';
    signal op                           : std_logic_vector(1 downto 0) := "00";
    signal number                       : std_logic_vector(7 downto 0) := "00000000";
    signal state                        : std_logic_vector(2 downto 0) := "000";
    signal hex_out                      : ssd_arr_t;

    procedure DelayClocks(Cycles : integer := 1) is
    begin
        for iter in 0 to (Cycles - 1) loop
            wait until rising_edge(clk);
        end loop;
    end procedure;

    procedure CheckDisplay(Row : integer) is
    begin
        for dsp_index in 2 downto 0 loop
            assert hex_out(dsp_index) = DSP_VALS(Row)(dsp_index) 
                report integer'image(Row) & ": Hex " & integer'image(dsp_index) & " does not match expected value!" 
                    severity error;
        end loop;
    end procedure;
begin
    gen_clock: process
    begin
        while done /= '1' loop 
            clk <= not clk;
            
            wait for CYCLE_INTERVAL;
        end loop;

        wait;
    end process gen_clock;

    main: process
    begin
        DelayClocks(10);
        reset  <= '1';

        DelayClocks(10);

        CheckDisplay(0);

        DelayClocks(1);

        number <= "00000100";
        exec   <= '1';

        DelayClocks(4);
        exec   <= '0';

        DelayClocks(10);
        CheckDisplay(1);

        DelayClocks(4);

        number <= "00001000";
        op     <= "10";
        exec   <= '1';

        DelayClocks(4);
        exec   <= '0';

        DelayClocks(10);
        CheckDisplay(2);

        ms     <= '1';
        DelayClocks(4);
        ms     <= '0';
        DelayClocks(10);

        op     <= "01";
        exec   <= '1';

        DelayClocks(4);
        exec   <= '0';

        DelayClocks(10);
        CheckDisplay(3);

        number <= "00000010";
        op     <= "11";
        exec   <= '1';

        DelayClocks(4);
        exec   <= '0';

        DelayClocks(10);
        CheckDisplay(4);

        mr     <= '1';
        DelayClocks(4);
        mr     <= '0';
        DelayClocks(4);

        DelayClocks(10);
        CheckDisplay(5);

        exec   <= '1';

        DelayClocks(4);
        exec   <= '0';

        DelayClocks(10);
        CheckDisplay(6);

        done   <= '1';

        wait;
    end process main;

    uut : tlde
        port map (
            reset     => reset,
            clk       => clk,
            op        => op,
            number    => number,
            exec      => exec,
            mr        => mr,
            ms        => ms,
            hex2      => hex_out(2),
            hex1      => hex_out(1),
            hex0      => hex_out(0),
            state     => state
        );
end architecture stim;