%% File    : pt.xrl
%% Author  : Robert Virding
%% Purpose : A very simple example of pushing back characters.

Definitions.

D = [0-9]+
L = [a-zA-Z_][a-zA-Z_0-9]*

Comment = \#.*\n
Whites = (\s|\t|\n|\r)+

Rules.

def       : {token, {def, TokenLine}}.
if        : {token, {'if', TokenLine}}.
else      : {token, {'else', TokenLine}}.
while     : {token, {'while', TokenLine}}.

\:        : {token, {':', TokenLine}}.
\;        : {token, {';', TokenLine}}.

and       : {token, {'and', TokenLine}}.
or        : {token, {'or', TokenLine}}.

\<        : {token, {'<', TokenLine}}.
\>        : {token, {'>', TokenLine}}.
\<\=      : {token, {'<=', TokenLine}}.
\>\=      : {token, {'>=', TokenLine}}.
\=\=      : {token, {'==', TokenLine}}.
\!\=      : {token, {'!=', TokenLine}}.

\+        : {token, {'+', TokenLine}}.
\-        : {token, {'-', TokenLine}}.
\*        : {token, {'*', TokenLine}}.
\/        : {token, {'/', TokenLine}}.
\%        : {token, {'%', TokenLine}}.

\=        : {token, {'=', TokenLine}}.
\,        : {token, {',', TokenLine}}.

\(        : {token, {open, TokenLine}}.
\)        : {token, {close, TokenLine}}.
\[        : {token, {open_b, TokenLine}}.
\]        : {token, {close_b, TokenLine}}.

{L}       : {token, {identifier, TokenChars, TokenLine}}.
{D}       : {token, {integer, list_to_integer(TokenChars), TokenLine}}.

{Comment} : skip_token.
{Whites}  : skip_token.

Erlang code.
