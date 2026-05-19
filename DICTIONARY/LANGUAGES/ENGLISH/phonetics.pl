:- module(phonetics, [entry_index/1]).

read_dictionary(Text) :-
    retractall(phonetic_entry(_, _)),
    open_string(Text, Stream),
    read_all_entries(Stream),
    close(Stream).

read_all_entries(Stream) :-
    read(Stream, Term),
    (   Term == eof
    ->  true
    ;   assert_entry(Term),
        read_all_entries(Stream)
    ).

% Matches entry(Word, PartOfSpeech, Plurals, Definition)
assert_entry(entry(Word, _, _, _)) :-
    atom_chars(Word, Chars),
    phrase(grapheme_to_ipa(Phonetics), Chars),
    assertz(phonetic_entry(Word, Phonetics)).
assert_entry(_).

entry_index(JSONList) :-
    findall([W, P], phonetic_entry(W, P), JSONList).

% --- Grapheme-to-Phoneme Rules (DCG) ---
grapheme_to_ipa([]) --> [].
grapheme_to_ipa([tS | R]) --> [c, h], !, grapheme_to_ipa(R).
grapheme_to_ipa([S | R])  --> [s, h], !, grapheme_to_ipa(R).
grapheme_to_ipa([T | R])  --> [t, h], !, grapheme_to_ipa(R).
grapheme_to_ipa([f | R])  --> [p, h], !, grapheme_to_ipa(R).
grapheme_to_ipa([ŋ | R])  --> [n, g], !, grapheme_to_ipa(R).
grapheme_to_ipa([kw | R]) --> [q, u], !, grapheme_to_ipa(R).
grapheme_to_ipa([aI | R]) --> [i, _], [e], {R = []}, !.
grapheme_to_ipa([OI | R]) --> [o, y], !, grapheme_to_ipa(R).
grapheme_to_ipa([oυ | R]) --> [o, a], !, grapheme_to_ipa(R).
grapheme_to_ipa([u | R])  --> [o, o], !, grapheme_to_ipa(R).
grapheme_to_ipa([O | R])  --> [a, u], !, grapheme_to_ipa(R).
grapheme_to_ipa([æ | R])  --> [a], !, grapheme_to_ipa(R).
grapheme_to_ipa([ε | R])  --> [e], !, grapheme_to_ipa(R).
grapheme_to_ipa([I | R])  --> [i], !, grapheme_to_ipa(R).
grapheme_to_ipa([oυ | R]) --> [o], !, grapheme_to_ipa(R).
grapheme_to_ipa([ | R])  --> [u], !, grapheme_to_ipa(R).
grapheme_to_ipa([C | R])  --> [C], !, grapheme_to_ipa(R).
