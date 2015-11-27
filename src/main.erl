-module(main).
-author("Pedro Melgueira").
-compile(export_all).

pexe([A]) -> io:fwrite("~p~n", [A]).

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

    io:write(Tokens),
    io:write(AST).

getSource(Device) ->
    case io:get_line(Device, "") of
        eof -> "";
        Str -> Str ++ getSource(Device)
    end.
