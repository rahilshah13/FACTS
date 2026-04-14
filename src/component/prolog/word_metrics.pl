:- module(word_metrics, [entry_index/1]).

entry_index(Results) :-
    setup_call_cleanup(
        open('/english.pl', read, Stream),
        process_dictionary(Stream, RawCounts),
        close(Stream)
    ),
    format_for_js(RawCounts, Results).

process_dictionary(Stream, IndexMap) :-
    read(Stream, FirstTerm),
    (   FirstTerm == end_of_file 
    ->  IndexMap = []
    ;   term_to_first_char(FirstTerm, Char),
        count_group(Stream, Char, 1, NextTerm, Count),
        IndexMap = [Char-Count | Rest],
        process_remaining(Stream, NextTerm, Rest)
    ).

process_remaining(_Stream, end_of_file, []) :- !.
process_remaining(Stream, CurrentTerm, [Char-Count | Rest]) :-
    term_to_first_char(CurrentTerm, Char),
    count_group(Stream, Char, 1, NextTerm, Count),
    process_remaining(Stream, NextTerm, Rest).

count_group(Stream, Char, Acc, NextTerm, Total) :-
    read(Stream, Term),
    (   Term \== end_of_file, term_to_first_char(Term, Char)
    ->  NewAcc is Acc + 1,
        count_group(Stream, Char, NewAcc, NextTerm, Total)
    ;   NextTerm = Term,
        Total = Acc
    ).

term_to_first_char(entry(Word, _, _, _), Char) :-
    atom_chars(Word, [Char|_]).

format_for_js([], []).
format_for_js([Char-Count|T], [metric(Char, Count, 'Alpha')|Rest]) :-
    format_for_js(T, Rest).