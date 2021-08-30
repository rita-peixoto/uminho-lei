%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Sistema de Representacao de Conhecimento e Raciocinio
% Trabalho Prático Individual

% DEFINIÇÕES INICIAIS
:- set_prolog_flag(answer_write_options, [max_depth(0)]).
:- set_prolog_flag( discontiguous_warnings,off ).
:- set_prolog_flag( single_var_warnings,off ).

:- style_check(-singleton).


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% FUNCIONALIDADES
%--------------------------------------- - - - - - - - - - - - - - - -

%--------------------------------------- - - - - - - - - - - - - - - -
% PROFUNDIDADE PRIMEIRO SELETIVA V1 - de acordo com o tipo de lixo (gera caminhos só com esse tipo de lixo)
% pp_seletiva(81,93,C,"papel e cartão",Qnt,Num,Dist).

pp_seletiva(Origem,Destino,Sol,Tipo,Qnt,Number,Dist) :- 
    profundidade_sel(Origem,Destino,[Origem],Caminho,Tipo,Qnt),
    reverse(Caminho,Aux),
    verificaDeposito(Aux,Novo,QntDep,Dep),
    Res = [201 | Novo],
    insertAtEnd(201,Res,Sol),
    length(Sol,Number),
    calcula_dist(Sol,Dist).

profundidade_sel(Destino,Destino,H,D,Tipo,0) :- inverso(H,D).

profundidade_sel(Origem,Destino,His,C,Tipo,Qnt) :- 
    adjacente_sel(Origem,Prox,Tipo,Qnt0),
    nao(membro(Prox,His)),
    profundidade_sel(Prox,Destino,[Prox|His],C,Tipo,Qnt1),
    Qnt is Qnt1 + Qnt0.

%--------------------------------------- - - - - - - - - - - - - - - -
% PROFUNDIDADE PRIMEIRO SELETIVA V2 - de acordo com o tipo de lixo (gera caminhos só com esse tipo de lixo)
% pp_seletiva(81,93,C,"papel e cartão",Qnt,Num,Dist).

pp_seletiva2(Origem,Destino,Sol,Tipo,Qnt,Number,Dep,Dist) :-
    profundidade_sel2(Origem,Destino,[Origem],Caminho,Tipo,Qnt),
    reverse(Caminho,Aux),
    verificaDeposito(Aux,Novo,QntDep,Dep),
    Res = [201 , Origem | Novo],
    insertAtEnd(201,Res,Sol),
    length(Sol,Number),
    calcula_dist(Sol,Dist).

profundidade_sel2(Origem,Destino,_,[],T,0) :- Origem == Destino,!.

profundidade_sel2(Origem,Destino,His,[R|Solucao],Tipo,Qnt) :- 
    adjacente_sel2(Origem,R,Qnt0,T),
    nao(membro(R,His)),
    profundidade_sel2(R,Destino,[R|His],Solucao,Tipo,Qnt1),
    ( T == Tipo -> Qnt is Qnt1 + Qnt0; 
    Qnt is Qnt1).


%--------------------------------------- - - - - - - - - - - - - - - -
% CIRCUITOS COM MAIS PONTOS DE RECOLHA 
%--------------------------------------- - - - - - - - - - - - - - - -
% Profundidade Limitada

circuito_PR_limitada(Origem, Caminho) :-
    findall((C,Num),resolve_pp_limitada(100,Origem,C,Qnt,Dist,Num),Lst),
    maiorPR(Lst,Caminho). % predicado para calcular o caminho com mais pontos de recolha


%--------------------------------------- - - - - - - - - - - - - - - -
% Profundidade primeiro

circuito_PR_pp(Origem,Destino, Caminho) :-
    findall((C,Num),resolve_pp_h(Origem,Destino,C,Qnt,Num,Dep,Dist),Lst),
    maiorPR(Lst,Caminho). % predicado para calcular o caminho com mais pontos de recolha


%--------------------------------------- - - - - - - - - - - - - - - -
% CIRCUITO MAIS RÁPIDO (menor distância)
%--------------------------------------- - - - - - - - - - - - - - - -
% Profundidade Limitada

circuito_Rapido_limitada(Origem, Caminho) :-
    findall((C,Dist),resolve_pp_limitada(100,Origem,C,Qnt,Dist,Num),Lst),
    minimo(Lst,Caminho). % predicado para calcular o caminho com mais pontos de recolha


%--------------------------------------- - - - - - - - - - - - - - - -
% Profundidade primeiro

circuito_Rapido_pp(Origem, Destino, Caminho) :-
    findall((C,Dist),resolve_pp_h(Origem,Destino,C,Qnt,Num,Dep,Dist),Lst),
    minimo(Lst,Caminho). % predicado para calcular o caminho com mais pontos de recolha


%--------------------------------------- - - - - - - - - - - - - - - -
% CIRCUITO MAIS EFICIENTE 
% O circuito mais eficiente é aquele que consegue recolher mais quantidade de resíduos
% circuito_eficiente(15,16,C).

circuito_eficiente(Origem,Destino,Caminho) :-
    findall((C,Qnt),resolve_pp_h(Origem,Destino,C,Qnt,Num,Dep,Dist),Lst),
    maiorPR(Lst,Caminho).



