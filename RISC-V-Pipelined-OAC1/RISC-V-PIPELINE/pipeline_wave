onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider top-level
add wave -noupdate /testbench/dut/clock
add wave -noupdate /testbench/dut/reset
add wave -noupdate -divider instruction-mem
add wave -noupdate -radix decimal /testbench/dut/inst_mem/addr
add wave -noupdate -radix hexadecimal /testbench/dut/inst_mem/data
add wave -noupdate -divider data-mem
add wave -noupdate /testbench/dut/data_mem/write_enable
add wave -noupdate -radix decimal /testbench/dut/data_mem/addr
add wave -noupdate -radix decimal /testbench/dut/data_mem/data_in
add wave -noupdate -radix decimal /testbench/dut/data_mem/data_out
add wave -noupdate -divider fetch
add wave -noupdate /testbench/dut/pipeline/fetch/pc_src_e
add wave -noupdate -radix decimal /testbench/dut/pipeline/fetch/target_addr
add wave -noupdate -radix decimal /testbench/dut/pipeline/fetch/pc_out
add wave -noupdate -divider decode
add wave -noupdate -radix decimal /testbench/dut/pipeline/pipe_d/Rs2D_in
add wave -noupdate -radix decimal /testbench/dut/pipeline/pipe_d/Rs1D_in
add wave -noupdate -radix decimal /testbench/dut/pipeline/pipe_d/RdD_in
add wave -noupdate -radix decimal /testbench/dut/pipeline/decode/data_reg_src1
add wave -noupdate -radix decimal /testbench/dut/pipeline/decode/data_reg_src2
add wave -noupdate -divider alu
add wave -noupdate -radix decimal /testbench/dut/pipeline/execute/imm_ext_e
add wave -noupdate /testbench/dut/pipeline/execute/forwarding_a_e
add wave -noupdate /testbench/dut/pipeline/execute/forwarding_b_e
add wave -noupdate -radix decimal /testbench/dut/pipeline/execute/alu_result_e
add wave -noupdate /testbench/dut/pipeline/execute/zero_e
add wave -noupdate -radix decimal /testbench/dut/pipeline/execute/s_src_a_e
add wave -noupdate -radix decimal /testbench/dut/pipeline/execute/s_src_b_e
add wave -noupdate -divider write-back
add wave -noupdate -radix decimal /testbench/dut/pipeline/write_back/result_mux/y
add wave -noupdate /testbench/dut/pipeline/decode/reg_write_w
add wave -noupdate -radix unsigned /testbench/dut/pipeline/decode/addr_reg_write
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {83764 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 150
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 1
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {252 ns}
