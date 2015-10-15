-module(redis_proxy).
-export([main/0]).
-export([start/0]).

-mode(compile).

-define(TRACE(X), io:format("TRACE ~p:~p ~p~n", [?FILE, ?LINE, X])).

start() ->
  start(6380).

start(BindPort) ->
  start(BindPort, "0.0.0.0").

start(BindPort, null) ->
  start(BindPort);
start(BindPort, BindIp) ->
  redis_proxy(BindPort, BindIp).

loop(Listen) ->
  {ok, Socket} = gen_tcp:accept(Listen),
  spawn(fun() -> loop(Listen) end),
  % { ok, RemoteSocket } = gen_tcp:connect({127,0,0,1}, 6379, []),
  % { ok, RemoteSocket } = gen_tcp:connect({192,168,200,11}, 6379, []),
  receive
    {tcp, Socket, <<Ip:32,Port:16,Data/binary>>} ->
%      { ok, { SrcIp, SrcPort } } = inet:peername(Socket),
%%      io:format("Client is ~p:~p ~n", [ SrcIp, SrcPort ]),
% filter rules
%      case SrcIp of
%        {127,0,0,1} ->
%           exit(1)
%      end,
      case <<Ip:32>> of
%        <<127,0,0,1>> ->
%           exit(1);
        <<0,0,0,0>> ->
           exit(1);
        {106,75,198,50} ->
           case <<Port:16>> of
              <<0,80>> ->
                true;
              _AnyPort ->
                exit(1)
           end;
        _Any ->
          true
      end,
      { ok, RemoteSocket } = gen_tcp:connect(list_to_tuple(binary_to_list(<<Ip:32>>)), Port, []),
      gen_tcp:send(RemoteSocket, Data),
      process_data(Socket, RemoteSocket);
    _Any ->
      ?TRACE( {invalid_packet_data, _Any} )
  end.
%  receive
%    {tcp, Socket, Data} ->
%      process_data(Socket, RemoteSocket)
%    {tcp_closed, Socket} ->
%      io:format("Client closed connection ~p~n", [Socket])
%  end.

process_data(Socket, RemoteSocket) ->
  receive
    {tcp, Socket, Data} ->
      % io:format("Received from client: ~p~n", [Data]),
      gen_tcp:send(RemoteSocket, Data),
      % io:format("send to proxy server: ~p ~p ~n", [RemoteSocket, encode(Data)]),
      process_data(Socket, RemoteSocket);

    {tcp, RemoteSocket, RemoteData} ->
      io:format("Received from remote: ~p~n", [RemoteData]),
      gen_tcp:send(Socket, RemoteData),
      process_data(Socket, RemoteSocket);

    {tcp_closed, Socket} ->
      io:format("Client closed connection ~p~n", [Socket]),
      gen_tcp:close(RemoteSocket);

    {tcp_closed, RemoteSocket} ->
      io:format("Remote closed connection ~p~n", [RemoteSocket]),
      gen_tcp:close(Socket)

  end.

redis_proxy(BindPort, BindIp) ->
  { ok, Ip } = inet:parse_address(BindIp),
  % {ok, Listen} = gen_tcp:listen(Port, [ binary, {ip, Ip}, {reuseaddr, true}, {nodelay, true}, {active, true} ]),
  {ok, Listen} = gen_tcp:listen(BindPort, [ binary, {ip, Ip}, {reuseaddr, true}, {active, true} ]),
  % ?TRACE([ Port, [ binary, {ip, Ip}, {reuseaddr, true}, {nodelay, true}, {active, true} ] ]),
  spawn(fun() -> loop(Listen) end).

main() ->
  Args = init:get_plain_arguments(),
  {BindPort, _} = string:to_integer(get(Args, 0, "6380")),
  ?TRACE([ BindPort, get(Args, 1, null)  ]),
  start(BindPort, get(Args, 1, null)),
  timer:sleep(infinity). % sleep forever

get([], _) ->
  null;

get([H | _], 0) ->
  H;
get([_ | T], I) ->
  get(T, I - 1).

get(L, I, Default) ->
  E = get(L, I),
  case E of
    null ->
      Default;
    _ ->
      E
  end.

