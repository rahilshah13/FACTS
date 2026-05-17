:- module(yoruba, [sentence_len/2, entry_only/1, fill_template/1]).

:- dynamic(entry/4). % entry(Word, PartOfSpeech, Inflections, Meaning/Notes)
:- use_module(library(dcgs)).
:- use_module(library(lists)).
:- use_module(library(random)).

% Lati pari gbolohun (Complete the sentence helpers)
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

% --- Lexical Helpers (Àwọn Olùrànlọ́wọ́ Ọ̀rọ̀ / Ẹ̀ka Ọ̀rọ̀) ---
noun(W) :- entry(W, n, _, _).   % Ọ̀rọ̀-orúkọ (Noun)
adj(W)  :- entry(W, adj, _, _). % Ọ̀rọ̀-àpèjúwe (Adjective)

verb(W) :- entry(W, v, _, _).   % Ọ̀rọ̀-ìṣe (Verb)
verb(W) :- entry(_, v, Inflections, _),
           member(W, Inflections). % Àwọn àyípadà ọ̀rọ̀-ìṣe (Verb Inflections/Aspect Markers)

% --- Yoruba DCG Rules (Òfin Gírámà Yorùbá) ---
% Yoruba is strictly SVO (Olùṣe + Ọ̀rọ̀-ìṣe + Olùgbà).
sentence --> noun_phrase, verb_phrase.

% Verb Phrase contains the verb and its optional object noun phrase
verb_phrase --> verb.
verb_phrase --> verb, noun_phrase.

% Noun Phrase (Àpólà Ọ̀rọ̀-orúkọ)
% Structural adjustment: Adjectives and core determiners (like demonstratives) FOLLOW the noun.
noun_phrase --> noun.
noun_phrase --> noun, adj.
noun_phrase --> noun, post_det.
noun_phrase --> noun, adj, post_det.
% Exception: Broad quantifiers and numbers can precede the noun.
noun_phrase --> pre_det, noun.
noun_phrase --> pre_det, noun, adj.
noun_phrase --> pre_det, noun, adj, post_det.

% --- Determiners / Modifiers (Àwọn Ọ̀rọ̀ Atọ́ka) ---
% Split into Pre-nominal (Sáájú ọ̀rọ̀-orúkọ) and Post-nominal (Lẹ́yìn ọ̀rọ̀-orúkọ) layers.
pre_det  --> predet_core.
pre_det  --> quantifier.
pre_det  --> number_pre.

post_det --> demonstrative.
post_det --> possessive.
post_det --> number_post.
post_det --> distributive.
post_det --> interrogative.
post_det --> difference.

% Predeterminers / Universal Quantifiers (Pre-nominal)
predet_core --> [gbogbo].    % all
predet_core --> [àwọn méjèèjì]. % both (literally "the two")
predet_core --> [àbọ̀].      % half

% Demonstratives (Ọ̀rọ̀-atọ́ka Nǹkan - Post-nominal)
demonstrative --> [yìí].     % this / these
demonstrative --> [yẹn].     % that / those

% Possessives (Ọ̀rọ̀-arọ́pò fún Ohun-ìní - Post-nominal)
possessive --> [mi].       % my
possessive --> [rẹ].       % your (singular)
possessive --> [rẹ̀].       % his / her / its
possessive --> [wa].       % our
possessive --> [yín].      % your (plural/respectful)
possessive --> [wọn].      % their

% Quantifiers (Ọ̀rọ̀ Ìwọ̀n - Pre-nominal)
quantifier --> [bákan].     % some / any
quantifier --> [púpọ̀].     % many / much (can also follow as adj)
quantifier --> [díẹ̀].      % few / little
quantifier --> [oríṣiríṣi]. % several / various
quantifier --> [púpọ̀ jùlọ]. % most
quantifier --> [tó kámọ́].   % enough

% Numbers (Pre-nominal cardinally, or Post-nominal ordinally)
number_pre  --> [okan].     % one
number_pre  --> [meji].     % two
number_pre  --> [mẹta].     % three

number_post --> [kìn-ín-ní]. % first
number_post --> [kejì].     % second
number_post --> [kẹta].     % third
number_post --> [kan].      % a / certain one (functions as indefinite article)

% Distributives (Post-nominal context)
distributive --> [kọ̀ọ̀kan].   % each / every
distributive --> [yálà].      % either (often used as conjunction)
distributive --> [kò sí èyí]. % neither 

% Interrogatives (Post-nominal modifiers)
interrogative --> [wo].       % which
interrogative --> [kí].       % what
interrogative --> [ti tani].  % whose

% Difference / choice (Post-nominal)
difference --> [míràn].     % other / another
difference --> [tókù].      % the other / remaining

% --- Terminals (Àwọn Ọ̀rọ̀ Ìparí) ---
noun --> [W], { noun(W) }.
verb --> [W], { verb(W) }.
adj  --> [W], { adj(W) }.
