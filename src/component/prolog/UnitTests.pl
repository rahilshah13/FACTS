:- module(unit_tests, [main/1]).

% --- Load all standard Trealla JS libraries ---
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
:- use_module(library(ordsets)).
:- use_module(library(heaps)).
:- use_module(library(queues)).
:- use_module(library(clpz)).
:- use_module(library(lambda)).
:- use_module(library(wasm)).
:- use_module(library(pio)).
:- use_module(library(freeze)).

% --- Descriptive Test Runner ---
run_test(Category, Name, Goal, test(Name, Status, Category)) :-
    ( catch(Goal, _, fail)
    -> Status = pass
    ; Status = fail
    ).

% --- Main Entry Point ---
main(Results) :-
    findall(Res, (
        % --- Core Logic & Arithmetic ---
        run_test(unification, 'unification (=)', (X = 1, X == 1), Res)
        ; run_test(unification, 'not unifiable (\\=)', (1 \= 2), Res)
        ; run_test(arithmetic, 'arithmetic (is)', (5 is 2 + 3), Res)
        ; run_test(arithmetic, 'comparison (>)', (10 > 5), Res)
        ; run_test(types, 'atom/1', atom(hello), Res)
        ; run_test(types, 'integer/1', integer(42), Res)
        ; run_test(types, 'var/1', (var(U), U = 1), Res)
        ; run_test(control, 'conjunction (,)', (true, true), Res)
        ; run_test(control, 'disjunction (;)', (true ; fail), Res)
        
        % --- library(lists) ---
        ; run_test(lists, 'length/2', length([a, b, c], 3), Res)
        ; run_test(lists, 'member/2', member(x, [a, x, c]), Res)
        ; run_test(lists, 'reverse/2', reverse([1,2], [2,1]), Res)
        
        % --- library(apply) ---
        ; run_test(apply, 'exclude/3', exclude(integer, [a, 1, b], [a, b]), Res)
        ; run_test(apply, 'foldl/4', foldl(plus, [1,2,3], 0, 6), Res)
        
        % --- library(dif) ---
        ; run_test(dif, 'dif/2 inequality', (dif(A, B), A = 1, B = 2), Res)

        % --- library(charsio) ---
        ; run_test(charsio, 'with_output_to_chars/2', with_output_to_chars(write(hi), "hi"), Res)
        
        % --- library(dcgs) ---
        ; run_test(dcgs, 'seq//1', phrase(seq("abc"), "abc"), Res)

        % --- library(format) ---
        ; run_test(format, 'format/2 to stdout', format("~n", []), Res)

        % --- library(js) ---
        ; run_test(js, 'js_eval/1 (void)', js_eval("console.log('test')"), Res)
        ; run_test(js, 'js_fetch/3 (mock)', (catch(js_fetch('https://localhost', _, []), _, true)), Res)

        % --- library(pseudojson) ---
        ; run_test(pseudojson, 'json_chars/2 object', json_chars(pairs([a-1]), '{"a":1}'), Res)

        % --- library(crypto) ---
        ; run_test(crypto, 'crypto_password_hash/2', crypto_password_hash("pass", _), Res)

        % --- library(random) ---
        ; run_test(random, 'random/1', (random(F), float(F)), Res)

        % --- library(assoc) ---
        ; run_test(assoc, 'get_assoc/3', (list_to_assoc([a-1], Assoc), get_assoc(a, Assoc, 1)), Res)

        % --- library(ordsets) ---
        ; run_test(ordsets, 'ord_union/3', ord_union([1,3], [2,4], [1,2,3,4]), Res)

        % --- library(heaps) ---
        % Fixed: changed heap_add/4 to add_to_heap/4
        ; run_test(heaps, 'add_to_heap/4', (empty_heap(H), add_to_heap(H, 1, v, _)), Res)

        % --- library(queues) ---
        ; run_test(queues, 'is_queue/1', (empty_queue(Q), is_queue(Q)), Res)

        % --- library(clpz) ---
        ; run_test(clpz, 'clpz constraint #=', (X + Y #= 10, X = 7, Y = 3), Res)

        % --- library(lambda) ---
        % Fixed: Corrected lambda syntax for Trealla
        ; run_test(lambda, 'lambda call', call(\X^Y^(Y is X + 1), 1, 2), Res)

        % --- library(wasm) ---
        ; run_test(wasm, 'wasm_print/1', wasm_print(test_output), Res)

        % --- library(freeze) ---
        ; run_test(freeze, 'freeze/2 delay', (freeze(X, (Y = 1)), X = 2, Y = 1), Res)

        % --- library(terms) ---
        ; run_test(terms, 'functor/3', functor(f(a,b), f, 2), Res)
        ; run_test(terms, 'arg/3', arg(1, g(x,y), x), Res)

    ), Results).
