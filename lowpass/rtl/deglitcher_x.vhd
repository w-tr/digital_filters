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
-- Description : This deglitch circuit uses a bitwise NOR and AND reduction on a 
--             : shift register to check stability for a period of sr length.
--             : This acts as a low pass filter
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
library ieee;
use ieee.std_logic_1164.all;

entity deglitcher_x is
    generic
    (
        sr_length : integer
    );
    port
    (
        clk      :  in std_logic;
        rst      :  in std_logic;
        sig_in   :  in std_logic;
        sig_out  :  out std_logic
    );
end entity deglitcher_x;

architecture rtl of deglitcher_x is

    signal sr : std_logic_vector(sr_length-1 downto 0);
    signal sig_0 : std_logic_vector(1 downto 0);
    signal sig_1 : std_logic_vector(1 downto 0);

begin

    sr_proc : process(clk) is
        variable sig_1_re : boolean;
        variable sig_0_re : boolean;
    begin

        if rising_edge(clk) then
            if rst then
                sr       <= (others => '0');
                sig_1    <= (others => '0');
                sig_0    <= (others => '0');
                sig_out  <= '0';
                sig_1_re := false;
                sig_0_re := true;
            else
                sr    <= sr(sr_length-2 downto 0) & sig_in;
                sig_1 <= sig_1(0) & (AND (sr));
                sig_0 <= sig_0(0) & (NOR(sr));
                sig_1_re := sig_1(1) ='0' AND sig_1(0)='1';
                sig_0_re := sig_0(1) ='0' AND sig_0(0)='1';
                if sig_1_re then
                    sig_out <= '1';
                elsif sig_0_re then
                    sig_out <= '0';
                end if;
            end if;
        end if;
    end process;

end architecture;
