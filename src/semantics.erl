-module(semantics).
-author("Pedro Melgueira").
-compile(export_all).

checkSemanticAST(AST) ->
    checkSemanticAST(AST, dict:new()).

checkSemanticAST([], Context) -> Context;

checkSemanticAST([Head | Tail], Context) ->
    Context2 = checkSemantic(Head, Context),
    checkSemanticAST(Tail, Context2).

checkSemantic(Element, Context) ->
    case Element of
        {assign, {identifier, Id, _Lo}, Expr} ->
            % Check if the name already exists
            Context2 = case dict:is_key(Id, Context) of
                true -> Context;
                false -> dict:store(Id, variable, Context)
            end,

            checkSemantic(Expr, Context2);

        {fun_decl, {identifier, Id, _Lo}, Args, Expr} ->
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

        {integer, _, _} -> Context;

        {variable_usage, {identifier, Id, Lo}} ->
            % Check if name of the variable has been defined
            _VarValue = try dict:fetch(Id, Context)
                       catch error:_ ->
                            Msg = io_lib:format("Variable ~s not declared on line ~p", [Id, Lo]),
                            throw({context, Msg})
                       end,
            Context;

        {expr, _Op, Expr1, Expr2} ->
            checkSemantic(Expr1, Context),
            checkSemantic(Expr2, Context),
            Context;

        {fun_call, {identifier, Id, Lo}, CallArgs} ->
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

            Context
    end.
