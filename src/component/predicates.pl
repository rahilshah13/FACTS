:- module(english, [sentence_len/2, entry_only/1, fill_template/1]).
% dynamic makes entries mutable
:- dynamic(entry/4).
:- use_module(library(dcgs)).
:- use_module(library(lists)).
:- use_module(library(random)).

% complete the sentence
entry_only(W) :- nonvar(W), !.
entry_only(W) :- entry(W, _, _, _).

fill_template(List) :- 
    fill_template(List, []).

fill_template([], _).
fill_template([Word|Rest], Seen) :-
    (   nonvar(Word) 
    ->  fill_template(Rest, [Word|Seen])
    ;   entry_only(Word),
        \+ member(Word, Seen),
        fill_template(Rest, [Word|Seen])
    ).


sentence_len(L, W) :- entry(W, _, _, _), atom_length(W, L).

% --- Lexical Helpers ---
% A noun is the first argument where the second argument is 'n'
noun(W) :- entry(W, n, _, _).
adj(W)  :- entry(W, adj, _, _).
% A verb can be the base form OR one of the inflected forms in the list
verb(W) :- entry(W, v, _, _).                   % Matches "divine"
verb(W) :- entry(_, v, Inflections, _),         % Matches "divined", "divining", etc.
           member(W, Inflections).

% --- DCG Rules ---
sentence --> noun_phrase, verb_phrase.
noun_phrase --> det, noun.
noun_phrase --> det, adj, noun.
verb_phrase --> verb.
verb_phrase --> verb, noun_phrase.
% Terminals
det --> [the].
det --> [a].
noun --> [W], { noun(W) }.
verb --> [W], { verb(W) }.
adj  --> [W], { adj(W) }.