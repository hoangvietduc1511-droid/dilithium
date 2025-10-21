vlib work
vlib activehdl

vlib activehdl/xil_defaultlib

vmap xil_defaultlib activehdl/xil_defaultlib

vlog -work xil_defaultlib  -v2k5 \
"../../../../polyvec_ntt.gen/sources_1/bd/Expand_matA/ipshared/7ad0/hdl/verilog/expand_mat_expand_mat_Pipeline_VITIS_LOOP_31_1.v" \
"../../../../polyvec_ntt.gen/sources_1/bd/Expand_matA/ipshared/7ad0/hdl/verilog/expand_mat_expand_mat_Pipeline_VITIS_LOOP_41_4.v" \
"../../../../polyvec_ntt.gen/sources_1/bd/Expand_matA/ipshared/7ad0/hdl/verilog/expand_mat_expand_mat_Pipeline_VITIS_LOOP_372_1.v" \
"../../../../polyvec_ntt.gen/sources_1/bd/Expand_matA/ipshared/7ad0/hdl/verilog/expand_mat_expand_mat_Pipeline_VITIS_LOOP_384_4.v" \
"../../../../polyvec_ntt.gen/sources_1/bd/Expand_matA/ipshared/7ad0/hdl/verilog/expand_mat_expand_mat_Pipeline_VITIS_LOOP_386_5.v" \
"../../../../polyvec_ntt.gen/sources_1/bd/Expand_matA/ipshared/7ad0/hdl/verilog/expand_mat_expand_mat_Pipeline_VITIS_LOOP_390_6.v" \
"../../../../polyvec_ntt.gen/sources_1/bd/Expand_matA/ipshared/7ad0/hdl/verilog/expand_mat_expand_mat_Pipeline_VITIS_LOOP_416_2.v" \
"../../../../polyvec_ntt.gen/sources_1/bd/Expand_matA/ipshared/7ad0/hdl/verilog/expand_mat_flow_control_loop_pipe_sequential_init.v" \
"../../../../polyvec_ntt.gen/sources_1/bd/Expand_matA/ipshared/7ad0/hdl/verilog/expand_mat_inbuf_RAM_AUTO_1R1W.v" \
"../../../../polyvec_ntt.gen/sources_1/bd/Expand_matA/ipshared/7ad0/hdl/verilog/expand_mat_KeccakF1600_StatePermute.v" \
"../../../../polyvec_ntt.gen/sources_1/bd/Expand_matA/ipshared/7ad0/hdl/verilog/expand_mat_KeccakF1600_StatePermute_KeccakF_RoundConstants_ROM_AUTO_1R.v" \
"../../../../polyvec_ntt.gen/sources_1/bd/Expand_matA/ipshared/7ad0/hdl/verilog/expand_mat_outbuf_RAM_AUTO_1R1W.v" \
"../../../../polyvec_ntt.gen/sources_1/bd/Expand_matA/ipshared/7ad0/hdl/verilog/expand_mat_s_RAM_AUTO_1R1W.v" \
"../../../../polyvec_ntt.gen/sources_1/bd/Expand_matA/ipshared/7ad0/hdl/verilog/expand_mat_t_RAM_1WNR_AUTO_1R1W.v" \
"../../../../polyvec_ntt.gen/sources_1/bd/Expand_matA/ipshared/7ad0/hdl/verilog/expand_mat.v" \
"../../../bd/Expand_matA/ip/Expand_matA_expand_mat_0_0/sim/Expand_matA_expand_mat_0_0.v" \
"../../../bd/Expand_matA/sim/Expand_matA.v" \


vlog -work xil_defaultlib \
"glbl.v"

