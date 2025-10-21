-- Copyright 1986-2022 Xilinx, Inc. All Rights Reserved.
-- --------------------------------------------------------------------------------
-- Tool Version: Vivado v.2022.1 (win64) Build 3526262 Mon Apr 18 15:48:16 MDT 2022
-- Date        : Mon Apr 14 14:05:11 2025
-- Host        : IphoneH running 64-bit major release  (build 9200)
-- Command     : write_vhdl -force -mode synth_stub
--               d:/HOC_TAP/Nam_5/NCKH_2024/Vivado/dilithium/dilithium.gen/sources_1/bd/Expand_matA/ip/Expand_matA_expand_mat_0_0/Expand_matA_expand_mat_0_0_stub.vhdl
-- Design      : Expand_matA_expand_mat_0_0
-- Purpose     : Stub declaration of top-level module interface
-- Device      : xc7a35tcpg236-1
-- --------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity Expand_matA_expand_mat_0_0 is
  Port ( 
    mat_ce0 : out STD_LOGIC;
    mat_we0 : out STD_LOGIC;
    rho_ce0 : out STD_LOGIC;
    ap_clk : in STD_LOGIC;
    ap_rst : in STD_LOGIC;
    ap_start : in STD_LOGIC;
    ap_done : out STD_LOGIC;
    ap_idle : out STD_LOGIC;
    ap_ready : out STD_LOGIC;
    mat_address0 : out STD_LOGIC_VECTOR ( 12 downto 0 );
    mat_d0 : out STD_LOGIC_VECTOR ( 31 downto 0 );
    rho_address0 : out STD_LOGIC_VECTOR ( 4 downto 0 );
    rho_q0 : in STD_LOGIC_VECTOR ( 7 downto 0 )
  );

end Expand_matA_expand_mat_0_0;

architecture stub of Expand_matA_expand_mat_0_0 is
attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;
attribute syn_black_box of stub : architecture is true;
attribute black_box_pad_pin of stub : architecture is "mat_ce0,mat_we0,rho_ce0,ap_clk,ap_rst,ap_start,ap_done,ap_idle,ap_ready,mat_address0[12:0],mat_d0[31:0],rho_address0[4:0],rho_q0[7:0]";
attribute X_CORE_INFO : string;
attribute X_CORE_INFO of stub : architecture is "expand_mat,Vivado 2022.1";
begin
end;
