.PHONY: all

all:
	./leex_yeec/make_leex_yeec.erl
	mv leex_yeec/scanner.erl src/scanner.erl
	mv leex_yeec/parser.erl src/parser.erl
	erl -make
	erl -pa ebin -noshell -s main main input.xerl output.asm -s init stop
