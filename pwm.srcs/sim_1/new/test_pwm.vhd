----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date: 02/22/2022 06:01:09 PM
-- Design Name: 
-- Module Name: test_pwm - Behavioral
-- Project Name: 
-- Target Devices: 
-- Tool Versions: 
-- Description: 
-- 
-- Dependencies: 
-- 
-- Revision:
-- Revision 0.01 - File Created
-- Additional Comments:
-- 
----------------------------------------------------------------------------------


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity test_pwm is
--  Port ( );
end test_pwm;

architecture Behavioral of test_pwm is

component pwm is
    Port ( ck : in STD_LOGIC; -- system clock 100MHz
           duty_set : in STD_LOGIC_VECTOR (7 downto 0); -- presettable duty cycle (0...255)/256, lower switches
           Nfckpwm_set : in STD_LOGIC_VECTOR (7 downto 0); -- upper 8 switches 
           -- pwm clock division ratio (1...255) (fpwm=fck/(256*(Nfckpwm_set+1)), Nfckwpm_set>0
           pwm_out : out STD_LOGIC_VECTOR (0 downto 0); -- pwm output signal, declare 1-bit vector for monitoring with ILA
           led : out STD_LOGIC); -- LED PWM output signal
end component;

signal ck,led : std_logic;
signal pwm_out : std_logic_vector(0 downto 0);
signal duty_set,Nfckpwm_set : std_logic_vector(7 downto 0);


begin
gen_ck: process
begin
    ck<='0'; wait for 5 ns;
    ck<='1'; wait for 5 ns;
end process;

gen_Npre: process
begin
    Nfckpwm_set<="00100110"; wait for 3060us; -- set 38 -> fpwm=10kHz
    Nfckpwm_set<="00000111"; wait for 3060us; -- set 7 -> fpwm=50kHz
end process;

gen_duty: process
begin
    duty_set<="01010100"; wait for 1530us; -- set 33% --> 84 out of 256
    duty_set<="10011010"; wait for 1530us; -- set 60% --> 154 out of 256 
end process;

dut: pwm port map(ck=>ck,
                    duty_set=>duty_set,
                    Nfckpwm_set=>Nfckpwm_set,
                    pwm_out=>pwm_out,
                    led=>led);
end Behavioral;
