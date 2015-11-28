.PHONY: all compiler leex_yeec examples

EXAMPLES_INPUT=examples/README_example/input.xerl \
				examples/ex1/input.xerl \
				examples/ex2/input.xerl \
				examples/ex3/input.xerl

ERLFLAGS=-pa ebin -noshell
COMPILER=-s main main
INIT_STOP=-s init stop

all: compiler examples

compiler: leex_yeec
	erl -make

leex_yeec:
	./leex_yeec/make_leex_yeec.erl
	mv leex_yeec/scanner.erl src/scanner.erl
	mv leex_yeec/parser.erl src/parser.erl

examples: $(EXAMPLES_INPUT)

.PHONY: $(EXAMPLES_INPUT)
$(EXAMPLES_INPUT):
	erl $(ERLFLAGS) $(COMPILER) $@ $(subst input.xerl,output.asm,$@) $(INIT_STOP)
	as $(subst input.xerl,output.asm,$@) -o $(subst input.xerl,output.o,$@)
	ld -dynamic-linker /lib/ld-linux.so.2 -o $(subst input.xerl,output,$@) $(subst input.xerl,output.o,$@) -lc
