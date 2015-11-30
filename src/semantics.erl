-module(semantics).
-author("Pedro Melgueira").
-compile(export_all).

checkSemanticAST(AST) ->
    checkSemanticAST(AST, dict:new()).

checkSemanticAST([], Context) -> Context;

checkSemanticAST([Head | Tail], Context) ->
    Context2 = checkSemantic(Head, Context),
    checkSemanticAST(Tail, Context2).

% -----------------------------------------------------------------------------

checkSemantic({expr_stat, Expr}, Context) ->
    checkSemantic(Expr, Context);

checkSemantic({assign, {identifier, Id, _Lo}, Expr}, Context) ->
    % Check if the name already exists
    Context2 = case dict:is_key(Id, Context) of
        true -> Context;
        false -> dict:store(Id, variable, Context)
    end,

    checkSemantic(Expr, Context2);

checkSemantic({fun_decl, {identifier, Id, _Lo}, Args, Expr}, Context) ->
    % Check if the function's name already exists
    Context2 = case dict:is_key({Id, length(Args)}, Context) of
        true -> Context;
        false ->
            % Store this new function declaration
            ArgsList = context:makeArgsList(Args),
            ContextNew = dict:store({Id, length(Args)},
                                    ArgsList,
                                    Context),
            ContextNew
    end,

    % Check the context of the local scope
    ContextLocal = context:addLocalContext(Args, Context2),
    checkSemantic(Expr, ContextLocal),

    Context2; % The context doens't contain the local scope

checkSemantic({'if', ExprBool, Statments}, Context) ->
    % Check the expression
    checkSemantic(ExprBool, Context),

    % Check the statements
    checkSemanticAST(Statments, Context);

checkSemantic({'ifelse', ExprBool, Statments, ElseStatments}, Context) ->
    % Check the expression
    checkSemantic(ExprBool, Context),

    % Check the statements
    Context2 = checkSemanticAST(Statments, Context),
    checkSemanticAST(ElseStatments, Context2);

checkSemantic({'while', ExprBool, Statments}, Context) ->
    % Check the expression
    checkSemantic(ExprBool, Context),

    % Check the statements
    checkSemanticAST(Statments, Context);

checkSemantic({integer, _}, Context) -> Context;

checkSemantic({neg, Expr}, Context) ->
    checkSemantic(Expr, Context),
    Context;

checkSemantic({variable_usage, {identifier, Id, Lo}}, Context) ->
    % Check if name of the variable has been defined
    try dict:fetch(Id, Context)
    catch error:_ ->
         Msg = io_lib:format("Variable ~s not declared on line ~p", [Id, Lo]),
         throw({context, Msg})
    end,
    Context;

checkSemantic({expr_bool, _Op, Expr1, Expr2}, Context) ->
    checkSemantic(Expr1, Context),
    checkSemantic(Expr2, Context),
    Context;

checkSemantic({expr_bool_lp, _Op, Expr1, Expr2}, Context) ->
    checkSemantic(Expr1, Context),
    checkSemantic(Expr2, Context),
    Context;

checkSemantic({expr, _Op, Expr1, Expr2}, Context) ->
    checkSemantic(Expr1, Context),
    checkSemantic(Expr2, Context),
    Context;

checkSemantic({fun_call, {identifier, Id, Lo}, CallArgs}, Context) ->
    % Check if the function exists
    Args = try dict:fetch({Id, length(CallArgs)}, Context)
           catch error:_ ->
                Msg = io_lib:format("Function ~s not declared on line ~p", [Id, Lo]),
                throw({context, Msg})
           end,

    % Check if the arguments are correct
    if length(CallArgs) /= length(Args) ->
        throw({context, io_lib:format("Arguments of call to ~s in line ~p are wrong.", [Id, Lo])});
        true -> ok
    end,

    Context.
