-module(genCode).
-author("Pedro Melgueira").
-compile(export_all).


genCode(Device, AST, Context) ->
    % Generate .bss part
    genBSS(Device, Context),

    % Generate functions

    % Generate _start
    genCodeInst(Device, AST, Context).

genCodeInst(_Device, [], _Context) -> ok;

genCodeInst(Device, [_Element | AST_Tail], Context) ->
    io:fwrite(Device, "Line~n", []),
    genCodeInst(Device, AST_Tail, Context).

% -----------------------------------------------------------------------------

genBSS(Device, Context) ->
    % Get the number of the variables
    VarsNum = countVariables(dict:to_list(Context)),
    VarsSize = VarsNum * 4,

    % Write bss section
    io:fwrite(Device, ".section .bss~n", []),
    io:fwrite(Device, ".lcomm VARS, ~p~n", [VarsSize]),
    io:fwrite(Device, "~n", []).

countVariables(Context) -> countVariables(Context, 0).

countVariables([], Count) -> Count;

countVariables([{_, variable} | T], Count) ->
    countVariables(T, Count+1);

countVariables([_ | T], Count) ->
    countVariables(T, Count).
