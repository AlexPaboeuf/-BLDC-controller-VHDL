--------------------------------------------------------------------------------
-- sin_approx.vhd
-- Auteurs       : PESCAY Maxime, PABOEUF Alexandre
-- Date         : 10/04/2025
--
-- Description :
--   Ce module approximatif calcule sin(angle) sur l'intervalle [0, 90°].
--   Les valeurs de référence utilisées sont :
--       sin(0)  = 0       => 0/1000
--       sin(30) = 0.5     => 500/1000
--       sin(45) = 0.707   => 707/1000
--       sin(60) = 0.866   => 866/1000
--       sin(90) = 1       => 1000/1000
--
--   Pour des valeurs intermédiaires, une interpolation linéaire est réalisée.
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sin_approx is
  port(
    angle   : in  integer range 0 to 90;
    sin_out : out integer range 0 to 1000
  );
end sin_approx;

architecture Behavioral of sin_approx is
begin
  process(angle)
  begin
    case angle is
      when 0  => sin_out <= 0;
      when 30 => sin_out <= 500;
      when 45 => sin_out <= 707;
      when 60 => sin_out <= 866;
      when 90 => sin_out <= 1000;
      when others =>
        if angle < 30 then
          -- Interpolation linéaire entre 0 et 30
          sin_out <= (angle * 500) / 30;
        elsif angle < 45 then
          -- Interpolation linéaire entre 30 et 45
          sin_out <= 500 + ((angle - 30) * (707 - 500)) / (45 - 30);
        elsif angle < 60 then
          -- Interpolation linéaire entre 45 et 60
          sin_out <= 707 + ((angle - 45) * (866 - 707)) / (60 - 45);
        elsif angle < 90 then
          -- Interpolation linéaire entre 60 et 90
          sin_out <= 866 + ((angle - 60) * (1000 - 866)) / (90 - 60);
        else
          sin_out <= 1000;
        end if;
    end case;
  end process;
end Behavioral;
