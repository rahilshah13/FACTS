:- module(swahili, [sentence_len/2, entry_only/1, fill_template/1]).

:- dynamic(entry/4). % entry(Word, PartOfSpeech, Inflections, Meaning/Notes)
:- use_module(library(dcgs)).
:- use_module(library(lists)).
:- use_module(library(random)).

% Kamilisha sentensi (Complete the sentence helpers)
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

% --- Lexical Helpers (Aina za Maneno / Wasaidizi wa Kamusi) ---
noun(W) :- entry(W, n, _, _).   % Nomino (Noun)
adj(W)  :- entry(W, adj, _, _). % Kivumishi (Adjective)

verb(W) :- entry(W, v, _, _).   % Kitenzi (Verb)
verb(W) :- entry(_, v, Inflections, _),
           member(W, Inflections). % Nyakati na Viambishi vya Kitenzi (Verb Inflections/Prefixes)

% --- Swahili DCG Rules (Sheria za Sarufi ya Kiswahili) ---
% Swahili is strictly SVO (Kiambishi Awali/Kiinitendaji + Kitenzi + Yambwa).
sentence --> noun_phrase, verb_phrase.

% Verb Phrase contains the verb and its optional object noun phrase
verb_phrase --> verb.
verb_phrase --> verb, noun_phrase.

% Noun Phrase (Kishazi Nomino)
% Structural adjustment: Adjectives and core determiners (demonstratives/possessives) FOLLOW the noun.
noun_phrase --> noun.
noun_phrase --> noun, adj.
noun_phrase --> noun, post_det.
noun_phrase --> noun, adj, post_det.
% Exception: Select distributives like "kila" precede the noun.
noun_phrase --> pre_det, noun.
noun_phrase --> pre_det, noun, adj.

% --- Determiners / Modifiers (Viwakilishi / Viainishi) ---
% Split into Pre-nominal (Kabla ya nomino) and Post-nominal (Baada ya nomino) layers.
pre_det  --> predet_core.

post_det --> demonstrative.
post_det --> possessive.
post_det --> quantifier.
post_det --> number.
post_det --> distributive.
post_det --> interrogative.
post_det --> difference.

% Predeterminers (Pre-nominal)
predet_core --> [kila].       % each / every

% Demonstratives (Viwakilishi vya Ishara - Post-nominal, standard Ki-/Vi- class baseline used here)
demonstrative --> [hiki].     % this (near)
demonstrative --> [hicho].    % that (reference/medium distance)
demonstrative --> [kile].     % that (far)
demonstrative --> [hivi].     % these (near - plural)
demonstrative --> [vile].     % those (far - plural)

% Possessives (Viwakilishi Milki - Post-nominal)
possessive --> [wangu].    % my
possessive --> [wako].     % your (singular)
possessive --> [wake].     % his / her / its
possessive --> [wetu].     % our
possessive --> [wenu].     % your (plural)
possessive --> [wao].      % their

% Quantifiers (Vivumishi vya Idadi - Post-nominal)
quantifier --> [baadhi ya]. % some of
quantifier --> [nyingi].    % many / much
quantifier --> [chache].   % few / little
quantifier --> [kadhaa].    % several
quantifier --> [vingi].     % most / plenty
quantifier --> [ya kutosha]. % enough

% Numbers (Namba / Idadi - Post-nominal)
number --> [moja].     % one
number --> [mbili].    % two
number --> [tatu].     % three
number --> [kwanza].   % first
number --> [pili].     % second
number --> [tatu].     % third (e.g., nafasi ya tatu)

% Distributives (Post-nominal context)
distributive --> [wote wawili]. % both
distributive --> [nusu].       % half
distributive --> [yoyote].     % either / any
distributive --> [wala].       % neither (used as conjunction with negative verbs)

% Interrogatives (Vivumishi vya Maswali)
interrogative --> [ipi].       % which
interrogative --> [nini].      % what
interrogative --> [ya nani].   % whose

% Difference / choice (Mabadiliko - Post-nominal)
difference --> [ingine].    % other
difference --> [inginezo].  % another / others

% --- Terminals (Vipengele vya Mwisho) ---
noun --> [W], { noun(W) }.
verb --> [W], { verb(W) }.
adj  --> [W], { adj(W) }.
