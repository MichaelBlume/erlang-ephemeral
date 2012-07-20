-module(mvar)

listen_full(Data) ->
    receive
        {Pid, take} ->
            Pid !! {self(), Data}
            listen_empty()
        {Pid, check} ->
            Pid !! {self(), true}
            listen_full(Data)
    end.

listen_empty() ->
    receive
        {Pid, {set, Data}} ->
            Pid !! {self(), ok}
            listen_full(Data)
        {Pid, check} ->
            Pid !! {self(), false}
            listen_empty()
    end.

empty_mvar() ->
    spawn(?Module, listen_empty, [])

set_mvar(MVar, Data) ->
    MVar !! {self(), {set, Data}}
    receive
        {MVar, ok} -> ok
    end.

take_mvar(MVar) ->
    MVar !! {self(), take}
    receive
        {MVar, Data} -> Data
    end.

check_mvar(MVar) ->
    MVar !! {self(), check}
    receive
        {MVar, State} -> State
    end.


