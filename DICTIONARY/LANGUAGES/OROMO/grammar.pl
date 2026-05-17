:- module(oromo, [sentence_len/2, entry_only/1, fill_template/1]).

:- dynamic(entry/4). % entry(Word, PartOfSpeech, Inflections, Meaning/Notes)
:- use_module(library(dcgs)).
:- use_module(library(lists)).
:- use_module(library(random)).

% Himarree guutuu (Complete the sentence helpers)
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

% --- Lexical Helpers (Gargaartota Jechootaa / Ramaddii Jechaa) ---
noun(W) :- entry(W, n, _, _).   % Maqaa (Noun)
adj(W)  :- entry(W, adj, _, _). % Ibsamaqaa (Adjective)

verb(W) :- entry(W, v, _, _).   % Gochima (Verb)
verb(W) :- entry(_, v, Inflections, _),
           member(W, Inflections). % Dhamsaga Gochimaa (Verb Inflections)

% --- Oromo DCG Rules (Seerlugaa Afaan Oromoo) ---
% Oromo is strictly SOV (Abbaa + Antaa + Gochima).
sentence --> noun_phrase, verb_phrase.             % Abbaa + Gochima (Subject + Verb)
sentence --> noun_phrase, object_phrase, verb_phrase. % Abbaa + Antaa + Gochima (Subject + Object + Verb)

% Noun Phrase (Haree Maqaa)
% Structural adjustment: Adjectives and core determiners (demonstratives/possessives) FOLLOW the noun.
noun_phrase --> noun.
noun_phrase --> noun, adj.
noun_phrase --> noun, post_det.
noun_phrase --> noun, adj, post_det.
% Exception: Universal quantifiers or select pre-determiners can precede the noun.
noun_phrase --> pre_det, noun.
noun_phrase --> pre_det, noun, adj.

% Object Phrase (Frasa Antaa - structurally mirrors a noun phrase)
object_phrase --> noun_phrase.

% Verb Phrase (Haree Gochimaa - always anchors the sentence end)
verb_phrase --> verb.

% --- Determiners / Modifiers (Jechoota Agarsiiftuu fi Madaltoo) ---
% Split into Pre-nominal (Maqaa Dura) and Post-nominal (Maqaa Duuba) layers.
pre_det  --> predet_core.
pre_det  --> quantifier_pre.

post_det --> demonstrative.
post_det --> possessive.
post_det --> quantifier_post.
post_det --> number.
post_det --> distributive.
post_det --> interrogative.
post_det --> difference.

% Predeterminers / Broad Modifiers (Pre-nominal)
predet_core --> [hunda].     % all (can also follow the noun)
predet_core --> [lachan].    % both
predet_core --> [walakkaa].  % half

% Demonstratives (Maqaddaa Agarsiiftuu - Post-nominal)
demonstrative --> [kana].    % this / these
demonstrative --> [sana].    % that / those

% Possessives (Maqaddaa Abbaa-lummaa - Post-nominal)
possessive --> [koo].       % my
possessive --> [kee].       % your (singular)
possessive --> [isáa].      % his / its
possessive --> [ishee].     % her
possessive --> [keenya].    % our
possessive --> [keessan].   % your (plural)
possessive --> [isaanii].   % their

% Quantifiers (Pre-nominal and Post-nominal variants)
quantifier_pre  --> [muraasa].   % some / few
quantifier_pre  --> [baay'ee].   % many / much / a lot of
quantifier_post --> [gahaa].     % enough
quantifier_post --> [baay'inaan]. % most

% Numbers (Lakkofsa - Post-nominal standard alignment)
number --> [tokko].    % one (also implies "a/an" when following a noun)
number --> [lama].     % two
number --> [sadii].    % three
number --> [tokkoffaa].% first
number --> [lammaffaa].% second
number --> [saddaffaa].% third

% Distributives (Post-nominal context)
distributive --> [addaan].      % each / apart
distributive --> [tokkoo tokkoo]. % each / every
distributive --> [lameen keessaa tokko]. % either
distributive --> [kamayyuu miti]. % neither (requires negative verb)

% Interrogatives (Jechoota Gaaffii)
interrogative --> [kam].       % which
interrogative --> [maal].      % what
interrogative --> [kan eenyuu]. % whose

% Difference / choice (Post-nominal)
difference --> [biroo].    % other
difference --> [kan biraa]. % another

% --- Terminals (Jechoota Dhumaa) ---
noun --> [W], { noun(W) }.
verb --> [W], { verb(W) }.
adj  --> [W], { adj(W) }.
