addMap(_, _, _, 0).

addMap(Name, D, S, L) :-
    D2 is D + 1,
    S2 is S + 1,
    L2 is L - 1,
    Fact =.. [Name, D, S],
    asserta(Fact),
    addMap(Name, D2, S2, L2).

addMap(Name) :-
    Fact =.. [Name, X, X],
    assert(Fact).

useMap(_, [], []).
useMap(Name, [DH | DT], [SH | ST]) :-
    !, useMap(Name, DH, SH),
    useMap(Name, DT, ST).

useMap(Name, [DH], [SH]) :-
    !,
    useMap(Name, DH, SH).


useMap(Name, D, S) :-
    Fact =.. [Name, D, S],
    Fact -> true; D = S.


min(X, X, Y) :- X < Y.
min(Y, X, Y) :- Y < X.

lowest(X, [X]).
lowest(L, [H | T]) :-
	lowest(LT, T),
	min(L, H, LT).


seeds([79, 14, 55, 13]).

order([hl, th, lt, wl, fw, sf, ss]).

runL(Dest, Seeds, Layer) :-
    useMap(Layer, Dest, Seeds).

run(S, S, []).
run(Dest, Seeds, [LH | LT]):-
    run(D, Seeds, LT),
    runL(Dest, D, LH).


run(M) :-
    seeds(S),
    order(O),
    run(R, S, O),
    write("Final locations: " + R),
    lowest(M, R).



% seed soil
:- addMap(ss, 50, 98, 2), addMap(ss, 52, 50, 48).

% soil fert
:- addMap(sf, 0, 15, 37), addMap(sf, 37, 52, 2), addMap(sf, 39, 0, 15).

% fert water
:- addMap(fw, 49, 53, 8), addMap(fw, 0, 11, 42), addMap(fw, 42, 0, 7), addMap(fw, 57, 7, 4).

% water light
:- addMap(wl, 88, 18, 7), addMap(wl, 18, 25, 70).

% light temp
:- addMap(lt, 45, 77, 23), addMap(lt, 81, 45, 19), addMap(lt, 68, 64, 13).

% temp hum
:- addMap(th, 0, 69, 1), addMap(th, 1, 0, 69).

% hum loc
:- addMap(hl, 60, 56, 37), addMap(hl, 56, 93, 4).
