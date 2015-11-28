-module(context).
-author("Pedro Melgueira").
-compile(export_all).

addLocalContext(Args, Context) ->
    addLocalContext(Args, 0, Context).

addLocalContext([], _Number, Context) -> Context;

addLocalContext([{identifier, Id, _Lo} | ArgsT], Number, Context) ->
    Context2 = dict:store(Id, {argument, Number}, Context),
    addLocalContext(ArgsT, Number+1, Context2).

% -----------------------------------------------------------------------------

makeArgsList([]) -> [];

makeArgsList([{identifier, Id, _Lo} | Tail]) ->
    [Id] ++ makeArgsList(Tail).
