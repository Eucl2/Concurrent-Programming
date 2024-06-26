-module(server).
-export([start/1, stop/1]).
-import(login_manager,[start/0, 
        create_account/2,
        close_account/2,
        login/2,
        logout/2,
        online/0]).
-import(state,[join_room/2,login_state/1,check_state/5,ganhou/2]).

start(Port) -> spawn(fun() -> server(Port) end).
stop(Server) -> Server ! stop.

server(Port) ->
    {ok, LSock} = gen_tcp:listen(Port, [binary, {packet, line}, {reuseaddr, true}]),
    spawn(fun()->state:start() end),
    spawn(fun()-> login_manager:start() end),
    Rooms = spawn(fun()->rooms(#{}) end),
    spawn(fun() -> acceptor(LSock, Rooms) end),
    receive
        stop -> ok
    end.

acceptor(LSock, Rooms) ->
    Res = gen_tcp:accept(LSock),
    case Res of
        {ok, Sock} ->
            spawn(fun() -> acceptor(LSock, Rooms) end),
            Rooms ! {self()},
            user(Sock, Rooms, "Anonymous");
        {error, closed} ->
            ok
    end.


rooms(Pids) ->
    receive
        {Pid} ->
            NewPids = maps:put(Pid, "Anonymous", Pids),
            io:fwrite("User detetado\n"),
            rooms(NewPids);
            

        {create_account,RealName,RealPass,Pid}->
            Res=login_manager:create_account(RealName,RealPass),
            Message="Account "++RealName++" com pass "++RealPass++" criada\n",
            if 
                Res == ok->sendMessage(Pid,"Criada\n"),io:fwrite(Message);
                true -> handleError("Nao deu",Pid)
                end,
            
            rooms(Pids);

        {close_account,RealName,RealPass,Pid}->
            Res=login_manager:close_account(RealName,RealPass),
            Message="Account "++RealName++" com pass "++RealPass++" removida\n",
            
            if 
                Res == ok->sendMessage(Pid,"Removida\n"),io:fwrite(Message);
                true -> handleError("Nao deu",Pid)
                end,
            rooms(Pids);
        

        {login,RealName,RealPass,Pid}->
            Res=login_manager:login(RealName,RealPass),
            if Res==invalid ->
                    handleError("Invalid account",Pid),
                    rooms(Pids);
                true->
                    if
                        RealName == "Anonymous" ->
                            handleError("Name Anonymous cannot be used.", Pid),
                            rooms(Pids);
                        true ->
                            case lists:member(RealName, [UUser || {_, UUser} <- maps:to_list(Pids)]) of
                                true ->
                                    handleError("User " ++ RealName ++ " already exists", Pid),
                                    rooms(Pids);
                                false ->
                                    NewPids = maps:put(Pid, RealName, Pids),
                                    Res=state:login_state(RealName),
                                    if Res==ok->
                                        io:fwrite("Anonymous changed username to "++RealName++"\n"),
                                        sendMessage(Pid, "Logou\n")
                                    end,
                                    rooms(NewPids)
                            end
                end
            end;

        {logout,RealName,RealPass,Pid} ->
            Res=login_manager:logout(RealName,RealPass),
            if Res==invalid->
                    handleError("Invalide account",Pid),
                    rooms(Pids);
                true->
                    
                    io:fwrite("Changed name to Anonymous\n"),
                    NewPids = maps:put(Pid, "Anonymous", Pids),
                    
                    sendMessage(Pid,"Logged out\n"),
                    rooms(NewPids)

            end
            
    end.


sendMessage(Pid, Message) ->
    Pid ! {broadcast, Message}.

handleError(Error, Pid) ->
    io:format("Error: ~p~n", [Error]),
    sendMessage(Pid, "Error: " ++ Error ++ "\n").


user(Sock, Rooms, User) ->
   
    receive
        {broadcast, Data} ->
            
            gen_tcp:send(Sock, Data),
            user(Sock, Rooms, User);
        {tcp, _, Data} ->
            case re:split(Data, " ", [{parts, 2}]) of
                %join room user_name
                [<<"join">>, Content] ->
                    [Room,Jogador]=re:split(Content," ",[{parts,2}]),  
                    RealRoom=string:trim(binary_to_list(Room)),
                    RealJogador=string:trim(binary_to_list(Jogador)),
                    Res=state:join_room(RealRoom,RealJogador),
                    case Res of
                        ok->
                            io:fwrite(RealJogador ++ " entrou na sala: "++RealRoom++"\n"),
                            gen_tcp:send(Sock, "JoinedRoom\n");
                        invalid->
                            io:fwrite(RealJogador++" tentou entrar na sala: "++RealRoom++" Mas jÃ¡ tem um jogo a decorrer\n"),
                            gen_tcp:send(Sock, "Error: FailedToJoinRoom\n")
                    end,
                    user(Sock, Rooms, User);

                [<<"logout">>, Content] ->
                    [Name,Pass]=re:split(Content," ",[{parts,2}]),  
                    RealName=string:trim(binary_to_list(Name)),
                    RealPass=string:trim(binary_to_list(Pass)),
                    Rooms ! {logout,RealName,RealPass,self()},
                    user(Sock,Rooms,User);
                [<<"create_account">>,Content]->
                    [Name,Pass]=re:split(Content," ",[{parts,2}]),  
                    RealName=string:trim(binary_to_list(Name)),
                    RealPass=string:trim(binary_to_list(Pass)),
                    Rooms ! {create_account,RealName,RealPass,self()},
                    user(Sock,Rooms,User);

                [<<"close_account">>,Content]->
                    [Name,Pass]=re:split(Content," ",[{parts,2}]),  
                    RealName=string:trim(binary_to_list(Name)),
                    RealPass=string:trim(binary_to_list(Pass)),
                    Rooms ! {close_account,RealName,RealPass,self()},
                    user(Sock,Rooms,User);

                [<<"login">>,Content]->
                    [Name,Pass]=re:split(Content," ",[{parts,2}]),  
                    RealName=string:trim(binary_to_list(Name)),
                    RealPass=string:trim(binary_to_list(Pass)),
                    Rooms ! {login,RealName,RealPass,self()},
                    user(Sock,Rooms,User);

                [<<"check_pos">>,Content]->
                    [Pid_jogo,X,Y,F,User1]=re:split(Content," ",[{parts,5}]),

                    RealPid=string:trim(binary_to_list(Pid_jogo)),
                    RealX=string:trim(binary_to_list(X)),
                    RealY=string:trim(binary_to_list(Y)),
                    RealFu=string:trim(binary_to_list(F)),
                    RealUser=string:trim(binary_to_list(User1)),
                    Res=check_state(RealPid,list_to_float(RealX),list_to_float(RealY),list_to_float(RealFu),RealUser),
                    
                    gen_tcp:send(Sock,Res),
                  
                    user(Sock,Rooms,User);
                [<<"Ganhou">>,Content]->
                    [Pid_jogo,User1]=re:split(Content," ",[{parts,2}]),
                    RealPid=string:trim(binary_to_list(Pid_jogo)),
                    RealUser=string:trim(binary_to_list(User1)),
                    ganhou(RealPid,RealUser),
                    user(Sock,Rooms,User);
                _ ->
                    gen_tcp:send(Sock, "Error: Incorrect syntax. Use:\n"),
                    
                    user(Sock, Rooms, User)
            end;
        {tcp_closed, _} ->
            Rooms ! {logout, self()};
        {tcp_error, _, _} ->
            Rooms ! {logout, self()};
        _ ->
            io:fwrite("ERROR\n")
    end.