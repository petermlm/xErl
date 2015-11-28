.PHONY: all

all:
	./leex_yeec/make_leex_yeec.erl
	mv leex_yeec/scanner.erl src/scanner.erl
	mv leex_yeec/parser.erl src/parser.erl
	erl -make
	erl -pa ebin -noshell -s main main examples/ex1/input.xerl examples/ex1/output.asm -s init stop
	erl -pa ebin -noshell -s main main examples/ex2/input.xerl examples/ex2/output.asm -s init stop
	erl -pa ebin -noshell -s main main examples/ex3/input.xerl examples/ex3/output.asm -s init stop
	erl -pa ebin -noshell -s main main examples/README_example/input.xerl examples/README_example/output.asm -s init stop
