import 'dart:async';
import 'package:flutter/widgets.dart' as widgets;
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;
import 'package:graphql_flutter/graphql_flutter.dart' as graphql_flutter;

class Variables$Mutation$RemoveDownvote {
  factory Variables$Mutation$RemoveDownvote({required String imageId}) =>
      Variables$Mutation$RemoveDownvote._({
        r'imageId': imageId,
      });

  Variables$Mutation$RemoveDownvote._(this._$data);

  factory Variables$Mutation$RemoveDownvote.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$imageId = data['imageId'];
    result$data['imageId'] = (l$imageId as String);
    return Variables$Mutation$RemoveDownvote._(result$data);
  }

  Map<String, dynamic> _$data;

  String get imageId => (_$data['imageId'] as String);
  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$imageId = imageId;
    result$data['imageId'] = l$imageId;
    return result$data;
  }

  CopyWith$Variables$Mutation$RemoveDownvote<Variables$Mutation$RemoveDownvote>
      get copyWith => CopyWith$Variables$Mutation$RemoveDownvote(
            this,
            (i) => i,
          );
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (!(other is Variables$Mutation$RemoveDownvote) ||
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

abstract class CopyWith$Variables$Mutation$RemoveDownvote<TRes> {
  factory CopyWith$Variables$Mutation$RemoveDownvote(
    Variables$Mutation$RemoveDownvote instance,
    TRes Function(Variables$Mutation$RemoveDownvote) then,
  ) = _CopyWithImpl$Variables$Mutation$RemoveDownvote;

  factory CopyWith$Variables$Mutation$RemoveDownvote.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$RemoveDownvote;

  TRes call({String? imageId});
}

class _CopyWithImpl$Variables$Mutation$RemoveDownvote<TRes>
    implements CopyWith$Variables$Mutation$RemoveDownvote<TRes> {
  _CopyWithImpl$Variables$Mutation$RemoveDownvote(
    this._instance,
    this._then,
  );

  final Variables$Mutation$RemoveDownvote _instance;

  final TRes Function(Variables$Mutation$RemoveDownvote) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? imageId = _undefined}) =>
      _then(Variables$Mutation$RemoveDownvote._({
        ..._instance._$data,
        if (imageId != _undefined && imageId != null)
          'imageId': (imageId as String),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$RemoveDownvote<TRes>
    implements CopyWith$Variables$Mutation$RemoveDownvote<TRes> {
  _CopyWithStubImpl$Variables$Mutation$RemoveDownvote(this._res);

  TRes _res;

  call({String? imageId}) => _res;
}

class Mutation$RemoveDownvote {
  Mutation$RemoveDownvote({
    required this.removeDownvote,
    this.$__typename = 'MutationRoot',
  });

  factory Mutation$RemoveDownvote.fromJson(Map<String, dynamic> json) {
    final l$removeDownvote = json['removeDownvote'];
    final l$$__typename = json['__typename'];
    return Mutation$RemoveDownvote(
      removeDownvote: (l$removeDownvote as bool),
      $__typename: (l$$__typename as String),
    );
  }

  final bool removeDownvote;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$removeDownvote = removeDownvote;
    _resultData['removeDownvote'] = l$removeDownvote;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$removeDownvote = removeDownvote;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$removeDownvote,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (!(other is Mutation$RemoveDownvote) ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$removeDownvote = removeDownvote;
    final lOther$removeDownvote = other.removeDownvote;
    if (l$removeDownvote != lOther$removeDownvote) {
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

extension UtilityExtension$Mutation$RemoveDownvote on Mutation$RemoveDownvote {
  CopyWith$Mutation$RemoveDownvote<Mutation$RemoveDownvote> get copyWith =>
      CopyWith$Mutation$RemoveDownvote(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Mutation$RemoveDownvote<TRes> {
  factory CopyWith$Mutation$RemoveDownvote(
    Mutation$RemoveDownvote instance,
    TRes Function(Mutation$RemoveDownvote) then,
  ) = _CopyWithImpl$Mutation$RemoveDownvote;

  factory CopyWith$Mutation$RemoveDownvote.stub(TRes res) =
      _CopyWithStubImpl$Mutation$RemoveDownvote;

  TRes call({
    bool? removeDownvote,
    String? $__typename,
  });
}

class _CopyWithImpl$Mutation$RemoveDownvote<TRes>
    implements CopyWith$Mutation$RemoveDownvote<TRes> {
  _CopyWithImpl$Mutation$RemoveDownvote(
    this._instance,
    this._then,
  );

  final Mutation$RemoveDownvote _instance;

  final TRes Function(Mutation$RemoveDownvote) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? removeDownvote = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$RemoveDownvote(
        removeDownvote: removeDownvote == _undefined || removeDownvote == null
            ? _instance.removeDownvote
            : (removeDownvote as bool),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Mutation$RemoveDownvote<TRes>
    implements CopyWith$Mutation$RemoveDownvote<TRes> {
  _CopyWithStubImpl$Mutation$RemoveDownvote(this._res);

  TRes _res;

  call({
    bool? removeDownvote,
    String? $__typename,
  }) =>
      _res;
}

const documentNodeMutationRemoveDownvote = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'RemoveDownvote'),
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
        name: NameNode(value: 'removeDownvote'),
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
Mutation$RemoveDownvote _parserFn$Mutation$RemoveDownvote(
        Map<String, dynamic> data) =>
    Mutation$RemoveDownvote.fromJson(data);
typedef OnMutationCompleted$Mutation$RemoveDownvote = FutureOr<void> Function(
  Map<String, dynamic>?,
  Mutation$RemoveDownvote?,
);

class Options$Mutation$RemoveDownvote
    extends graphql.MutationOptions<Mutation$RemoveDownvote> {
  Options$Mutation$RemoveDownvote({
    String? operationName,
    required Variables$Mutation$RemoveDownvote variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$RemoveDownvote? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$RemoveDownvote? onCompleted,
    graphql.OnMutationUpdate<Mutation$RemoveDownvote>? update,
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
                    data == null
                        ? null
                        : _parserFn$Mutation$RemoveDownvote(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationRemoveDownvote,
          parserFn: _parserFn$Mutation$RemoveDownvote,
        );

  final OnMutationCompleted$Mutation$RemoveDownvote? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$RemoveDownvote
    extends graphql.WatchQueryOptions<Mutation$RemoveDownvote> {
  WatchOptions$Mutation$RemoveDownvote({
    String? operationName,
    required Variables$Mutation$RemoveDownvote variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$RemoveDownvote? typedOptimisticResult,
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
          document: documentNodeMutationRemoveDownvote,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$RemoveDownvote,
        );
}

extension ClientExtension$Mutation$RemoveDownvote on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$RemoveDownvote>> mutate$RemoveDownvote(
          Options$Mutation$RemoveDownvote options) async =>
      await this.mutate(options);
  graphql.ObservableQuery<Mutation$RemoveDownvote> watchMutation$RemoveDownvote(
          WatchOptions$Mutation$RemoveDownvote options) =>
      this.watchMutation(options);
}

class Mutation$RemoveDownvote$HookResult {
  Mutation$RemoveDownvote$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$RemoveDownvote runMutation;

  final graphql.QueryResult<Mutation$RemoveDownvote> result;
}

Mutation$RemoveDownvote$HookResult useMutation$RemoveDownvote(
    [WidgetOptions$Mutation$RemoveDownvote? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$RemoveDownvote());
  return Mutation$RemoveDownvote$HookResult(
    (variables, {optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables.toJson(),
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$RemoveDownvote>
    useWatchMutation$RemoveDownvote(
            WatchOptions$Mutation$RemoveDownvote options) =>
        graphql_flutter.useWatchMutation(options);

class WidgetOptions$Mutation$RemoveDownvote
    extends graphql.MutationOptions<Mutation$RemoveDownvote> {
  WidgetOptions$Mutation$RemoveDownvote({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$RemoveDownvote? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$RemoveDownvote? onCompleted,
    graphql.OnMutationUpdate<Mutation$RemoveDownvote>? update,
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
                    data == null
                        ? null
                        : _parserFn$Mutation$RemoveDownvote(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationRemoveDownvote,
          parserFn: _parserFn$Mutation$RemoveDownvote,
        );

  final OnMutationCompleted$Mutation$RemoveDownvote? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$RemoveDownvote
    = graphql.MultiSourceResult<Mutation$RemoveDownvote> Function(
  Variables$Mutation$RemoveDownvote, {
  Object? optimisticResult,
  Mutation$RemoveDownvote? typedOptimisticResult,
});
typedef Builder$Mutation$RemoveDownvote = widgets.Widget Function(
  RunMutation$Mutation$RemoveDownvote,
  graphql.QueryResult<Mutation$RemoveDownvote>?,
);

class Mutation$RemoveDownvote$Widget
    extends graphql_flutter.Mutation<Mutation$RemoveDownvote> {
  Mutation$RemoveDownvote$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$RemoveDownvote? options,
    required Builder$Mutation$RemoveDownvote builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$RemoveDownvote(),
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
