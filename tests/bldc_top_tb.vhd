--------------------------------------------------------------------------------
-- bldc_top_tb.vhd
-- Auteurs       : PESCAY Maxime, PABOEUF Alexandre
-- Date         : 28/03/2025
-- Test bench pour valider :
--   1) ramp_controller.vhd
--   2) pwm_generator.vhd
--   3) sequencer.vhd
--   4) bldc_top.vhd
--
-- Hypothèses / Paramètres :
--   - Horloge à 1 MHz (période = 1 us)
--   - MAX_CPT = 20000 (=> PWM ~ 50 Hz)
--   - RAMP_INC_PERIOD = 500
--
-- Ce test bench :
--   - génère un clk,
--   - gère un reset_n (actif bas),
--   - fait évoluer hall_code selon les 6 pas classiques,
--   - modifie target_duty_in pour vérifier la rampe (accélération/décélération).
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity bldc_top_tb is
end bldc_top_tb;

architecture TB of bldc_top_tb is

  ------------------------------------------------------------------------------
  -- Paramètres fixés pour la simulation (mêmes valeurs que dans bldc_top)
  ------------------------------------------------------------------------------
  constant c_MAX_CPT         : integer := 20000;
  constant c_RAMP_INC_PERIOD : integer := 500;

  ------------------------------------------------------------------------------
  -- Signaux de test
  ------------------------------------------------------------------------------
  signal clk           : std_logic := '0';
  signal reset_n       : std_logic := '0';
  signal hall_code     : std_logic_vector(2 downto 0) := (others => '0');
  signal target_duty_in: integer range 0 to c_MAX_CPT := 0;

  -- Sorties du top
  signal A_H, A_L, B_H, B_L, C_H, C_L : std_logic;

  ------------------------------------------------------------------------------
  -- Instanciation du "bldc_top"
  ------------------------------------------------------------------------------
  component bldc_top
    generic(
      MAX_CPT         : integer := 20000;
      RAMP_INC_PERIOD : integer := 500
    );
    port(
      clk            : in  std_logic;
      reset_n        : in  std_logic;
      hall_code      : in  std_logic_vector(2 downto 0);
      target_duty_in : in  integer range 0 to MAX_CPT;

      A_H : out std_logic;
      A_L : out std_logic;
      B_H : out std_logic;
      B_L : out std_logic;
      C_H : out std_logic;
      C_L : out std_logic
    );
  end component;

begin

  ----------------------------------------------------------------------------
  -- UUT : "Unit Under Test"
  ----------------------------------------------------------------------------
  UUT: bldc_top
    generic map(
      MAX_CPT         => c_MAX_CPT,
      RAMP_INC_PERIOD => c_RAMP_INC_PERIOD
    )
    port map(
      clk            => clk,
      reset_n        => reset_n,
      hall_code      => hall_code,
      target_duty_in => target_duty_in,

      A_H => A_H,
      A_L => A_L,
      B_H => B_H,
      B_L => B_L,
      C_H => C_H,
      C_L => C_L
    );

  ----------------------------------------------------------------------------
  -- GENERATION DE L'HORLOGE (période 1 µs => 1 MHz)
  ----------------------------------------------------------------------------
  process
  begin
    while true loop
      clk <= '0';
      wait for 500 ns;
      clk <= '1';
      wait for 500 ns;
    end loop;
  end process;

  ----------------------------------------------------------------------------
  -- SCENARIO DE TEST
  ----------------------------------------------------------------------------
  process
  begin
    -- Etape 0 : Reset actif (bas) pendant quelques microsecondes
    reset_n <= '0';
    hall_code <= "000";       -- Au reset, code "000" (état invalide)
    target_duty_in <= 0;      -- Duty cycle à 0
    wait for 10 us;           -- On maintient reset bas 10 µs

    -- Etape 1 : On relâche le reset, le système commence à fonctionner
    reset_n <= '1';
    wait for 20 us;           -- Laisse le temps d'initialisation

    ----------------------------------------------------------------------------
    -- On commence à faire tourner le code Hall pour simuler les positions rotor
    -- et on fait évoluer la consigne de duty cycle
    ----------------------------------------------------------------------------

    -- On passe hall_code = "001" (A+ / B-), duty cycle tjrs 0
    hall_code <= "001";
    wait for 20 us;

    -- Monte la consigne à 5000
    target_duty_in <= 5000;
    wait for 20 us;

    -- Step suivant hall_code = "011" (B+ / C-)
    hall_code <= "011";
    wait for 20 us;

    -- Step : "010" (B+ / A-)
    hall_code <= "010";
    wait for 20 us;

    -- Monte la consigne à 15000
    target_duty_in <= 15000;
    wait for 20 us;

    -- Step : "110" (C+ / A-)
    hall_code <= "110";
    wait for 20 us;

    -- Step : "100" (C+ / B-)
    hall_code <= "100";
    wait for 20 us;

    -- Step : "101" (A+ / C-)
    hall_code <= "101";
    wait for 20 us;

    -- Monte la consigne à 20000 (100%)
    target_duty_in <= 20000;
    wait for 20 us;

    -- Reboucle sur "001" pour tester la commutation en continu
    hall_code <= "001";
    wait for 20 us;

    -- Baisse la consigne à 0 => on veut voir la rampe descendre
    target_duty_in <= 0;
    wait for 100 us;

    ----------------------------------------------------------------------------
    -- Arrêt simulation
    ----------------------------------------------------------------------------
    report "Fin de la simulation - BLDC_TOP test bench" severity note;
    wait;
  end process;

end TB;
