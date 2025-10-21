//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
//Date        : Mon Apr 14 13:57:23 2025
//Host        : IphoneH running 64-bit major release  (build 9200)
//Command     : generate_target Expand_matA_wrapper.bd
//Design      : Expand_matA_wrapper
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

module Expand_matA_wrapper
   (ap_clk_0,
    ap_ctrl_0_done,
    ap_ctrl_0_idle,
    ap_ctrl_0_ready,
    ap_ctrl_0_start,
    ap_rst_0,
    mat_address0_0,
    mat_ce0_0,
    mat_d0_0,
    mat_we0_0,
    rho_address0_0,
    rho_ce0_0,
    rho_q0_0);
  input ap_clk_0;
  output ap_ctrl_0_done;
  output ap_ctrl_0_idle;
  output ap_ctrl_0_ready;
  input ap_ctrl_0_start;
  input ap_rst_0;
  output [12:0]mat_address0_0;
  output mat_ce0_0;
  output [31:0]mat_d0_0;
  output mat_we0_0;
  output [4:0]rho_address0_0;
  output rho_ce0_0;
  input [7:0]rho_q0_0;

  wire ap_clk_0;
  wire ap_ctrl_0_done;
  wire ap_ctrl_0_idle;
  wire ap_ctrl_0_ready;
  wire ap_ctrl_0_start;
  wire ap_rst_0;
  wire [12:0]mat_address0_0;
  wire mat_ce0_0;
  wire [31:0]mat_d0_0;
  wire mat_we0_0;
  wire [4:0]rho_address0_0;
  wire rho_ce0_0;
  wire [7:0]rho_q0_0;

  Expand_matA Expand_matA_i
       (.ap_clk_0(ap_clk_0),
        .ap_ctrl_0_done(ap_ctrl_0_done),
        .ap_ctrl_0_idle(ap_ctrl_0_idle),
        .ap_ctrl_0_ready(ap_ctrl_0_ready),
        .ap_ctrl_0_start(ap_ctrl_0_start),
        .ap_rst_0(ap_rst_0),
        .mat_address0_0(mat_address0_0),
        .mat_ce0_0(mat_ce0_0),
        .mat_d0_0(mat_d0_0),
        .mat_we0_0(mat_we0_0),
        .rho_address0_0(rho_address0_0),
        .rho_ce0_0(rho_ce0_0),
        .rho_q0_0(rho_q0_0));
endmodule
