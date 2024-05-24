onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate -divider tb
add wave -noupdate /testbench/reset_in
add wave -noupdate /testbench/clk_in
add wave -noupdate -divider instr-mem
add wave -noupdate -radix decimal /testbench/dut/inst_mem/addr
add wave -noupdate -radix hexadecimal /testbench/dut/inst_mem/data
add wave -noupdate -divider data-mem
add wave -noupdate /testbench/dut/data_mem/write_enable
add wave -noupdate -radix decimal /testbench/dut/data_mem/addr
add wave -noupdate -radix decimal /testbench/dut/data_mem/data_in
add wave -noupdate -radix decimal /testbench/dut/data_mem/data_out
add wave -noupdate -divider df
add wave -noupdate -radix decimal /testbench/dut/risc_v/dp/WriteData
add wave -noupdate -radix decimal /testbench/dut/risc_v/dp/ReadData
add wave -noupdate -radix decimal /testbench/dut/risc_v/dp/PCNext
add wave -noupdate -radix decimal /testbench/dut/risc_v/dp/PCTarget
add wave -noupdate -radix decimal /testbench/dut/risc_v/dp/ImmExt
add wave -noupdate -divider {ALU: SEL}
add wave -noupdate /testbench/dut/risc_v/control/ALUControl
add wave -noupdate -divider {ALU: A_IN}
add wave -noupdate -radix decimal /testbench/dut/risc_v/dp/SrcA
add wave -noupdate -divider {ALU: B_IN}
add wave -noupdate -radix decimal /testbench/dut/risc_v/dp/SrcB
add wave -noupdate -divider {ALU: OUT}
add wave -noupdate -radix decimal /testbench/dut/risc_v/dp/Result
add wave -noupdate -divider REGILE
add wave -noupdate /testbench/dut/risc_v/dp/rf/regWrite
add wave -noupdate -radix unsigned /testbench/dut/risc_v/dp/rf/rr1
add wave -noupdate -radix unsigned /testbench/dut/risc_v/dp/rf/rr2
add wave -noupdate -radix unsigned /testbench/dut/risc_v/dp/rf/wr
add wave -noupdate -radix decimal /testbench/dut/risc_v/dp/rf/d
add wave -noupdate -radix decimal /testbench/dut/risc_v/dp/rf/q1
add wave -noupdate -radix decimal /testbench/dut/risc_v/dp/rf/q2
add wave -noupdate -divider control
add wave -noupdate /testbench/dut/risc_v/control/op
add wave -noupdate /testbench/dut/risc_v/control/funct3
add wave -noupdate /testbench/dut/risc_v/control/funct7b5
add wave -noupdate /testbench/dut/risc_v/control/Zero
add wave -noupdate /testbench/dut/risc_v/control/ResultSrc
add wave -noupdate /testbench/dut/risc_v/control/MemWrite
add wave -noupdate /testbench/dut/risc_v/control/PCSrc
add wave -noupdate /testbench/dut/risc_v/control/ALUSrc
add wave -noupdate /testbench/dut/risc_v/control/RegWrite
add wave -noupdate /testbench/dut/risc_v/control/Jump
add wave -noupdate /testbench/dut/risc_v/control/ImmSrc
add wave -noupdate /testbench/dut/risc_v/control/ALUOp
add wave -noupdate /testbench/dut/risc_v/control/Branch
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {40000 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 122
configure wave -valuecolwidth 75
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
WaveRestoreZoom {0 ps} {230910 ps}
