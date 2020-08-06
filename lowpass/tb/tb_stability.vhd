--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
--   ____ ___   __    _               
--  / __// o |,'_/  .' \              
-- / _/ / _,'/ /_n / o /   _   __  _    ___  _   _  __
--/_/  /_/   |__,'/_n_/   / \,' /.' \ ,' _/,' \ / |/ /
--                       / \,' // o /_\ `./ o // || / 
--                      /_/ /_//_n_//___,'|_,'/_/|_/ 
-- 
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
-- Author      : Wesley Taylor-Rendal (WTR)
-- Syntax      : VHDL-2008
-- Description : This testbench toggles the value of a signal rapidly. The
--             : units under test are not suppose to let the input signal value
--             : pass through until it's reached a stable state for a defined 
--             : duration.
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
library ieee;
use ieee.std_logic_1164.all;
library digital_filter;

entity tb_stability is
    end entity;

architecture tb of tb_stability is

    constant w                :  integer   := 5;
    constant c_stable_length  :  integer   := 16;
    signal clk                :  std_logic := '0';
    signal rst                :  std_logic;
    signal trigger            :  std_logic;
    signal trigger2           :  std_logic;
    signal trigger_n          :  std_logic;
    signal stable_length      :  std_logic_vector(w-1 downto 0);
    signal ack_btn            :  std_logic;
    signal ack_btn_up         :  std_logic;
    signal ack_btn_down       :  std_logic;
    signal ack_trig           :  std_logic;
    signal xor_deglitch       :  std_logic;
    signal out_sr_1           :  std_logic;
    signal out_sr_0           :  std_logic;
    signal out_sr_x           :  std_logic;

begin

    rst <= '1','0' after 1 us;
    clk <= not clk after 5 ns;

    uut_cnt_fsm : entity digital_filter.debouncer_fsm
    generic map
    (
        w => w
    )
    port map
    (
        clk              => clk,
        rst              => rst,
        btn_press        => trigger,
        stable_length    => stable_length,
        ack_press        => ack_btn,
        ack_press_edge   => ack_btn_up,
        ack_depress_edge => ack_btn_down
    );

    uut_cnt_xor : entity digital_filter.debouncer_xor
    generic map
    (
        stable_time => c_stable_length
    )
    port map
    (
        clk      => clk,
        rst      => rst,
        trig     => trigger,
        ack_trig => ack_trig
    );

    uut_sr_1 : entity digital_filter.deglitcher_1
    generic map
    (
        sr_length => c_stable_length
    )
    port map
    (
        clk     => clk,
        rst     => rst,
        sig_in  => trigger,
        sig_out => out_sr_1
    );

    uut_sr_0 : entity digital_filter.deglitcher_0
    generic map
    (
        sr_length => c_stable_length
    )
    port map
    (
        clk     => clk,
        rst     => rst,
        sig_in  => trigger,
        sig_out => out_sr_0
    );


    uut_sr_x : entity digital_filter.deglitcher_x
    generic map
    (
        sr_length => c_stable_length
    )
    port map
    (
        clk     => clk,
        rst     => rst,
        sig_in  => trigger,
        sig_out => out_sr_x
    );


    -- TODO
    -- bit horrible the way i toggle the trigger/input signal
    -- might be more elegant to have a procedure call
    stim : process
    begin
        stable_length <= 5D"16";
        trigger <= '0';
        wait until rst <= '0';
        for i in 1 to 100 loop
            wait until rising_edge(clk);
        end loop;
        report "Test for false rise";
        trigger <= '1';
        for i in 1 to 5 loop
            wait until rising_edge(clk);
        end loop;
        trigger <= '0';
        for i in 1 to 100 loop
            wait until rising_edge(clk);
        end loop;
        report "Test for true rise";
        trigger <= '1';
        for i in 1 to 80 loop
            wait until rising_edge(clk);
        end loop;
        report "Test for false fall";
        trigger <= '0';
        for i in 1 to 5 loop
            wait until rising_edge(clk);
        end loop;
        trigger <= '1';
        for i in 1 to 100 loop
            wait until rising_edge(clk);
        end loop;
        report "Test for true fall";
        trigger <= '0';
        for i in 1 to 80 loop
            wait until rising_edge(clk);
        end loop;

        report "REPEAT";
        report "Test for false rise";
        trigger <= '1';
        for i in 1 to 5 loop
            wait until rising_edge(clk);
        end loop;
        trigger <= '0';
        for i in 1 to 100 loop
            wait until rising_edge(clk);
        end loop;
        report "Test for true rise";
        trigger <= '1';
        for i in 1 to 80 loop
            wait until rising_edge(clk);
        end loop;
        report "Test for false fall";
        trigger <= '0';
        for i in 1 to 5 loop
            wait until rising_edge(clk);
        end loop;
        trigger <= '1';
        for i in 1 to 100 loop
            wait until rising_edge(clk);
        end loop;
        report "Test for true fall";
        trigger <= '0';
        for i in 1 to 80 loop
            wait until rising_edge(clk);
        end loop;

        report "END OF SIM" severity Failure;
    end process;

end architecture;
