:- module(tagalog, [sentence_len/2, entry_only/1, fill_template/1]).

:- dynamic(entry/4). % entry(Word, PartOfSpeech, Inflections, Meaning/Notes)
:- use_module(library(dcgs)).
:- use_module(library(lists)).
:- use_module(library(random)).

% Para kumpletuhin ang pangungusap (Complete the sentence helpers)
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

% --- Lexical Helpers (Mga Bahagi ng Pananalita) ---
noun(W) :- entry(W, n, _, _).   % Pangngalan (Noun)
adj(W)  :- entry(W, adj, _, _). % Pang-uri (Adjective)

verb(W) :- entry(W, v, _, _).   % Pandiwa (Verb)
verb(W) :- entry(_, v, Inflections, _),
           member(W, Inflections). % Mga Aspekto ng Pandiwa (Verb Inflections/Aspects)

% --- Tagalog DCG Rules (Batas ng Balarilang Tagalog) ---
% Tagalog is strictly Predicate-Initial (Verb-Subject-Object / VSO).
sentence --> verb_phrase, subject_phrase.
sentence --> verb_phrase, subject_phrase, object_phrase.

% Verb Phrase (Pariralang Pandiwa) starts the sentence
verb_phrase --> verb.

% Subject Phrase (Pariralang Simuno - marked by "ang")
subject_phrase --> [ang], noun_phrase.

% Object Phrase (Pariralang Layon - marked by "ng" or "sa")
object_phrase --> [ng], noun_phrase.
object_phrase --> [sa], noun_phrase.

% Noun Phrase Base Structure (Kaanyuan ng Pariralang Pangngalan)
% Tagalog utilizes a linker ("na" or "-ng") to bind nouns and adjectives.
noun_phrase --> noun.
noun_phrase --> det_phrase, noun.
noun_phrase --> adj, [na], noun.   % e.g., "mabait na bata"
noun_phrase --> det_phrase, adj, [na], noun.
noun_phrase --> noun, [na], adj.   % Adjectives can also follow the noun

% --- Determiners / Modifiers (Mga Panuring / Pantukoy) ---
det_phrase --> predet, det_core.
det_phrase --> det_core.

% Predeterminers (Mga Unang Panuring)
predet --> [lahat ng].  % all
predet --> [parehong].  % both
predet --> [kalahati ng]. % half

% Core determiners
det_core --> demonstrative.
det_core --> possessive.
det_core --> quantifier.
det_core --> number.
det_core --> distributive.
det_core --> interrogative.
det_core --> difference.

% Demonstratives (Mga Panghalip Pamatlig)
demonstrative --> [ito].     % this / these (near speaker)
demonstrative --> [iyan].    % that / those (near listener)
demonstrative --> [iyon].    % that / those yonder (far from both)

% Possessives (Mga Panghalip Paari - Pre-nominal "Paari" form mapped here)
possessive --> [aking].    % my
possessive --> [iyong].    % your (singular)
possessive --> [kanilang]. % their
possessive --> [kanyang].  % his / her / its
possessive --> [ating].    % our (inclusive)
possessive --> [aming].    % our (exclusive)

% Quantifiers (Mga Panukat / Pang-uri ng Dami)
quantifier --> [ilang].     % some / several
quantifier --> [maraming].  % many / much
quantifier --> [kaunting].  % few / little
quantifier --> [karamihan sa]. % most
quantifier --> [sapat na].  % enough

% Numbers (Mga Pangatnig na Bilang)
number --> [isa].       % one
number --> [dalawa].    % two
number --> [tatlo].     % three
number --> [una].       % first
number --> [pangalawa]. % second
number --> [pangatlo].  % third

% Distributives (Pamahagi)
distributive --> [bawat].    % each / every
distributive --> [alinman].  % either
distributive --> [alinman sa dalawa ay hindi]. % neither

% Interrogatives (Mga Panghalip Pananong)
interrogative --> [alin].    % which
interrogative --> [ano].     % what
interrogative --> [kanino].  % whose

% Difference / choice (Iba pang Uri)
difference --> [iba].      % other
difference --> [isa pang].  % another

% --- Terminals (Mga Huling Elemento) ---
noun --> [W], { noun(W) }.
verb --> [W], { verb(W) }.
adj  --> [W], { adj(W) }.
