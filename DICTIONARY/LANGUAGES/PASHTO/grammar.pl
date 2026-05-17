:- module(pashto, [sentence_len/2, entry_only/1, fill_template/1]).

:- dynamic(entry/4). % entry(Word, PartOfSpeech, Inflections, Meaning/Notes)
:- use_module(library(dcgs)).
:- use_module(library(lists)).
:- use_module(library(random)).

% د جملې بشپړول (Complete the sentence helpers)
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

% --- Lexical Helpers (د کلمو ډولونه / مرستندویان) ---
noun(W) :- entry(W, n, _, _).   % نوم (Noun)
adj(W)  :- entry(W, adj, _, _). % صفت (Adjective)

verb(W) :- entry(W, v, _, _).   % فعل (Verb)
verb(W) :- entry(_, v, Inflections, _),
           member(W, Inflections). % د فعل اړوند گردانونه (Verb Inflections)

% --- Pashto DCG Rules (د پښتو ژبې د ګرامر اصول) ---
% Pashto is strictly SOV (فاعل + مفعول + فعل).
sentence --> noun_phrase, verb_phrase.             % فاعل + فعل (Subject + Verb)
sentence --> noun_phrase, object_phrase, verb_phrase. % فاعل + مفعول + فعل (Subject + Object + Verb)

% Noun Phrase (اسمي غونډ)
noun_phrase --> det_phrase, noun.
noun_phrase --> det_phrase, adj, noun.
noun_phrase --> adj, noun.
noun_phrase --> noun.

% Object Phrase (مفعولي غونډ - structurally mirrors a noun phrase)
object_phrase --> noun_phrase.

% Verb Phrase (فعلي غونډ - always anchors the sentence end)
verb_phrase --> verb.

% --- Determiners / Modifiers (د نوم ټاکونکي کلمې) ---
det_phrase --> predet, det_core.
det_phrase --> det_core.

% Predeterminers (مخکیني ټاکونکي)
predet --> [ټول].      % tol (all)
predet --> [دواړه].    % dwarah (both)
predet --> [نیم].      % neem (half)

% Core determiners
det_core --> demonstrative.
det_core --> possessive.
det_core --> quantifier.
det_core --> number.
det_core --> distributive.
det_core --> interrogative.
det_core --> difference.
% Note: Standalone articles like "the" are absent. "A/An" is handled by the number [یو].

% Demonstratives (اشاري ضمیرونه)
demonstrative --> [دا].      % da (this / these - near)
demonstrative --> [اغه].     % agha (that / those - far)
demonstrative --> [دغه].     % dagha (this very / just that)

% Possessives (ملکي ضمیرونه - Pre-nominal forms)
possessive --> [زما].     % zma (my)
possessive --> [ستاسو].   % staso (your - plural/formal)
possessive --> [ستا].     % sta (your - singular)
possessive --> [د ده].    % da da (his / its)
possessive --> [د دې].    % da de (her)
possessive --> [زموږ].    % zmung (our)
possessive --> [د دوی].   % da dwi (their)

% Quantifiers (کمیت ښودونکي کلمې)
quantifier --> [ځینې].     % zene (some)
quantifier --> [هیڅ].      % hets (any / none)
quantifier --> [ډېر].      % der (many / much / a lot of)
quantifier --> [څو].       % tso (several / a few)
quantifier --> [لږ].       % lagz (few / little)
quantifier --> [اکثره].     % aksara (most)
quantifier --> [کافي].     % kafi (enough)

% Numbers (عددونه)
number --> [یو].       % yew (one / used also as "a")
number --> [دوه].      % dwo (two)
number --> [دري].      % dre (three)
number --> [لومړی].     % lumray (first)
number --> [دویم].     % dwayam (second)
number --> [دریم].     % dreyam (third)

% Distributives (ویشونکي توري)
distributive --> [هر].       % har (each / every)
distributive --> [هر یو].    % har yew (either / any one)
distributive --> [هیڅ یو].   % hets yew (neither - requires negative verb coordination)

% Interrogatives (پوښتني توري)
interrogative --> [کوم].     % kum (which)
interrogative --> [څه].      % tsah (what)
interrogative --> [د چا].    % da cha (whose)

% Difference / choice (د توپیر ښودلو توري)
difference --> [بل].       % bal (other / another)
difference --> [نور].       % nor (the other / more)

% --- Terminals (پایانې کلمې) ---
noun --> [W], { noun(W) }.
verb --> [W], { verb(W) }.
adj  --> [W], { adj(W) }.
