-module(supdls_tcp).

-export_type([
        
    ]).
-export([
        start/0
      , connected/1
    ]).

start() ->
    {ok, Port} = application:get_env(supdls, port),
    {ok, ListenSocket} = gen_tcp:listen(Port, [{active, true}, binary]),
    accept(ListenSocket).
    
accept(ListenSocket) ->
    {ok, Port} = gen_tcp:accept(ListenSocket),
    spawn(supdls_tcp, connected, [Port]),
    accept(ListenSocket).
    
connected(Port) ->
    {ok, DataPath} = application:get_env(supdls, data_path),
    {ok, Data} = file:read_file(DataPath),
    FileName = case filename:basename(DataPath) of
        FN when is_list(FN) ->
            list_to_binary(FN);
        FN -> FN
    end,
    Size = integer_to_binary(size(Data)),
    gen_tcp:send(Port, <<"HTTP/1.1 200\r\n"
      , "content-type: application/octet-stream\r\n"
      , "content-disposition: attachment; filename="
      , FileName/binary, "\r\n"
      , "Content-Length: ", Size/binary, "\r\n"
      , "\r\n">>),
    send(Port, Data, 0).

send(Port, <<H:60000/binary, T/binary>>, Count) ->
    gen_tcp:send(Port, H),
    send(Port, T, Count+1);
send(Port, Data, _Count) ->
    gen_tcp:send(Port, Data),
    ok.
    



