//Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
//--------------------------------------------------------------------------------
//Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
//Date        : Mon Apr 14 13:57:23 2025
//Host        : IphoneH running 64-bit major release  (build 9200)
//Command     : generate_target Expand_matA.bd
//Design      : Expand_matA
//Purpose     : IP block netlist
//--------------------------------------------------------------------------------
`timescale 1 ps / 1 ps

(* CORE_GENERATION_INFO = "Expand_matA,IP_Integrator,{x_ipVendor=xilinx.com,x_ipLibrary=BlockDiagram,x_ipName=Expand_matA,x_ipVersion=1.00.a,x_ipLanguage=VERILOG,numBlks=1,numReposBlks=1,numNonXlnxBlks=0,numHierBlks=0,maxHierDepth=0,numSysgenBlks=0,numHlsBlks=1,numHdlrefBlks=0,numPkgbdBlks=0,bdsource=USER,synth_mode=OOC_per_IP}" *) (* HW_HANDOFF = "Expand_matA.hwdef" *) 
module Expand_matA
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
  (* X_INTERFACE_INFO = "xilinx.com:signal:clock:1.0 CLK.AP_CLK_0 CLK" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME CLK.AP_CLK_0, ASSOCIATED_RESET ap_rst_0, CLK_DOMAIN Expand_matA_ap_clk_0, FREQ_HZ 100000000, FREQ_TOLERANCE_HZ 0, INSERT_VIP 0, PHASE 0.0" *) input ap_clk_0;
  (* X_INTERFACE_INFO = "xilinx.com:interface:acc_handshake:1.0 ap_ctrl_0 done" *) output ap_ctrl_0_done;
  (* X_INTERFACE_INFO = "xilinx.com:interface:acc_handshake:1.0 ap_ctrl_0 idle" *) output ap_ctrl_0_idle;
  (* X_INTERFACE_INFO = "xilinx.com:interface:acc_handshake:1.0 ap_ctrl_0 ready" *) output ap_ctrl_0_ready;
  (* X_INTERFACE_INFO = "xilinx.com:interface:acc_handshake:1.0 ap_ctrl_0 start" *) input ap_ctrl_0_start;
  (* X_INTERFACE_INFO = "xilinx.com:signal:reset:1.0 RST.AP_RST_0 RST" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME RST.AP_RST_0, INSERT_VIP 0, POLARITY ACTIVE_HIGH" *) input ap_rst_0;
  (* X_INTERFACE_INFO = "xilinx.com:signal:data:1.0 DATA.MAT_ADDRESS0_0 DATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME DATA.MAT_ADDRESS0_0, LAYERED_METADATA undef" *) output [12:0]mat_address0_0;
  output mat_ce0_0;
  (* X_INTERFACE_INFO = "xilinx.com:signal:data:1.0 DATA.MAT_D0_0 DATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME DATA.MAT_D0_0, LAYERED_METADATA undef" *) output [31:0]mat_d0_0;
  output mat_we0_0;
  (* X_INTERFACE_INFO = "xilinx.com:signal:data:1.0 DATA.RHO_ADDRESS0_0 DATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME DATA.RHO_ADDRESS0_0, LAYERED_METADATA undef" *) output [4:0]rho_address0_0;
  output rho_ce0_0;
  (* X_INTERFACE_INFO = "xilinx.com:signal:data:1.0 DATA.RHO_Q0_0 DATA" *) (* X_INTERFACE_PARAMETER = "XIL_INTERFACENAME DATA.RHO_Q0_0, LAYERED_METADATA undef" *) input [7:0]rho_q0_0;

  wire ap_clk_0_1;
  wire ap_ctrl_0_1_done;
  wire ap_ctrl_0_1_idle;
  wire ap_ctrl_0_1_ready;
  wire ap_ctrl_0_1_start;
  wire ap_rst_0_1;
  wire [12:0]expand_mat_0_mat_address0;
  wire expand_mat_0_mat_ce0;
  wire [31:0]expand_mat_0_mat_d0;
  wire expand_mat_0_mat_we0;
  wire [4:0]expand_mat_0_rho_address0;
  wire expand_mat_0_rho_ce0;
  wire [7:0]rho_q0_0_1;

  assign ap_clk_0_1 = ap_clk_0;
  assign ap_ctrl_0_1_start = ap_ctrl_0_start;
  assign ap_ctrl_0_done = ap_ctrl_0_1_done;
  assign ap_ctrl_0_idle = ap_ctrl_0_1_idle;
  assign ap_ctrl_0_ready = ap_ctrl_0_1_ready;
  assign ap_rst_0_1 = ap_rst_0;
  assign mat_address0_0[12:0] = expand_mat_0_mat_address0;
  assign mat_ce0_0 = expand_mat_0_mat_ce0;
  assign mat_d0_0[31:0] = expand_mat_0_mat_d0;
  assign mat_we0_0 = expand_mat_0_mat_we0;
  assign rho_address0_0[4:0] = expand_mat_0_rho_address0;
  assign rho_ce0_0 = expand_mat_0_rho_ce0;
  assign rho_q0_0_1 = rho_q0_0[7:0];
  Expand_matA_expand_mat_0_0 expand_mat_0
       (.ap_clk(ap_clk_0_1),
        .ap_done(ap_ctrl_0_1_done),
        .ap_idle(ap_ctrl_0_1_idle),
        .ap_ready(ap_ctrl_0_1_ready),
        .ap_rst(ap_rst_0_1),
        .ap_start(ap_ctrl_0_1_start),
        .mat_address0(expand_mat_0_mat_address0),
        .mat_ce0(expand_mat_0_mat_ce0),
        .mat_d0(expand_mat_0_mat_d0),
        .mat_we0(expand_mat_0_mat_we0),
        .rho_address0(expand_mat_0_rho_address0),
        .rho_ce0(expand_mat_0_rho_ce0),
        .rho_q0(rho_q0_0_1));
endmodule
