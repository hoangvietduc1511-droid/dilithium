onbreak {quit -f}
onerror {quit -f}

vsim -lib xil_defaultlib Expand_matA_opt

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure
view signals

do {Expand_matA.udo}

run -all

quit -force
