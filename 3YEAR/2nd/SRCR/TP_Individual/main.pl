%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Sistema de Representacao de Conhecimento e Raciocinio
% Trabalho Prático Individual
%--------------------------------------- - - - - - - - - - - - - - - -

% DEFINIÇÕES INICIAIS
:- set_prolog_flag(answer_write_options, [max_depth(0)]).
:- set_prolog_flag( discontiguous_warnings,off ).
:- set_prolog_flag( single_var_warnings,off ).

:- style_check(-singleton).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% INCLUDES

:- include('base_conhecimento.pl').
%:- include('base_conhecimento_reduzida.pl').
:- include('regras_auxiliares.pl').
:- include('funcionalidades.pl').


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% ALGORITMOS
%--------------------------------------- - - - - - - - - - - - - - - -

% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% PROCURA NÃO INFORMADA

%--------------------------------------- - - - - - - - - - - - - - - -
% PROFUNDIDADE (DFS - Depth-First Search) 
% resolve_pp(1,C,Qnt,Dist,Num). => para goal(175).
% resolve_pp(150,C,Qnt,Dist,Num). => para goal(175).
% resolve_pp(140,C,Qnt,Dist,Num). => para goal(175).

resolve_pp(Nodo, Sol,Qnt,Dist,Number) :- 
    profundidadeprimeiro1(Nodo,[Nodo],Caminho,Qnt),
    reverse(Caminho,Aux),
    verificaDeposito(Aux,Novo,QntDep,Dep),
    Res = [201 , Nodo | Novo],
    insertAtEnd(201,Res,Sol),
    length(Sol,Number),
    calcula_dist(Sol,Dist).

profundidadeprimeiro1(Nodo,_,[],0) :-
    goal(Nodo). 

profundidadeprimeiro1(Nodo, Historico, [ProxNodo|Caminho], Qnt) :-
    adjacente(Nodo,ProxNodo), % Os nodos devem ser adjacentes
	nao(membro(ProxNodo,Historico)),
    registo(_,_,Nodo,_,_,_,_,Qnt0),
	profundidadeprimeiro1(ProxNodo, [ProxNodo|Historico], Caminho, Qnt1), % Recursividade
    Qnt is Qnt1 + Qnt0.


%--------------------------------------- - - - - - - - - - - - - - - -
% Pesquisa em profundidade primeiro Multi_Estados

resolve_pp_h(Origem,Destino,Sol,Qnt,Number,Dep,Dist) :-
    profundidade(Origem,Destino,[Origem],Caminho,Qnt),
    reverse(Caminho,Aux),
    verificaDeposito(Aux,Novo,QntDep,Dep),
    Res = [201 , Origem | Novo],
    insertAtEnd(201,Res,Sol),
    length(Sol,Number),
    calcula_dist(Sol,Dist).

profundidade(Origem,Destino,_,[],0) :- Origem == Destino,!.

profundidade(Origem,Destino,His,[R|Solucao],Qnt) :- 
    adjacente(Origem,R),
    nao(membro(R,His)),
    registo(_,_,R,_,_,_,_,Qnt0),
    profundidade(R,Destino,[R|His],Solucao,Qnt1),
    Qnt is Qnt1 + Qnt0.



%--------------------------------------- - - - - - - - - - - - - - - -
% Pesquisa em profundidade limitada

resolve_pp_limitada(Profundidade, Nodo, Sol,Qnt,Dist,Number) :-
	pp_limitada(Profundidade,Nodo,[Nodo],Caminho,Qnt),
    reverse(Caminho,Aux),
    verificaDeposito(Aux,Novo,QntDep,Dep),
    Res = [201 , Origem | Novo],
    insertAtEnd(201,Res,Sol),
    length(Sol,Number),
    calcula_dist(Sol,Dist).

pp_limitada(Profundidade,Nodo,_,[],0) :-
	goal(Nodo).

pp_limitada(Profundidade,Nodo,Historico,[ProxNodo|Caminho],Qnt) :-
	Profundidade > 0,
	adjacente(Nodo,ProxNodo),
	ProfNova is Profundidade - 1,
	nao(membro(ProxNodo,Historico)),
    registo(_,_,Nodo,_,_,_,_,Qnt0),
	pp_limitada(ProfNova,ProxNodo,[ProxNodo|Historico],Caminho,Qnt1),
    Qnt is Qnt1 + Qnt0.


%--------------------------------------- - - - - - - - - - - - - - - -
% LARGURA (BFS - Breadth-First Search)

resolve_largura( Origem, Sol, Number, Qnt, Dist)  :-
  breadthfirst( [ [Origem] ], Caminho),
  verificaDeposito(Caminho,Novo,QntDep,Dep),
  Res = [201 | Novo],
  insertAtEnd(201,Res,Sol),
  length(Sol,Number),
  calcula_qnt(Sol,Qnt),
  calcula_dist(Sol,Dist),
  length(Sol,Number).

breadthfirst( [ [Origem | Caminho] | _], [Origem | Caminho])  :-
    goal( Origem).

breadthfirst( [Caminho | Caminhos], Solucao)  :-
    extend( Caminho, NovoCaminho),
    append( Caminhos, NovoCaminho, Paths1),
    breadthfirst( Paths1, Solucao).

extend( [Origem | Caminho], NovoCaminho)  :-
    bagof( [NovoNodo, Origem | Caminho],
         ( adjacente( Origem, NovoNodo), \+ member( NovoNodo, [Origem | Caminho] ) ),
         NovoCaminho), !.

extend( Caminho, [] ).    




% - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
% PROCURA INFORMADA

%--------------------------------------- - - - - - - - - - - - - - - -
% GULOSA

resolve_gulosa(Nodo,Sol/Custo,Number,Qnt,Dist) :- 
    registo(_,_,Nodo,_,_,_,_,Estima),
    agulosa([[Nodo]/0/Estima],InvCaminho/Custo/_),
    verificaDeposito(InvCaminho,Novo,QntDep,Dep),
    Res = [201 | Novo],
    insertAtEnd(201,Res,Sol),
    length(Sol,Number),
    calcula_qnt(Sol,Qnt),
    calcula_dist(Sol,Dist),
    length(Sol,Number).


agulosa(Caminhos, Caminho) :- 
    obtem_melhor_g(Caminhos,Caminho),
    Caminho = [Nodo|_]/_/_,goal(Nodo).

agulosa(Caminhos,SolucaoCaminho) :-
    obtem_melhor_g(Caminhos,MelhorCaminho),
    seleciona(MelhorCaminho,Caminhos,OutrosCaminhos),
    expande_gulosa(MelhorCaminho,ExpCaminhos),
    append(OutrosCaminhos,ExpCaminhos,NovoCaminhos),
    agulosa(NovoCaminhos,SolucaoCaminho).

obtem_melhor_g([Caminho], Caminho) :- !.

obtem_melhor_g([Caminho1/Custo1/Est1,_/Custo2/Est2|Caminhos], MelhorCaminho) :-
    Est1 =< Est2, !,
    obtem_melhor_g([Caminho1/Custo1/Est1|Caminhos], MelhorCaminho).

obtem_melhor_g([_|Caminhos], MelhorCaminho) :-
    obtem_melhor_g(Caminhos,MelhorCaminho).

expande_gulosa(Caminho, ExpCaminhos) :- 
    findall(NovoCaminho,adjacente3(Caminho,NovoCaminho),ExpCaminhos).


%--------------------------------------- - - - - - - - - - - - - - - -
% A ESTRELA

resolve_aestrela(Nodo,Sol/Custo,Number,Qnt,Dist) :-
    registo(_,_,Nodo,_,_,_,_,Estima),
    aestrela([[Nodo]/0/Estima], InvCaminho/Custo/_),
    verificaDeposito(InvCaminho,Novo,QntDep,Dep),
    Res = [201 | Novo],
    insertAtEnd(201,Res,Sol),
    length(Sol,Number),
    calcula_qnt(Sol,Qnt),
    calcula_dist(Sol,Dist),
    length(Sol,Number).

aestrela(Caminhos,Caminho) :-
    obtem_melhor(Caminhos,Caminho),
    Caminho = [Nodo|_]/_/_,goal(Nodo).

aestrela(Caminhos,SolucaoCaminho) :-
    obtem_melhor(Caminhos,MelhorCaminho),
    seleciona(MelhorCaminho,Caminhos,OutrosCaminhos),
    expande_aestrela(MelhorCaminho,ExpCaminhos),
    append(OutrosCaminhos,ExpCaminhos,NovoCaminhos),
    aestrela(NovoCaminhos,SolucaoCaminho).

obtem_melhor([Caminho], Caminho) :- !.

obtem_melhor([Caminho1/Custo1/Est1,_/Custo2/Est2|Caminhos], MelhorCaminho) :-
    Custo1 + Est1 =< Custo2 + Est2, !,
    obtem_melhor([Caminho1/Custo1/Est1|Caminhos], MelhorCaminho).

obtem_melhor([_|Caminhos], MelhorCaminho) :-
    obtem_melhor(Caminhos,MelhorCaminho).

expande_aestrela(Caminho,ExpCaminhos) :-
    findall(NovoCaminho,adjacente3(Caminho,NovoCaminho), ExpCaminhos).


%--------------------------------------- - - - - - - - - - - - - - - -
% ESTATISTICAS - Análise de Resultados

% Procura em profundidade
estatistica_profundidade(C, Mem) :-
    statistics(global_stack, [G1,L1]),
    time(resolve_pp_h(1,35,C,Qnt,Num,Dep,Dist)),
    statistics(global_stack, [G2,L2]),
    Mem is G2 - G1.

% Procura em profundidade limitada
estatistica_profundidade_limitada(C, Mem) :-
    statistics(global_stack, [G1,L1]),
    time(resolve_pp_limitada(25,1,C,Qnt,Num,Dist)),
    statistics(global_stack, [G2,L2]),
    Mem is G2 - G1.

% Procura em largura
estatistica_largura(C, Mem) :-
    statistics(global_stack, [G1,L1]),
    time(resolve_largura(1,C,Num,Qnt,Dist)),
    statistics(global_stack, [G2,L2]),
    Mem is G2 - G1.

% Procura gulosa
estatistica_gulosa(C, Mem, Dist) :-
    statistics(global_stack, [G1,L1]),
    time(resolve_gulosa(1,C,Num,Qnt,Dist)), 
    statistics(global_stack, [G2,L2]),
    Mem is G2 - G1.

% Procura a estrela
estatistica_a_estrela(C, Mem, Dist) :-
    statistics(global_stack, [G1,L1]),
    time(resolve_aestrela(1,C,Num,Qnt,Dist)),
    statistics(global_stack, [G2,L2]),
    Mem is G2 - G1.


% Procura profundidade findall
estatistica_profundidade_findall(C, Mem) :-
    statistics(global_stack, [G1,L1]),
    time(circuito_Rapido_pp(1,10,C)),
    statistics(global_stack, [G2,L2]),
    Mem is G2 - G1.
