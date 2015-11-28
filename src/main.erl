-module(main).
-author("Pedro Melgueira").
-compile(export_all).

main([Input]) ->
    % Get the program's source
    {ok, Device} = try file:open(Input, [read])
                   catch _ -> io:fwrite("Kia")
                   end,

    Source = try getSource(Device)
    after file:close(Device)
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

    %% io:write(Tokens),
    %% io:write(AST),
    io:write(dict:to_list(Context)),
    io:fwrite("~s~n", [ok]).

getSource(Device) ->
    case io:get_line(Device, "") of
        eof -> "";
        Str -> Str ++ getSource(Device)
    end.
