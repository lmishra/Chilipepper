-- -------------------------------------------------------------
-- 
-- File Name: C:\GIT\QPSK_Pcore\Labs\Lab_0\MATLAB\codegen\blink_leds\hdlsrc\blink_leds_pcore_dut.vhd
-- Created: 2013-12-11 16:55:47
-- 
-- Generated by MATLAB 8.3, MATLAB Coder 2.6 and HDL Coder 3.4
-- 
-- 
-- -------------------------------------------------------------


-- -------------------------------------------------------------
-- 
-- Module: blink_leds_pcore_dut
-- Source Path: blink_leds_pcore/blink_leds_pcore_dut
-- Hierarchy Level: 1
-- 
-- -------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY blink_leds_pcore_dut IS
  PORT( clk                               :   IN    std_logic;
        reset                             :   IN    std_logic;
        dut_enable                        :   IN    std_logic;  -- ufix1
        dummy_input                       :   IN    std_logic;  -- ufix1
        ce_out                            :   OUT   std_logic;  -- ufix1
        blinky                            :   OUT   std_logic_vector(3 DOWNTO 0)  -- ufix4
        );
END blink_leds_pcore_dut;


ARCHITECTURE rtl OF blink_leds_pcore_dut IS

  -- Component Declarations
  COMPONENT blink_leds_fixpt
    PORT( clk                             :   IN    std_logic;
          clk_enable                      :   IN    std_logic;
          reset                           :   IN    std_logic;
          dummy_input                     :   IN    std_logic;  -- ufix1
          ce_out                          :   OUT   std_logic;  -- ufix1
          blinky                          :   OUT   std_logic_vector(3 DOWNTO 0)  -- ufix4
          );
  END COMPONENT;

  -- Component Configuration Statements
  FOR ALL : blink_leds_fixpt
    USE ENTITY work.blink_leds_fixpt(rtl);

  -- Signals
  SIGNAL enb                              : std_logic;
  SIGNAL dummy_input_sig                  : std_logic;  -- ufix1
  SIGNAL ce_out_sig                       : std_logic;  -- ufix1
  SIGNAL blinky_sig                       : std_logic_vector(3 DOWNTO 0);  -- ufix4

BEGIN
  u_blink_leds_fixpt : blink_leds_fixpt
    PORT MAP( clk => clk,
              clk_enable => enb,
              reset => reset,
              dummy_input => dummy_input_sig,  -- ufix1
              ce_out => ce_out_sig,  -- ufix1
              blinky => blinky_sig  -- ufix4
              );

  dummy_input_sig <= dummy_input;

  enb <= dut_enable;

  ce_out <= ce_out_sig;

  blinky <= blinky_sig;

END rtl;

