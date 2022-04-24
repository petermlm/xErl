A compiler from a simple language to x86 in Erlang. The language is just a simple integer calculator with variables and functions.

This is just a personal project of mine and I did it to learn Erlang and x86.

[Link for blog post about this.](https://petermlm.wordpress.com/2015/12/01/compiler-from-simple-language-to-x86-in-erlang/)

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

# 32 Bits

*Added 24 April 2022*

When I developed this project in 2015, I did so on my then old but reliable
ACER laptop. This laptop had been bought by my parents for me while I was still
in school in the year 2008. It was a 32 bit Intel Celeron and my only PC where
I did programming on a personal level between 2008 and 2016.

Because I was on my old laptop when I did this project, I simply made this
compiler generate ASM code that would be compilable on that machine. I wasn't
worried about compatibility, or other instruction sets and architectures. That
was a bit out of scope for my experience at the time.

But now in 2022, I still would like to at least make this project run. So
instead of making it more complex, and generating ASM for 64 bits, I simply
still compile only for 32 bits.

To run this on a 64 bit machine, the following package is required:

    libc6-dev-i386

On a 32 bit machine, the `xerl` script should also be executed with a second
argument set to 32, like so:

    ./xerl ./examples/arithmetic/input.xerl 32
