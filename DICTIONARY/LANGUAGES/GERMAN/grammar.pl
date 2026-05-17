:- module(german, [sentence_len/2, entry_only/1, fill_template/1]).

:- dynamic(entry/4). % entry(Word, PartOfSpeech, Inflections, Meaning/Notes)
:- use_module(library(dcgs)).
:- use_module(library(lists)).
:- use_module(library(random)).

% Satz vervollständigen (Complete the sentence helpers)
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

% --- Lexical Helpers (Wortarten / Lexikalische Helfer) ---
noun(W) :- entry(W, n, _, _).   % Nomen / Substantiv (Noun)
adj(W)  :- entry(W, adj, _, _). % Adjektiv (Adjective)

verb(W) :- entry(W, v, _, _).   % Verb (Verb)
verb(W) :- entry(_, v, Inflections, _),
           member(W, Inflections). % Verbkonjugation (Verb Inflections)

% --- German DCG Rules (Deutsche Grammatikregeln) ---
% Baseline SVO order for simple main clauses (Subjekt + Verb + Objekt).
sentence --> noun_phrase, verb_phrase.

verb_phrase --> verb.
verb_phrase --> verb, noun_phrase.

% Noun Phrase (Nominalphrase)
noun_phrase --> det_phrase, noun.
noun_phrase --> det_phrase, adj, noun.
noun_phrase --> adj, noun.
noun_phrase --> noun.

% --- Determiners / Modifiers (Artikel und Begleiter) ---
det_phrase --> predet, det_core.
det_phrase --> det_core.

% Predeterminers (Prädeterminer)
predet --> [alle].     % all
predet --> [beide].    % both
predet --> [halb].     % half (often used as "halb" or inflected "halbe")

% Core determiners (Mutually exclusive layer)
det_core --> article.
det_core --> demonstrative.
det_core --> possessive.
det_core --> quantifier.
det_core --> number.
det_core --> distributive.
det_core --> interrogative.
det_core --> difference.

% Articles (Artikel - Nominative base forms provided)
article --> [der].     % the (masculine)
article --> [die].     % the (feminine / plural)
article --> [das].     % the (neuter)
article --> [ein].     % a / an (masculine / neuter)
article --> [eine].    % a / an (feminine)

% Demonstratives (Demonstrativpronomen)
demonstrative --> [dieser].  % this (masculine)
demonstrative --> [diese].   % this (feminine / plural)
demonstrative --> [dieses].  % this (neuter)
demonstrative --> [jener].   % that (masculine)
demonstrative --> [jene].    % that (feminine)
demonstrative --> [jenes].   % that (neuter)

% Possessives (Possessivpronomen)
possessive --> [mein].     % my
possessive --> [dein].     % your (singular informal)
possessive --> [sein].     % his / its
possessive --> [ihr].      % her / their / your (formal)
possessive --> [unser].    % our
possessive --> [euer].     % your (plural informal)

% Quantifiers (Quantoren)
quantifier --> [einige].   % some / several
quantifier --> [manche].   % some / many a
quantifier --> [viele].    % many
quantifier --> [wenige].   % few
quantifier --> [etwas].    % little / some
quantifier --> [mehrere].  % several
quantifier --> [meist].    % most (usually "die meisten")
quantifier --> [genug].    % enough

% Numbers (Numerale)
number --> [eins].     % one
number --> [zwei].     % two
number --> [drei].     % three
number --> [erster].   % first
number --> [zweiter].  % second
number --> [dritter].  % third

% Distributives (Distributivpronomen)
distributive --> [jeder].    % each / every (masculine)
distributive --> [jede].     % each / every (feminine)
distributive --> [jedes].    % each / every (neuter)
distributive --> [weder].    % neither (usually used with "noch")
distributive --> [entweder]. % either (usually used with "oder")

% Interrogatives (Interrogativpronomen)
interrogative --> [welcher]. % which (masculine)
interrogative --> [welche].  % which (feminine)
interrogative --> [welches]. % which (neuter)
interrogative --> [was].     % what
interrogative --> [wessen].  % whose

% Difference / choice (Differenzierung)
difference --> [anderer].  % other (masculine)
difference --> [andere].   % other (feminine / plural)
difference --> [ein anderer]. % another

% --- Terminals (Terminalelemente) ---
noun --> [W], { noun(W) }.
verb --> [W], { verb(W) }.
adj  --> [W], { adj(W) }.
