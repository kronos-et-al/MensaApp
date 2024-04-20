import 'dart:async';
import 'package:flutter/widgets.dart' as widgets;
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;
import 'package:graphql_flutter/graphql_flutter.dart' as graphql_flutter;
import 'package:http/http.dart';
import 'schema.graphql.dart';

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

class Variables$Mutation$AddDownvote {
  factory Variables$Mutation$AddDownvote({required String imageId}) =>
      Variables$Mutation$AddDownvote._({
        r'imageId': imageId,
      });

  Variables$Mutation$AddDownvote._(this._$data);

  factory Variables$Mutation$AddDownvote.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$imageId = data['imageId'];
    result$data['imageId'] = (l$imageId as String);
    return Variables$Mutation$AddDownvote._(result$data);
  }

  Map<String, dynamic> _$data;

  String get imageId => (_$data['imageId'] as String);
  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$imageId = imageId;
    result$data['imageId'] = l$imageId;
    return result$data;
  }

  CopyWith$Variables$Mutation$AddDownvote<Variables$Mutation$AddDownvote>
      get copyWith => CopyWith$Variables$Mutation$AddDownvote(
            this,
            (i) => i,
          );
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (!(other is Variables$Mutation$AddDownvote) ||
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

abstract class CopyWith$Variables$Mutation$AddDownvote<TRes> {
  factory CopyWith$Variables$Mutation$AddDownvote(
    Variables$Mutation$AddDownvote instance,
    TRes Function(Variables$Mutation$AddDownvote) then,
  ) = _CopyWithImpl$Variables$Mutation$AddDownvote;

  factory CopyWith$Variables$Mutation$AddDownvote.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$AddDownvote;

  TRes call({String? imageId});
}

class _CopyWithImpl$Variables$Mutation$AddDownvote<TRes>
    implements CopyWith$Variables$Mutation$AddDownvote<TRes> {
  _CopyWithImpl$Variables$Mutation$AddDownvote(
    this._instance,
    this._then,
  );

  final Variables$Mutation$AddDownvote _instance;

  final TRes Function(Variables$Mutation$AddDownvote) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? imageId = _undefined}) =>
      _then(Variables$Mutation$AddDownvote._({
        ..._instance._$data,
        if (imageId != _undefined && imageId != null)
          'imageId': (imageId as String),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$AddDownvote<TRes>
    implements CopyWith$Variables$Mutation$AddDownvote<TRes> {
  _CopyWithStubImpl$Variables$Mutation$AddDownvote(this._res);

  TRes _res;

  call({String? imageId}) => _res;
}

class Mutation$AddDownvote {
  Mutation$AddDownvote({
    required this.addDownvote,
    this.$__typename = 'MutationRoot',
  });

  factory Mutation$AddDownvote.fromJson(Map<String, dynamic> json) {
    final l$addDownvote = json['addDownvote'];
    final l$$__typename = json['__typename'];
    return Mutation$AddDownvote(
      addDownvote: (l$addDownvote as bool),
      $__typename: (l$$__typename as String),
    );
  }

  final bool addDownvote;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$addDownvote = addDownvote;
    _resultData['addDownvote'] = l$addDownvote;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$addDownvote = addDownvote;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$addDownvote,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (!(other is Mutation$AddDownvote) || runtimeType != other.runtimeType) {
      return false;
    }
    final l$addDownvote = addDownvote;
    final lOther$addDownvote = other.addDownvote;
    if (l$addDownvote != lOther$addDownvote) {
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

extension UtilityExtension$Mutation$AddDownvote on Mutation$AddDownvote {
  CopyWith$Mutation$AddDownvote<Mutation$AddDownvote> get copyWith =>
      CopyWith$Mutation$AddDownvote(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Mutation$AddDownvote<TRes> {
  factory CopyWith$Mutation$AddDownvote(
    Mutation$AddDownvote instance,
    TRes Function(Mutation$AddDownvote) then,
  ) = _CopyWithImpl$Mutation$AddDownvote;

  factory CopyWith$Mutation$AddDownvote.stub(TRes res) =
      _CopyWithStubImpl$Mutation$AddDownvote;

  TRes call({
    bool? addDownvote,
    String? $__typename,
  });
}

class _CopyWithImpl$Mutation$AddDownvote<TRes>
    implements CopyWith$Mutation$AddDownvote<TRes> {
  _CopyWithImpl$Mutation$AddDownvote(
    this._instance,
    this._then,
  );

  final Mutation$AddDownvote _instance;

  final TRes Function(Mutation$AddDownvote) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? addDownvote = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$AddDownvote(
        addDownvote: addDownvote == _undefined || addDownvote == null
            ? _instance.addDownvote
            : (addDownvote as bool),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Mutation$AddDownvote<TRes>
    implements CopyWith$Mutation$AddDownvote<TRes> {
  _CopyWithStubImpl$Mutation$AddDownvote(this._res);

  TRes _res;

  call({
    bool? addDownvote,
    String? $__typename,
  }) =>
      _res;
}

const documentNodeMutationAddDownvote = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'AddDownvote'),
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
        name: NameNode(value: 'addDownvote'),
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
Mutation$AddDownvote _parserFn$Mutation$AddDownvote(
        Map<String, dynamic> data) =>
    Mutation$AddDownvote.fromJson(data);
typedef OnMutationCompleted$Mutation$AddDownvote = FutureOr<void> Function(
  Map<String, dynamic>?,
  Mutation$AddDownvote?,
);

class Options$Mutation$AddDownvote
    extends graphql.MutationOptions<Mutation$AddDownvote> {
  Options$Mutation$AddDownvote({
    String? operationName,
    required Variables$Mutation$AddDownvote variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$AddDownvote? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$AddDownvote? onCompleted,
    graphql.OnMutationUpdate<Mutation$AddDownvote>? update,
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
                    data == null ? null : _parserFn$Mutation$AddDownvote(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationAddDownvote,
          parserFn: _parserFn$Mutation$AddDownvote,
        );

  final OnMutationCompleted$Mutation$AddDownvote? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$AddDownvote
    extends graphql.WatchQueryOptions<Mutation$AddDownvote> {
  WatchOptions$Mutation$AddDownvote({
    String? operationName,
    required Variables$Mutation$AddDownvote variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$AddDownvote? typedOptimisticResult,
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
          document: documentNodeMutationAddDownvote,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$AddDownvote,
        );
}

extension ClientExtension$Mutation$AddDownvote on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$AddDownvote>> mutate$AddDownvote(
          Options$Mutation$AddDownvote options) async =>
      await this.mutate(options);
  graphql.ObservableQuery<Mutation$AddDownvote> watchMutation$AddDownvote(
          WatchOptions$Mutation$AddDownvote options) =>
      this.watchMutation(options);
}

class Mutation$AddDownvote$HookResult {
  Mutation$AddDownvote$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$AddDownvote runMutation;

  final graphql.QueryResult<Mutation$AddDownvote> result;
}

Mutation$AddDownvote$HookResult useMutation$AddDownvote(
    [WidgetOptions$Mutation$AddDownvote? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$AddDownvote());
  return Mutation$AddDownvote$HookResult(
    (variables, {optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables.toJson(),
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$AddDownvote> useWatchMutation$AddDownvote(
        WatchOptions$Mutation$AddDownvote options) =>
    graphql_flutter.useWatchMutation(options);

class WidgetOptions$Mutation$AddDownvote
    extends graphql.MutationOptions<Mutation$AddDownvote> {
  WidgetOptions$Mutation$AddDownvote({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$AddDownvote? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$AddDownvote? onCompleted,
    graphql.OnMutationUpdate<Mutation$AddDownvote>? update,
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
                    data == null ? null : _parserFn$Mutation$AddDownvote(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationAddDownvote,
          parserFn: _parserFn$Mutation$AddDownvote,
        );

  final OnMutationCompleted$Mutation$AddDownvote? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$AddDownvote
    = graphql.MultiSourceResult<Mutation$AddDownvote> Function(
  Variables$Mutation$AddDownvote, {
  Object? optimisticResult,
  Mutation$AddDownvote? typedOptimisticResult,
});
typedef Builder$Mutation$AddDownvote = widgets.Widget Function(
  RunMutation$Mutation$AddDownvote,
  graphql.QueryResult<Mutation$AddDownvote>?,
);

class Mutation$AddDownvote$Widget
    extends graphql_flutter.Mutation<Mutation$AddDownvote> {
  Mutation$AddDownvote$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$AddDownvote? options,
    required Builder$Mutation$AddDownvote builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$AddDownvote(),
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

class Variables$Mutation$AddUpvote {
  factory Variables$Mutation$AddUpvote({required String imageId}) =>
      Variables$Mutation$AddUpvote._({
        r'imageId': imageId,
      });

  Variables$Mutation$AddUpvote._(this._$data);

  factory Variables$Mutation$AddUpvote.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$imageId = data['imageId'];
    result$data['imageId'] = (l$imageId as String);
    return Variables$Mutation$AddUpvote._(result$data);
  }

  Map<String, dynamic> _$data;

  String get imageId => (_$data['imageId'] as String);
  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$imageId = imageId;
    result$data['imageId'] = l$imageId;
    return result$data;
  }

  CopyWith$Variables$Mutation$AddUpvote<Variables$Mutation$AddUpvote>
      get copyWith => CopyWith$Variables$Mutation$AddUpvote(
            this,
            (i) => i,
          );
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (!(other is Variables$Mutation$AddUpvote) ||
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

abstract class CopyWith$Variables$Mutation$AddUpvote<TRes> {
  factory CopyWith$Variables$Mutation$AddUpvote(
    Variables$Mutation$AddUpvote instance,
    TRes Function(Variables$Mutation$AddUpvote) then,
  ) = _CopyWithImpl$Variables$Mutation$AddUpvote;

  factory CopyWith$Variables$Mutation$AddUpvote.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$AddUpvote;

  TRes call({String? imageId});
}

class _CopyWithImpl$Variables$Mutation$AddUpvote<TRes>
    implements CopyWith$Variables$Mutation$AddUpvote<TRes> {
  _CopyWithImpl$Variables$Mutation$AddUpvote(
    this._instance,
    this._then,
  );

  final Variables$Mutation$AddUpvote _instance;

  final TRes Function(Variables$Mutation$AddUpvote) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? imageId = _undefined}) =>
      _then(Variables$Mutation$AddUpvote._({
        ..._instance._$data,
        if (imageId != _undefined && imageId != null)
          'imageId': (imageId as String),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$AddUpvote<TRes>
    implements CopyWith$Variables$Mutation$AddUpvote<TRes> {
  _CopyWithStubImpl$Variables$Mutation$AddUpvote(this._res);

  TRes _res;

  call({String? imageId}) => _res;
}

class Mutation$AddUpvote {
  Mutation$AddUpvote({
    required this.addUpvote,
    this.$__typename = 'MutationRoot',
  });

  factory Mutation$AddUpvote.fromJson(Map<String, dynamic> json) {
    final l$addUpvote = json['addUpvote'];
    final l$$__typename = json['__typename'];
    return Mutation$AddUpvote(
      addUpvote: (l$addUpvote as bool),
      $__typename: (l$$__typename as String),
    );
  }

  final bool addUpvote;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$addUpvote = addUpvote;
    _resultData['addUpvote'] = l$addUpvote;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$addUpvote = addUpvote;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$addUpvote,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (!(other is Mutation$AddUpvote) || runtimeType != other.runtimeType) {
      return false;
    }
    final l$addUpvote = addUpvote;
    final lOther$addUpvote = other.addUpvote;
    if (l$addUpvote != lOther$addUpvote) {
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

extension UtilityExtension$Mutation$AddUpvote on Mutation$AddUpvote {
  CopyWith$Mutation$AddUpvote<Mutation$AddUpvote> get copyWith =>
      CopyWith$Mutation$AddUpvote(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Mutation$AddUpvote<TRes> {
  factory CopyWith$Mutation$AddUpvote(
    Mutation$AddUpvote instance,
    TRes Function(Mutation$AddUpvote) then,
  ) = _CopyWithImpl$Mutation$AddUpvote;

  factory CopyWith$Mutation$AddUpvote.stub(TRes res) =
      _CopyWithStubImpl$Mutation$AddUpvote;

  TRes call({
    bool? addUpvote,
    String? $__typename,
  });
}

class _CopyWithImpl$Mutation$AddUpvote<TRes>
    implements CopyWith$Mutation$AddUpvote<TRes> {
  _CopyWithImpl$Mutation$AddUpvote(
    this._instance,
    this._then,
  );

  final Mutation$AddUpvote _instance;

  final TRes Function(Mutation$AddUpvote) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? addUpvote = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$AddUpvote(
        addUpvote: addUpvote == _undefined || addUpvote == null
            ? _instance.addUpvote
            : (addUpvote as bool),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Mutation$AddUpvote<TRes>
    implements CopyWith$Mutation$AddUpvote<TRes> {
  _CopyWithStubImpl$Mutation$AddUpvote(this._res);

  TRes _res;

  call({
    bool? addUpvote,
    String? $__typename,
  }) =>
      _res;
}

const documentNodeMutationAddUpvote = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'AddUpvote'),
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
        name: NameNode(value: 'addUpvote'),
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
Mutation$AddUpvote _parserFn$Mutation$AddUpvote(Map<String, dynamic> data) =>
    Mutation$AddUpvote.fromJson(data);
typedef OnMutationCompleted$Mutation$AddUpvote = FutureOr<void> Function(
  Map<String, dynamic>?,
  Mutation$AddUpvote?,
);

class Options$Mutation$AddUpvote
    extends graphql.MutationOptions<Mutation$AddUpvote> {
  Options$Mutation$AddUpvote({
    String? operationName,
    required Variables$Mutation$AddUpvote variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$AddUpvote? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$AddUpvote? onCompleted,
    graphql.OnMutationUpdate<Mutation$AddUpvote>? update,
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
                    data == null ? null : _parserFn$Mutation$AddUpvote(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationAddUpvote,
          parserFn: _parserFn$Mutation$AddUpvote,
        );

  final OnMutationCompleted$Mutation$AddUpvote? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$AddUpvote
    extends graphql.WatchQueryOptions<Mutation$AddUpvote> {
  WatchOptions$Mutation$AddUpvote({
    String? operationName,
    required Variables$Mutation$AddUpvote variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$AddUpvote? typedOptimisticResult,
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
          document: documentNodeMutationAddUpvote,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$AddUpvote,
        );
}

extension ClientExtension$Mutation$AddUpvote on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$AddUpvote>> mutate$AddUpvote(
          Options$Mutation$AddUpvote options) async =>
      await this.mutate(options);
  graphql.ObservableQuery<Mutation$AddUpvote> watchMutation$AddUpvote(
          WatchOptions$Mutation$AddUpvote options) =>
      this.watchMutation(options);
}

class Mutation$AddUpvote$HookResult {
  Mutation$AddUpvote$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$AddUpvote runMutation;

  final graphql.QueryResult<Mutation$AddUpvote> result;
}

Mutation$AddUpvote$HookResult useMutation$AddUpvote(
    [WidgetOptions$Mutation$AddUpvote? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$AddUpvote());
  return Mutation$AddUpvote$HookResult(
    (variables, {optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables.toJson(),
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$AddUpvote> useWatchMutation$AddUpvote(
        WatchOptions$Mutation$AddUpvote options) =>
    graphql_flutter.useWatchMutation(options);

class WidgetOptions$Mutation$AddUpvote
    extends graphql.MutationOptions<Mutation$AddUpvote> {
  WidgetOptions$Mutation$AddUpvote({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$AddUpvote? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$AddUpvote? onCompleted,
    graphql.OnMutationUpdate<Mutation$AddUpvote>? update,
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
                    data == null ? null : _parserFn$Mutation$AddUpvote(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationAddUpvote,
          parserFn: _parserFn$Mutation$AddUpvote,
        );

  final OnMutationCompleted$Mutation$AddUpvote? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$AddUpvote
    = graphql.MultiSourceResult<Mutation$AddUpvote> Function(
  Variables$Mutation$AddUpvote, {
  Object? optimisticResult,
  Mutation$AddUpvote? typedOptimisticResult,
});
typedef Builder$Mutation$AddUpvote = widgets.Widget Function(
  RunMutation$Mutation$AddUpvote,
  graphql.QueryResult<Mutation$AddUpvote>?,
);

class Mutation$AddUpvote$Widget
    extends graphql_flutter.Mutation<Mutation$AddUpvote> {
  Mutation$AddUpvote$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$AddUpvote? options,
    required Builder$Mutation$AddUpvote builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$AddUpvote(),
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

class Variables$Mutation$LinkImage {
  factory Variables$Mutation$LinkImage({
    required String mealId,
    required MultipartFile image,
    required String hash,
  }) =>
      Variables$Mutation$LinkImage._({
        r'mealId': mealId,
        r'image': image,
        r'hash': hash,
      });

  Variables$Mutation$LinkImage._(this._$data);

  factory Variables$Mutation$LinkImage.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$mealId = data['mealId'];
    result$data['mealId'] = (l$mealId as String);
    final l$image = data['image'];
    result$data['image'] = (l$image as MultipartFile);
    final l$hash = data['hash'];
    result$data['hash'] = (l$hash as String);
    return Variables$Mutation$LinkImage._(result$data);
  }

  Map<String, dynamic> _$data;

  String get mealId => (_$data['mealId'] as String);
  MultipartFile get image => (_$data['image'] as MultipartFile);
  String get hash => (_$data['hash'] as String);
  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$mealId = mealId;
    result$data['mealId'] = l$mealId;
    final l$image = image;
    result$data['image'] = l$image;
    final l$hash = hash;
    result$data['hash'] = l$hash;
    return result$data;
  }

  CopyWith$Variables$Mutation$LinkImage<Variables$Mutation$LinkImage>
      get copyWith => CopyWith$Variables$Mutation$LinkImage(
            this,
            (i) => i,
          );
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (!(other is Variables$Mutation$LinkImage) ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$mealId = mealId;
    final lOther$mealId = other.mealId;
    if (l$mealId != lOther$mealId) {
      return false;
    }
    final l$image = image;
    final lOther$image = other.image;
    if (l$image != lOther$image) {
      return false;
    }
    final l$hash = hash;
    final lOther$hash = other.hash;
    if (l$hash != lOther$hash) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$mealId = mealId;
    final l$image = image;
    final l$hash = hash;
    return Object.hashAll([
      l$mealId,
      l$image,
      l$hash,
    ]);
  }
}

abstract class CopyWith$Variables$Mutation$LinkImage<TRes> {
  factory CopyWith$Variables$Mutation$LinkImage(
    Variables$Mutation$LinkImage instance,
    TRes Function(Variables$Mutation$LinkImage) then,
  ) = _CopyWithImpl$Variables$Mutation$LinkImage;

  factory CopyWith$Variables$Mutation$LinkImage.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$LinkImage;

  TRes call({
    String? mealId,
    MultipartFile? image,
    String? hash,
  });
}

class _CopyWithImpl$Variables$Mutation$LinkImage<TRes>
    implements CopyWith$Variables$Mutation$LinkImage<TRes> {
  _CopyWithImpl$Variables$Mutation$LinkImage(
    this._instance,
    this._then,
  );

  final Variables$Mutation$LinkImage _instance;

  final TRes Function(Variables$Mutation$LinkImage) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? mealId = _undefined,
    Object? image = _undefined,
    Object? hash = _undefined,
  }) =>
      _then(Variables$Mutation$LinkImage._({
        ..._instance._$data,
        if (mealId != _undefined && mealId != null)
          'mealId': (mealId as String),
        if (image != _undefined && image != null)
          'image': (image as MultipartFile),
        if (hash != _undefined && hash != null) 'hash': (hash as String),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$LinkImage<TRes>
    implements CopyWith$Variables$Mutation$LinkImage<TRes> {
  _CopyWithStubImpl$Variables$Mutation$LinkImage(this._res);

  TRes _res;

  call({
    String? mealId,
    MultipartFile? image,
    String? hash,
  }) =>
      _res;
}

class Mutation$LinkImage {
  Mutation$LinkImage({
    required this.addImage,
    this.$__typename = 'MutationRoot',
  });

  factory Mutation$LinkImage.fromJson(Map<String, dynamic> json) {
    final l$addImage = json['addImage'];
    final l$$__typename = json['__typename'];
    return Mutation$LinkImage(
      addImage: (l$addImage as bool),
      $__typename: (l$$__typename as String),
    );
  }

  final bool addImage;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$addImage = addImage;
    _resultData['addImage'] = l$addImage;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$addImage = addImage;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$addImage,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (!(other is Mutation$LinkImage) || runtimeType != other.runtimeType) {
      return false;
    }
    final l$addImage = addImage;
    final lOther$addImage = other.addImage;
    if (l$addImage != lOther$addImage) {
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

extension UtilityExtension$Mutation$LinkImage on Mutation$LinkImage {
  CopyWith$Mutation$LinkImage<Mutation$LinkImage> get copyWith =>
      CopyWith$Mutation$LinkImage(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Mutation$LinkImage<TRes> {
  factory CopyWith$Mutation$LinkImage(
    Mutation$LinkImage instance,
    TRes Function(Mutation$LinkImage) then,
  ) = _CopyWithImpl$Mutation$LinkImage;

  factory CopyWith$Mutation$LinkImage.stub(TRes res) =
      _CopyWithStubImpl$Mutation$LinkImage;

  TRes call({
    bool? addImage,
    String? $__typename,
  });
}

class _CopyWithImpl$Mutation$LinkImage<TRes>
    implements CopyWith$Mutation$LinkImage<TRes> {
  _CopyWithImpl$Mutation$LinkImage(
    this._instance,
    this._then,
  );

  final Mutation$LinkImage _instance;

  final TRes Function(Mutation$LinkImage) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? addImage = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$LinkImage(
        addImage: addImage == _undefined || addImage == null
            ? _instance.addImage
            : (addImage as bool),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Mutation$LinkImage<TRes>
    implements CopyWith$Mutation$LinkImage<TRes> {
  _CopyWithStubImpl$Mutation$LinkImage(this._res);

  TRes _res;

  call({
    bool? addImage,
    String? $__typename,
  }) =>
      _res;
}

const documentNodeMutationLinkImage = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'LinkImage'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'mealId')),
        type: NamedTypeNode(
          name: NameNode(value: 'UUID'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'image')),
        type: NamedTypeNode(
          name: NameNode(value: 'Upload'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'hash')),
        type: NamedTypeNode(
          name: NameNode(value: 'String'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'addImage'),
        alias: null,
        arguments: [
          ArgumentNode(
            name: NameNode(value: 'mealId'),
            value: VariableNode(name: NameNode(value: 'mealId')),
          ),
          ArgumentNode(
            name: NameNode(value: 'image'),
            value: VariableNode(name: NameNode(value: 'image')),
          ),
          ArgumentNode(
            name: NameNode(value: 'hash'),
            value: VariableNode(name: NameNode(value: 'hash')),
          ),
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
Mutation$LinkImage _parserFn$Mutation$LinkImage(Map<String, dynamic> data) =>
    Mutation$LinkImage.fromJson(data);
typedef OnMutationCompleted$Mutation$LinkImage = FutureOr<void> Function(
  Map<String, dynamic>?,
  Mutation$LinkImage?,
);

class Options$Mutation$LinkImage
    extends graphql.MutationOptions<Mutation$LinkImage> {
  Options$Mutation$LinkImage({
    String? operationName,
    required Variables$Mutation$LinkImage variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$LinkImage? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$LinkImage? onCompleted,
    graphql.OnMutationUpdate<Mutation$LinkImage>? update,
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
                    data == null ? null : _parserFn$Mutation$LinkImage(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationLinkImage,
          parserFn: _parserFn$Mutation$LinkImage,
        );

  final OnMutationCompleted$Mutation$LinkImage? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$LinkImage
    extends graphql.WatchQueryOptions<Mutation$LinkImage> {
  WatchOptions$Mutation$LinkImage({
    String? operationName,
    required Variables$Mutation$LinkImage variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$LinkImage? typedOptimisticResult,
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
          document: documentNodeMutationLinkImage,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$LinkImage,
        );
}

extension ClientExtension$Mutation$LinkImage on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$LinkImage>> mutate$LinkImage(
          Options$Mutation$LinkImage options) async =>
      await this.mutate(options);
  graphql.ObservableQuery<Mutation$LinkImage> watchMutation$LinkImage(
          WatchOptions$Mutation$LinkImage options) =>
      this.watchMutation(options);
}

class Mutation$LinkImage$HookResult {
  Mutation$LinkImage$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$LinkImage runMutation;

  final graphql.QueryResult<Mutation$LinkImage> result;
}

Mutation$LinkImage$HookResult useMutation$LinkImage(
    [WidgetOptions$Mutation$LinkImage? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$LinkImage());
  return Mutation$LinkImage$HookResult(
    (variables, {optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables.toJson(),
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$LinkImage> useWatchMutation$LinkImage(
        WatchOptions$Mutation$LinkImage options) =>
    graphql_flutter.useWatchMutation(options);

class WidgetOptions$Mutation$LinkImage
    extends graphql.MutationOptions<Mutation$LinkImage> {
  WidgetOptions$Mutation$LinkImage({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$LinkImage? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$LinkImage? onCompleted,
    graphql.OnMutationUpdate<Mutation$LinkImage>? update,
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
                    data == null ? null : _parserFn$Mutation$LinkImage(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationLinkImage,
          parserFn: _parserFn$Mutation$LinkImage,
        );

  final OnMutationCompleted$Mutation$LinkImage? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$LinkImage
    = graphql.MultiSourceResult<Mutation$LinkImage> Function(
  Variables$Mutation$LinkImage, {
  Object? optimisticResult,
  Mutation$LinkImage? typedOptimisticResult,
});
typedef Builder$Mutation$LinkImage = widgets.Widget Function(
  RunMutation$Mutation$LinkImage,
  graphql.QueryResult<Mutation$LinkImage>?,
);

class Mutation$LinkImage$Widget
    extends graphql_flutter.Mutation<Mutation$LinkImage> {
  Mutation$LinkImage$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$LinkImage? options,
    required Builder$Mutation$LinkImage builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$LinkImage(),
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

class Variables$Mutation$ReportImage {
  factory Variables$Mutation$ReportImage({
    required String imageId,
    required Enum$ReportReason reason,
  }) =>
      Variables$Mutation$ReportImage._({
        r'imageId': imageId,
        r'reason': reason,
      });

  Variables$Mutation$ReportImage._(this._$data);

  factory Variables$Mutation$ReportImage.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$imageId = data['imageId'];
    result$data['imageId'] = (l$imageId as String);
    final l$reason = data['reason'];
    result$data['reason'] = fromJson$Enum$ReportReason((l$reason as String));
    return Variables$Mutation$ReportImage._(result$data);
  }

  Map<String, dynamic> _$data;

  String get imageId => (_$data['imageId'] as String);
  Enum$ReportReason get reason => (_$data['reason'] as Enum$ReportReason);
  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$imageId = imageId;
    result$data['imageId'] = l$imageId;
    final l$reason = reason;
    result$data['reason'] = toJson$Enum$ReportReason(l$reason);
    return result$data;
  }

  CopyWith$Variables$Mutation$ReportImage<Variables$Mutation$ReportImage>
      get copyWith => CopyWith$Variables$Mutation$ReportImage(
            this,
            (i) => i,
          );
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (!(other is Variables$Mutation$ReportImage) ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$imageId = imageId;
    final lOther$imageId = other.imageId;
    if (l$imageId != lOther$imageId) {
      return false;
    }
    final l$reason = reason;
    final lOther$reason = other.reason;
    if (l$reason != lOther$reason) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$imageId = imageId;
    final l$reason = reason;
    return Object.hashAll([
      l$imageId,
      l$reason,
    ]);
  }
}

abstract class CopyWith$Variables$Mutation$ReportImage<TRes> {
  factory CopyWith$Variables$Mutation$ReportImage(
    Variables$Mutation$ReportImage instance,
    TRes Function(Variables$Mutation$ReportImage) then,
  ) = _CopyWithImpl$Variables$Mutation$ReportImage;

  factory CopyWith$Variables$Mutation$ReportImage.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$ReportImage;

  TRes call({
    String? imageId,
    Enum$ReportReason? reason,
  });
}

class _CopyWithImpl$Variables$Mutation$ReportImage<TRes>
    implements CopyWith$Variables$Mutation$ReportImage<TRes> {
  _CopyWithImpl$Variables$Mutation$ReportImage(
    this._instance,
    this._then,
  );

  final Variables$Mutation$ReportImage _instance;

  final TRes Function(Variables$Mutation$ReportImage) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? imageId = _undefined,
    Object? reason = _undefined,
  }) =>
      _then(Variables$Mutation$ReportImage._({
        ..._instance._$data,
        if (imageId != _undefined && imageId != null)
          'imageId': (imageId as String),
        if (reason != _undefined && reason != null)
          'reason': (reason as Enum$ReportReason),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$ReportImage<TRes>
    implements CopyWith$Variables$Mutation$ReportImage<TRes> {
  _CopyWithStubImpl$Variables$Mutation$ReportImage(this._res);

  TRes _res;

  call({
    String? imageId,
    Enum$ReportReason? reason,
  }) =>
      _res;
}

class Mutation$ReportImage {
  Mutation$ReportImage({
    required this.reportImage,
    this.$__typename = 'MutationRoot',
  });

  factory Mutation$ReportImage.fromJson(Map<String, dynamic> json) {
    final l$reportImage = json['reportImage'];
    final l$$__typename = json['__typename'];
    return Mutation$ReportImage(
      reportImage: (l$reportImage as bool),
      $__typename: (l$$__typename as String),
    );
  }

  final bool reportImage;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$reportImage = reportImage;
    _resultData['reportImage'] = l$reportImage;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$reportImage = reportImage;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$reportImage,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (!(other is Mutation$ReportImage) || runtimeType != other.runtimeType) {
      return false;
    }
    final l$reportImage = reportImage;
    final lOther$reportImage = other.reportImage;
    if (l$reportImage != lOther$reportImage) {
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

extension UtilityExtension$Mutation$ReportImage on Mutation$ReportImage {
  CopyWith$Mutation$ReportImage<Mutation$ReportImage> get copyWith =>
      CopyWith$Mutation$ReportImage(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Mutation$ReportImage<TRes> {
  factory CopyWith$Mutation$ReportImage(
    Mutation$ReportImage instance,
    TRes Function(Mutation$ReportImage) then,
  ) = _CopyWithImpl$Mutation$ReportImage;

  factory CopyWith$Mutation$ReportImage.stub(TRes res) =
      _CopyWithStubImpl$Mutation$ReportImage;

  TRes call({
    bool? reportImage,
    String? $__typename,
  });
}

class _CopyWithImpl$Mutation$ReportImage<TRes>
    implements CopyWith$Mutation$ReportImage<TRes> {
  _CopyWithImpl$Mutation$ReportImage(
    this._instance,
    this._then,
  );

  final Mutation$ReportImage _instance;

  final TRes Function(Mutation$ReportImage) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? reportImage = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$ReportImage(
        reportImage: reportImage == _undefined || reportImage == null
            ? _instance.reportImage
            : (reportImage as bool),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Mutation$ReportImage<TRes>
    implements CopyWith$Mutation$ReportImage<TRes> {
  _CopyWithStubImpl$Mutation$ReportImage(this._res);

  TRes _res;

  call({
    bool? reportImage,
    String? $__typename,
  }) =>
      _res;
}

const documentNodeMutationReportImage = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'ReportImage'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'imageId')),
        type: NamedTypeNode(
          name: NameNode(value: 'UUID'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'reason')),
        type: NamedTypeNode(
          name: NameNode(value: 'ReportReason'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'reportImage'),
        alias: null,
        arguments: [
          ArgumentNode(
            name: NameNode(value: 'imageId'),
            value: VariableNode(name: NameNode(value: 'imageId')),
          ),
          ArgumentNode(
            name: NameNode(value: 'reason'),
            value: VariableNode(name: NameNode(value: 'reason')),
          ),
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
Mutation$ReportImage _parserFn$Mutation$ReportImage(
        Map<String, dynamic> data) =>
    Mutation$ReportImage.fromJson(data);
typedef OnMutationCompleted$Mutation$ReportImage = FutureOr<void> Function(
  Map<String, dynamic>?,
  Mutation$ReportImage?,
);

class Options$Mutation$ReportImage
    extends graphql.MutationOptions<Mutation$ReportImage> {
  Options$Mutation$ReportImage({
    String? operationName,
    required Variables$Mutation$ReportImage variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$ReportImage? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$ReportImage? onCompleted,
    graphql.OnMutationUpdate<Mutation$ReportImage>? update,
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
                    data == null ? null : _parserFn$Mutation$ReportImage(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationReportImage,
          parserFn: _parserFn$Mutation$ReportImage,
        );

  final OnMutationCompleted$Mutation$ReportImage? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$ReportImage
    extends graphql.WatchQueryOptions<Mutation$ReportImage> {
  WatchOptions$Mutation$ReportImage({
    String? operationName,
    required Variables$Mutation$ReportImage variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$ReportImage? typedOptimisticResult,
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
          document: documentNodeMutationReportImage,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$ReportImage,
        );
}

extension ClientExtension$Mutation$ReportImage on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$ReportImage>> mutate$ReportImage(
          Options$Mutation$ReportImage options) async =>
      await this.mutate(options);
  graphql.ObservableQuery<Mutation$ReportImage> watchMutation$ReportImage(
          WatchOptions$Mutation$ReportImage options) =>
      this.watchMutation(options);
}

class Mutation$ReportImage$HookResult {
  Mutation$ReportImage$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$ReportImage runMutation;

  final graphql.QueryResult<Mutation$ReportImage> result;
}

Mutation$ReportImage$HookResult useMutation$ReportImage(
    [WidgetOptions$Mutation$ReportImage? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$ReportImage());
  return Mutation$ReportImage$HookResult(
    (variables, {optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables.toJson(),
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$ReportImage> useWatchMutation$ReportImage(
        WatchOptions$Mutation$ReportImage options) =>
    graphql_flutter.useWatchMutation(options);

class WidgetOptions$Mutation$ReportImage
    extends graphql.MutationOptions<Mutation$ReportImage> {
  WidgetOptions$Mutation$ReportImage({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$ReportImage? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$ReportImage? onCompleted,
    graphql.OnMutationUpdate<Mutation$ReportImage>? update,
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
                    data == null ? null : _parserFn$Mutation$ReportImage(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationReportImage,
          parserFn: _parserFn$Mutation$ReportImage,
        );

  final OnMutationCompleted$Mutation$ReportImage? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$ReportImage
    = graphql.MultiSourceResult<Mutation$ReportImage> Function(
  Variables$Mutation$ReportImage, {
  Object? optimisticResult,
  Mutation$ReportImage? typedOptimisticResult,
});
typedef Builder$Mutation$ReportImage = widgets.Widget Function(
  RunMutation$Mutation$ReportImage,
  graphql.QueryResult<Mutation$ReportImage>?,
);

class Mutation$ReportImage$Widget
    extends graphql_flutter.Mutation<Mutation$ReportImage> {
  Mutation$ReportImage$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$ReportImage? options,
    required Builder$Mutation$ReportImage builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$ReportImage(),
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

class Variables$Mutation$UpdateRating {
  factory Variables$Mutation$UpdateRating({
    required String mealId,
    required int rating,
  }) =>
      Variables$Mutation$UpdateRating._({
        r'mealId': mealId,
        r'rating': rating,
      });

  Variables$Mutation$UpdateRating._(this._$data);

  factory Variables$Mutation$UpdateRating.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$mealId = data['mealId'];
    result$data['mealId'] = (l$mealId as String);
    final l$rating = data['rating'];
    result$data['rating'] = (l$rating as int);
    return Variables$Mutation$UpdateRating._(result$data);
  }

  Map<String, dynamic> _$data;

  String get mealId => (_$data['mealId'] as String);
  int get rating => (_$data['rating'] as int);
  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$mealId = mealId;
    result$data['mealId'] = l$mealId;
    final l$rating = rating;
    result$data['rating'] = l$rating;
    return result$data;
  }

  CopyWith$Variables$Mutation$UpdateRating<Variables$Mutation$UpdateRating>
      get copyWith => CopyWith$Variables$Mutation$UpdateRating(
            this,
            (i) => i,
          );
  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (!(other is Variables$Mutation$UpdateRating) ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$mealId = mealId;
    final lOther$mealId = other.mealId;
    if (l$mealId != lOther$mealId) {
      return false;
    }
    final l$rating = rating;
    final lOther$rating = other.rating;
    if (l$rating != lOther$rating) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$mealId = mealId;
    final l$rating = rating;
    return Object.hashAll([
      l$mealId,
      l$rating,
    ]);
  }
}

abstract class CopyWith$Variables$Mutation$UpdateRating<TRes> {
  factory CopyWith$Variables$Mutation$UpdateRating(
    Variables$Mutation$UpdateRating instance,
    TRes Function(Variables$Mutation$UpdateRating) then,
  ) = _CopyWithImpl$Variables$Mutation$UpdateRating;

  factory CopyWith$Variables$Mutation$UpdateRating.stub(TRes res) =
      _CopyWithStubImpl$Variables$Mutation$UpdateRating;

  TRes call({
    String? mealId,
    int? rating,
  });
}

class _CopyWithImpl$Variables$Mutation$UpdateRating<TRes>
    implements CopyWith$Variables$Mutation$UpdateRating<TRes> {
  _CopyWithImpl$Variables$Mutation$UpdateRating(
    this._instance,
    this._then,
  );

  final Variables$Mutation$UpdateRating _instance;

  final TRes Function(Variables$Mutation$UpdateRating) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? mealId = _undefined,
    Object? rating = _undefined,
  }) =>
      _then(Variables$Mutation$UpdateRating._({
        ..._instance._$data,
        if (mealId != _undefined && mealId != null)
          'mealId': (mealId as String),
        if (rating != _undefined && rating != null) 'rating': (rating as int),
      }));
}

class _CopyWithStubImpl$Variables$Mutation$UpdateRating<TRes>
    implements CopyWith$Variables$Mutation$UpdateRating<TRes> {
  _CopyWithStubImpl$Variables$Mutation$UpdateRating(this._res);

  TRes _res;

  call({
    String? mealId,
    int? rating,
  }) =>
      _res;
}

class Mutation$UpdateRating {
  Mutation$UpdateRating({
    required this.setRating,
    this.$__typename = 'MutationRoot',
  });

  factory Mutation$UpdateRating.fromJson(Map<String, dynamic> json) {
    final l$setRating = json['setRating'];
    final l$$__typename = json['__typename'];
    return Mutation$UpdateRating(
      setRating: (l$setRating as bool),
      $__typename: (l$$__typename as String),
    );
  }

  final bool setRating;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$setRating = setRating;
    _resultData['setRating'] = l$setRating;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$setRating = setRating;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$setRating,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (!(other is Mutation$UpdateRating) || runtimeType != other.runtimeType) {
      return false;
    }
    final l$setRating = setRating;
    final lOther$setRating = other.setRating;
    if (l$setRating != lOther$setRating) {
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

extension UtilityExtension$Mutation$UpdateRating on Mutation$UpdateRating {
  CopyWith$Mutation$UpdateRating<Mutation$UpdateRating> get copyWith =>
      CopyWith$Mutation$UpdateRating(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Mutation$UpdateRating<TRes> {
  factory CopyWith$Mutation$UpdateRating(
    Mutation$UpdateRating instance,
    TRes Function(Mutation$UpdateRating) then,
  ) = _CopyWithImpl$Mutation$UpdateRating;

  factory CopyWith$Mutation$UpdateRating.stub(TRes res) =
      _CopyWithStubImpl$Mutation$UpdateRating;

  TRes call({
    bool? setRating,
    String? $__typename,
  });
}

class _CopyWithImpl$Mutation$UpdateRating<TRes>
    implements CopyWith$Mutation$UpdateRating<TRes> {
  _CopyWithImpl$Mutation$UpdateRating(
    this._instance,
    this._then,
  );

  final Mutation$UpdateRating _instance;

  final TRes Function(Mutation$UpdateRating) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? setRating = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Mutation$UpdateRating(
        setRating: setRating == _undefined || setRating == null
            ? _instance.setRating
            : (setRating as bool),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Mutation$UpdateRating<TRes>
    implements CopyWith$Mutation$UpdateRating<TRes> {
  _CopyWithStubImpl$Mutation$UpdateRating(this._res);

  TRes _res;

  call({
    bool? setRating,
    String? $__typename,
  }) =>
      _res;
}

const documentNodeMutationUpdateRating = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.mutation,
    name: NameNode(value: 'UpdateRating'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'mealId')),
        type: NamedTypeNode(
          name: NameNode(value: 'UUID'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'rating')),
        type: NamedTypeNode(
          name: NameNode(value: 'Int'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'setRating'),
        alias: null,
        arguments: [
          ArgumentNode(
            name: NameNode(value: 'mealId'),
            value: VariableNode(name: NameNode(value: 'mealId')),
          ),
          ArgumentNode(
            name: NameNode(value: 'rating'),
            value: VariableNode(name: NameNode(value: 'rating')),
          ),
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
Mutation$UpdateRating _parserFn$Mutation$UpdateRating(
        Map<String, dynamic> data) =>
    Mutation$UpdateRating.fromJson(data);
typedef OnMutationCompleted$Mutation$UpdateRating = FutureOr<void> Function(
  Map<String, dynamic>?,
  Mutation$UpdateRating?,
);

class Options$Mutation$UpdateRating
    extends graphql.MutationOptions<Mutation$UpdateRating> {
  Options$Mutation$UpdateRating({
    String? operationName,
    required Variables$Mutation$UpdateRating variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateRating? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateRating? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateRating>? update,
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
                    data == null ? null : _parserFn$Mutation$UpdateRating(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateRating,
          parserFn: _parserFn$Mutation$UpdateRating,
        );

  final OnMutationCompleted$Mutation$UpdateRating? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

class WatchOptions$Mutation$UpdateRating
    extends graphql.WatchQueryOptions<Mutation$UpdateRating> {
  WatchOptions$Mutation$UpdateRating({
    String? operationName,
    required Variables$Mutation$UpdateRating variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateRating? typedOptimisticResult,
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
          document: documentNodeMutationUpdateRating,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Mutation$UpdateRating,
        );
}

extension ClientExtension$Mutation$UpdateRating on graphql.GraphQLClient {
  Future<graphql.QueryResult<Mutation$UpdateRating>> mutate$UpdateRating(
          Options$Mutation$UpdateRating options) async =>
      await this.mutate(options);
  graphql.ObservableQuery<Mutation$UpdateRating> watchMutation$UpdateRating(
          WatchOptions$Mutation$UpdateRating options) =>
      this.watchMutation(options);
}

class Mutation$UpdateRating$HookResult {
  Mutation$UpdateRating$HookResult(
    this.runMutation,
    this.result,
  );

  final RunMutation$Mutation$UpdateRating runMutation;

  final graphql.QueryResult<Mutation$UpdateRating> result;
}

Mutation$UpdateRating$HookResult useMutation$UpdateRating(
    [WidgetOptions$Mutation$UpdateRating? options]) {
  final result = graphql_flutter
      .useMutation(options ?? WidgetOptions$Mutation$UpdateRating());
  return Mutation$UpdateRating$HookResult(
    (variables, {optimisticResult, typedOptimisticResult}) =>
        result.runMutation(
      variables.toJson(),
      optimisticResult: optimisticResult ?? typedOptimisticResult?.toJson(),
    ),
    result.result,
  );
}

graphql.ObservableQuery<Mutation$UpdateRating> useWatchMutation$UpdateRating(
        WatchOptions$Mutation$UpdateRating options) =>
    graphql_flutter.useWatchMutation(options);

class WidgetOptions$Mutation$UpdateRating
    extends graphql.MutationOptions<Mutation$UpdateRating> {
  WidgetOptions$Mutation$UpdateRating({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Mutation$UpdateRating? typedOptimisticResult,
    graphql.Context? context,
    OnMutationCompleted$Mutation$UpdateRating? onCompleted,
    graphql.OnMutationUpdate<Mutation$UpdateRating>? update,
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
                    data == null ? null : _parserFn$Mutation$UpdateRating(data),
                  ),
          update: update,
          onError: onError,
          document: documentNodeMutationUpdateRating,
          parserFn: _parserFn$Mutation$UpdateRating,
        );

  final OnMutationCompleted$Mutation$UpdateRating? onCompletedWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onCompleted == null
            ? super.properties
            : super.properties.where((property) => property != onCompleted),
        onCompletedWithParsed,
      ];
}

typedef RunMutation$Mutation$UpdateRating
    = graphql.MultiSourceResult<Mutation$UpdateRating> Function(
  Variables$Mutation$UpdateRating, {
  Object? optimisticResult,
  Mutation$UpdateRating? typedOptimisticResult,
});
typedef Builder$Mutation$UpdateRating = widgets.Widget Function(
  RunMutation$Mutation$UpdateRating,
  graphql.QueryResult<Mutation$UpdateRating>?,
);

class Mutation$UpdateRating$Widget
    extends graphql_flutter.Mutation<Mutation$UpdateRating> {
  Mutation$UpdateRating$Widget({
    widgets.Key? key,
    WidgetOptions$Mutation$UpdateRating? options,
    required Builder$Mutation$UpdateRating builder,
  }) : super(
          key: key,
          options: options ?? WidgetOptions$Mutation$UpdateRating(),
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
