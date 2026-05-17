:- module(tamil, [sentence_len/2, entry_only/1, fill_template/1]).

:- dynamic(entry/4). % entry(Word, PartOfSpeech, Inflections, Meaning/Notes)
:- use_module(library(dcgs)).
:- use_module(library(lists)).
:- use_module(library(random)).

% வாக்கியத்தை நிரப்புதல் (Complete the sentence helpers)
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

% --- Lexical Helpers (சொல்வகை உதவியாளர்கள்) ---
noun(W) :- entry(W, n, _, _).   % பெயர்ச்சொல் (Noun)
adj(W)  :- entry(W, adj, _, _). % பெயரடை (Adjective)

verb(W) :- entry(W, v, _, _).   % வினைச்சொல் (Verb)
verb(W) :- entry(_, v, Inflections, _),
           member(W, Inflections). % வினைமுற்று / வினையெச்ச உருபுகள்

% --- Tamil DCG Rules (தமிழ் இலக்கண விதிகள்) ---
% Tamil is SOV (Subject-Object-Verb). Verbs come at the end.
sentence --> noun_phrase, verb_phrase.             % எழுவாய் + பயனிலை (Subject + Verb)
sentence --> noun_phrase, object_phrase, verb_phrase. % எழுவாய் + செயப்படுபொருள் + பயனிலை (Subject + Object + Verb)

% Noun Phrase (பெயர்ச்சொற்றொடர்)
noun_phrase --> det_phrase, noun.
noun_phrase --> det_phrase, adj, noun.
noun_phrase --> adj, noun.
noun_phrase --> noun.

% Object Phrase (செயப்படுபொருள் தொடர் - often mirrors noun phrases or takes case markers)
object_phrase --> noun_phrase.

% Verb Phrase (வினைச்சொற்றொடர்)
verb_phrase --> verb.

% --- Determiners / Modifiers (சுட்டுச்சொற்கள் / எண்ணுப்பெயர்கள்) ---
det_phrase --> predet, det_core.
det_phrase --> det_core.

% Predeterminers (முன்சுட்டுகள்)
predet --> [எல்லா].      % ella (all)
predet --> [இரு].        % iru (both)
predet --> [அரை].       % arai (half)

% Core determiners
det_core --> demonstrative.
det_core --> possessive.
det_core --> quantifier.
det_core --> number.
det_core --> distributive.
det_core --> interrogative.
det_core --> difference.
% Note: Tamil does not have articles like "a", "an", "the". They are omitted.

% Demonstratives (சுட்டுப்பெயர்கள்)
demonstrative --> [இந்த].    % indha (this)
demonstrative --> [அந்த].    % andha (that)
demonstrative --> [இவை].    % ivai (these)
demonstrative --> [அவை].    % avai (those)

% Possessives (உடைமைப் பெயர்கள்)
possessive --> [என்னுடைய].  % ennudaiya (my)
possessive --> [உன்னுடைய].  % unnudaiya (your)
possessive --> [அவனுடைய].  % avanudaiya (his)
possessive --> [அவளுடைய].  % avaludaiya (her)
possessive --> [அதனுடைய].  % adhanudaiya (its)
possessive --> [நம்முடைய].  % nammudaiya (our)
possessive --> [அவர்களுடைய]. % avarghaludaiya (their)

% Quantifiers (அளவுப் பெயர்கள்)
quantifier --> [சில].       % sila (some)
quantifier --> [ஏதேனும்].    % edhenum (any)
quantifier --> [பல].       % pala (many)
quantifier --> [அதிக].      % adhiga (much/more)
quantifier --> [சிலவற்று].   % silavattru (few)
quantifier --> [கொஞ்சம்].    % konjam (little)
quantifier --> [பலதரப்பட்ட].  % paladharappatta (several)
quantifier --> [பெரும்பாலான]. % perumboolana (most)
quantifier --> [போதிய].     % podhiya (enough)

% Numbers (எண்கள்)
number --> [ஒன்று].     % ondru (one)
number --> [இரண்டு].    % irandu (two)
number --> [மூன்று].    % moondru (three)
number --> [முதல்].     % mudhal (first)
number --> [இரண்டாம்].  % irandaam (second)
number --> [மூன்றாம்].  % moondraam (third)

% Distributives (பகிர்வுப் பெயர்கள்)
distributive --> [ஒவ்வொரு].  % ovvoru (each/every)
distributive --> [ஏதாவது ஒன்று]. % eadhaavadhu ondru (either)
distributive --> [எதுவும் இல்லை]. % edhuvum illai (neither)

% Interrogatives (வினாச்சொற்கள்)
interrogative --> [எந்த].     % endha (which)
interrogative --> [என்ன].     % enna (what)
interrogative --> [யாருடைய].  % yaarudaiya (whose)

% Difference / choice (வேறுபாடு)
difference --> [இதர].     % idhara (other)
difference --> [மற்றொரு].  % mattroru (another)

% --- Terminals (இறுதி உறுப்புகள்) ---
noun --> [W], { noun(W) }.
verb --> [W], { verb(W) }.
adj  --> [W], { adj(W) }.
