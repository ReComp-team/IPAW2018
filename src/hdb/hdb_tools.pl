:- module(hdb_tools, [
    build_recomp_front/2,
    print_front/1,
    print_tree/1,
    front_to_json/2,
    trans_used/2,
    trans_used/3,
    entity_in_neighbourhood/3,
    entity_out_neighbourhood/3
]).


% For the given list of new data items build a list of
% restart trees on the re-computation front.
% Each restart tree is rooted with the top-level execution that needs re-execution.
% Every tree node has form (Exec, [DataChanges], [ChildrenEx]) and may include:
% -- an optional list of data changes that the execution directly used, and
% -- a list of children that also need an update.
%
% The DataChanges list includes pairs (NewItem, OldItem) which the Exec used directly.
% The ChildrenEx list includes sub-trees of executions that wasPartOf Exec.
%
%
% build_recomp_front(+InDataList, -OutTreeList)
%
build_recomp_front(InDataList, OutTreeList) :-
    build_recomp_front_(InDataList, (root, [], OutTreeList)).

build_recomp_front_([DataItem | Tail], Tree) :-
    build_recomp_front_(Tail, T0),
    build_recomp_front_for_item(DataItem, DataItem, T0, Tree).

build_recomp_front_([], (root, [], [])).

build_recomp_front_for_item(NewData, DataItem, InTree, OutTree) :-
    hdb_store_2:wasDerivedFrom(_, DataItem, OldData, _, _, _, _), !,
    findall(Usage-Exec, hdb_store_2:used(Usage, Exec, OldData, _, _), UsgList),
    build_recomp_front_for_executions(OldData-NewData, UsgList, InTree, T0),
    build_recomp_front_for_item(NewData, OldData, T0, OutTree).

build_recomp_front_for_item(_, _, Tree, Tree).

build_recomp_front_for_executions(DataChange, [UsgEx | Tail], InTree, OutTree) :-
    !, build_recomp_front_for_executions(DataChange, Tail, InTree, T0),
    % TODO: The algorithm might be improved here if path_to_root_with_chk takes in T0 and can check whether
    %       Ex is in the tree already. Also if the algorithm could keep the tree of blacklisted executions,
    %       a similar check could be done to speed up with negative checks.
    ( path_to_root_with_chk(DataChange, UsgEx, Path) ->
        x_merge_path_with_datatree(T0, Path, OutTree)
    ;
        T0 = OutTree
    ).

build_recomp_front_for_executions(_, [], InTree, InTree).

%
% If the second argument is the last two elements on the list, i.e. execution + data, 
% check if the Head is among the RootChildren, and if it is, combine new data with any data that may already be listed at that child.
%
x_merge_path_with_datatree((Root, RootData, RootChildren), [Head, NewHeadData], (Root, RootData, [Out | RemainingChildren])) :-
    selectchk((Head, HeadData, HeadChildren), RootChildren, RemainingChildren), !,
    union(HeadData, [NewHeadData], HD),
    Out = (Head, HD, HeadChildren).

%
% If the second argument is the last two elements: execution + data and the previous rule failed,
% add a new child to the RootChildren.
%
x_merge_path_with_datatree((Root, RootData, RootChildren), [Head, NewHeadData], (Root, RootData, [(Head, [NewHeadData], []) | RootChildren])) :-
    !.

%
% If the second argument is longer than two elements: execution + data, check if the heads match.
% If they match, go down the tree. If they do not match, run the next rule.
%
x_merge_path_with_datatree((Root, RootData, RootChildren), [Head|Tail], (Root, RootData, [Out0 | RemainingChildren])) :-
    selectchk((Head, HeadData, HeadChildren), RootChildren, RemainingChildren), !,
    x_merge_path_with_datatree((Head, HeadData, HeadChildren), Tail, Out0).

%
% If the heads do not match, turn the Path into a Tree and add the Tree to the RootChildren.
%
x_merge_path_with_datatree((Root, RootData, RootChildren), Path, (Root, RootData, [Tree | RootChildren])) :-
    x_path_to_datatree(Path, Tree).


x_path_to_datatree([Elem0, Elem1], (Elem0, [Elem1], [])) :- !.
x_path_to_datatree([Head|Tail], (Head, [], [SubTree])) :-
    x_path_to_datatree(Tail, SubTree).


%
% front_to_json(-Front, +JsonOut)
%
% Serializes a list of restart trees (the re-comp front) into the JSON format.
% The output has the following JSON form:
%
% [{
%     "execution" : "<EXEC_ID>",
%     "changes"    : [{
%           "old_data" : "<DOC_ID>",
%           "new_data" : "<DOC_ID>"
%        }, {
%           "old_data" : "<DOC_ID>",
%           "new_data" : "<DOC_ID>"
%        }, ...],
%     "children"  : [{
%           "execution" : "<EXEC_ID>",
%           "changes"    : [...],
%           "children"  : [...]
%        }, ...],
%  }, {
%     "execution" : "<EXEC_ID>",
%     "changes"    : [...],
%     "children"  : [...]
%  }, ...
% ]
%
front_to_json(Front, JsonOut) :-
    front_to_json_(Front, [], JsonOut).

front_to_json_([], JsonIn, JsonIn).
front_to_json_([H|T], JsonIn, JsonOut) :-
    x_tree_to_json_(H, Json0),
    Json1 = [Json0|JsonIn],
    front_to_json_(T, Json1, JsonOut).

x_tree_to_json_((Root, DataChange, Children), JsonOut) :-
    x_data_to_json_(DataChange, [], ChangeJson),
    front_to_json_(Children, [], ChildrenJson),
    JsonOut = json(['execution'=Root, 'changes'=ChangeJson, 'children'=ChildrenJson]).

x_data_to_json_([], JsonIn, JsonIn).
x_data_to_json_([Port-Old-New | T], JsonIn, JsonOut) :-
    L0 = ['old_data'=Old, 'new_data'=New],
    ( nonvar(Port) ->
        L1 = ['port'=Port | L0]
    ;
        L1 = L0
    ),
    append([json(L1)], JsonIn, Json0),
    x_data_to_json_(T, Json0, JsonOut).


print_front([]).
print_front([H|T]) :-
    print_tree(H),
    print_front(T).

print_tree(Tree) :- x_print_tree_('', Tree).

x_print_tree_(Indent, (Root, DataList, [])) :-
    !, format(atom(Out1), '~w(~w, ~w, [])', [Indent, Root, DataList]),
    writeln(Out1).

x_print_tree_(Indent, (Root, DataList, ChildList)) :-
    format(atom(Out1), '~w(~w, ~w, [', [Indent, Root, DataList]),
    writeln(Out1),
    format(atom(I1), '  ~w', [Indent]),
    x_print_tree_list_(I1, ChildList),
    format(atom(Out2), '~w])', [Indent]),
    writeln(Out2).

x_print_tree_list_(_, []) :- !.
x_print_tree_list_(Indent, [H | T]) :-
    x_print_tree_(Indent, H),
    x_print_tree_list_(Indent, T).



% +(OldData, NewData), +Exec, -Path
path_to_root_with_chk(OldData-NewData, Usage-Exec, Path) :-
    % The soft-cut operator is used to add all port-datachange associations if there are any,
    % or one _-datachange if no port information is available.
    % NOTE: The code may behave strange if provenance has some but not all hadInPort facts missing.
    %       It may report the same data change multiple times, then.
    (hdb_store_2:hadInPort(Usage, Port) *->
        path_to_root_with_chk_simple(Exec, [Port-OldData-NewData], Path)
    ;
        path_to_root_with_chk_simple(Exec, [_-OldData-NewData], Path)
    ).

path_to_root_with_chk_simple(Exec, InPath, OutPath) :-
    \+ once((
        hdb_store_2:wasInformedBy(_, _, Exec, Attrs),
        is_dict(Attrs),
        get_dict('prov:type', Attrs, Types),
        member("recomp:re-execution", Types))),
    %\+ (
    %    hdb_store_2:wasInformedBy(_, _, Exec, Attrs),
    %    is_dict(Attrs),
    %    get_dict('prov:type', Attrs, Types),
    %    member("recomp:re-execution", Types),
    %    get_dict('recomp:data-change-new', Attrs, DataChange),
    %    \+ is_enclosed_by(DataChange, DataList)
    %),
    (hdb_store_2:wasPartOf(Exec, ParentExec) ->
        path_to_root_with_chk_simple(ParentExec, [Exec|InPath], OutPath)
    ;
        OutPath = [Exec|InPath]
    ).


% A simple NULL constraint rule to be used with trans_used/3, entity_in_ or entity_out_neighbourhood/3 as the ScopeGoal argument.
% 
ignore_fact(_).


% May be used to enumerate all activities directly or indirectly involved in generating the given Entity.
% May be used to enumerate all entities directly or indirectly generated by the given Activity.
%
% May also be used to check whether the given Activity directly or indirectly contributed to the production of the given Entity.
% In that case it may be wrapped with once/1, like once(trans_used(Activity, Entity))
%
% ?Activity, ?Entity
trans_used(Activity, Entity) :-
    trans_used(Activity, Entity, ignore_fact).


% May be used to enumerate all activities directly or indirectly involved in generating the given Entity.
% May be used to enumerate all entities directly or indirectly generated by the given Activity.
%
% May also be used to check whether the given Activity directly or indirectly contributed to the production of the given Entity.
% In that case it may be wrapped with once/1, like once(trans_used(Activity, Entity, Constr))
%
% ?Activity, ?Entity, +ScopeGoal
trans_used(Activity, Entity, ScopeGoal) :-
    (nonvar(Activity) ->
        trans_used_a(Activity, Entity, ScopeGoal)
    ;
        trans_used_e(Activity, Entity, ScopeGoal)
    ).

% -Activity, +Entity, +Constr
trans_used_e(Activity, Entity, Constr) :-
    (
        hdb_store_2:used(_, Activity, Entity, _, _),
        once(call(Constr, Activity))
    ;
        hdb_store_2:used(_, A0, Entity, _, _),
        once(call(Constr, A0)),
        hdb_store_2:wasGeneratedBy(_, E0, A0, _, _),
        trans_used_e(Activity, E0, Constr)
    ).

% +Activity, -Entity, +Constr
trans_used_a(Activity, Entity, Constr) :-
    once(call(Constr, Activity)),
    (
        hdb_store_2:used(_, Activity, Entity, _, _)
    ;
        hdb_store_2:used(_, Activity, E0, _, _),
        hdb_store_2:wasGeneratedBy(_, E0, A0, _, _),
        trans_used_a(A0, Entity, Constr)
    ).


% Enumerate entities on the in-neighbourhood (lineage) of the given Entity.
%
% +Entity, -PEntity, +ScopeGoal
%
% Enumerates entities that were involved in generating the given Entity.
% The ScopeGoal is used to limit the kind of activities that are considered in
% the search.
%
% Note, it is a simple search that may return duplicated entries, so use it with
% setof to get rid of duplicates.
%
% TODO: Improve the search to avoid traversal through already visited nodes.
%
entity_in_neighbourhood(Entity, Parent, ScopeGoal) :-
    hdb_store_2:wasGeneratedBy(_, Entity, A0, _, _),
    once(call(ScopeGoal, A0)),
    hdb_store_2:used(_, A0, Parent, _, _).

entity_in_neighbourhood(Entity, Parent, ScopeGoal) :-
    hdb_store_2:wasGeneratedBy(_, Entity, A0, _, _),
    once(call(ScopeGoal, A0)),
    hdb_store_2:used(_, A0, E0, _, _),
    entity_in_neighbourhood(E0, Parent, ScopeGoal).

% Enumerate entities on the out-neighbourhood of the given Entity.
%
% +Entity, -Child, +ScopeGoal
%
% Enumerates entities that may have been directly or indirectly derived from
% the given Entity. The ScopeGoal is used to limit the kind of activities that
% are considered in the search.
%
% Note, it is a simple search that may return duplicated entries, so use it with
% setof to get rid of duplicates.
%
% TODO: Improve the search to avoid traversal through already visited nodes.
%
entity_out_neighbourhood(Entity, Child, ScopeGoal) :-
    hdb_store_2:used(_, A0, Entity, _, _),
    once(call(ScopeGoal, A0)),
    hdb_store_2:wasGeneratedBy(_, Child, A0, _, _).

entity_out_neighbourhood(Entity, Child, ScopeGoal) :-
    hdb_store_2:used(_, A0, Entity, _, _),
    once(call(ScopeGoal, A0)),
    hdb_store_2:wasGeneratedBy(_, E0, A0, _, _),
    entity_out_neighbourhood(E0, Child, ScopeGoal).


%%%%%%%%%%%%%%&
%
% Various helper functions
%

print_forest([]).
print_forest([H|T]) :-
    y_print_tree(H),
    print_forest(T).

y_print_tree(Tree) :- y_print_tree_('', Tree).

y_print_tree_(Indent, (Root, List)) :-
    !, format(atom(Out1), '~w~w = [', [Indent, Root]),
    writeln(Out1),
    format(atom(I1), '  ~w', [Indent]),
    print_list_(I1, List),
    format(atom(Out2), '~w]', [Indent]),
    writeln(Out2).

y_print_tree_(Indent, Elem) :-
    format(atom(Out), '~w~w', [Indent, Elem]),
    writeln(Out).

print_list_(_, []) :- !.
print_list_(Indent, [H | T]) :-
    y_print_tree_(Indent, H),
    print_list_(Indent, T).


tree_to_dict((Root, Children), Dict) :-
    !, treelist_to_dictlist(Children, DictChildren),
    atom_string(RootA, Root),
    dict_create(Dict, tree, [ RootA : DictChildren]).

tree_to_dict(Elem, Elem).

treelist_to_dictlist([], []) :- !.
treelist_to_dictlist([H | T], List) :-
    treelist_to_dictlist(T, L0),
    tree_to_dict(H, D),
    append([D], L0, List).

tree_to_json((Root, Children), json([Root = Json])) :-
    !, treelist_to_jsonlist(Children, Json).
tree_to_json(Elem, Elem).

treelist_to_jsonlist([], []) :- !.
treelist_to_jsonlist([H | T], List) :-
    treelist_to_jsonlist(T, L0),
    tree_to_json(H, J),
    append([J], L0, List).
