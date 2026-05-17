:- module(javanese, [sentence_len/2, entry_only/1, fill_template/1]).

:- dynamic(entry/4). % entry(Word, PartOfSpeech, Inflections, Meaning/Notes)
:- use_module(library(dcgs)).
:- use_module(library(lists)).
:- use_module(library(random)).

% Kanggo njangkapi ukara (Complete the sentence helpers)
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

% --- Lexical Helpers (Katrangan Jinising Tembung) ---
noun(W) :- entry(W, n, _, _).   % Tembung Aran (Noun)
adj(W)  :- entry(W, adj, _, _). % Tembung Kahanan (Adjective)

verb(W) :- entry(W, v, _, _).   % Tembung Kriya (Verb)
verb(W) :- entry(_, v, Inflections, _),
           member(W, Inflections). % Ater-ater lan Panambang Kriya (Verb Inflections/Afixes)

% --- Javanese DCG Rules (Tata Basa Jawa) ---
% Javanese is primarily SVO (Jejer + Wasesa + Lesan).
sentence --> noun_phrase, verb_phrase.

% Verb Phrase contains the verb and its optional object noun phrase
verb_phrase --> verb.
verb_phrase --> verb, noun_phrase.

% Noun Phrase (Frasa Nomina)
% Structural adjustment: Adjectives and core determiners (demonstratives/possessives) FOLLOW the noun.
noun_phrase --> noun.
noun_phrase --> noun, adj.
noun_phrase --> noun, post_det.
noun_phrase --> noun, adj, post_det.
% Exception: Broad quantifiers and numbers can precede the noun.
noun_phrase --> pre_det, noun.
noun_phrase --> pre_det, noun, adj.

% --- Determiners / Modifiers (Tembung Panyilah / Panudhuh) ---
% Split into Pre-nominal (Sakdurungé tembung aran) and Post-nominal (Sakwisé tembung aran) layers.
pre_det  --> predet_core.

post_det --> demonstrative.
post_det --> possessive.
post_det --> quantifier.
post_det --> number.
post_det --> distributive.
post_det --> interrogative.
post_det --> difference.

% Predeterminers (Pre-nominal)
predet_core --> [kabèh].     % all (can also follow the noun)
predet_core --> [karong].     % both
predet_core --> [setengah].  % half

% Demonstratives (Tembung Panudhuh - Post-nominal)
% Note: Ngoko (informal) registers used as standard baselines here.
demonstrative --> [iki].     % this / these
demonstrative --> [iku].     % that / those (medium distance)
demonstrative --> [kaé].     % that / those (far away)

% Possessives (Panyilah Darbe - Post-nominal)
possessive --> [ku].       % my (enclitic)
possessive --> [mu].       % your (enclitic)
possessive --> [dhèwèké].  % his / her
possessive --> [é].        % its / his / her (suffix)
possessive --> [kita].     % our
possessive --> [marang].   % their

% Quantifiers (Tembung Cacah - Post-nominal)
quantifier --> [saperangan]. % some
quantifier --> [akeh].       % many / much
quantifier --> [sithik].     % few / little
quantifier --> [sawetara].   % several
quantifier --> [akèhé].      % most
quantifier --> [cukup].      % enough

% Numbers (Tembung Wilangan - Post-nominal standard parsing)
number --> [siji].     % one
number --> [loro].     % two
number --> [telu].     % three
number --> [kapisan].  % first
number --> [kapindho]. % second
number --> [kaping].   % third

% Distributives (Post-nominal context)
distributive --> [saben].         % each / every
distributive --> [salah siji].    % either
distributive --> [ora loro-lorone]. % neither

% Interrogatives (Tembung Pitakon)
interrogative --> [sing endi]. % which
interrogative --> [apa].       % what
interrogative --> [sapa].      % whose (strictly used with a linker, e.g., "gandhengane sapa")

% Difference / choice (Post-nominal)
difference --> [liya].     % other
difference --> [liyane].   % another

% --- Terminals (Pungkasaning Unsur) ---
noun --> [W], { noun(W) }.
verb --> [W], { verb(W) }.
adj  --> [W], { adj(W) }.
