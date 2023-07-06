import 'dart:async';
import 'package:flutter/widgets.dart' as widgets;
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;
import 'package:graphql_flutter/graphql_flutter.dart' as graphql_flutter;

class Query$GetMeals {
  Query$GetMeals({this.$__typename = 'QueryRoot'});

  factory Query$GetMeals.fromJson(Map<String, dynamic> json) {
    final l$$__typename = json['__typename'];
    return Query$GetMeals($__typename: (l$$__typename as String));
  }

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$$__typename = $__typename;
    return Object.hashAll([l$$__typename]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (!(other is Query$GetMeals) || runtimeType != other.runtimeType) {
      return false;
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$GetMeals on Query$GetMeals {
  CopyWith$Query$GetMeals<Query$GetMeals> get copyWith =>
      CopyWith$Query$GetMeals(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Query$GetMeals<TRes> {
  factory CopyWith$Query$GetMeals(
    Query$GetMeals instance,
    TRes Function(Query$GetMeals) then,
  ) = _CopyWithImpl$Query$GetMeals;

  factory CopyWith$Query$GetMeals.stub(TRes res) =
      _CopyWithStubImpl$Query$GetMeals;

  TRes call({String? $__typename});
}

class _CopyWithImpl$Query$GetMeals<TRes>
    implements CopyWith$Query$GetMeals<TRes> {
  _CopyWithImpl$Query$GetMeals(
    this._instance,
    this._then,
  );

  final Query$GetMeals _instance;

  final TRes Function(Query$GetMeals) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? $__typename = _undefined}) => _then(Query$GetMeals(
      $__typename: $__typename == _undefined || $__typename == null
          ? _instance.$__typename
          : ($__typename as String)));
}

class _CopyWithStubImpl$Query$GetMeals<TRes>
    implements CopyWith$Query$GetMeals<TRes> {
  _CopyWithStubImpl$Query$GetMeals(this._res);

  TRes _res;

  call({String? $__typename}) => _res;
}

const documentNodeQueryGetMeals = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.query,
    name: NameNode(value: 'GetMeals'),
    variableDefinitions: [],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: '__typename'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      )
    ]),
  ),
]);
Query$GetMeals _parserFn$Query$GetMeals(Map<String, dynamic> data) =>
    Query$GetMeals.fromJson(data);
typedef OnQueryComplete$Query$GetMeals = FutureOr<void> Function(
  Map<String, dynamic>?,
  Query$GetMeals?,
);

class Options$Query$GetMeals extends graphql.QueryOptions<Query$GetMeals> {
  Options$Query$GetMeals({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetMeals? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$GetMeals? onComplete,
    graphql.OnQueryError? onError,
  })  : onCompleteWithParsed = onComplete,
        super(
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          pollInterval: pollInterval,
          context: context,
          onComplete: onComplete == null
              ? null
              : (data) => onComplete(
                    data,
                    data == null ? null : _parserFn$Query$GetMeals(data),
                  ),
          onError: onError,
          document: documentNodeQueryGetMeals,
          parserFn: _parserFn$Query$GetMeals,
        );

  final OnQueryComplete$Query$GetMeals? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onComplete == null
            ? super.properties
            : super.properties.where((property) => property != onComplete),
        onCompleteWithParsed,
      ];
}

class WatchOptions$Query$GetMeals
    extends graphql.WatchQueryOptions<Query$GetMeals> {
  WatchOptions$Query$GetMeals({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetMeals? typedOptimisticResult,
    graphql.Context? context,
    Duration? pollInterval,
    bool? eagerlyFetchResults,
    bool carryForwardDataOnException = true,
    bool fetchResults = false,
  }) : super(
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          context: context,
          document: documentNodeQueryGetMeals,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Query$GetMeals,
        );
}

class FetchMoreOptions$Query$GetMeals extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$GetMeals({required graphql.UpdateQuery updateQuery})
      : super(
          updateQuery: updateQuery,
          document: documentNodeQueryGetMeals,
        );
}

extension ClientExtension$Query$GetMeals on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$GetMeals>> query$GetMeals(
          [Options$Query$GetMeals? options]) async =>
      await this.query(options ?? Options$Query$GetMeals());
  graphql.ObservableQuery<Query$GetMeals> watchQuery$GetMeals(
          [WatchOptions$Query$GetMeals? options]) =>
      this.watchQuery(options ?? WatchOptions$Query$GetMeals());
  void writeQuery$GetMeals({
    required Query$GetMeals data,
    bool broadcast = true,
  }) =>
      this.writeQuery(
        graphql.Request(
            operation: graphql.Operation(document: documentNodeQueryGetMeals)),
        data: data.toJson(),
        broadcast: broadcast,
      );
  Query$GetMeals? readQuery$GetMeals({bool optimistic = true}) {
    final result = this.readQuery(
      graphql.Request(
          operation: graphql.Operation(document: documentNodeQueryGetMeals)),
      optimistic: optimistic,
    );
    return result == null ? null : Query$GetMeals.fromJson(result);
  }
}

graphql_flutter.QueryHookResult<Query$GetMeals> useQuery$GetMeals(
        [Options$Query$GetMeals? options]) =>
    graphql_flutter.useQuery(options ?? Options$Query$GetMeals());
graphql.ObservableQuery<Query$GetMeals> useWatchQuery$GetMeals(
        [WatchOptions$Query$GetMeals? options]) =>
    graphql_flutter.useWatchQuery(options ?? WatchOptions$Query$GetMeals());

class Query$GetMeals$Widget extends graphql_flutter.Query<Query$GetMeals> {
  Query$GetMeals$Widget({
    widgets.Key? key,
    Options$Query$GetMeals? options,
    required graphql_flutter.QueryBuilder<Query$GetMeals> builder,
  }) : super(
          key: key,
          options: options ?? Options$Query$GetMeals(),
          builder: builder,
        );
}
