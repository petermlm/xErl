#!/usr/bin/env escript
-module(make_pre).
-compile(export_all).

main(_) ->
    leex:file('leex_yeec/scanner', []),
    yecc:file('leex_yeec/parser', []).
