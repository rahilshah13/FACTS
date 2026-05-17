:- module(indonesian, [sentence_len/2, entry_only/1, fill_template/1]).

:- dynamic(entry/4). % entry(Word, PartOfSpeech, Inflections, Meaning/Notes)
:- use_module(library(dcgs)).
:- use_module(library(lists)).
:- use_module(library(random)).

% Melengkapi kalimat (Complete the sentence helpers)
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

% --- Lexical Helpers (Pembantu Leberkala / Kelas Kata) ---
noun(W) :- entry(W, n, _, _).   % Kata Benda (Noun)
adj(W)  :- entry(W, adj, _, _). % Kata Sifat (Adjective)

verb(W) :- entry(W, v, _, _).   % Kata Kerja (Verb)
verb(W) :- entry(_, v, Inflections, _),
           member(W, Inflections). % Imbuhan Kata Kerja (Verb Inflections/Afixes)

% --- Indonesian DCG Rules (Tata Bahasa Indonesia) ---
% Indonesian is SVO (Subject + Verb + Object).
sentence --> noun_phrase, verb_phrase.

% Verb Phrase contains the verb and its optional object noun phrase
verb_phrase --> verb.
verb_phrase --> verb, noun_phrase.

% Noun Phrase (Frasa Nomina)
% Crucial change: Adjectives and Determiners FOLLOW the noun in Indonesian.
noun_phrase --> noun.
noun_phrase --> noun, adj.
noun_phrase --> noun, det_phrase.
noun_phrase --> noun, adj, det_phrase.
% Exception: Some pre-determiners (like numbers or quantifiers) can precede the noun.
noun_phrase --> det_phrase, noun.
noun_phrase --> det_phrase, noun, adj.

% --- Determiners / Modifiers (Kata Penentu / Penggolong) ---
det_phrase --> predet, det_core.
det_phrase --> det_core.

% Predeterminers (Biasanya diletakkan di depan)
predet --> [semua].     % all
predet --> [kedua].     % both
predet --> [setengah].  % half

% Core determiners
det_core --> demonstrative.
det_core --> possessive.
det_core --> quantifier.
det_core --> number.
det_core --> distributive.
det_core --> interrogative.
det_core --> difference.

% Demonstratives (Kata Tunjuk - always placed AFTER the noun)
demonstrative --> [ini].       % this / these
demonstrative --> [itu].       % that / those

% Possessives (Kata Ganti Kepunyaan - placed AFTER the noun)
possessive --> [saya].      % my (formal)
possessive --> [ku].        % my (clitic suffix)
possessive --> [kamu].      % your
possessive --> [mu].        % your (clitic suffix)
possessive --> [dia].       % his / her
possessive --> [nya].       % his / her / its (clitic suffix)
possessive --> [kami].      % our (excluding listener)
possessive --> [kita].      % our (including listener)
possessive --> [mereka].    % their

% Quantifiers (Kata Kuantitas)
quantifier --> [beberapa].  % some / several
quantifier --> [banyak].    % many / much
quantifier --> [sedikit].   % few / little
quantifier --> [sebagian besar]. % most
quantifier --> [cukup].     % enough

% Numbers (Kata Bilangan - usually placed BEFORE the noun)
number --> [satu].      % one
number --> [dua].       % two
number --> [tiga].      % three
number --> [pertama].   % first
number --> [kedua].     % second
number --> [ketiga].    % third

% Distributives (Kata Distribusi)
distributive --> [setiap].     % each / every
distributive --> [salah satu]. % either
distributive --> [bukan keduanya]. % neither

% Interrogatives (Kata Tanya)
interrogative --> [yang mana]. % which
interrogative --> [apa].       % what
interrogative --> [siapa].     % whose (strictly "siapa punya" or noun + "siapa")

% Difference / choice (Perbedaan)
difference --> [lain].      % other (placed after noun)
difference --> [lainnya].    % another / the other (placed after noun)

% --- Terminals (Elemen Akhir) ---
noun --> [W], { noun(W) }.
verb --> [W], { verb(W) }.
adj  --> [W], { adj(W) }.
