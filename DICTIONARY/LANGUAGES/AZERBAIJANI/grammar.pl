:- module(azerbaijani, [sentence_len/2, entry_only/1, fill_template/1]).

:- dynamic(entry/4). % entry(Word, PartOfSpeech, Inflections, Meaning/Notes)
:- use_module(library(dcgs)).
:- use_module(library(lists)).
:- use_module(library(random)).

% Cümləni tamamlamaq (Complete the sentence helpers)
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

% --- Lexical Helpers (Nitq hissələri / Leksik köməkçilər) ---
noun(W) :- entry(W, n, _, _).   % İsim (Noun)
adj(W)  :- entry(W, adj, _, _). % Sifət (Adjective)

verb(W) :- entry(W, v, _, _).   % Fel (Verb)
verb(W) :- entry(_, v, Inflections, _),
           member(W, Inflections). % Felin təsriflənən formaları (Verb Inflections)

% --- Azerbaijani DCG Rules (Azərbaycan dili qrammatika qaydaları) ---
% Azerbaijani is strictly SOV (Mübtəda + Tamamlıq + Xəbər).
sentence --> noun_phrase, verb_phrase.             % Mübtəda + Xəbər (Subject + Verb)
sentence --> noun_phrase, object_phrase, verb_phrase. % Mübtəda + Tamamlıq + Xəbər (Subject + Object + Verb)

% Noun Phrase (İsim birləşməsi)
noun_phrase --> det_phrase, noun.
noun_phrase --> det_phrase, adj, noun.
noun_phrase --> adj, noun.
noun_phrase --> noun.

% Object Phrase (Tamamlıq - structurally mirrors a noun phrase)
object_phrase --> noun_phrase.

% Verb Phrase (Fel birləşməsi)
verb_phrase --> verb.

% --- Determiners / Modifiers (Təyinlər) ---
det_phrase --> predet, det_core.
det_phrase --> det_core.

% Predeterminers (Ön təyinlər)
predet --> [bütün].     % all
predet --> [hər iki].   % both
predet --> [yarım].     % half

% Core determiners
det_core --> demonstrative.
det_core --> possessive.
det_core --> quantifier.
det_core --> number.
det_core --> distributive.
det_core --> interrogative.
det_core --> difference.
% Note: There are no absolute equivalents to "the". "A/An" is handled by the number [bir].

% Demonstratives (İşarə əvəzlikləri)
demonstrative --> [bu].      % this / these
demonstrative --> [o].       % that / those
demonstrative --> [həmin].   % that specific / the said

% Possessives (Yiyəlik əvəzlikləri)
possessive --> [mənim].    % my
possessive --> [sənin].    % your (singular / informal)
possessive --> [onun].     % his / her / its
possessive --> [bizim].    % our
possessive --> [sizin].    % your (plural / formal)
possessive --> [onların].  % their

% Quantifiers (Kəmiyyət bildirənlər)
quantifier --> [bəzi].     % some
quantifier --> [bir az].   % a little / some
quantifier --> [çox].      % many / much
quantifier --> [bir neçə]. % several / a few
quantifier --> [az].       % few / little
quantifier --> [əksər].    % most
quantifier --> [kifayət qədər]. % enough

% Numbers (Saylar)
number --> [bir].      % one / "a"
number --> [iki].      % two
number --> [üç].       % three
number --> [birinci].  % first
number --> [ikinci].   % second
number --> [üçüncü].   % third

% Distributives (Bölüşdürmə bildirənlər)
distributive --> [hər].       % each / every
distributive --> [hər hansı bir]. % either / any one
distributive --> [heç biri].  % neither (usually used with negative verbs)

% Interrogatives (Sual əvəzlikləri)
interrogative --> [hansı].    % which
interrogative --> [nə].       % what
interrogative --> [kimin].    % whose

% Difference / choice (Fərqləndiricilər)
difference --> [digər].    % other
difference --> [başqa].    % another / different

% --- Terminals (Sonluqlar) ---
noun --> [W], { noun(W) }.
verb --> [W], { verb(W) }.
adj  --> [W], { adj(W) }.
