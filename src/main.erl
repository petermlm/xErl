-module(main).
-author("Pedro Melgueira").
-compile(export_all).

main([Input, Output]) ->
    % Get the program's source
    {ok, InDevice} = try file:open(Input, [read])
                     catch _ -> io:fwrite("TODO")
                     end,

    Source = try getSource(InDevice)
    after file:close(InDevice)
    end,

    % Execute scanner and parser
    {ok, Tokens, _LinesNum} = scanner:string(Source),
    {ok, AST} = parser:parse(Tokens),

    % Check semantics
    Context = try
        semantics:checkSemanticAST(AST)
    catch
        throw:{context, Msg} ->
            io:format("Context error: ~s.~n", [Msg])
    end,

    % Make output
    {ok, OutDevice} = try file:open(Output, [write])
                      catch _ -> io:fwrite("TODO")
                      end,

    try genCode:genCode(OutDevice, AST, Context)
    after file:close(OutDevice)
    end.

getSource(Device) ->
    case io:get_line(Device, "") of
        eof -> "";
        Str -> Str ++ getSource(Device)
    end.
