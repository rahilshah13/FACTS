:- module(english, [sentence_len/2, entry_only/1, fill_template/1, avg_word_length/2, words_per_closure/2, sentence_eval/3]).

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

% --- New Metric Predicates ---

avg_word_length(ClosureStr, AvgLen) :-
    split_string(ClosureStr, " \t\n\r", " \t\n\r", Words),
    length(Words, NumWords),
    ( NumWords > 0 ->
        sum_word_lengths(Words, 0, TotalLen),
        AvgLen is TotalLen / NumWords
    ;   AvgLen = 0.0
    ).

sum_word_lengths([], Acc, Acc).
sum_word_lengths([W|Ws], Acc, Total) :-
    atom_length(W, Len),
    NewAcc is Acc + Len,
    sum_word_lengths(Ws, NewAcc, Total).

words_per_closure(ClosureStr, WordsPerCl) :-
    split_string(ClosureStr, " \t\n\r", " \t\n\r", Words),
    length(Words, WordsPerCl).

sentence_eval(ClosureStr, CorrectCount, IncorrectCount) :-
    split_string(ClosureStr, ".?!", " \t\n\r", RawSentences),
    exclude(=(""), RawSentences, Sentences),
    evaluate_sentences(Sentences, 0, 0, CorrectCount, IncorrectCount).

evaluate_sentences([], Cor, Inc, Cor, Inc).
evaluate_sentences([S|Rest], CorIn, IncIn, CorOut, IncOut) :-
    split_string(S, " \t\n\r", " \t\n\r", WordStrs),
    maplist(atom_string, Atoms, WordStrs),
    ( phrase(sentence, Atoms) ->
        CorNext is CorIn + 1,
        evaluate_sentences(Rest, CorNext, IncIn, CorOut, IncOut)
    ;   IncNext is IncIn + 1,
        evaluate_sentences(Rest, CorIn, IncNext, CorOut, IncOut)
    ).

% --- Lexical Helpers ---
noun(W) :- entry(W, n, _, _).
adj(W)  :- entry(W, adj, _, _).

verb(W) :- entry(W, v, _, _).
verb(W) :- entry(_, v, Inflections, _),
            member(W, Inflections).

% --- DCG Rules ---
sentence --> noun_phrase, verb_phrase.

noun_phrase --> det_phrase, noun.
noun_phrase --> det_phrase, adj, noun.

verb_phrase --> verb.
verb_phrase --> verb, noun_phrase.

% --- Determiners (FIXED) ---
% Allow combinations like: "all the", "my two", etc.
det_phrase --> predet, det_core.
det_phrase --> det_core.

% Predeterminers
predet --> [all].
predet --> [both].
predet --> [half].

% Core determiners (mutually exclusive layer)
det_core --> article.
det_core --> demonstrative.
det_core --> possessive.
det_core --> quantifier.
det_core --> number.
det_core --> distributive.
det_core --> interrogative.
det_core --> difference.

% Articles
article --> [the].
article --> [a].
article --> [an].

% Demonstratives
demonstrative --> [this].
demonstrative --> [that].
demonstrative --> [these].
demonstrative --> [those].

% Possessives
possessive --> [my].
possessive --> [your].
possessive --> [his].
possessive --> [her].
possessive --> [its].
possessive --> [our].
possessive --> [their].

% Quantifiers
quantifier --> [some].
quantifier --> [any].
quantifier --> [many].
quantifier --> [much].
quantifier --> [few].
quantifier --> [little].
quantifier --> [several].
quantifier --> [most].
quantifier --> [enough].

% Numbers (minimal; extend as needed)
number --> [one].
number --> [two].
number --> [three].
number --> [first].
number --> [second].
number --> [third].

% Distributives
distributive --> [each].
distributive --> [every].
distributive --> [either].
distributive --> [neither].

% Interrogatives
interrogative --> [which].
interrogative --> [what].
interrogative --> [whose].

% Difference / choice
difference --> [other].
difference --> [another].

% --- Terminals ---
noun --> [W], { noun(W) }.
verb --> [W], { verb(W) }.
adj  --> [W], { adj(W) }.
