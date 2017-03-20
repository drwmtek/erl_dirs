
-module(client_node).
-export([start/1, ask_loop/2, send/1]).
start(Server) ->
	io:fwrite("Client started...~nNode name '~s'~n", [node()]),
	net_kernel:connect_node(Server),
	Pid = rpc:call(Server, erlang, whereis, [srv_node]),
	Get_msg_pid = spawn(fun () -> get_msg() end),
	Ask_pid = spawn(fun () -> ask_loop(Pid, Get_msg_pid) end),
	register(ask_pid, Ask_pid).

send(Text) ->
	io:fwrite("~p", [whereis(ask_pid)]),
	whereis(ask_pid) ! {Text}.

ask_loop(Pid, Get_msg_pid) ->
receive
	{Mess} ->
		io:fwrite("~p  ~p~n", [Pid, Get_msg_pid]),
		Pid ! {Get_msg_pid, Mess},
		ask_loop(Pid, Get_msg_pid)
	end.

get_msg() ->
receive
	{From, Msg} ->
		io:fwrite("~w", [Msg]),
		[io:format("~tp~n", [I]) || I <- Msg],
		get_msg();
	stop ->
		true
	end.