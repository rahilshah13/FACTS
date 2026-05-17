:- module(amharic, [sentence_len/2, entry_only/1, fill_template/1]).

:- dynamic(entry/4). % entry(Word, PartOfSpeech, Inflections, Meaning/Notes)
:- use_module(library(dcgs)).
:- use_module(library(lists)).
:- use_module(library(random)).

% ዓረፍተ ነገር ማሟያ (Complete the sentence helpers)
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

% --- Lexical Helpers (የቃል ክፍሎች / ረዳቶች) ---
noun(W) :- entry(W, n, _, _).   % ስም (Noun)
adj(W)  :- entry(W, adj, _, _). % ቅፅል (Adjective)

verb(W) :- entry(W, v, _, _).   % ግስ (Verb)
verb(W) :- entry(_, v, Inflections, _),
           member(W, Inflections). % የግስ እርባታ (Verb Inflections)

% --- Amharic DCG Rules (የአማርኛ ሰዋስው ደንቦች) ---
% Amharic is strictly SOV (ባለቤት + ተሳቢ + ማሰሪያ ግስ).
sentence --> noun_phrase, verb_phrase.             % ባለቤት + ማሰሪያ ግስ (Subject + Verb)
sentence --> noun_phrase, object_phrase, verb_phrase. % ባለቤት + ተሳቢ + ማሰሪያ ግስ (Subject + Object + Verb)

% Noun Phrase (የስም ሀረግ)
noun_phrase --> det_phrase, noun.
noun_phrase --> det_phrase, adj, noun.
noun_phrase --> adj, noun.
noun_phrase --> noun.

% Object Phrase (የተሳቢ ሀረግ - structurally mirrors a noun phrase)
% Note: In continuous text, definite objects often take the suffix marker "-ን" (-n)
object_phrase --> noun_phrase.

% Verb Phrase (የግስ ሀረግ - always anchors the sentence end)
verb_phrase --> verb.

% --- Determiners / Modifiers (አመላካች / መጣኝ ቃላት) ---
det_phrase --> predet, det_core.
det_phrase --> det_core.

% Predeterminers (ቅድመ-አመላካቾች)
predet --> [ሁሉም].     % hulum (all)
predet --> [ሁለቱም].    % huletum (both)
predet --> [እኩሌታ].    % ekulieta (half)

% Core determiners
det_core --> demonstrative.
det_core --> possessive.
det_core --> quantifier.
det_core --> number.
det_core --> distributive.
det_core --> interrogative.
det_core --> difference.
% Note: Standalone articles like "a" or "the" are absent. 

% Demonstratives (አመላካች ተውላጠ ስሞች)
demonstrative --> [ይህ].      % yihe (this - masculine)
demonstrative --> [ይህች].    % yihich (this - feminine)
demonstrative --> [ያ].       % ya (that - masculine)
demonstrative --> [ያች].      % yach (that - feminine)
demonstrative --> [እነዚህ].   % enezihe (these)
demonstrative --> [እነዚያ].   % eneziya (those)

% Possessives (የባለቤትነት አመላካቾች - Pre-nominal forms mapped here)
% Note: Amharic frequently uses prefixes like "የ-" (ye-) combined with pronouns for possessives.
possessive --> [የኔ].      % yene (my)
possessive --> [የአንተ].    % ye-ante (your - masculine)
possessive --> [የአንቺ].    % ye-anchi (your - feminine)
possessive --> [የእሱ].     % ye-essu (his / its)
possessive --> [የእሷ].     % ye-esswa (her)
possessive --> [የኛ].      % yegna (our)
possessive --> [የእናንተ].   % ye-enante (your - plural)
possessive --> [የእነሱ].    % ye-enessu (their)

% Quantifiers (መጠንን አመላካቾች)
quantifier --> [አንዳንድ].   % andand (some)
quantifier --> [ማንኛውም].   % manyawum (any)
quantifier --> [ብዙ].      % bzu (many / much / a lot of)
quantifier --> [ጥቂት].     % t’ikit (few / little)
quantifier --> [በርካታ].    % berkata (several)
quantifier --> [አብዛኛው].   % abzanyawu (most)
quantifier --> [በቂ].      % beqi (enough)

% Numbers (ቁጥሮች)
number --> [አንድ].     % and (one / used also as "a")
number --> [ሁለት].    % hulet (two)
number --> [ሦስት].    % sost (three)
number --> [አንደኛ].    % andegna (first)
number --> [ሁለተኛ].   % huletegna (second)
number --> [ሦስተኛ].   % sostegna (third)

% Distributives (አከፋፋይ ቃላት)
distributive --> [እያንዳንዱ]. % eyandandu (each / every)
distributive --> [ከሁለቱ አንዱ]. % kehuletu andu (either)
distributive --> [ሁለቱም አይደለም]. % huletum aydellem (neither - requires negative verb coordination)

% Interrogatives (ጠያቂ ቃላት)
interrogative --> [የትኛው].   % yetnyawu (which)
interrogative --> [ምን].     % mn (what)
interrogative --> [የማን].    % yeman (whose)

% Difference / choice (ሌላነት አመላካች)
difference --> [ሌላ].     % lela (other)
difference --> [ሌላኛው].   % lelanyawu (another)

% --- Terminals (የመጨረሻ አካላት) ---
noun --> [W], { noun(W) }.
verb --> [W], { verb(W) }.
adj  --> [W], { adj(W) }.
