onbreak {quit -force}
onerror {quit -force}

asim +access +r +m+Expand_matA -L xil_defaultlib -L unisims_ver -L unimacro_ver -L secureip -O5 xil_defaultlib.Expand_matA xil_defaultlib.glbl

set NumericStdNoWarnings 1
set StdArithNoWarnings 1

do {wave.do}

view wave
view structure

do {Expand_matA.udo}

run -all

endsim

quit -force
