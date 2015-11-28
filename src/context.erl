-module(context).
-author("Pedro Melgueira").
-compile(export_all).

addLocalContext([], Context) -> Context;

addLocalContext([{identifier, Id, _Lo} | ArgsT], Context) ->
    Context2 = dict:store(Id, argument, Context),
    addLocalContext(ArgsT, Context2).

makeArgsList([]) -> [];

makeArgsList([{identifier, Id, _Lo} | Tail]) ->
    [Id] ++ makeArgsList(Tail).
