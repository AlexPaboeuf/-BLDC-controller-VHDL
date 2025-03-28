--------------------------------------------------------------------------------
-- sequencer.vhd
-- Auteurs       : PESCAY Maxime, PABOEUF Alexandre
-- Date         : 28/03/2025
--
-- Description :
--   Séquenceur pour un moteur BLDC triphasé :
--   - hall_code indique la position rotor (3 bits).
--   - pwm_in est le signal PWM (HIGH side).
--   - On sort 6 signaux : A_H, A_L, B_H, B_L, C_H, C_L
--     pour piloter les 3 phases (A, B, C) en 6 étapes.
--
-- Hypothèse : code hall sur 3 bits, 6 codes valides, 2 non utilisés (000,111).
--------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity sequencer is
  port(
    clk       : in  std_logic;
    reset_n   : in  std_logic;
    hall_code : in  std_logic_vector(2 downto 0);  -- 3 bits
    pwm_in    : in  std_logic;                     -- PWM généré par pwm_generator

    A_H : out std_logic;
    A_L : out std_logic;
    B_H : out std_logic;
    B_L : out std_logic;
    C_H : out std_logic;
    C_L : out std_logic
  );
end sequencer;

architecture Behavioral of sequencer is

  signal reg_A_H, reg_A_L : std_logic := '0';
  signal reg_B_H, reg_B_L : std_logic := '0';
  signal reg_C_H, reg_C_L : std_logic := '0';

begin

  ------------------------------------------------------------------------------
  -- PROCESS : détermination des sorties en fonction du code hall
  ------------------------------------------------------------------------------
  process(clk, reset_n)
  begin
    if reset_n = '0' then
      reg_A_H <= '0';
      reg_A_L <= '0';
      reg_B_H <= '0';
      reg_B_L <= '0';
      reg_C_H <= '0';
      reg_C_L <= '0';

    elsif rising_edge(clk) then
      case hall_code is

        when "001" =>
          -- A+ / B- / C off
          reg_A_H <= pwm_in;  -- phase A high reçoit le PWM
          reg_A_L <= '0';
          reg_B_H <= '0';
          reg_B_L <= '1';     -- phase B low au niveau bas
          reg_C_H <= '0';
          reg_C_L <= '0';

        when "011" =>
          -- B+ / C- / A off
          reg_A_H <= '0';
          reg_A_L <= '0';
          reg_B_H <= pwm_in;
          reg_B_L <= '0';
          reg_C_H <= '0';
          reg_C_L <= '1';

        when "010" =>
          -- B+ / A- / C off
          reg_A_H <= '0';
          reg_A_L <= '1';
          reg_B_H <= pwm_in;
          reg_B_L <= '0';
          reg_C_H <= '0';
          reg_C_L <= '0';

        when "110" =>
          -- C+ / A- / B off
          reg_A_H <= '0';
          reg_A_L <= '1';
          reg_B_H <= '0';
          reg_B_L <= '0';
          reg_C_H <= pwm_in;
          reg_C_L <= '0';

        when "100" =>
          -- C+ / B- / A off
          reg_A_H <= '0';
          reg_A_L <= '0';
          reg_B_H <= '0';
          reg_B_L <= '1';
          reg_C_H <= pwm_in;
          reg_C_L <= '0';

        when "101" =>
          -- A+ / C- / B off
          reg_A_H <= pwm_in;
          reg_A_L <= '0';
          reg_B_H <= '0';
          reg_B_L <= '0';
          reg_C_H <= '0';
          reg_C_L <= '1';

        when others =>
          -- (000 ou 111 ou autres cas invalides)
          -- On met tout à 0 = tout transistors off
          reg_A_H <= '0';
          reg_A_L <= '0';
          reg_B_H <= '0';
          reg_B_L <= '0';
          reg_C_H <= '0';
          reg_C_L <= '0';
      end case;
    end if;
  end process;

  ------------------------------------------------------------------------------
  -- Assignations finales aux sorties
  ------------------------------------------------------------------------------
  A_H <= reg_A_H;
  A_L <= reg_A_L;
  B_H <= reg_B_H;
  B_L <= reg_B_L;
  C_H <= reg_C_H;
  C_L <= reg_C_L;

end Behavioral;