:- module(english, [
    sentence_len/2, entry_only/1, fill_template/1, 
    avg_word_length/2, words_per_closure/2, sentence_eval/3, 
    lexical_density/2, semantic_coherence/2, syntactic_entropy/2, readability_score/2,
    bpe_len/2, ipa_len_val/2
]).

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

% --- Core & Mocked Metric Predicates ---

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

% --- Additional Mocked Metrics ---

lexical_density(ClosureStr, Density) :-
    split_string(ClosureStr, " \t\n\r", " \t\n\r", Words),
    length(Words, Total),
    ( Total > 0 ->
        include(is_long_word, Words, LongWords),
        length(LongWords, LongCount),
        Density is LongCount / Total
    ;   Density = 0.0
    ).

is_long_word(W) :-
    atom_length(W, Len),
    Len > 4.

semantic_coherence(ClosureStr, Coherence) :-
    atom_length(ClosureStr, Len),
    Coherence is (Len mod 100) / 100.0.

syntactic_entropy(ClosureStr, Entropy) :-
    atom_length(ClosureStr, Len),
    Entropy is (Len mod 50) / 10.0.

readability_score(ClosureStr, Score) :-
    split_string(ClosureStr, " \t\n\r", " \t\n\r", Words),
    length(Words, Total),
    Score is 206.835 - (1.015 * (Total max 1)) - (84.6 * 4.5 / (Total max 1)).

bpe_len(ClosureStr, Len) :-
    string_codes(ClosureStr, Codes),
    bpe_code_count(Codes, 0, Len).

bpe_code_count([], Acc, Acc).
bpe_code_count([C1, C2 | Rest], Acc, Len) :-
    (   \+ char_type(C1, space), \+ char_type(C2, space)
    ->  NewAcc is Acc + 1
    ;   NewAcc is Acc
    ),
    bpe_code_count([C2 | Rest], NewAcc, Len).
bpe_code_count([_], Acc, Acc).

ipa_len_val(ClosureStr, Len) :-
    ipa_tokens(ClosureStr, Tokens),
    length(Tokens, TLen),
    ( TLen > 1 -> Len is TLen - 1 ; Len is 0 ).

ipa_tokens(Str, Tokens) :-
    atom_string(Atom, Str),
    atom_codes(Atom, Codes),
    extract_ipa(Codes, Tokens).

extract_ipa([], []).
extract_ipa([C|Cs], [Token|Rest]) :-
    ipamatch([C|Cs], Token, Rem),
    !,
    extract_ipa(Rem, Rest).
extract_ipa([C|Cs], [C|Rest]) :-
    \+ char_type(C, space),
    extract_ipa(Cs, Rest).
extract_ipa([C|Cs], Rest) :-
    char_type(C, space),
    extract_ipa(Cs, Rest).

ipamatch(Codes, Token, Rem) :-
    ipasymbol(Sym),
    atom_codes(Sym, SymCodes),
    append(SymCodes, Rem, Codes),
    atom_string(Token, Sym).

ipasymbol("p"). ipasymbol("b"). ipasymbol("t"). ipasymbol("d").
ipasymbol("k"). ipasymbol("g"). ipasymbol("m"). ipasymbol("n").
ipasymbol("ŋ"). ipasymbol("f"). ipasymbol("v"). ipasymbol("θ").
ipasymbol("ð"). ipasymbol("s"). ipasymbol("z"). ipasymbol("ʃ").
ipasymbol("ʒ"). ipasymbol("h"). ipasymbol("tʃ"). ipasymbol("dʒ").
ipasymbol("w"). ipasymbol("j"). ipasymbol("r"). ipasymbol("l").
ipasymbol("i"). ipasymbol("ɪ"). ipasymbol("e"). ipasymbol("ɛ").
ipasymbol("æ"). ipasymbol("a"). ipasymbol("ə"). ipasymbol("ʌ").
ipasymbol("u"). ipasymbol("ʊ"). ipasymbol("o"). ipasymbol("ɔ").
ipasymbol("ɑ"). ipasymbol("ɒ"). ipasymbol("aɪ"). ipasymbol("eɪ").
ipasymbol("ɔɪ"). ipasymbol("aʊ"). ipasymbol("oʊ").

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
det_phrase --> predet, det_core.
det_phrase --> det_core.

predet --> [all].
predet --> [both].
predet --> [half].

det_core --> article.
det_core --> demonstrative.
det_core --> possessive.
det_core --> quantifier.
det_core --> number.
det_core --> distributive.
det_core --> interrogative.
det_core --> difference.

article --> [the].
article --> [a].
article --> [an].

demonstrative --> [this].
demonstrative --> [that].
demonstrative --> [these].
demonstrative --> [those].

possessive --> [my].
possessive --> [your].
possessive --> [his].
possessive --> [her].
possessive --> [its].
possessive --> [our].
possessive --> [their].

quantifier --> [some].
quantifier --> [any].
quantifier --> [many].
quantifier --> [much].
quantifier --> [few].
quantifier --> [little].
quantifier --> [several].
quantifier --> [most].
quantifier --> [enough].

number --> [one].
number --> [two].
number --> [three].
number --> [first].
number --> [second].
number --> [third].

distributive --> [each].
distributive --> [every].
distributive --> [either].
distributive --> [neither].

interrogative --> [which].
interrogative --> [what].
interrogative --> [whose].

difference --> [other].
difference --> [another].

% --- Terminals ---
noun --> [W], { noun(W) }.
verb --> [W], { verb(W) }.
adj  --> [W], { adj(W) }.
