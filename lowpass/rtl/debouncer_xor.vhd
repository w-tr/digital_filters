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
-- Description : This debounce circuit uses a XOR on consecutive states and a 
--             : counter to check stability for a period determined by stable time
--             : It has the characteristics of a low pass filter.
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
library ieee;
use ieee.std_logic_1164.all;

entity debouncer_xor is
    generic
    (
        stable_time : integer := 10 -- of clock
    );
    port
    (
        clk       :  in  std_logic;
        rst       :  in  std_logic;
        trig      :  in  std_logic;
        ack_trig  :  out std_logic
    ); 
end entity debouncer_xor;

architecture rtl of debouncer_xor is

    signal ff2    :  std_logic_vector(1 downto 0);
    signal clear  :  std_logic;
    signal cnt    :  integer; -- optimisation could be made here, but i'm happy with 32 bit counter

begin

    clear <= ff2(0) xor ff2(1);  --determine when to start/reset counter

    process(clk) is
    begin
        if rising_edge(clk) then
            if rst then
                ff2      <= (others => '0');
                ack_trig <= '0';
                cnt      <= 0;
            else
                ff2 <= ff2(0) & trig;
                -- priority if
                if clear then
                    cnt <= 0;
                elsif(cnt < stable_time) then
                    cnt <= cnt + 1;
                else
                    ack_trig <= ff2(1);
                end if;    
            end if;
        end if;
    end process;

end architecture rtl;
