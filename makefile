CC := iverilog
CC2 := vvp
wv := gtkwave
files := Insmem.v Decode.v Regfile32.v

clean: a.out
	rm a.out

test1: test1.v ${files} testcode.txt
	${CC} test1.v ${files}
	${CC2} a.out
	${wv} test1.vcd

test2: test2.v ${files} testcode.txt
	${CC} test2.v ${files}
	${CC2} a.out
	${wv} test2.vcd

	