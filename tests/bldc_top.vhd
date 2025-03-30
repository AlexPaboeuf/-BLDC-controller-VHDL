--------------------------------------------------------------------------------
-- bldc_top.vhd
-- Auteurs       : PESCAY Maxime, PABOEUF Alexandre
-- Date         : 28/03/2025
--
-- Description :
--   Module top qui instancie :
--     - ramp_controller pour obtenir un duty cycle progressif (ramped_duty)
--     - pwm_generator pour générer le signal PWM (pwm_signal)
--     - sequencer pour distribuer ce PWM aux phases A, B, C en fonction de hall_code
--
-- Ports externes :
--   - clk, reset_n
--   - hall_code        (position rotor en 3 bits)
--   - target_duty_in   (valeur de consigne souhaitée : 0..MAX_CPT)
--   - A_H, A_L, B_H, B_L, C_H, C_L (commandes finales)
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity bldc_top is
  generic(
    MAX_CPT         : integer := 20000;
    RAMP_INC_PERIOD : integer := 500
  );
  port(
    clk           : in  std_logic;
    reset_n       : in  std_logic;
    hall_code     : in  std_logic_vector(2 downto 0);
    target_duty_in: in  integer range 0 to MAX_CPT;

    A_H : out std_logic;
    A_L : out std_logic;
    B_H : out std_logic;
    B_L : out std_logic;
    C_H : out std_logic;
    C_L : out std_logic
  );
end bldc_top;

architecture Structural of bldc_top is

  -- Signaux internes
  signal ramped_duty : integer range 0 to MAX_CPT := 0;
  signal pwm_signal  : std_logic;

begin

  ------------------------------------------------------------------------------
  -- Instanciation du ramp_controller
  ------------------------------------------------------------------------------
  u_ramp_controller : entity work.ramp_controller
    generic map(
      MAX_CPT         => MAX_CPT,
      RAMP_INC_PERIOD => RAMP_INC_PERIOD
    )
    port map(
      clk               => clk,
      reset_n           => reset_n,
      target_duty_cycle => target_duty_in,
      ramped_duty_cycle => ramped_duty
    );

  ------------------------------------------------------------------------------
  -- Instanciation du pwm_generator
  ------------------------------------------------------------------------------
  u_pwm_generator : entity work.pwm_generator
    generic map(
      MAX_CPT => MAX_CPT
    )
    port map(
      clk        => clk,
      reset_n    => reset_n,
      duty_cycle => ramped_duty,
      pwm_out    => pwm_signal
    );

  ------------------------------------------------------------------------------
  -- Instanciation du sequencer
  ------------------------------------------------------------------------------
  u_sequencer : entity work.sequencer
    port map(
      clk       => clk,
      reset_n   => reset_n,
      hall_code => hall_code,
      pwm_in    => pwm_signal,
      A_H       => A_H,
      A_L       => A_L,
      B_H       => B_H,
      B_L       => B_L,
      C_H       => C_H,
      C_L       => C_L
    );

end Structural;
