--------------------------------------------------------------------------------
-- ramp_controller.vhd
-- Auteurs       : PESCAY Maxime, PABOEUF Alexandre
-- Date         : 28/03/2025
--
-- Description :
--   Fait varier de manière progressive (ramp-up/ramp-down) la valeur d'un
--   duty_cycle courant vers une consigne target_duty_cycle. A chaque expiration
--   de RAMP_INC_PERIOD cycles d'horloge, on incrémente ou décrémente de 1.
--
-- Paramètres génériques :
--   - MAX_CPT         : Valeur maximale pour le duty_cycle
--   - RAMP_INC_PERIOD : Intervalle (en nombre de cycles dhorloge)
--                       entre deux pas de montee/descente.
--
-- Ports :
--   - clk               : Horloge principale
--   - reset_n           : Reset asynchrone actif bas
--   - target_duty_cycle : Consigne de rapport cyclique (0..MAX_CPT)
--   - ramped_duty_cycle : Sortie lissée (va converger vers target_duty_cycle)
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity ramp_controller is
  generic(
    MAX_CPT         : integer := 20000;
    RAMP_INC_PERIOD : integer := 500
  );
  port(
    clk               : in  std_logic;
    reset_n           : in  std_logic;
    target_duty_cycle : in  integer range 0 to MAX_CPT;
    ramped_duty_cycle : out integer range 0 to MAX_CPT
  );
end ramp_controller;

architecture Behavioral of ramp_controller is

  signal current_duty_cycle : integer range 0 to MAX_CPT := 0;
  signal ramp_timer         : integer range 0 to RAMP_INC_PERIOD := 0;

begin

  ------------------------------------------------------------------------------
  -- PROCESS : Gère le timer de rampe et ajuste current_duty_cycle vers la consigne
  ------------------------------------------------------------------------------
  process(clk, reset_n)
  begin
    if (reset_n = '0') then
      current_duty_cycle <= 0;
      ramp_timer         <= 0;
    elsif rising_edge(clk) then
      -- Incrémente le timer
      if (ramp_timer < RAMP_INC_PERIOD) then
        ramp_timer <= ramp_timer + 1;
      else
        -- Quand on atteint RAMP_INC_PERIOD, on remet ramp_timer à 0,
        -- et on fait un pas vers la consigne
        ramp_timer <= 0;
        if (current_duty_cycle < target_duty_cycle) then
          current_duty_cycle <= current_duty_cycle + 1;
        elsif (current_duty_cycle > target_duty_cycle) then
          current_duty_cycle <= current_duty_cycle - 1;
        else
          current_duty_cycle <= current_duty_cycle;  -- Déjà égal, on ne bouge pas
        end if;
      end if;
    end if;
  end process;

  ramped_duty_cycle <= current_duty_cycle;

end Behavioral;