:- module(polish, [sentence_len/2, entry_only/1, fill_template/1]).

:- dynamic(entry/4). % entry(Word, PartOfSpeech, Inflections, Meaning/Notes)
:- use_module(library(dcgs)).
:- use_module(library(lists)).
:- use_module(library(random)).

% Uzupełnianie zdania (Complete the sentence helpers)
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

% --- Lexical Helpers (Części mowy / Pomocniki leksykalne) ---
noun(W) :- entry(W, n, _, _).   % Rzeczownik (Noun)
adj(W)  :- entry(W, adj, _, _). % Przymiotnik (Adjective)

verb(W) :- entry(W, v, _, _).   % Czasownik (Verb)
verb(W) :- entry(_, v, Inflections, _),
           member(W, Inflections). % Formy odmienne czasownika (Verb Inflections)

% --- Polish DCG Rules (Reguły gramatyczne języka polskiego) ---
% Polish is primarily SVO (Subject + Verb + Object).
sentence --> noun_phrase, verb_phrase.

verb_phrase --> verb.
verb_phrase --> verb, noun_phrase.

% Noun Phrase (Fraza rzeczownikowa)
noun_phrase --> det_phrase, noun.
noun_phrase --> det_phrase, adj, noun.
noun_phrase --> adj, noun.
noun_phrase --> noun.

% --- Determiners / Modifiers (Określniki) ---
% Note: Polish has no articles. 
det_phrase --> predet, det_core.
det_phrase --> det_core.

% Predeterminers (Przedokreślniki)
predet --> [wszystkie]. % all (plural)
predet --> [wszyscy].   % all (masculine personal plural)
predet --> [oba].       % both (masculine/neuter)
predet --> [obie].      % both (feminine)
predet --> [pół].       % half

% Core determiners
det_core --> demonstrative.
det_core --> possessive.
det_core --> quantifier.
det_core --> number.
det_core --> distributive.
det_core --> interrogative.
det_core --> difference.

% Demonstratives (Zaimki wskazujące - Nominative baselines provided)
demonstrative --> [ten].    % this (masculine)
demonstrative --> [ta].     % this (feminine)
demonstrative --> [to].     % this (neuter) / that (general)
demonstrative --> [tamten]. % that (masculine)
demonstrative --> [tamta].  % that (feminine)
demonstrative --> [ci].     % these (masculine personal)
demonstrative --> [te].     % these / those (non-masculine personal)

% Possessives (Zaimki dzierżawcze)
possessive --> [mój].     % my
possessive --> [twój].    % your (singular informal)
possessive --> [jego].    % his / its
possessive --> [jej].     % her
possessive --> [nasz].    % our
possessive --> [wasz].    % your (plural)
possessive --> [ich].     % their

% Quantifiers (Kwantyfikatory)
quantifier --> [kilka].   % some / a few (with genitive)
quantifier --> [niektóre].% some (plural)
quantifier --> [dużo].    % many / much
quantifier --> [wiele].   % many / several
quantifier --> [mało].    % few / little
quantifier --> [trochę].  % a little
quantifier --> [większość].% most
quantifier --> [wystarczająco]. % enough

% Numbers (Liczebniki)
number --> [jeden].    % one
number --> [dwa].      % two
number --> [trzy].     % three
number --> [pierwszy]. % first
number --> [drugi].    % second
number --> [trzeci].   % third

% Distributives (Zaimki dystrybutywne)
distributive --> [każdy].    % each / every (masculine)
distributive --> [każda].    % each / every (feminine)
distributive --> [żaden].    % neither / none (requires negative verb contextualization)
distributive --> [którykolwiek]. % either / whichever

% Interrogatives (Zaimki pytajne)
interrogative --> [który].   % which
interrogative --> [co].      % what
interrogative --> [czyj].    % whose

% Difference / choice (Inność / wybór)
difference --> [inny].     % other
difference --> [kolejny].  % another / next

% --- Terminals (Elementy końcowe) ---
noun --> [W], { noun(W) }.
verb --> [W], { verb(W) }.
adj  --> [W], { adj(W) }.
