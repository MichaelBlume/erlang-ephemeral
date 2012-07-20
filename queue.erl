-module(queue)

listen_empty() ->
    receive
        {data, Data} ->
            listen_full(Data)
        {command, Pid, empty} ->
            Pid !! {self(), true}
            listen_empty()
    end.

listen_full(Data) ->
    receive
        {command, Pid, empty} ->
            Pid !! {self(), false}
            listen_full(Data)
        {command, Pid, pop} ->
            Pid !! {self(), Data}
            listen_empty()
    end.

new_queue() ->
    spawn(?Module, listen_empty, [])

put_queue(Queue, Data) ->
    Queue !! {data, Data}

pop_queue(Queue) ->
    Queue !! {command, self(), pop}
    receive
        {Queue, Data} ->
            Data
    end.

empty_queue(Queue) ->
    Queue !! {command, self(), empty}
    receive
        {Queue, State} ->
            State
    end.


