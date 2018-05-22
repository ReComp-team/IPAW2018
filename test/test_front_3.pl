%
% To run the tests load hdb_tools and this file and issue run_tests as follows:
%
%   ?- ['test/test_front_3.pl'].
%   ?- run_tests.
%
% The output should look like:
%
%   % PL-Unit: test_front_3 .... done
%   % All N tests passed
%
% None of the tests should fail unless there is a bug somewhere, which you are encouraged to report via the GitHub issue system.
%
:- begin_tests(test_front_3).

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
    
hdb_store_2:execution("ex1", _, _, _).
hdb_store_2:execution("ex2", _, _, _).

hdb_store_2:used(_, "ex1", "v1_0", _, _).
hdb_store_2:used(_, "ex1", "v2_0", _, _).
hdb_store_2:used(_, "ex1", "v3_0", _, _).
hdb_store_2:used(_, "ex2", "v1_1", _, _).
hdb_store_2:used(_, "ex2", "v2_1", _, _).
hdb_store_2:used(_, "ex2", "v3_D", _, _).

hdb_store_2:wasDerivedFrom("d1", "v1_1", "v1_0", _, _, _, _).
hdb_store_2:wasDerivedFrom("d2", "v1_2", "v1_1", _, _, _, _).
hdb_store_2:wasDerivedFrom("d3", "v2_1", "v2_0", _, _, _, _).
hdb_store_2:wasDerivedFrom("d4", "v2_2", "v2_1", _, _, _, _).
hdb_store_2:wasDerivedFrom("d5", "v2_3", "v2_2", _, _, _, _).
hdb_store_2:wasDerivedFrom("d6", "v3_D", "v3_0", _, _, _, _).
hdb_store_2:wasDerivedFrom("d7", "v3_1", "v3_0", _, _, _, _).
hdb_store_2:wasDerivedFrom("d8", "v3_2", "v3_1", _, _, _, _).

% A simple test to show that branching is supported by the build_recomp_front rule.
% Both executions are included in the returned front.
%
test(branching_0) :-
    build_recomp_front(["v1_2", "v2_3", "v3_1"], [("ex1", [_-"v3_0"-"v3_1", _-"v2_0"-"v2_3", _-"v1_0"-"v1_2"], []), ("ex2", [_-"v2_1"-"v2_3", _-"v1_1"-"v1_2"], [])]).

:- end_tests(test_front_3).
