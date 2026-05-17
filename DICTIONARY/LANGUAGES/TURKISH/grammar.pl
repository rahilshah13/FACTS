:- module(turkish, [sentence_len/2, entry_only/1, fill_template/1]).

:- dynamic(entry/4). % entry(Word, PartOfSpeech, Inflections, Meaning/Notes)
:- use_module(library(dcgs)).
:- use_module(library(lists)).
:- use_module(library(random)).

% Cümleyi tamamlama (Complete the sentence helpers)
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

% --- Lexical Helpers (Sözcük Türleri / Sözlüksel Yardımcılar) ---
noun(W) :- entry(W, n, _, _).   % İsim / Ad (Noun)
adj(W)  :- entry(W, adj, _, _). % Sıfat / Ön ad (Adjective)

verb(W) :- entry(W, v, _, _).   % Fiil / Eylem (Verb)
verb(W) :- entry(_, v, Inflections, _),
           member(W, Inflections). % Fiil Çekimleri (Verb Inflections)

% --- Turkish DCG Rules (Türkçe Dilbilgisi Kuralları) ---
% Turkish is strictly SOV (Özne + Nesne + Yüklem).
sentence --> noun_phrase, verb_phrase.             % Özne + Yüklem (Subject + Verb)
sentence --> noun_phrase, object_phrase, verb_phrase. % Özne + Nesne + Yüklem (Subject + Object + Verb)

% Noun Phrase (İsim Tamlaması / Öbek yapısı)
noun_phrase --> det_phrase, noun.
noun_phrase --> det_phrase, adj, noun.
noun_phrase --> adj, noun.
noun_phrase --> noun.

% Object Phrase (Nesne Öbeği - structurally mirrors a noun phrase)
object_phrase --> noun_phrase.

% Verb Phrase (Yüklem Öbeği - always anchors the sentence end)
verb_phrase --> verb.

% --- Determiners / Modifiers (Belirteçler / Belirleyiciler) ---
det_phrase --> predet, det_core.
det_phrase --> det_core.

% Predeterminers (Ön Belirleyiciler)
predet --> [bütün].     % all
predet --> [tüm].       % all
predet --> [her iki].   % both
predet --> [yarım].     % half

% Core determiners (Mutually exclusive layer)
det_core --> demonstrative.
det_core --> possessive.
det_core --> quantifier.
det_core --> number.
det_core --> distributive.
det_core --> interrogative.
det_core --> difference.
% Note: There is no word for "the". "A/An" is handled by the number [bir].

% Demonstratives (İşaret Sıfatları)
demonstrative --> [bu].      % this / these
demonstrative --> [şu].      % that / those (closer or being pointed to)
demonstrative --> [o].       % that / those (further away)

% Possessives (İyelik / Sahiplik Sıfatları - Pre-nominal forms mapped here)
% Note: Turkish also uses explicit matching noun suffixes which belong in your inflections dictionary.
possessive --> [benim].    % my
possessive --> [senin].    % your (singular / informal)
possessive --> [onun].     % his / her / its
possessive --> [bizim].    % our
possessive --> [sizin].    % your (plural / formal)
possessive --> [onların].  % their

% Quantifiers (Belgisiz Sıfatlar / Miktar Belirteçleri)
quantifier --> [bazı].     % some
quantifier --> [birkaç].   % several / a few
quantifier --> [biraz].    % a little / some
quantifier --> [çok].      % many / much / a lot of
quantifier --> [az].       % few / little
quantifier --> [çoğu].     % most
quantifier --> [yeterli].  % enough

% Numbers (Sayı Sıfatları)
number --> [bir].      % one / "a"
number --> [iki].      % two
number --> [üç].       % three
number --> [birinci].  % first
number --> [ikinci].   % second
number --> [üçüncü].   % third

% Distributives (Üleştirme / Dağıtma Sıfatları)
distributive --> [her].       % each / every
distributive --> [herhangi bir]. % either / any one
distributive --> [hiçbiri].   % neither (frequently paired with negative verb forms)

% Interrogatives (Soru Sıfatları)
interrogative --> [hangi].    % which
interrogative --> [ne].       % what
interrogative --> [kimin].    % whose

% Difference / choice (Niteleme Farkı)
difference --> [diğer].    % other
difference --> [başka].    % another / different

% --- Terminals (Uç Elemanlar) ---
noun --> [W], { noun(W) }.
verb --> [W], { verb(W) }.
adj  --> [W], { adj(W) }.
