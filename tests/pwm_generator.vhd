--------------------------------------------------------------------------------
-- pwm_generator.vhd
-- Module : Générateur de signal PWM basé sur un générique MAX_CPT
-- Auteurs       : PESCAY Maxime, PABOEUF Alexandre
-- Date         : 28/03/2025
-- Description :
--   Générateur de signal PWM basé sur un compteur interne allant de 0 à
--   MAX_CPT-1. Le duty_cycle (rapport cyclique) est un entier dans la plage
--   [0 .. MAX_CPT]. Si duty_cycle = 0 => 0% de PWM, duty_cycle = MAX_CPT => 100%.
--
-- Paramètre générique :
--   MAX_CPT : Nombre de ticks d'horloge pour parcourir un cycle PWM
--             (ex : 20000 pour un PWM à 50 Hz si clk=1MHz).
--
-- Ports :
--   - clk        : Horloge principale
--   - reset_n    : Reset asynchrone actif bas
--   - duty_cycle : Valeur désirée du rapport cyclique (0 => 0%, MAX_CPT => 100%)
--   - pwm_out    : Sortie PWM
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity pwm_generator is
  generic(
    MAX_CPT : natural := 20000
  );
  port(
    clk        : in  std_logic;
    reset_n    : in  std_logic;
    duty_cycle : in  integer range 0 to MAX_CPT;
    pwm_out    : out std_logic
  );
end pwm_generator;

architecture Behavioral of pwm_generator is

  signal cpt : integer range 0 to MAX_CPT := 0;

begin

  -- PROCESS de comptage
  process(clk, reset_n)
  begin
    if (reset_n = '0') then
      cpt <= 0;
    elsif rising_edge(clk) then
      if (cpt >= MAX_CPT - 1) then
        cpt <= 0;  -- On reboucle
      else
        cpt <= cpt + 1;
      end if;
    end if;
  end process;

  -- Génération du PWM en comparant cpt et duty_cycle
  pwm_out <= '1' when cpt < duty_cycle else '0';

end Behavioral;