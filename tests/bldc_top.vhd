--------------------------------------------------------------------------------
-- bldc_top.vhd
-- Auteurs       : PESCAY Maxime, PABOEUF Alexandre
-- Date         : 10/04/2025
--
-- Description :
--   Module top de contrôle BLDC. Il instancie les modules suivants :
--     ramp_controller pour effectuer la montée/descente progressive
--     sin_approx pour obtenir une approximation sinusoïdale (sur [0,90°])
--     pwm_generator qui génère le signal PWM à partir de la consigne
--     sequencer qui gère la commutation des phases en fonction du hall_code
--
--   La consigne effective du PWM est calculée par :
--     effective_duty = (ramped_duty * sin_value) / 1000
--
--   Les valeurs sinusoïdales utilisées sont basées sur :
--     sin(0)=0, sin(30)=0.5 (500/1000), sin(45)=0.707 (707/1000),
--     sin(60)=0.866 (866/1000), sin(90)=1 (1000/1000).
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
    clk            : in std_logic;
    reset_n        : in std_logic;
    hall_code      : in std_logic_vector(2 downto 0);
    target_duty_in : in integer range 0 to MAX_CPT;
    
    A_H            : out std_logic;
    A_L            : out std_logic;
    B_H            : out std_logic;
    B_L            : out std_logic;
    C_H            : out std_logic;
    C_L            : out std_logic
  );
end bldc_top;

architecture Structural of bldc_top is

  -- Signaux issus des modules internes
  signal ramped_duty    : integer range 0 to MAX_CPT := 0;
  signal pwm_signal     : std_logic;
  signal effective_duty : integer range 0 to MAX_CPT := 0;
  
  -- Signaux pour la fonctionnalité sinusoïdale
  signal angle      : integer range 0 to 90 := 45;     -- Angle fixé à 45° (modifiable)
  signal sin_value  : integer range 0 to 1000 := 707;    -- Approximation de sin(45°) : 707/1000

begin

  -- Instanciation du module ramp_controller
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

  -- Calcul de la consigne effective en modulant ramped_duty par sin_value
  process(ramped_duty, sin_value)
  begin
    effective_duty <= (ramped_duty * sin_value) / 1000;
  end process;

  -- Instanciation du module sin_approx qui calcule sin_value en fonction de angle
  u_sin : entity work.sin_approx
    port map(
      angle   => angle,
      sin_out => sin_value
    );
    
  -- Instanciation du module pwm_generator
  u_pwm_generator : entity work.pwm_generator
    generic map(
      MAX_CPT => MAX_CPT
    )
    port map(
      clk        => clk,
      reset_n    => reset_n,
      duty_cycle => effective_duty,
      pwm_out    => pwm_signal
    );

  -- Instanciation du module sequencer
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
