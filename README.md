A compiler from a simple language to x86 in Erlang. The language is just a simple integer calculator with variables and functions.

This is just a personal project of mine and I did it to learn Erlang and x86.

Program:

    # Variables are simply defined like so:

    x = 10;

    # An expression statement prints its result out

    x; # Output: 10

    # Expressions:

    10 * (2 + x); # Output: 120

    # Functions
    def f(x): x*2;
    def f(x, y): x*y;
    def g(a, b, c): a*b*c;

    f(50) + f(2, 3);              # Output: 106
    g(f(50), 1 + 2, (1 + 2) * 2); # Output: 1800

    def f(a): a+1; # Redefines f with one argument

    f(1); # Output: 2

    # Ifs and elses, Output: 10
    if x == 10 [
        x;
    ] else [
        0;
    ]

    # While
    while x > 0 [ x = x - 1; ]
    x; # Output: 0

Output:

    10
    120
    106
    1800
    2
    10
    0
