// Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
// --------------------------------------------------------------------------------
// Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
// Date        : Mon Apr 14 14:05:11 2025
// Host        : IphoneH running 64-bit major release  (build 9200)
// Command     : write_verilog -force -mode synth_stub
//               d:/HOC_TAP/Nam_5/NCKH_2024/Vivado/dilithium/dilithium.gen/sources_1/bd/Expand_matA/ip/Expand_matA_expand_mat_0_0/Expand_matA_expand_mat_0_0_stub.v
// Design      : Expand_matA_expand_mat_0_0
// Purpose     : Stub declaration of top-level module interface
// Device      : xc7a35tcpg236-1
// --------------------------------------------------------------------------------

// This empty module with port declaration file causes synthesis tools to infer a black box for IP.
// The synthesis directives are for Synopsys Synplify support to prevent IO buffer insertion.
// Please paste the declaration into a Verilog source file or add the file as an additional source.
(* X_CORE_INFO = "expand_mat,Vivado 2022.1" *)
module Expand_matA_expand_mat_0_0(mat_ce0, mat_we0, rho_ce0, ap_clk, ap_rst, 
  ap_start, ap_done, ap_idle, ap_ready, mat_address0, mat_d0, rho_address0, rho_q0)
/* synthesis syn_black_box black_box_pad_pin="mat_ce0,mat_we0,rho_ce0,ap_clk,ap_rst,ap_start,ap_done,ap_idle,ap_ready,mat_address0[12:0],mat_d0[31:0],rho_address0[4:0],rho_q0[7:0]" */;
  output mat_ce0;
  output mat_we0;
  output rho_ce0;
  input ap_clk;
  input ap_rst;
  input ap_start;
  output ap_done;
  output ap_idle;
  output ap_ready;
  output [12:0]mat_address0;
  output [31:0]mat_d0;
  output [4:0]rho_address0;
  input [7:0]rho_q0;
endmodule
