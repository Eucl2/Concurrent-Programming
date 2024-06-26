-module(login_manager).
-export([start/0, 
        create_account/2,
        close_account/2,
        login/2,
        logout/2,
        online/0]).

%Consideremos User ->{Passwd, Online}

start() -> register(?MODULE,spawn(fun()-> loop(#{}) end)).



create_account(User, Pass) -> ?MODULE ! {{create_account, User, Pass}, self()}, receive {Res,?MODULE} -> Res end.

close_account(User, Pass) -> ?MODULE ! {{close_account, User, Pass}, self()}, receive{Res, ?MODULE} -> Res end. 

login(User, Pass) -> ?MODULE ! {{login, User, Pass}, self()}, receive{Res, ?MODULE} -> Res end. 

logout(User, Pass) -> ?MODULE ! {{logout, User, Pass}, self()}, receive{Res, ?MODULE} -> Res end.

online() -> ?MODULE ! {online, self()}, receive{Res, ?MODULE} -> Res end.


loop(Map) ->
        receive
                {Request, From} ->
                        {Res, NewMap} = handle(Request, Map),
                        From ! {Res, ?MODULE},
                        loop(NewMap)
        end.



handle({create_account, User, Pass}, Map) ->
          case maps:is_key(User, Map) of
                true -> 
                        {user, Map};
                false -> 
                        {ok, maps:put(User, {Pass, false}, Map)}
          end;


handle({close_account, User, Pass}, Map) ->
          case maps:find(User,Map) of
                {ok,{Pass, _}} -> 
                        {ok, maps:remove(User,Map)}; 
                _ -> 
                        {invalid, Map}
          end;


handle({login, User, Pass}, Map) ->
        case maps:find(User, Map) of
                {ok, {Passwd, false}} ->
                        if
                        (Pass == Passwd) -> {ok, maps:update(User, {Pass, true}, Map)};
                        true -> {invalid, Map}
                        end;
                _ -> {invalid, Map}
        end;


handle({logout, User, Pass}, Map) ->
        case maps:find(User, Map) of
                {ok, {Passwd, true}} ->
                        if
                        (Pass == Passwd) -> {ok, maps:update(User, {Pass, false}, Map)};
                        true -> {invalid, Map}
                        end;
                _ -> {invalid, Map}
        end;


handle(online, Map)     -> 
        Pred = fun(_, {_, State}) -> State end,
        M = maps: filter(Pred, Map),
        {maps: keys(M), Map}.