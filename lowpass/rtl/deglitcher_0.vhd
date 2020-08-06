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
-- Description : This deglitch circuit uses a bitwise NOR reduction on a shift
--             : register to check stability for a period of sr length.
--             : This acts as a low pass filter against logic 0 glitchs, however
--             : it lets through high freq '1' glitchs.
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
library ieee;
use ieee.std_logic_1164.all;

entity deglitcher_0 is
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
end entity deglitcher_0;

architecture rtl of deglitcher_0 is

    signal sr : std_logic_vector(sr_length-1 downto 0);

begin

    sr_proc : process(clk) is
    begin

        if rising_edge(clk) then
            if rst then
                sr      <= (others => '0');
                sig_out <= '0';
            else
                sr      <= sr(sr_length-2 downto 0) & sig_in;
                sig_out <= NOR (sr);
            end if;
        end if;
    end process;

end architecture;
