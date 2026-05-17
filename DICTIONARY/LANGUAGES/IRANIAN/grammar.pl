:- module(persian, [sentence_len/2, entry_only/1, fill_template/1]).

:- dynamic(entry/4). % entry(Word, PartOfSpeech, Inflections, Meaning/Notes)
:- use_module(library(dcgs)).
:- use_module(library(lists)).
:- use_module(library(random)).

% تکمیل جمله (Complete the sentence helpers)
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

% --- Lexical Helpers (اجزای کلام / راهنمای واژگان) ---
noun(W) :- entry(W, n, _, _).   % اسم (Noun)
adj(W)  :- entry(W, adj, _, _). % صفت (Adjective)

verb(W) :- entry(W, v, _, _).   % فعل (Verb)
verb(W) :- entry(_, v, Inflections, _),
           member(W, Inflections). % شناسه‌ها و صرف فعل (Verb Inflections)

% --- Persian DCG Rules (دستور زبان فارسی) ---
% Persian is strictly SOV (نهاد + مفعول + گزاره).
sentence --> noun_phrase, verb_phrase.
sentence --> noun_phrase, object_phrase, verb_phrase.

% Noun Phrase (گروه اسمی)
% Persian split layout: Quantifiers/Demonstratives come BEFORE the noun.
% Adjectives and Possessives come AFTER the noun (linked via Ezafe in speech/text).
noun_phrase --> noun.
noun_phrase --> pre_det, noun.
noun_phrase --> noun, post_det.
noun_phrase --> noun, adj.
noun_phrase --> pre_det, noun, adj.
noun_phrase --> pre_det, noun, post_det.
noun_phrase --> pre_det, noun, adj, post_det.

% Object Phrase (گروه مفعولی - often followed by the marker "ra" [را] if definite)
object_phrase --> noun_phrase.
object_phrase --> noun_phrase, [را]. % ra (definite object marker)

% Verb Phrase (گروه فعلی - always at the end)
verb_phrase --> verb.

% --- Determiners / Modifiers (وابسته‌های اسم) ---
% Split into Pre-nominal (قبل از اسم) and Post-nominal (بعد از اسم) layers.

pre_det --> predet_core.
pre_det --> demonstrative.
pre_det --> quantifier.
pre_det --> number.
pre_det --> distributive.
pre_det --> interrogative.

post_det --> possessive.
post_det --> difference.

% Predeterminers / Broad Quantifiers
predet_core --> [همه].       % hame (all)
predet_core --> [هر دو].     % har do (both)
predet_core --> [نصف].       % nesf (half)

% Demonstratives (صفت‌های اشاره - Precede the noun)
demonstrative --> [این].     % in (this / these)
demonstrative --> [آن].     % an (that / those)

% Possessives (ضمایر متصل یا منفصل ملکی - Follow the noun via Ezafe)
% Note: In text, these are often attached or follow an ezafe-constructed noun
possessive --> [من].       % man (my)
possessive --> [تو].       % to (your - sing.)
possessive --> [او].       % ou (his / her / its)
possessive --> [ما].       % ma (our)
possessive --> [شما].     % shoma (your - plur.)
possessive --> [آنها].     % anha (their)

% Quantifiers (صفت‌های شمارشی مبهم - Precede the noun)
quantifier --> [برخی].     % barkhi (some)
quantifier --> [کمی].      % kami (a little)
quantifier --> [بسیاری].   % bicyari (many / much)
quantifier --> [خیلی].     % kheyli (a lot of)
quantifier --> [چندین].    % chandin (several)
quantifier --> [بیشتر].     % bishtar (most)
quantifier --> [کافی].     % kafi (enough)

% Numbers (اعداد - Precede the noun)
number --> [یک].       % yek (one / "a")
number --> [دو].       % do (two)
number --> [سه].       % se (three)
number --> [اول].      % avval (first)
number --> [دوم].      % dovvom (second)
number --> [سوم].      % sevvom (third)

% Distributives (صفت‌های توزیعی)
distributive --> [هر].       % har (each / every)
distributive --> [هر کدام].   % har kodam (either)
distributive --> [هیچکدام].   % hichkodam (neither - acts with negative verb)

% Interrogatives (کلمات پرسشی قبل از اسم)
interrogative --> [کدام].    % kodam (which)
interrogative --> [چه].      % che (what)
interrogative --> [مال چه کسی]. % male che kasi (whose)

% Difference / choice (نشانه دگرگونی - Follows the noun)
difference --> [دیگر].     % digar (other)
difference --> [دیگری].    % digari (another)

% --- Terminals (پایانه‌ها) ---
noun --> [W], { noun(W) }.
verb --> [W], { verb(W) }.
adj  --> [W], { adj(W) }.
