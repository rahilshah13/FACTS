:- module(unit_test, [main/1]).

% --- Descriptive Test Runner ---
% Returns a term: test(Name, Status, Category)
run_test(Category, Name, Goal, test(Name, Status, Category)) :-
    (   catch(Goal, _, fail)
    ->  Status = pass
    ;   Status = fail
    ).

% --- Driver returns a list of descriptive terms ---
main(Results) :-
    findall(Res, (
        % Format: run_test(Category, Name, Goal, Output)
        run_test(unification, 'unification (=)', (X = 1, X == 1), Res)
        ; run_test(unification, 'not unifiable (\\=)', (1 \= 2), Res)
        ; run_test(arithmetic, 'arithmetic (is)', (5 is 2 + 3), Res)
        ; run_test(arithmetic, 'comparison (>)', (10 > 5), Res)
        ; run_test(types, 'atom/1', atom(hello), Res)
        ; run_test(types, 'integer/1', integer(42), Res)
        ; run_test(types, 'var/1', (var(U), U = 1), Res)
        ; run_test(control, 'conjunction (,)', (true, true), Res)
        ; run_test(control, 'disjunction (;)', (true ; fail), Res)
        ; run_test(lists, 'length/2', length([a, b, c], 3), Res)
        ; run_test(lists, 'member/2', member(2, [1, 2, 3]), Res)
        ; run_test(terms, 'functor/3', functor(f(a,b), f, 2), Res)
        ; run_test(terms, 'arg/3', arg(1, g(x,y), x), Res)
    ), Results).    