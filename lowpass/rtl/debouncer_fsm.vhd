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
-- Description : This debounce circuit uses a state machine and a counter to 
--             : check stability for a period determined by stability length.
--             : The signal names are associated with a push button.
--             : It has the characteristics of a low pass filter.
--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity debouncer_fsm is
    generic 
    (
        w : integer
    );
    port
    (
        clk               :  in  std_logic;
        rst               :  in  std_logic;
        btn_press         :  in  std_logic;
        stable_length     :  in  std_logic_vector(w-1 downto 0);
        ack_press         :  out std_logic;
        ack_press_edge    :  out std_logic;
        ack_depress_edge  :  out std_logic
    );
end entity debouncer_fsm;


architecture rtl of debouncer_fsm is


    type btn_fsm_t is (depressed, pressed);
    signal btn_fsm         :  btn_fsm_t;
    signal press_reg       :  std_logic_vector(1 downto 0);
    signal pressed_reg     :  std_logic_vector(1 downto 0);
    signal depressed_reg   :  std_logic_vector(1 downto 0);
    signal stable_press    :  unsigned(w-1 downto 0);
    signal stable_depress  :  unsigned(w-1 downto 0);

begin

    process (clk) is

        variable is_press                :  boolean;
        variable is_depress              :  boolean;
        variable is_depressed            :  boolean;
        variable is_pressed              :  boolean;
        variable is_pressed_edge         :  boolean;
        variable is_depressed_edge       :  boolean;
        variable is_press_interrupted    :  boolean;
        variable is_depress_interrupted  :  boolean;
        variable not_yet_down            :  boolean;
        variable not_yet_up              :  boolean;

    begin
        if rising_edge(clk) then
            if rst then

                btn_fsm                <=  depressed;
                ack_press              <=  '0';
                ack_press_edge         <=  '0';
                ack_depress_edge       <=  '0';
                stable_depress         <=  (others => '0');
                stable_press           <=  (others => '0');
                press_reg              <=  (others => '0');
                pressed_reg            <=  (others => '0');
                depressed_reg          <=  (others => '1');

                is_press               :=  false;
                is_depress             :=  false;
                is_depressed           :=  true ;
                is_pressed             :=  false;
                is_pressed_edge        :=  false;
                is_depressed_edge      :=  false;
                is_press_interrupted   :=  false;
                is_depress_interrupted :=  false;

            else
                ----------------------------------------
                -- Conditional checks
                -- ~~~~~~~~~~~~~~~~~~
                -- The purpose of this is to make the if
                -- statments that follow easier to read.
                ----------------------------------------
                not_yet_down           :=  stable_depress < unsigned(stable_length);
                is_depress             :=  press_reg(1)   =  '0' and not_yet_down;
                is_depressed           :=  stable_depress =  unsigned(stable_length);
                is_depress_interrupted :=  press_reg(1)   =  '1' and is_depressed    =  false and stable_depress > 0;

                not_yet_up             :=  stable_press <  unsigned(stable_length);
                is_pressed             :=  stable_press =  unsigned(stable_length);
                is_press               :=  press_reg(1) =  '1' and not_yet_up;
                is_press_interrupted   :=  press_reg(1) =  '0' and is_pressed        =  false and stable_press > 0;

                is_pressed_edge        :=  pressed_reg(0)   =  '1' and pressed_reg(1)    =  '0';
                is_depressed_edge      :=  depressed_reg(0) =  '1' and depressed_reg(1)  =  '0';
                ----------------------------------------
                -- Shift Registers
                ----------------------------------------
                press_reg(0)     <= btn_press;
                press_reg(1)     <= press_reg(0);
                pressed_reg(1)   <= pressed_reg(0);
                depressed_reg(1) <= depressed_reg(0);

                case btn_fsm is

                    when depressed => 

                        pressed_reg(0)   <= '0';
                        depressed_reg(0) <= '1';
                        if is_press_interrupted then
                            stable_press   <= (others => '0');
                        elsif is_press then
                            stable_press   <= stable_press + 1;
                        elsif is_pressed then
                            stable_press   <= (others => '0');
                            stable_depress <= (others => '0');
                            btn_fsm        <= pressed;
                        end if;

                    when pressed => 

                        pressed_reg(0)   <= '1';
                        depressed_reg(0) <= '0';
                        if is_depress_interrupted then
                            stable_depress <= (others => '0');
                        elsif is_depress then
                            stable_depress <= stable_depress + 1;
                        -- Acknowledge when in a state.
                        elsif is_depressed then 
                            stable_press   <= (others => '0');
                            stable_depress <= (others => '0');
                            btn_fsm        <= depressed;
                        end if;

                end case;

                -- Output a clean state
                if is_pressed_edge then
                    ack_press_edge <= '1';
                    ack_press      <= '1';
                else 
                    ack_press_edge <=  '0';
                end if;
                if is_depressed_edge then
                    ack_depress_edge <= '1';
                    ack_press        <= '0';
                else 
                    ack_depress_edge <= '0';
                end if;

            end if;

        end if;

    end process;

end architecture rtl;
