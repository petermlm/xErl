-module(genCode).
-author("Pedro Melgueira").
-compile(export_all).


genCode(Device, AST, Context) ->
    % Generate .bss part
    genBSS(Device, Context),

    % Generate functions
    io:fwrite(Device, ".section .text~n~n", []),
    genFuncDecls(Device, AST, Context),

    % Generate _start
    genCodeMain(Device, AST, Context).

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

% -----------------------------------------------------------------------------

genFuncDecls(Device, AST, Context) ->
    genFuncDecls(Device, AST, Context, dict:new()).

genFuncDecls(_Device, [], _Context, _Counters) -> ok;

genFuncDecls(Device, [{fun_decl, {identifier, Id, _}, _, _} | AST_Tail], Context, Counters) ->
    % Get count of the function
    Counters2 = dict:update_counter(Id, 1, Counters),
    Count = dict:fetch(Id, Counters2),

    % Write head of the function
    io:fwrite(Device, ".type ~s_~p, function~n", [Id, Count]),
    io:fwrite(Device, "~s_~p:~n", [Id, Count]),

    % Function's prologue
    io:fwrite(Device, "    pushl %ebp~n", []),
    io:fwrite(Device, "    movl %esp, %ebp~n", []),

    % Function's body TODO

    % Function's epilogue
    io:fwrite(Device, "    movl %ebp, %esp~n", []),
    io:fwrite(Device, "    popl %ebp~n", []),
    io:fwrite(Device, "    ret~n~n", []),

    genFuncDecls(Device, AST_Tail, Context, Counters2);

genFuncDecls(Device, [_ | AST_Tail], Context, Counters) ->
    genFuncDecls(Device, AST_Tail, Context, Counters).

% -----------------------------------------------------------------------------

genCodeMain(Device, AST, Context) ->
    io:fwrite(Device, ".globl _start~n", []),
    io:fwrite(Device, "_start:~n", []),
    genCodeMainAST(Device, AST, Context).

genCodeMainAST(_Device, [], _Context) -> ok;

genCodeMainAST(Device, [AST_Ele | AST_Tail], Context) ->
    genCodeMainInst(Device, AST_Ele, Context),
    genCodeMainAST(Device, AST_Tail, Context).

genCodeMainInst(Device, {assign, _Id, Expr}, Context) ->
    % Expression code
    genCodeMainInst(Device, Expr, Context),

    % Assignment code
    io:fwrite(Device, "    movl $VARS, %ebx~n", []),
    io:fwrite(Device, "    movl %eax, (%ebx, 1, 4)~n", []);

genCodeMainInst(Device, {fun_decl, _Id, _Args, _Expr}, Context) ->
    % TODO
    io:fwrite(Device, "fun_decl~n", []);

genCodeMainInst(Device, {expr, Op, Expr1, Expr2}, Context) ->
    % Code for first expression
    genCodeMainInst(Device, Expr1, Context),
    io:fwrite(Device, "    pushl %eax~n", []),

    % Code for second expression
    genCodeMainInst(Device, Expr2, Context),

    io:fwrite(Device, "    popl %ebx~n", []),

    % Code for this expression's op
    case Op of
        {'+', _} -> io:fwrite(Device, "    addl %ebx, %eax~n", []);
        {'-', _} -> io:fwrite(Device, "    subl %ebx, %eax~n", []);
        {'*', _} -> io:fwrite(Device, "    imull %ebx, %eax~n", []);
        {'/', _} -> io:fwrite(Device, "    idivl %ebx, %eax~n", [])
    end;

genCodeMainInst(Device, {variable_usage, _Id}, Context) ->
    % TODO
    io:fwrite(Device, "variable_usage~n", []);

genCodeMainInst(Device, {integer, {integer, N, _}}, Context) ->
    io:fwrite(Device, "    movl $~p, %eax~n", [N]);

genCodeMainInst(Device, {fun_call, _Id, _Args}, Context) ->
    % TODO
    io:fwrite(Device, "fun_call~n", []).
