%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Sistema de Representacao de Conhecimento e Raciocinio
% Trabalho Prático Individual 

%--------------------------------- - - - - - - - - - -  -  -  -  -   - 
%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% REGRAS AUXILIARES
%--------------------------------------- - - - - - - - - - - - - - - -

%goal(175).
%goal(81).
%goal(170).
goal(35).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensao do meta-predicado nao: Questao -> {V,F}

nao( Questao ) :-
    Questao, !, fail.
nao( Questao ).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Extensão do predicado membro. Verifica se um elemento pertence a uma lista
% membro : Elemento, Lista -> {V,F}

membro(X, [X|_]).
membro(X, [_|Xs]):-
	membro(X, Xs).


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Predicado que cálcula o inverso de uma lista
% inverso : Lista , Lista -> {V,F}

inverso(Xs,Ys) :-
	inverso(Xs,[],Ys).

inverso([], Xs, Xs).
inverso([X|Xs], Ys, Zs) :- inverso(Xs, [X|Ys], Zs).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Predicado que cálcula o elemento mínimo de uma lista
% minimo : Lista , Elemento -> {V,F}

minimo([(P,X)],(P,X)).
minimo([(Px,X)|L], (Py,Y)) :- minimo(L,(Py,Y)), X > Y.
minimo([(Px,X)|L], (Px,X)) :- minimo(L,(Py,Y)), X =< Y.


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Predicado que calcula a distância euclidiana entre dois nodos
% distancia : Nodo, Nodo, Distancia -> {V,F}

distancia(Nodo1, Nodo2, Dist) :-
	registo(_,_,Nodo1,Lat1,Long1,_,_,_),
	registo(_,_,Nodo2,Lat2,Long2,_,_,_),
	Dist is sqrt((Lat2-Lat1)^2 + (Long2-Long1)^2). 


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Predicado que verifica se 2 quaisquer nodos são adjacentes
% adjacente : Nodo, ProxNodo -> {V,F}

adjacente(Nodo,ProxNodo) :- 
	registo(_,_,Nodo,_,_,_,Adj,_), 
	membro(ProxNodo,Adj).


%adjacente(Nodo,ProxNodo) :-
%	registo(_,_,ProxNodo,_,_,_,Adj,_), 
%	membro(Nodo,Adj).


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Predicado que verifica se 2 nodos são adjacentes consoante o tipo de lixo. 
% Auxiliar para a pesquisa seletiva.
% adjacente_sel: Nodo, ProxNodo, Tipo de Lixo, Qtd Recolhida -> {V,F}

adjacente_sel(Nodo,ProxNodo,Tipo,Qnt0) :- 
	registo(_,T,Nodo,_,_,_,Adj,Qnt0), 
	registo(_,T0,ProxNodo,_,_,_,_,_), 
	T == Tipo,
	T0 == Tipo,
	membro(ProxNodo,Adj).

adjacente_sel(Nodo,ProxNodo,Tipo,Qnt0) :-
	registo(_,T,ProxNodo,_,_,_,Adj,Qnt0),
	registo(_,T0,Nodo,_,_,_,_,_), 
	T == Tipo,
	T0 == Tipo,
	membro(Nodo,Adj).


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Predicado que verifica se 2 nodos são adjacentes e retorna a quantidade. 
% Auxiliar para a pesquisa seletiva 2.
% adjacente_sel2 : Nodo, ProxNodo, Qtd Recolhida, Tipo de Lixo -> {V,F}

adjacente_sel2(Nodo,ProxNodo,Qnt0,T) :- 
	registo(_,T,Nodo,_,_,_,Adj,Qnt0), 
	registo(_,_,ProxNodo,_,_,_,_,_), 
	membro(ProxNodo,Adj).

adjacente_sel2(Nodo,ProxNodo,Qnt0,T) :-
	registo(_,T,ProxNodo,_,_,_,Adj,Qnt0),
	registo(_,_,Nodo,_,_,_,_,_), 
	membro(Nodo,Adj).


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Seleciona : Elemento, Lista, Lista -> {V,F}

seleciona(E,[E|Xs],Xs).
seleciona(E,[X|Xs],[X|Ys]) :- seleciona(E,Xs,Ys).


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Adjacente3 : Elemento, Lista -> {V,F}

adjacente3([Nodo|Caminho]/Custo/_,[ProxNodo,Nodo|Caminho]/NovoCusto/Est) :-
    adjacente2(Nodo,ProxNodo),
	distancia(Nodo,ProxNodo,PassoCusto),
    \+ member(ProxNodo,Caminho),
    NovoCusto is Custo + PassoCusto,
	estima(ProxNodo,Est).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Adjacente2 : Elemento, Elemento -> {V,F}

adjacente2(Nodo,ProxNodo) :- 
	registo(_,_,Nodo,_,_,_,Adj,_), 
	membro(ProxNodo,Adj).

adjacente2(Nodo,ProxNodo) :-
	registo(_,_,ProxNodo,_,_,_,Adj,_), 
	membro(Nodo,Adj).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% estima : Elemento, Estimativa -> {V,F}

estima(ProxNodo,Est) :-
	goal(Destino),
	distancia(ProxNodo,Destino,Est).

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Calcula a quantidade de lixo recolhida num caminho
% calcula_qnt : Caminho, Qnt -> {V,F}

calcula_qnt([],0).
calcula_qnt([C|T],Qnt) :- 
	registo(_,_,C,_,_,_,_,Qnt0), 
	calcula_qnt(T,Qnt1),
	Qnt is Qnt0 + Qnt1.

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Calcula a distancia percorrida num caminho
% calcula_dist : Caminho, Dist -> {V,F}

calcula_dist([],0).
calcula_dist([C],0).
calcula_dist([C,C1|T],Dist) :- 
	calcula_dist([C1|T],Dist1),
	distancia(C,C1,Dist0),
	Dist is Dist0 + Dist1.

%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Predicado que calcula o caminho com mais pontos de recolha
% maior : Lista , Elemento -> {V,F}

maiorPR([(P,X)],(P,X)).
maiorPR([(Px,X)|L], (Py,Y)) :- maiorPR(L,(Py,Y)), Y > X.
maiorPR([(Px,X)|L], (Px,X)) :- maiorPR(L,(Py,Y)), X >= Y.


%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Predicado que insere um elemento no final de uma lista
% insertAtEnd : Elemento , Lista , Lista -> {V,F}

insertAtEnd(X,[ ],[X]).
insertAtEnd(X,[H|T],[H|Z]) :- insertAtEnd(X,T,Z).  



%--------------------------------- - - - - - - - - - -  -  -  -  -   -
% Predicado que verifica quando se deve ir ao depósito
% verificaDeposito : Caminho , Resultado , Quantidade , Visitas ao depósito -> {V,F}

verificaDeposito(Caminho,Novo,Qnt,Dep) :-
    verificaDeposito2(Caminho,[200],Novo,Qnt,Dep).

verificaDeposito2([],Novo,Novo,0,1).
verificaDeposito2([Nodo|Caminho],Aux,Novo,Qnt,Dep) :-
    registo(_,_,Nodo,_,_,_,_,Qnt0),  
    verificaDeposito2(Caminho,Lst,Novo,Qnt1,DepAux),
    ( Qnt1 + Qnt0 < 15000 -> Lst = [Nodo|Aux], Qnt is Qnt1 + Qnt0, 
	  Dep is DepAux;
      Lst = [200,Nodo|Aux], Qnt is 0 , Dep is DepAux + 1).    


