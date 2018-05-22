%
% To run the tests load hdb_tools and this file and issue run_tests as follows:
%
%   ?- ['test/test_front_0.pl'].
%   ?- run_tests.
%
% The output should look like:
%
%   % PL-Unit: test_front_0 .... done
%   % All N tests passed
%
% None of the tests should fail unless there is a bug somewhere, which you are encouraged to report via the GitHub issue system.
%
:- begin_tests(test_front_0).

:- use_module('../src/hdb/hdb_tools').

:- multifile
    hdb_store_2:document/2,
    hdb_store_2:execution/4,
    hdb_store_2:hadInPort/2,
    hdb_store_2:used/5,
    hdb_store_2:wasGeneratedBy/5,
    hdb_store_2:wasPartOf/2,
    hdb_store_2:wasDerivedFrom/7,
    hdb_store_2:wasInformedBy/4.

:- discontiguous
    hdb_store_2:document/2,
    hdb_store_2:execution/4,
    hdb_store_2:hadInPort/2,
    hdb_store_2:used/5,
    hdb_store_2:wasGeneratedBy/5,
    hdb_store_2:wasPartOf/2,
    hdb_store_2:wasDerivedFrom/7,
    hdb_store_2:wasInformedBy/4.

hdb_store_2:document("doc-1-v1", _).
hdb_store_2:document("doc-1-v2", _).
hdb_store_2:document("doc-1-v3", _).
hdb_store_2:document("doc-1-v4", _).
hdb_store_2:document("doc-2-v1", _).
hdb_store_2:document("doc-2-v2", _).
hdb_store_2:document("doc-2-v3", _).
hdb_store_2:document("doc-2-v4", _).
hdb_store_2:document("doc-2-v5", _).
hdb_store_2:document("doc-3-v1", _).
hdb_store_2:document("doc-3-v2", _).
hdb_store_2:document("doc-3-v3", _).
hdb_store_2:document("doc-4-v1", _).
hdb_store_2:document("doc-4-v2", _).
hdb_store_2:document("cc-in-v1", _).
hdb_store_2:document("cc-in-v2", _).
hdb_store_2:document("cc-in-v3", _).
hdb_store_2:document("cc-in-v4", _).
hdb_store_2:document("cc-in-v5", _).

hdb_store_2:execution("p1-ex1", _, _, _).
hdb_store_2:execution("p2-ex1", _, _, _).
hdb_store_2:execution("p3-ex1", _, _, _).
hdb_store_2:execution("gp2-ex1", _, _, _).
hdb_store_2:execution("gp2-ex2", _, _, _).
hdb_store_2:execution("ggp2-ex1", _, _, _).
hdb_store_2:execution("p2-ex2", _, _, _).
hdb_store_2:execution("p2-ex3", _, _, _).
hdb_store_2:execution("cc-ex1", _, _, _).
hdb_store_2:execution("cc-ex2", _, _, _).
hdb_store_2:execution("cc-ex3", _, _, _).
hdb_store_2:execution("cc-ex4", _, _, _).

hdb_store_2:used(_, "p1-ex1", "doc-1-v1", _, _).
hdb_store_2:used(_, "p1-ex1", "doc-4-v1", _, _).
hdb_store_2:used(_, "p2-ex1", "doc-2-v1", _, _).
hdb_store_2:used(_, "p2-ex2", "doc-2-v2", _, _).
hdb_store_2:used(_, "p2-ex3", "doc-2-v3", _, _).
hdb_store_2:used(_, "p3-ex1", "doc-1-v1", _, _).
hdb_store_2:used(_, "p3-ex1", "doc-2-v1", _, _).
hdb_store_2:used(_, "p3-ex1", "doc-3-v1", _, _).
hdb_store_2:used(_, "cc-ex1", "cc-in-v1", _, _).
% Note, usageId is given to allow port information to be linked to the data usage.
hdb_store_2:used("usage-a", "cc-ex2", "cc-in-v2", _, _).
hdb_store_2:used("usage-b", "cc-ex3", "cc-in-v2", _, _).
hdb_store_2:used("usage-c", "cc-ex4", "cc-in-v3", _, _).
hdb_store_2:used("usage-d", "p4-ex1", "doc-3-v1", _, _).
hdb_store_2:used("usage-e", "p4-ex1", "doc-3-v1", _, _).
hdb_store_2:used("usage-f", "p4-ex1", "doc-3-v2", _, _).

hdb_store_2:hadInPort("usage-a", "port-a").
hdb_store_2:hadInPort("usage-b", "port-b").
hdb_store_2:hadInPort("usage-d", "port-d").
hdb_store_2:hadInPort("usage-e", "port-e").
hdb_store_2:hadInPort("usage-f", "port-f").

hdb_store_2:wasInformedBy("inf-1", "gp2-ex2", "gp2-ex1", _{'prov:type' : ["recomp:re-execution"], 'recomp:data-change-new': ["doc-2-v2"]}).
hdb_store_2:wasInformedBy("inf-1.9", "xxxx", "top-level", _{}).
hdb_store_2:wasInformedBy("inf-2", "top-level-ex2", "top-level", _{'prov:type' : ["recomp:re-execution"], 'recomp:data-change-new': ["doc-2-v3"]}).
hdb_store_2:wasInformedBy("inf-2.1", "xxxxx", "top-level", _{}).
hdb_store_2:wasInformedBy("inf-3", "cc-ex2", "cc-ex1", _{'prov:type' : ["recomp:re-execution"], 'recomp:data-change-new': ["cc-in-v2"]}).
hdb_store_2:wasInformedBy("inf-4", "cc-ex3", "cc-ex1", _{'prov:type' : ["recomp:re-execution"], 'recomp:data-change-new': ["cc-in-v2"]}).
hdb_store_2:wasInformedBy("inf-5", "cc-ex4", "cc-ex2", _{'prov:type' : ["recomp:re-execution"], 'recomp:data-change-new': ["cc-in-v3"]}).
hdb_store_2:wasInformedBy("inf-6", "xxx", "top-level-ex2", _{}).

hdb_store_2:wasPartOf("ggp2-ex1", "top-level").
hdb_store_2:wasPartOf("gp2-ex1", "ggp2-ex1").
hdb_store_2:wasPartOf("p3-ex1",  "ggp2-ex1").
hdb_store_2:wasPartOf("p2-ex1", "gp2-ex1").

hdb_store_2:wasPartOf("p2-ex2", "gp2-ex2").

hdb_store_2:wasPartOf("ggp2-ex3", "top-level-ex2").
hdb_store_2:wasPartOf("gp2-ex3", "ggp2-ex3").
hdb_store_2:wasPartOf("p2-ex3", "gp2-ex3").

% doc-1-v1 <-- doc-1-v2 <-- doc-1-v3
% doc-2-v1 <-- doc-2-v2 <-- doc-2-v3 <-- doc-2-v4
hdb_store_2:wasDerivedFrom("der-1", "doc-1-v2", "doc-1-v1", _, _, _, _).
hdb_store_2:wasDerivedFrom("der-2", "doc-1-v3", "doc-1-v2", _, _, _, _).
hdb_store_2:wasDerivedFrom("der-3", "doc-1-v4", "doc-1-v3", _, _, _, _).
hdb_store_2:wasDerivedFrom("der-4", "doc-2-v2", "doc-2-v1", _, _, _, _).
hdb_store_2:wasDerivedFrom("der-5", "doc-2-v3", "doc-2-v2", _, _, _, _).
hdb_store_2:wasDerivedFrom("der-6", "doc-2-v4", "doc-2-v3", _, _, _, _).
hdb_store_2:wasDerivedFrom("der-6.1", "doc-2-v5", "doc-2-v4", _, _, _, _).
hdb_store_2:wasDerivedFrom("der-7", "doc-3-v2", "doc-3-v1", _, _, _, _).
hdb_store_2:wasDerivedFrom("der-7.1", "doc-3-v3", "doc-3-v2", _, _, _, _).
hdb_store_2:wasDerivedFrom("der-8", "cc-in-v2", "cc-in-v1", _, _, _, _).
hdb_store_2:wasDerivedFrom("der-9", "cc-in-v3", "cc-in-v2", _, _, _, _).
hdb_store_2:wasDerivedFrom("der-a", "cc-in-v4", "cc-in-v3", _, _, _, _).
hdb_store_2:wasDerivedFrom("der-b", "cc-in-v5", "cc-in-v4", _, _, _, _).
hdb_store_2:wasDerivedFrom("der-c", "doc-4-v2", "doc-4-v1", _, _, _, _).


test(build_recomp_front_1) :-
    build_recomp_front(["doc-2-v1"], []).

test(build_recomp_front_2) :-
    build_recomp_front(["doc-2-v2"], []).

test(build_recomp_front_3) :-
    build_recomp_front(["doc-2-v3"], [("gp2-ex2", [], [("p2-ex2", [_-"doc-2-v2"-"doc-2-v3"], [])])]).

test(build_recomp_front_4) :-
    build_recomp_front(["doc-2-v4", "doc-4x-v2"], 
        [
            ("gp2-ex2", [], [("p2-ex2", [_-"doc-2-v2"-"doc-2-v4"], [])]),
            ("top-level-ex2", [], [("ggp2-ex3", [], [("gp2-ex3", [], [("p2-ex3", [_-"doc-2-v3"-"doc-2-v4"], [])])])])
        ]).

test(build_recomp_front_5) :-
    build_recomp_front(["doc-3-v3"],
        [
            ("p4-ex1", ["port-f"-"doc-3-v2"-"doc-3-v3", "port-e"-"doc-3-v1"-"doc-3-v3", "port-d"-"doc-3-v1"-"doc-3-v3"], [])
        ]
    ).

test(build_rf_cc_1) :-
    hdb_tools:build_recomp_front(["cc-in-v3"], [("cc-ex3", [_-"cc-in-v2"-"cc-in-v3"], [])]).

test(build_rf_cc_2) :-
    hdb_tools:build_recomp_front(["cc-in-v4"], [("cc-ex3", [_-"cc-in-v2"-"cc-in-v4"], []), ("cc-ex4", [_-"cc-in-v3"-"cc-in-v4"], [])]).

:- end_tests(test_front_0).
