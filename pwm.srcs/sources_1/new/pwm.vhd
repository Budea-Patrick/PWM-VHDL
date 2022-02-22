----------------------------------------------------------------------------------
-- Company: UTCN
-- Engineer: Budea Patrick
-- 
-- Create Date: 02/22/2022 05:20:59 PM
-- Design Name: Pulse Width Modulator
-- Module Name: pwm - Behavioral
-- Project Name: pwm
-- Target Devices: Basys 3
-- Tool Versions: Vivado 2020.1
-- Description: 
-- 
-- Dependencies: no dependencies
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pwm is
    Port ( ck : in STD_LOGIC; -- system clock 100MHz
           duty_set : in STD_LOGIC_VECTOR (7 downto 0); -- presettable duty cycle (0...255)/256, lower switches
           Nfckpwm_set : in STD_LOGIC_VECTOR (7 downto 0); -- upper 8 switches 
           -- pwm clock division ratio (1...255) (fpwm=fck/(256*(Nfckpwm_set+1)), Nfckwpm_set>0
           pwm_out : out STD_LOGIC_VECTOR (0 downto 0); -- pwm output signal, declare 1-bit vector for monitoring with ILA
           led : out STD_LOGIC); -- LED PWM output signal
end pwm;

architecture Behavioral of pwm is

component ila_0 is
    PORT (
        clk : IN STD_LOGIC;
        probe0 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe1 : IN STD_LOGIC_VECTOR(0 DOWNTO 0);
        probe2 : IN STD_LOGIC_VECTOR(7 DOWNTO 0);
        probe3 : IN STD_LOGIC_VECTOR(7 DOWNTO 0)
);
end component;

signal ckpwm : std_logic; -- divided PWM clock
signal ckpwm_vector : std_logic_vector (0 downto 0); -- 1 bit vector for feeding PWM clock into ILA probbe input
signal cntckdivPWM : integer range 0 to 255; -- clock divider/prescalar counter variable
signal cntPWM : integer range 0 to 255; -- PWM counter variable
signal Nfckpwm,duty : integer range 0 to 255; -- declar prescaler division ration and duty cycle as integers of easy handling
signal pwm_temp : std_logic_vector (0 downto 0); -- internal PWM signal needed for reading into ILA instead of OUT port


begin
-- convert division ratio and duty cycle settings to integer
Nfckpwm <= to_integer(unsigned(Nfckpwm_set));
duty <= to_integer(unsigned(duty_set));

-- PWM clock frequency divider to set PWM period/frequency
fckpwm:process (ck)
begin
    if(rising_edge(ck)) then
        -- count Nfckpwm states for clock division
        if(cntckdivPWM=Nfckpwm) then
            cntckdivPWM<=0;
            ckpwm<='1'; -- assign carry to the divided output clock
        else
            cntckdivPWM<=cntckdivPWM+1;
            ckpwm<='0';
        end if;
    end if;
end process;        

-- PWM counter with 8 bits resolution
PWMcounter: process(ckpwm)
begin
    if(rising_edge(ckpwm)) then
        if(cntPWM = 255) then --cycle end at exactly 256 states
            cntPWM<=0;
        else
            cntPWM<=cntPWM+1;
        end if;
        if(cntPWM<duty) then
            pwm_temp<="1"; -- set PWM outputs to 1 if prescirbed duty cycle not reached
            led<='1';
        else
            pwm_temp<="0"; -- if prescribed duty cycle exceeded, PWM outputs must be 0
            led<='0';
        end if;
    end if;
end process;

-- convert single clock to 1-bit vector for feeding to the appropiate ILA probe
ckpwm_vector(0)<=ckpwm;
-- connect ILA instance to the system
analyzer1 : ila_0 port map(clk=>ck,
                           probe0=>ckpwm_vector,
                           probe1=>pwm_temp,
                           probe2=>Nfckpwm_set,
                           probe3=>duty_set);
-- assign the temporary PWM variable to the actual output port
pwm_out<=pwm_temp;

end Behavioral;
