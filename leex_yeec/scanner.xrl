%% File    : pt.xrl
%% Author  : Robert Virding
%% Purpose : A very simple example of pushing back characters.

Definitions.

D = [0-9]+
L = [a-zA-Z][a-zA-Z0-9]*

Open  = \(
Close = \)

Endls  = (\s|\t)*(\r?\n)
Whites = \s+
Tabs   = \t+

Rules.

def : {token, {def, TokenLine}}.
\:  : {token, {':', TokenLine}}.

{L}  : {token, {identifier, TokenChars, TokenLine}}.
{D}  : {token, {integer, list_to_integer(TokenChars), TokenLine}}.

\+    : {token, {'+', TokenLine}}.
\-    : {token, {'-', TokenLine}}.
\*    : {token, {'*', TokenLine}}.
\/    : {token, {'/', TokenLine}}.
\%    : {token, {'%', TokenLine}}.
\=    : {token, {'=', TokenLine}}.
\,    : {token, {',', TokenLine}}.

{Open}  : {token, {open, TokenLine}}.
{Close} : {token, {close, TokenLine}}.

{Endls}  : {token, {nl, TokenLine}}.
{Whites} : skip_token.
{Tabs}   : skip_token.

Erlang code.
