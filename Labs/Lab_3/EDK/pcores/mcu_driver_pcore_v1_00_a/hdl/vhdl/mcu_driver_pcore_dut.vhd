-- -------------------------------------------------------------
-- 
-- File Name: C:\GIT\pcore_Branch\Chilipepper\Labs\Lab_3\MATLAB\codegen\mcu_driver\hdlsrc\mcu_driver_pcore_dut.vhd
-- Created: 2013-11-15 16:37:35
-- 
-- Generated by MATLAB 8.2, MATLAB Coder 2.5 and HDL Coder 3.3
-- 
-- 
-- -------------------------------------------------------------


-- -------------------------------------------------------------
-- 
-- Module: mcu_driver_pcore_dut
-- Source Path: mcu_driver_pcore/mcu_driver_pcore_dut
-- Hierarchy Level: 1
-- 
-- -------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY mcu_driver_pcore_dut IS
  PORT( clk                               :   IN    std_logic;
        reset                             :   IN    std_logic;
        dut_enable                        :   IN    std_logic;  -- ufix1
        init_done                         :   IN    std_logic;  -- ufix1
        mcu_reset_in                      :   IN    std_logic;  -- ufix1
        tr_sw_reg                         :   IN    std_logic;  -- ufix1
        pa_en_reg                         :   IN    std_logic;  -- ufix1
        tx_en_reg                         :   IN    std_logic;  -- ufix1
        rx_en_reg                         :   IN    std_logic;  -- ufix1
        latch                             :   IN    std_logic;  -- ufix1
        mcu_reg_reset                     :   IN    std_logic;  -- ufix1
        ce_out                            :   OUT   std_logic;  -- ufix1
        mcu_reset_out                     :   OUT   std_logic;  -- ufix1
        tr_sw                             :   OUT   std_logic;  -- ufix1
        pa_en                             :   OUT   std_logic;  -- ufix1
        tx_en                             :   OUT   std_logic;  -- ufix1
        rx_en                             :   OUT   std_logic;  -- ufix1
        init_done_reg                     :   OUT   std_logic;  -- ufix1
        latch_done                        :   OUT   std_logic;  -- ufix1
        reg_reset_done                    :   OUT   std_logic;  -- ufix1
        blinky                            :   OUT   std_logic  -- ufix1
        );
END mcu_driver_pcore_dut;


ARCHITECTURE rtl OF mcu_driver_pcore_dut IS

  -- Component Declarations
  COMPONENT mcu_driver_fixpt
    PORT( clk                             :   IN    std_logic;
          clk_enable                      :   IN    std_logic;
          reset                           :   IN    std_logic;
          init_done                       :   IN    std_logic;  -- ufix1
          mcu_reset_in                    :   IN    std_logic;  -- ufix1
          tr_sw_reg                       :   IN    std_logic;  -- ufix1
          pa_en_reg                       :   IN    std_logic;  -- ufix1
          tx_en_reg                       :   IN    std_logic;  -- ufix1
          rx_en_reg                       :   IN    std_logic;  -- ufix1
          latch                           :   IN    std_logic;  -- ufix1
          mcu_reg_reset                   :   IN    std_logic;  -- ufix1
          ce_out                          :   OUT   std_logic;  -- ufix1
          mcu_reset_out                   :   OUT   std_logic;  -- ufix1
          tr_sw                           :   OUT   std_logic;  -- ufix1
          pa_en                           :   OUT   std_logic;  -- ufix1
          tx_en                           :   OUT   std_logic;  -- ufix1
          rx_en                           :   OUT   std_logic;  -- ufix1
          init_done_reg                   :   OUT   std_logic;  -- ufix1
          latch_done                      :   OUT   std_logic;  -- ufix1
          reg_reset_done                  :   OUT   std_logic;  -- ufix1
          blinky                          :   OUT   std_logic  -- ufix1
          );
  END COMPONENT;

  -- Component Configuration Statements
  FOR ALL : mcu_driver_fixpt
    USE ENTITY work.mcu_driver_fixpt(rtl);

  -- Signals
  SIGNAL enb                              : std_logic;
  SIGNAL init_done_sig                    : std_logic;  -- ufix1
  SIGNAL mcu_reset_in_sig                 : std_logic;  -- ufix1
  SIGNAL tr_sw_reg_sig                    : std_logic;  -- ufix1
  SIGNAL pa_en_reg_sig                    : std_logic;  -- ufix1
  SIGNAL tx_en_reg_sig                    : std_logic;  -- ufix1
  SIGNAL rx_en_reg_sig                    : std_logic;  -- ufix1
  SIGNAL latch_sig                        : std_logic;  -- ufix1
  SIGNAL mcu_reg_reset_sig                : std_logic;  -- ufix1
  SIGNAL ce_out_sig                       : std_logic;  -- ufix1
  SIGNAL mcu_reset_out_sig                : std_logic;  -- ufix1
  SIGNAL tr_sw_sig                        : std_logic;  -- ufix1
  SIGNAL pa_en_sig                        : std_logic;  -- ufix1
  SIGNAL tx_en_sig                        : std_logic;  -- ufix1
  SIGNAL rx_en_sig                        : std_logic;  -- ufix1
  SIGNAL init_done_reg_sig                : std_logic;  -- ufix1
  SIGNAL latch_done_sig                   : std_logic;  -- ufix1
  SIGNAL reg_reset_done_sig               : std_logic;  -- ufix1
  SIGNAL blinky_sig                       : std_logic;  -- ufix1

BEGIN
  u_mcu_driver_fixpt : mcu_driver_fixpt
    PORT MAP( clk => clk,
              clk_enable => enb,
              reset => reset,
              init_done => init_done_sig,  -- ufix1
              mcu_reset_in => mcu_reset_in_sig,  -- ufix1
              tr_sw_reg => tr_sw_reg_sig,  -- ufix1
              pa_en_reg => pa_en_reg_sig,  -- ufix1
              tx_en_reg => tx_en_reg_sig,  -- ufix1
              rx_en_reg => rx_en_reg_sig,  -- ufix1
              latch => latch_sig,  -- ufix1
              mcu_reg_reset => mcu_reg_reset_sig,  -- ufix1
              ce_out => ce_out_sig,  -- ufix1
              mcu_reset_out => mcu_reset_out_sig,  -- ufix1
              tr_sw => tr_sw_sig,  -- ufix1
              pa_en => pa_en_sig,  -- ufix1
              tx_en => tx_en_sig,  -- ufix1
              rx_en => rx_en_sig,  -- ufix1
              init_done_reg => init_done_reg_sig,  -- ufix1
              latch_done => latch_done_sig,  -- ufix1
              reg_reset_done => reg_reset_done_sig,  -- ufix1
              blinky => blinky_sig  -- ufix1
              );

  init_done_sig <= init_done;

  mcu_reset_in_sig <= mcu_reset_in;

  tr_sw_reg_sig <= tr_sw_reg;

  pa_en_reg_sig <= pa_en_reg;

  tx_en_reg_sig <= tx_en_reg;

  rx_en_reg_sig <= rx_en_reg;

  latch_sig <= latch;

  mcu_reg_reset_sig <= mcu_reg_reset;

  enb <= dut_enable;

  ce_out <= ce_out_sig;

  mcu_reset_out <= mcu_reset_out_sig;

  tr_sw <= tr_sw_sig;

  pa_en <= pa_en_sig;

  tx_en <= tx_en_sig;

  rx_en <= rx_en_sig;

  init_done_reg <= init_done_reg_sig;

  latch_done <= latch_done_sig;

  reg_reset_done <= reg_reset_done_sig;

  blinky <= blinky_sig;

END rtl;
