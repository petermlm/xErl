-module(genCode).
-author("Pedro Melgueira").
-compile(export_all).


genCode(Device, AST, Context) ->
    % Generate .bss part
    genBSS(Device, Context),
    MappedContext = mapVariablesToBuffer(dict:to_list(Context)),

    % Generate .data part
    genData(Device),

    % Generate functions and _start
    io:fwrite(Device, ".section .text~n~n", []),
    genFuncDecls(Device, AST, MappedContext),
    genCodeMain(Device, AST, MappedContext).

% -----------------------------------------------------------------------------

mapVariablesToBuffer(ContextList) ->
    mapVariablesToBuffer(ContextList, 0, dict:new()).

mapVariablesToBuffer([], _Counter, MappedContext) -> MappedContext;

mapVariablesToBuffer([{Id, variable} | T], Counter, MappedContext) ->
    MappedContext2 = dict:store(Id, {variable, Counter}, MappedContext),
    mapVariablesToBuffer(T, Counter+1, MappedContext2);

mapVariablesToBuffer([{{Id, ArgsNum}, Args} | T], Counter, MappedContext) ->
    MappedContext2 = dict:store({Id, ArgsNum}, {Args, 0}, MappedContext),
    mapVariablesToBuffer(T, Counter, MappedContext2).

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

genData(Device) ->
    io:fwrite(Device, ".section .data~n", []),
    io:fwrite(Device, "OUTPUT_FORMAT:~n", []),
    io:fwrite(Device, "    .ascii \"%d\\n\\0\"~n~n", []).

% -----------------------------------------------------------------------------

genFuncDecls(Device, AST, Context) ->
    genFuncDecls(Device, AST, Context, dict:new()).

genFuncDecls(_Device, [], _Context, _Counters) -> ok;

genFuncDecls(Device, [{fun_decl, {identifier, Id, _}, Args, FunBody} | AST_Tail], Context, Counters) ->
    % Get count of the function
    Counters2 = dict:update_counter({Id, length(Args)}, 1, Counters),
    Count = dict:fetch({Id, length(Args)}, Counters2),

    % Write head of the function
    io:fwrite(Device, ".type ~s_~p_~p, function~n", [Id, length(Args), Count]),
    io:fwrite(Device, "~s_~p_~p:~n", [Id, length(Args), Count]),

    % Function's prologue
    io:fwrite(Device, "    pushl %ebp~n", []),
    io:fwrite(Device, "    movl %esp, %ebp~n", []),

    % Function's body
    LocalContext = context:addLocalContext(Args, Context),
    genCodeMainInst(Device, FunBody, LocalContext),

    % Function's epilogue
    io:fwrite(Device, "    movl %ebp, %esp~n", []),
    io:fwrite(Device, "    popl %ebp~n", []),
    io:fwrite(Device, "    ret~n~n", []),

    genFuncDecls(Device, AST_Tail, Context, Counters2);

genFuncDecls(Device, [_ | AST_Tail], Context, Counters) ->
    genFuncDecls(Device, AST_Tail, Context, Counters).

% -----------------------------------------------------------------------------

genCodeMain(Device, AST, Context) ->
    % Start label
    io:fwrite(Device, ".globl _start~n", []),
    io:fwrite(Device, "_start:~n", []),

    % Initialize Program
    io:fwrite(Device, "    movl %esp, %ebp~n", []),
    io:fwrite(Device, "    subl $0, %esp~n", []),

    % Code for the function
    genCodeMainAST(Device, AST, Context),

    % Exit
    io:fwrite(Device, "    movl $1, %eax~n", []),
    io:fwrite(Device, "    movl $0, %ebx~n", []),
    io:fwrite(Device, "    int $0x80~n", []).

genCodeMainAST(_Device, [], Context) -> Context;

genCodeMainAST(Device, [AST_Ele | AST_Tail], Context) ->
    Context2 = genCodeMainInst(Device, AST_Ele, Context),
    genCodeMainAST(Device, AST_Tail, Context2).

genCodeMainInst(Device, {expr_stat, Expr}, Context) ->
    % Generate the code for the expression
    genCodeMainInst(Device, Expr, Context),

    % Make the output
    io:fwrite(Device, "    push %eax~n", []),
    io:fwrite(Device, "    push $OUTPUT_FORMAT~n", []),
    io:fwrite(Device, "    call printf~n", []),

    Context;

genCodeMainInst(Device, {assign, {identifier, Id, _Lo}, Expr}, Context) ->
    % Expression code
    Context2 = genCodeMainInst(Device, Expr, Context),

    % Get address of buffer for variable
    {variable, Offset} = dict:fetch(Id, Context2),

    % Assignment code
    io:fwrite(Device, "    movl $VARS, %ebx~n", []),
    io:fwrite(Device, "    movl $~p, %ecx~n", [Offset]),
    io:fwrite(Device, "    movl %eax, (%ebx, %ecx, 4)~n", []),

    Context2;

genCodeMainInst(_Device, {fun_decl, {identifier, Id, _}, Args, _Expr}, Context) ->
    {ArgsList, FunCount} = dict:fetch({Id, length(Args)}, Context),
    dict:store({Id, length(Args)}, {ArgsList, FunCount+1}, Context);

genCodeMainInst(Device, {expr, Op, Expr1, Expr2}, Context) ->
    % Code for first expression
    Context2 = genCodeMainInst(Device, Expr1, Context),
    io:fwrite(Device, "    pushl %eax~n", []),

    % Code for second expression
    Context3 = genCodeMainInst(Device, Expr2, Context2),

    % Code for this expression's op
    case Op of
        {'+', _} -> io:fwrite(Device, "    popl %ebx~n", []),
                    io:fwrite(Device, "    addl %eax, %ebx~n", []),
                    io:fwrite(Device, "    movl %ebx, %eax~n", []);

        {'-', _} -> io:fwrite(Device, "    popl %ebx~n", []),
                    io:fwrite(Device, "    subl %eax, %ebx~n", []),
                    io:fwrite(Device, "    movl %ebx, %eax~n", []);

        {'*', _} -> io:fwrite(Device, "    popl %ebx~n", []),
                    io:fwrite(Device, "    imull %eax, %ebx~n", []),
                    io:fwrite(Device, "    movl %ebx, %eax~n", []);

        {'/', _} -> io:fwrite(Device, "    movl %eax, %ebx~n", []),
                    io:fwrite(Device, "    popl %eax~n", []),
                    io:fwrite(Device, "    movl $0, %edx~n", []),
                    io:fwrite(Device, "    idiv %ebx~n", []);

        {'%', _} -> io:fwrite(Device, "    movl %eax, %ebx~n", []),
                    io:fwrite(Device, "    popl %eax~n", []),
                    io:fwrite(Device, "    movl $0, %edx~n", []),
                    io:fwrite(Device, "    idiv %ebx~n", []),
                    io:fwrite(Device, "    movl %edx, %eax~n", [])
    end,

    Context3;

genCodeMainInst(Device, {variable_usage, {identifier, Id, _Lo}}, Context) ->
    % Get address buffer for variable
    {Scope, Offset} = dict:fetch(Id, Context),

    % Usage code
    case Scope of
        variable ->
            io:fwrite(Device, "    movl $VARS, %ebx~n", []),
            io:fwrite(Device, "    movl $~p, %ecx~n", [Offset]),
            io:fwrite(Device, "    movl (%ebx, %ecx, 4), %eax~n", []);

        argument ->
            io:fwrite(Device, "    movl ~p(%ebp), %eax~n", [(2+Offset)*4])
    end,

    Context;

genCodeMainInst(Device, {integer, {integer, N, _}}, Context) ->
    io:fwrite(Device, "    movl $~p, %eax~n", [N]),
    Context;

genCodeMainInst(Device, {neg, Expr}, Context) ->
    % Code for the expression
    genCodeMainInst(Device, Expr, Context),

    % Negate it
    io:fwrite(Device, "    negl %eax~n", []);

genCodeMainInst(Device, {fun_call, {identifier, Id, _Lo}, Args}, Context) ->
    % Put arguments
    genCodeFunDeclArgs(Device, Args, Context),

    % Call
    {_, FunCount} = dict:fetch({Id, length(Args)}, Context),
    io:fwrite(Device, "    call ~s_~p_~p~n", [Id, length(Args), FunCount]),

    % Reposition stack
    io:fwrite(Device, "    addl $~p, %esp~n", [length(Args)*4]),

    Context.

genCodeFunDeclArgs(_Device, [], _Context) -> ok;

genCodeFunDeclArgs(Device, [Ele_Args | Tail_Args], Context) ->
    % Arguments are placed in reserve order, so go recursivly first
    genCodeFunDeclArgs(Device, Tail_Args, Context),

    % Generate code for this argument
    genCodeMainInst(Device, Ele_Args, Context),
    io:fwrite(Device, "    pushl %eax~n", []).
