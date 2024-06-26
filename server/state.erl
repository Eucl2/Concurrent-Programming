-module (state).
-export([start/0,join_room/2,login_state/1,check_state/5,ganhou/2]).
-import(string,[equal/2]).

start() -> register(?MODULE,spawn(fun()-> loop(#{},#{},[],0) end)).

login_state(Jogador) -> ?MODULE ! {{login,Jogador}, self()}, receive {Res,?MODULE} -> Res end.

join_room(Room,Jogador) -> ?MODULE ! {{join_room, Room,Jogador}, self()}, receive {Res,?MODULE} -> Res end.

acabou_func(User,Room)-> ?MODULE !{{acabou,User,Room},self()}, receive {Res,?MODULE}-> Res end.

loop(Map_Rooms,Map_wins,LeaderBoard,Mapas_a_correr) ->
  receive
    {Request, From} ->
      {Res,NewMap_Rooms,NewMap_wins,NewLeaderBoard,NewMapas_a_correr} = handle(Request,Map_Rooms,Map_wins,LeaderBoard,Mapas_a_correr,From),
      From ! {Res, ?MODULE},
      loop(NewMap_Rooms,NewMap_wins,NewLeaderBoard,NewMapas_a_correr)
  end.


handle({login,Jogador},Map_Rooms,Map_wins,LeaderBoard,Mapas_a_correr,_)->
  NewMap=maps:put(Jogador,0,Map_wins),
  {ok,Map_Rooms,NewMap,LeaderBoard,Mapas_a_correr};

handle({acabou,User,Room},Map_Rooms,Map_wins,LeaderBoard,Mapas_a_correr,_)->
  NewMap_Rooms=maps:remove(Room,Map_Rooms),
  I=maps:get(User,Map_wins),
  NewMap_Wins=maps:put(User,I+1,Map_wins),

  {ok,NewMap_Rooms,NewMap_Wins,LeaderBoard,Mapas_a_correr-1};

handle({join_room, Room,Jogador},Map_Rooms,Map_wins,LeaderBoard,Mapas_a_correr,Pid) ->
  case maps:is_key(Room, Map_Rooms) of
    true ->
      io:fwrite("Criar room\n"),
      {ok,{Waiting,List}}=maps:find(Room,Map_Rooms),
      if
        (Waiting==waiting) ->
          io:fwrite("o waiting era waiting\n"),

          List2=[{Pid,Jogador}|List],
          NewMap=maps:put(Room,{waiting,List2},Map_Rooms),
          if
            ((length(List2)==2) and (Mapas_a_correr < 4)) ->

              NewMap2=maps:put(Room,{running,[]},Map_Rooms),
              spawn(fun()->jogo(List2,Room) end),
              {ok,NewMap2,Map_wins,LeaderBoard,Mapas_a_correr+1};
            true->
              {ok,NewMap,Map_wins,LeaderBoard,Mapas_a_correr}
          end;
        true->
          io:fwrite("o waiting era running"),
          {invalid,Map_Rooms,Map_wins,LeaderBoard,Mapas_a_correr}
      end;

    false ->
      io:fwrite("primeira vez que cria a sala ---> "++Room++"\n"),
      NewMap=maps:put(Room,{waiting,[{Pid,Jogador}]},Map_Rooms),
      {ok,NewMap,Map_wins,LeaderBoard,Mapas_a_correr}
  end.



otherFunction(Pid,Mapa)->
  %io:format("É este o pid ------> ~p~n",[Pid]),
  Pidstr=pid_to_list(self())++"\n",
  Pid ! {broadcast,"Comeca\n"},
  Pid ! {broadcast,Pidstr},
  Pid ! {broadcast,Mapa}.

func([],_)->ok;
func([H|T],Mapa)->
  otherFunction(H,Mapa),
  func(T,Mapa).


check_state(Pid_jogo,X,Y,F,User)-> list_to_atom(Pid_jogo) ! {{checkstate,X,Y,F,User},self()}, receive {Res,?MODULE}-> Res end.
ganhou(Pid_jogo,User)->list_to_atom(Pid_jogo) ! {{ganhou,User},self()},receive {Res,?MODULE}-> Res end.



-record(jogador,{user="",size=40.0,x=rand:uniform()*1440,y=rand:uniform()*900,fuel=100.0,state=1,cor=0}).
-record(corpo,{x,y,size,cor,ang}).


%cria uma lista de Max elementos do tipo #corpo{}
for(0,_,L)->
  L;
%gera o sol
for(1,Min,L)->
  L2 = [#corpo{x = 720.0, y = 450.0, size = 100.0, cor = 3,ang= 0.0} | L], %sol
  for(1-1,Min,L2);
for(Max,Min,L) when Max > 0 ->
  X = rand:uniform() * 1000,
  Y = rand:uniform() * 900,
  CenterX = 720.0,
  CenterY = 450.0,
  Ang = math:atan2(Y - CenterY, X - CenterX),
  C = floor(rand:uniform() * 3),
  case C of
    0 ->
      L2 = [#corpo{x = X, y = Y, size = rand:uniform() * 20, cor = C, ang = Ang} | L];
    1 ->
      L2 = [#corpo{x = X, y = Y, size = rand:uniform() * 50, cor = C, ang = Ang} | L];
    2 ->
      L2 = [#corpo{x = X, y = Y, size = rand:uniform() * 60, cor = C, ang = Ang} | L]
  end,
  for(Max - 1, Min, L2).


gera_mapa(Jogadores)->
  List=[#jogador{user=N}||N<-Jogadores],
  List2=for(3,0,[]),
  {List,List2}.

func2([],L)->
  L;
func2([H|T],L)->

  {_,P,_,X,Y,Fuel,State,Cor}=H,
  L2=P++"#"++float_to_list(X, [{decimals, 3}])++"#"++float_to_list(Y, [{decimals, 3}])++"#"++float_to_list(Fuel, [{decimals, 3}])++"#"++integer_to_list(Cor)++"#"++integer_to_list(State)++",",
  L3=[L2|L],
  func2(T,L3).

func3([],L)->
  L;
func3([H|T],L)->
  {_,X,Y,Size,Cor,Ang}=H,
  X2=float_to_list(X, [{decimals, 3}]),
  Y2=float_to_list(Y, [{decimals, 3}]),
  Size2=float_to_list(Size, [{decimals, 3}]),
  Cor2=integer_to_list(Cor),
  Ang2=float_to_list(Ang, [{decimals, 3}]),
  L2=X2++"#"++Y2++"#"++Cor2++"#"++Size2++"#"++Ang2++",",
  L3=[L2|L],
  func3(T,L3).

record_to_string(P,C)->
  List_Players=func2(P,[]),
  List_Corpos=func3(C,[]),
  List_Players++"&"++List_Corpos++"\n".



jogo(List_Pids_jogador,Room)->

  timer:sleep(5000),

  Pidstr=pid_to_list(self()),
  register(list_to_atom(Pidstr),self()),

  Jogadores=[N||{_,N}<-List_Pids_jogador],
  Pids=[P||{P,_}<-List_Pids_jogador],

  {Player,Corpos}=gera_mapa(Jogadores),

  Estado_inic=record_to_string(Player,Corpos),



  func(Pids,Estado_inic),

  loop2({Player,Corpos},Room).


loop2(Mapa,Room)->
  receive
    {Request, From} ->
      {Res,NewMapa} = handle(Mapa,Request,Room),

      if  Res/=acabou->
        From ! {Res, ?MODULE},
        loop2(NewMapa,Room);
        Res==acabou->

          From ! {"acabou\n",?MODULE}
      end
  end.



func4([],L,_)->
  L;
func4([H|T],L,User)->

  {_,P,_,_,_,_,_,_}=H,

  if P==User->
    L3=L;
    P/=User->

      L3=[H|L]

  end,
  func4(T,L3,User).

func5([], L, _, _, _, _) ->
  L;
func5([H|T], L, User, X1, Y1,F1) ->
  {I, P, K, X, Y, _, N, O} = H,
  % centro da tela
  CenterX = 720.0,
  CenterY = 450.0,
  % calcular distância do jogador ao centro
  Distance = math:sqrt((X - CenterX)*(X - CenterX) + (Y - CenterY)*(Y - CenterY)),
  % direção da gravidade
  DirX = (CenterX - X) / Distance,
  DirY = (CenterY - Y) / Distance,
  % intensidade da gravidade
  GravityStrength = 1000 / (Distance * Distance), % Lei do inverso do quadrado
  GravityX = (DirX * GravityStrength) *10,
  GravityY = (DirY * GravityStrength) *10,
  NewX = X1 + GravityX,
  NewY = Y1 + GravityY,
  if
    P == User ->
      % Verifica se o jogador pode se mover

      if(X1 >= 1440 orelse X1 =< 0 orelse Y1 >= 900 orelse Y1 =< 0) ->
        NewState=0,
        {I, P, K, X1, Y1, F1, NewState, O};
        true ->
          {I, P, K, NewX, NewY, F1, N, O} % Atualiza posição e fuel se houve movimento e há combustível.
      end;

    true ->
      func5(T, L, User, X1, Y1,F1) % Processa próximo jogador na lista.
  end.


func6([], L) ->
  L;
func6([{A, X, Y, B, 3,Ang} | T], L) ->
  % Se for o sol (c=3), não altera o corpo, apenas adiciona à lista acumulada
  func6(T, [{A, X, Y, B, 3,Ang} | L]);
func6([{A, X, Y, B, C,Ang} | T], L) ->
  % Se C != 3, atualiza os valores de X e Y
  CenterX = 720.0,
  CenterY = 450.0,
  Radius = math:sqrt((X - CenterX) * (X - CenterX) + (Y - CenterY) * (Y - CenterY)),
  case C of
    0 ->
      Va = 0.001;
    1 ->
      Va = 0.01;
    2 ->
      Va = 0.005
  end,
  NewAng = Ang + Va, % Incrementa o ângulo
  X1 = CenterX + Radius * math:cos(NewAng),
  Y1 = CenterY + Radius * math:sin(NewAng),
  UpdatedBody = {A, X1, Y1, B, C,NewAng},
  func6(T, [UpdatedBody | L]).




colisoes_corpos([],L,{Type,P,Size,X,Y,Fuel,State,Cor})->
  {L,{Type,P,Size,X,Y,Fuel,State,Cor}};
colisoes_corpos([H|T],L,{Type,P,Size,X,Y,Fuel,State,Cor})->
  {_,X2,Y2,_,Cor2,_}=H,
  if (((abs(X-X2))<(Size)) and ((abs(Y-Y2))<(Size)))->
    L2=L,
    State2=0,
    RealFuel=Fuel,
    Cor3=Cor2,
    colisoes_corpos(T,L2,{Type,P,Size,X,Y,RealFuel,State2,Cor3});
    true->
      L2=[H|L],
      colisoes_corpos(T,L2,{Type,P,Size,X,Y,Fuel,State,Cor})
  end.



colisoes_jogadores([],L,{Type,P,Size,X,Y,Fuel,State,Cor})->
  {L,{Type,P,Size,X,Y,Fuel,State,Cor}};
colisoes_jogadores([H|T],L,{Type,P,Size,X,Y,Fuel,State,Cor})->
  {Type2,P2,Size2,X2,Y2,Fuel2,State2,Cor2}=H,
  if (((abs(X-X2))<(Size)) and ((abs(Y-Y2))<(Size)) and (State2==1))->
    Type3=Type2,
    P3=P2,
    Size3=Size2,
    X3=X2-2.0,
    Y3=Y2-2.0,
    X4=X+2.0,
    Y4=Y+2.0,
    H2={Type3,P3,Size3,X3,Y3,Fuel2,State2,Cor2},
    L2=[H2|L],
    RealFuel=Fuel,
    colisoes_jogadores(T,L2,{Type,P,Size,X4,Y4,RealFuel,State,Cor});
    true->
      L2=[H|L],
      colisoes_jogadores(T,L2,{Type,P,Size,X,Y,Fuel,State,Cor})
  end.


atualiza_estado({Jogadores,Corpos},X,Y,F,User)->

  Players=func4(Jogadores,[],User),
  Player=func5(Jogadores,{},User,X,Y,F),
  CorposUP=func6(Corpos,[]),
  {Players2,Player2}=colisoes_jogadores(Players,[],Player),
  {Corpos2,Player3}=colisoes_corpos(CorposUP,[],Player2),

  Players3=[Player3|Players2],
  Estado=record_to_string(Players3,Corpos2),

  {Estado,{Players3,Corpos2}}.



handle(_,{ganhou,User},Room)->
  acabou_func(User,Room),
  {acabou,empty};

handle({Jogadores,Corpos},{checkstate,X,Y,F,User},_)->
  atualiza_estado({Jogadores,Corpos},X,Y,F,User).
