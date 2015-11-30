.PHONY: all compiler leex_yeec examples clean

EXAMPLES_INPUT=examples/README_example/input.xerl \
				examples/arithmetic/input.xerl \
				examples/logic/input.xerl \
				examples/control/input.xerl \
				examples/functions/input.xerl \
				examples/variables/input.xerl \
				examples/fibonacci/input.xerl
EXAMPLES_CLEAN=$(EXAMPLES_INPUT:input.xerl=input.asm) \
				$(EXAMPLES_INPUT:input.xerl=input.o) \
				$(EXAMPLES_INPUT:input.xerl=input)

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
	./xerl $@

clean:
	rm -f $(EXAMPLES_CLEAN)
	rm -f ebin/*
	rm -f src/scanner.erl src/parser.erl
