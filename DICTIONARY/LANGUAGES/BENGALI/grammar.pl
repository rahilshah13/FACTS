:- module(bengali, [sentence_len/2, entry_only/1, fill_template/1]).

:- dynamic(entry/4). % entry(Word, PartOfSpeech, Inflections, Meaning/Notes)
:- use_module(library(dcgs)).
:- use_module(library(lists)).
:- use_module(library(random)).

% বাক্য পূরণ করা (Complete the sentence helpers)
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

% --- Lexical Helpers (শব্দশ্রেণী সাহায্যকারী) ---
noun(W) :- entry(W, n, _, _).   % বিশেষ্য (Noun)
adj(W)  :- entry(W, adj, _, _). % বিশেষণ (Adjective)

verb(W) :- entry(W, v, _, _).   % ক্রিয়া (Verb)
verb(W) :- entry(_, v, Inflections, _),
           member(W, Inflections). % ক্রিয়ার রূপভেদ (Verb Inflections)

% --- Bengali DCG Rules (বাংলা ব্যাকরণ নিয়ম) ---
% Bengali follows SOV (Subject + Object + Verb).
sentence --> noun_phrase, verb_phrase.             % কর্তা + ক্রিয়া (Subject + Verb)
sentence --> noun_phrase, object_phrase, verb_phrase. % কর্তা + কর্ম + ক্রিয়া (Subject + Object + Verb)

% Noun Phrase (বিশেষ্য খণ্ড)
noun_phrase --> det_phrase, noun.
noun_phrase --> det_phrase, adj, noun.
noun_phrase --> adj, noun.
noun_phrase --> noun.

% Object Phrase (কর্ম খণ্ড - structurally mirrors a noun phrase)
object_phrase --> noun_phrase.

% Verb Phrase (ক্রিয়া খণ্ড)
verb_phrase --> verb.

% --- Determiners / Modifiers (নির্দেশক / বিশেষক শব্দ) ---
det_phrase --> predet, det_core.
det_phrase --> det_core.

% Predeterminers (প্রাক-নির্দেশক)
predet --> [সব].         % shob (all)
predet --> [উভয়].       % ubhoy (both)
predet --> [অর্ধেক].     % ordhek (half)

% Core determiners
det_core --> demonstrative.
det_core --> possessive.
det_core --> quantifier.
det_core --> number.
det_core --> distributive.
det_core --> interrogative.
det_core --> difference.
% Note: Standard standalone articles like "the" or "a" are omitted in Bengali grammar.

% Demonstratives (নির্দেশক সর্বনাম)
demonstrative --> [এই].    % ei (this)
demonstrative --> [ওই].    % oi (that)
demonstrative --> [সেটি].   % sheti (that specific object)
demonstrative --> [এগুলো]. % egulo (these)
demonstrative --> [ওগুলো]. % ogulo (those)

% Possessives (সম্বন্ধ পদ / স্বত্বাধিকার)
possessive --> [আমার].    % amar (my)
possessive --> [তোমার].   % tomar (your - familiar)
possessive --> [তার].     % tar (his/her)
possessive --> [আমাদের].  % amader (our)
possessive --> [তাদের].   % tader (their)

% Quantifiers (পরিমাণবাচক)
quantifier --> [কিছু].     % kichu (some / any)
quantifier --> [অনেক].    % onek (many / much)
quantifier --> [প্রচুর].    % prochur (a lot of)
quantifier --> [অল্প].     % olpo (few / little)
quantifier --> [বেশ কয়েকটি]. % besh koyekti (several)
quantifier --> [অধিকাংশ]. % odhikangsho (most)
quantifier --> [যথেষ্ট].    % jotheshto (enough)

% Numbers (সংখ্যাবাচক)
number --> [এক].      % ek (one)
number --> [দুই].     % dui (two)
number --> [তিন].     % tin (three)
number --> [প্রথম].   % prothom (first)
number --> [দ্বিতীয়].  % dbitiyo (second)
number --> [তৃতীয়].  % tritiyo (third)

% Distributives (বণ্টনবাচক)
distributive --> [প্রতিটি].    % protiti (each / every)
distributive --> [যেকোনো একটি]. % jekono ekti (either)
distributive --> [কোনোটিই না]. % konotiy-na (neither)

% Interrogatives (প্রশ্নবাচক)
interrogative --> [কোন].    % kon (which)
interrogative --> [কী].     % ki (what)
interrogative --> [কার].    % kar (whose)

% Difference / choice (ভিন্নতা সূচক)
difference --> [অন্য].    % onno (other)
difference --> [আরেকটি].  % arekti (another)

% --- Terminals (অন্তিম উপাদান) ---
noun --> [W], { noun(W) }.
verb --> [W], { verb(W) }.
adj  --> [W], { adj(W) }.
