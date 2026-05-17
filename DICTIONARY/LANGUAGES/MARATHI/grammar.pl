:- module(marathi, [sentence_len/2, entry_only/1, fill_template/1]).

:- dynamic(entry/4). % entry(Word, PartOfSpeech, Inflections, Meaning/Notes)
:- use_module(library(dcgs)).
:- use_module(library(lists)).
:- use_module(library(random)).

% वाक्य पूर्ण करणे (Complete the sentence helpers)
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

% --- Lexical Helpers (शब्दप्रकार सहाय्यक) ---
noun(W) :- entry(W, n, _, _).   % नाम (Noun)
adj(W)  :- entry(W, adj, _, _). % विशेषण (Adjective)

verb(W) :- entry(W, v, _, _).   % क्रियापद (Verb)
verb(W) :- entry(_, v, Inflections, _),
           member(W, Inflections). % क्रियापदाची रूपे (Verb Inflections)

% --- Marathi DCG Rules (मराठी व्याकरण नियम) ---
% Marathi follows SOV (Subject + Object + Verb).
sentence --> noun_phrase, verb_phrase.             % कर्ता + क्रियापद (Subject + Verb)
sentence --> noun_phrase, object_phrase, verb_phrase. % कर्ता + कर्म + क्रियापद (Subject + Object + Verb)

% Noun Phrase (नामबंध / नामपद)
noun_phrase --> det_phrase, noun.
noun_phrase --> det_phrase, adj, noun.
noun_phrase --> adj, noun.
noun_phrase --> noun.

% Object Phrase (कर्मपद - behaves structurally like a noun phrase)
object_phrase --> noun_phrase.

% Verb Phrase (क्रियापदबंध)
verb_phrase --> verb.

% --- Determiners / Modifiers (दर्शक / निर्धारक शब्द) ---
det_phrase --> predet, det_core.
det_phrase --> det_core.

% Predeterminers (पूर्व-निर्धारक)
predet --> [सर्व].      % sarva (all)
predet --> [दोन्ही].    % donhi (both)
predet --> [अर्धे].     % ardhe (half)

% Core determiners
det_core --> demonstrative.
det_core --> possessive.
det_core --> quantifier.
det_core --> number.
det_core --> distributive.
det_core --> interrogative.
det_core --> difference.
% Note: Marathi does not use articles like "a", "an", or "the".

% Demonstratives (दर्शके)
demonstrative --> [हा].    % ha (this - masculine)
demonstrative --> [ही].    % hi (this - feminine)
demonstrative --> [हे].    % he (this - neuter / plural)
demonstrative --> [तो].    % to (that - masculine)
demonstrative --> [ती].    % ti (that - feminine)
demonstrative --> [ते].    % te (that - neuter / plural)

% Possessives (स्वामित्वदर्शक / षष्ठी विभक्ती)
possessive --> [माझा].    % mazha (my)
possessive --> [तुझा].    % tuzha (your)
possessive --> [त्याचा].  % tyacha (his)
possessive --> [तिचा].    % ticha (her)
possessive --> [आमचा].    % aamcha (our)
possessive --> [त्यांचा]. % tyancha (their)

% Quantifiers (परिमाणवाचक)
quantifier --> [काही].    % kahi (some / any)
quantifier --> [पुष्कळ].  % pushkal (many / much)
quantifier --> [खूप].     % khoop (a lot of)
quantifier --> [थोडके].   % thodke (few)
quantifier --> [थोडे].    % thode (little)
quantifier --> [अनेक].    % anek (several)
quantifier --> [बहुतांश]. % bahutansh (most)
quantifier --> [पुरेसे].   % purese (enough)

% Numbers (संख्याविशेषणे)
number --> [एक].      % ek (one)
number --> [दोन].     % don (two)
number --> [तीन].     % teen (three)
number --> [पहिला].   % pahila (first)
number --> [दुसरा].   % dusra (second)
number --> [तिसरा].   % tisra (third)

% Distributives (विभाजक)
distributive --> [प्रत्येक].   % pratyek (each / every)
distributive --> [कोणताही एक]. % kontahi ek (either)
distributive --> [दोन्हींपैकी नाही]. % donhinpaiki nahi (neither)

% Interrogatives (प्रश्नार्थक)
interrogative --> [कोणता].  % konta (which)
interrogative --> [काय].    % kay (what)
interrogative --> [कोणाचा]. % konacha (whose)

% Difference / choice (भेददर्शक)
difference --> [इतर].    % itar (other)
difference --> [दुसरा].   % dusra (another)

% --- Terminals (अंतिम घटक) ---
noun --> [W], { noun(W) }.
verb --> [W], { verb(W) }.
adj  --> [W], { adj(W) }.
