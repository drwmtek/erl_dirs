
-module(server_node).
-export([start/0, loop/0, get_dirs/1]).
start() ->
	io:fwrite("Server started...~nNode name '~s'~n", [node()]),
	Pid = spawn(fun() -> loop() end),
	register(srv_node, Pid),
	{registered_name, Alias} = process_info(Pid, registered_name),
	io:fwrite("Current PID is ~w, Current alias is '~p'~n", [Pid, Alias]).

loop() ->
receive
	{From, Msg} ->
		io:fwrite("~s~n", [Msg]),
		{ok, Listing} = file:list_dir(Msg),
		io:fwrite("~w", Listing),
		From ! {whereis(srv_node), Listing},
		loop();
	stop ->
		true
	end.

get_dirs(Dir) ->
case file:list_dir(Dir) of
        {ok, Filenames} ->
            lists:foreach(fun(Name) ->
            	io:format("~tp~n", [Name])
            end, Filenames);
        {error, enoent} ->
            io:format("The directory(~s) does not exist.~n", [Dir]),
            ng
    end.