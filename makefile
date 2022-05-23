CC := iverilog
files := Insmem.v Decode.v Regfile32.v ALU.v Control.v DataMem.v 

run:

clean:

syntax:

test1: test1.v ${files}
	iverilog -o test1 test1.v ${files}
	vvp test1
	gtkwave test1.vcd

