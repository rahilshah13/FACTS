:- module(unit_test, [main/1]).

:- use_module(library(lists)).
:- use_module(library(apply)).
:- use_module(library(charsio)).
:- use_module(library(dcgs)).
:- use_module(library(format)).
:- use_module(library(dif)).
:- use_module(library(js)).
:- use_module(library(pseudojson)).
:- use_module(library(random)).
:- use_module(library(crypto)).
:- use_module(library(assoc)).

% --- Descriptive Test Runner ---
run_test(Category, Name, Goal, test(Name, Status, Category)) :-
    (   catch(Goal, _, fail)
    ->  Status = pass
    ;   Status = fail
    ).

% --- Driver returns a list of descriptive terms ---
main(Results) :-
    findall(Res, (
        % --- library(lists) ---
        run_test(lists, 'append/3', append([a], [b], [a, b]), Res)
        ; run_test(lists, 'select/3', select(2, [1, 2, 3], [1, 3]), Res)
        % --- library(apply) ---
        ; run_test(apply, 'maplist/2', maplist(integer, [1, 2, 3]), Res)
        % --- library(dif) ---
        ; run_test(dif, 'dif/2 success', dif(X, Y), Res)
        ; run_test(dif, 'dif/2 constraint', (dif(X, 1), X \= 1), Res)
        % --- library(charsio) ---
        ; run_test(charsio, 'read_from_chars/2', read_from_chars("foo.", foo), Res)
        % --- library(dcgs) ---
        ; run_test(dcgs, 'phrase/2', phrase(("a", "b"), "ab"), Res)
        % --- library(format) ---
        ; run_test(format, 'format_chars/3', format_chars("~w", [123], "123"), Res)
        % --- library(js) & library(pseudojson) ---
        % Note: js_eval/2 requires a JS environment to be active
        ; run_test(js, 'js_eval/2 string', js_eval("1 + 1", 2), Res)
        ; run_test(pseudojson, 'json_chars/2', json_chars(JSON, '{"a":1}'), Res)
        % --- library(crypto) ---
        ; run_test(crypto, 'crypto_data_hash/3', crypto_data_hash("abc", _, [algorithm(sha256)]), Res)
        % --- library(random) ---
        ; run_test(random, 'maybe/0', (maybe ; \+ maybe), Res)
        % --- library(assoc) ---
        ; run_test(assoc, 'empty_assoc/1', empty_assoc(_), Res)
        ; run_test(assoc, 'put_assoc/4', (empty_assoc(A), put_assoc(k, A, v, _)), Res)
    ), Results).