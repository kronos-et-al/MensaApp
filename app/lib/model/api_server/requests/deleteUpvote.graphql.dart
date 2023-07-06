import 'dart:async';
import 'package:flutter/widgets.dart' as widgets;
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;
import 'package:graphql_flutter/graphql_flutter.dart' as graphql_flutter;

class Variables$Mutation$RemoveUpvote {
  factory Variables$Mutation$RemoveUpvote({required String imageId}) =>
      Variables$Mutation$RemoveUpvote._({
        r'imageId': imageId,
      });

  Variables$Mutation$RemoveUpvote._(this._$data);

  factory Variables$Mutation$RemoveUpvote.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$imageId = data['imageId'];
    result$data['imageId'] = (l$imageId as String);
    return Variables$Mutation$RemoveUpvote._(result$data);
  }

  Map<String, dynamic> _$data;

  String get imageId => (_$data['imageId'] as String);
  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$imageId = imageId;
    result$data['imageId'] = l$imageId;
    return result$data;
  }

  CopyWith$Variables$Mutation$RemoveUpvote<Variables$Mutation$RemoveUpvote>
      get copyWith => CopyWith$Variables$Mutation$RemoveUpvote(
            this,
            (i) => i,
          );
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (!(other is Variables$Mutation$RemoveUpvote) ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$imageId = imageId;
    final lOther$imageId = other.imageId;
    if (l$imageId != lOther$imageId) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$imageId = imageId;
    return Object.hashAll([l$imageId]);
  }
}

abstract class CopyWith$Variables$Mutation$RemoveUpvote<TRes> {
  factory CopyWith$Variables$Mutation$RemoveUpvote(
    Variables$Mutation$RemoveUpvote instance,
    TRes Function(Variables$Mutation$RemoveUpvote) then,
  ) = _CopyWithImpl$Variables$Mutation$RemoveUpvote;

  factory CopyWith$Variables$Mutation$RemoveUpvote.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$RemoveUpvote;

  TRes call({String? imageId});
}

class _CopyWithImpl$Variables$Mutation$RemoveUpvote<TRes>
    implements CopyWith$Variables$Mutation$RemoveUpvote<TRes> {
  _CopyWithImpl$Variables$Mutation$RemoveUpvote(
    this._instance,
    this._then,
  );

  final Variables$Mutation$RemoveUpvote _instance;

  final TRes Function(Variables$Mutation$RemoveUpvote) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? imageId = _undefined}) =>
      _then(Variables$Mutation$RemoveUpvote._({
        ..._instance._$data,
        if (imageId != _undefined && imageId != null)
          'imageId': (imageId as String),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$RemoveUpvote<TRes>
    implements CopyWith$Variables$Mutation$RemoveUpvote<TRes> {
  _CopyWithStubImpl$Variables$Mutation$RemoveUpvote(this._res);

  TRes _res;

  call({String? imageId}) => _res;
}

class Mutation$RemoveUpvote {
  Mutation$RemoveUpvote({
    required this.removeUpvote,
    this.$__typename = 'MutationRoot',
  });

  factory Mutation$RemoveUpvote.fromJson(Map<String, dynamic> json) {
    final l$removeUpvote = json['removeUpvote'];
    final l$$__typename = json['__typename'];
    return Mutation$RemoveUpvote(
      removeUpvote: (l$removeUpvote as bool),
      $__typename: (l$$__typename as String),
    );
  }

  final bool removeUpvote;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$removeUpvote = removeUpvote;
    _resultData['removeUpvote'] = l$removeUpvote;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$removeUpvote = removeUpvote;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$removeUpvote,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (!(other is Mutation$RemoveUpvote) || runtimeType != other.runtimeType) {
      return false;
    }
    final l$removeUpvote = removeUpvote;
    final lOther$removeUpvote = other.removeUpvote;
    if (l$removeUpvote != lOther$removeUpvote) {
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

extension UtilityExtension$Mutation$RemoveUpvote on Mutation$RemoveUpvote {
  CopyWith$Mutation$RemoveUpvote<Mutation$RemoveUpvote> get copyWith =>
      CopyWith$Mutation$RemoveUpvote(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Mutation$RemoveUpvote<TRes> {
  factory CopyWith$Mutation$RemoveUpvote(
    Mutation$RemoveUpvote instance,
    TRes Function(Mutation$RemoveUpvote) then,
  ) = _CopyWithImpl$Mutation$RemoveUpvote;

  factory CopyWith$Mutation$RemoveUpvote.stub(TRes res) =
      _CopyWithStubImpl$Mutation$RemoveUpvote;

  TRes call({
    bool? removeUpvote,
    String? $__typename,
  });
}

class _CopyWithImpl$Mutation$RemoveUpvote<TRes>
    implements CopyWith$Mutation$RemoveUpvote<TRes> {
  _CopyWithImpl$Mutation$RemoveUpvote(
    this._instance,
    this._then,
  );

  final Mutation$RemoveUpvote _instance;

  final TRes Function(Mutation$RemoveUpvote) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? removeUpvote = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$RemoveUpvote(
        removeUpvote: removeUpvote == _undefined || removeUpvote == null
            ? _instance.removeUpvote
            : (removeUpvote as bool),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Mutation$RemoveUpvote<TRes>
    implements CopyWith$Mutation$RemoveUpvote<TRes> {
  _CopyWithStubImpl$Mutation$RemoveUpvote(this._res);

  TRes _res;

  call({
    bool? removeUpvote,
    String? $__typename,
  }) =>
      _res;
}

const documentNodeMutationRemoveUpvote = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'RemoveUpvote'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'imageId')),
        type: NamedTypeNode(
          name: NameNode(value: 'UUID'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      )
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'removeUpvote'),
        alias: null,
        arguments: [
          ArgumentNode(
            name: NameNode(value: 'imageId'),
            value: VariableNode(name: NameNode(value: 'imageId')),
          )
        ],
        directives: [],
        selectionSet: null,
      ),
      FieldNode(
        name: NameNode(value: '__typename'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
    ]),
  ),
]);
Mutation$RemoveUpvote _parserFn$Mutation$RemoveUpvote(
        Map<String, dynamic> data) =>
    Mutation$RemoveUpvote.fromJson(data);
typedef OnMutationCompleted$Mutation$RemoveUpvote = FutureOr<void> Function(
  Map<String, dynamic>?,
  Mutation$RemoveUpvote?,
);

class Options$Mutation$RemoveUpvote
    extends graphql.MutationOptions<Mutation$RemoveUpvote> {
  Options$Mutation$RemoveUpvote({
    String? operationName,
    required Variables$Mutation$RemoveUpvote variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$RemoveUpvote? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$RemoveUpvote? onCompleted,
    graphql.OnMutationUpdate<Mutation$RemoveUpvote>? update,
    graphql.OnError? onError,
  })  : onCompletedWithParsed = onCompleted,
        super(
          variables: variables.toJson(),
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          context: context,
          onCompleted: onCompleted == null
              ? null
              : (data) => onCompleted(
                    data,
                    data == null ? null : _parserFn$Mutation$RemoveUpvote(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationRemoveUpvote,
          parserFn: _parserFn$Mutation$RemoveUpvote,
        );

  final OnMutationCompleted$Mutation$RemoveUpvote? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$RemoveUpvote
    extends graphql.WatchQueryOptions<Mutation$RemoveUpvote> {
  WatchOptions$Mutation$RemoveUpvote({
    String? operationName,
    required Variables$Mutation$RemoveUpvote variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$RemoveUpvote? typedOptimisticResult,
    graphql.Context? context,
    Duration? pollInterval,
    bool? eagerlyFetchResults,
    bool carryForwardDataOnException = true,
    bool fetchResults = false,
  }) : super(
          variables: variables.toJson(),
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          context: context,
          document: documentNodeMutationRemoveUpvote,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$RemoveUpvote,
        );
}

extension ClientExtension$Mutation$RemoveUpvote on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$RemoveUpvote>> mutate$RemoveUpvote(
          Options$Mutation$RemoveUpvote options) async =>
      await this.mutate(options);
  graphql.ObservableQuery<Mutation$RemoveUpvote> watchMutation$RemoveUpvote(
          WatchOptions$Mutation$RemoveUpvote options) =>
      this.watchMutation(options);
}

class Mutation$RemoveUpvote$HookResult {
  Mutation$RemoveUpvote$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$RemoveUpvote runMutation;

  final graphql.QueryResult<Mutation$RemoveUpvote> result;
}

Mutation$RemoveUpvote$HookResult useMutation$RemoveUpvote(
    [WidgetOptions$Mutation$RemoveUpvote? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$RemoveUpvote());
  return Mutation$RemoveUpvote$HookResult(
    (variables, {optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables.toJson(),
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$RemoveUpvote> useWatchMutation$RemoveUpvote(
        WatchOptions$Mutation$RemoveUpvote options) =>
    graphql_flutter.useWatchMutation(options);

class WidgetOptions$Mutation$RemoveUpvote
    extends graphql.MutationOptions<Mutation$RemoveUpvote> {
  WidgetOptions$Mutation$RemoveUpvote({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$RemoveUpvote? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$RemoveUpvote? onCompleted,
    graphql.OnMutationUpdate<Mutation$RemoveUpvote>? update,
    graphql.OnError? onError,
  })  : onCompletedWithParsed = onCompleted,
        super(
          operationName: operationName,
          fetchPolicy: fetchPolicy,
          errorPolicy: errorPolicy,
          cacheRereadPolicy: cacheRereadPolicy,
          optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
          context: context,
          onCompleted: onCompleted == null
              ? null
              : (data) => onCompleted(
                    data,
                    data == null ? null : _parserFn$Mutation$RemoveUpvote(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationRemoveUpvote,
          parserFn: _parserFn$Mutation$RemoveUpvote,
        );

  final OnMutationCompleted$Mutation$RemoveUpvote? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$RemoveUpvote
    = graphql.MultiSourceResult<Mutation$RemoveUpvote> Function(
  Variables$Mutation$RemoveUpvote, {
  Object? optimisticResult,
  Mutation$RemoveUpvote? typedOptimisticResult,
});
typedef Builder$Mutation$RemoveUpvote = widgets.Widget Function(
  RunMutation$Mutation$RemoveUpvote,
  graphql.QueryResult<Mutation$RemoveUpvote>?,
);

class Mutation$RemoveUpvote$Widget
    extends graphql_flutter.Mutation<Mutation$RemoveUpvote> {
  Mutation$RemoveUpvote$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$RemoveUpvote? options,
    required Builder$Mutation$RemoveUpvote builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$RemoveUpvote(),
          builder: (
            run,
            result,
          ) =>
              builder(
            (
              variables, {
              optimisticResult,
              typedOptimisticResult,
            }) =>
                run(
              variables.toJson(),
              optimisticResult:
                  optimisticResult ?? typedOptimisticResult?.toJson(),
            ),
            result,
          ),
        );
}
