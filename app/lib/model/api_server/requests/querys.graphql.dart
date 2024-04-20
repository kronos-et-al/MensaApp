import 'dart:async';
import 'package:flutter/widgets.dart' as widgets;
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;
import 'package:graphql_flutter/graphql_flutter.dart' as graphql_flutter;
import 'schema.graphql.dart';

class Fragment$canteen {
  Fragment$canteen({
    required this.id,
    required this.name,
    this.$__typename = 'Canteen',
  });

  factory Fragment$canteen.fromJson(Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$name = json['name'];
    final l$$__typename = json['__typename'];
    return Fragment$canteen(
      id: (l$id as String),
      name: (l$name as String),
      $__typename: (l$$__typename as String),
    );
  }

  final String id;

  final String name;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$name = name;
    _resultData['name'] = l$name;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$name = name;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$name,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (!(other is Fragment$canteen) || runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
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

extension UtilityExtension$Fragment$canteen on Fragment$canteen {
  CopyWith$Fragment$canteen<Fragment$canteen> get copyWith =>
      CopyWith$Fragment$canteen(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Fragment$canteen<TRes> {
  factory CopyWith$Fragment$canteen(
    Fragment$canteen instance,
    TRes Function(Fragment$canteen) then,
  ) = _CopyWithImpl$Fragment$canteen;

  factory CopyWith$Fragment$canteen.stub(TRes res) =
      _CopyWithStubImpl$Fragment$canteen;

  TRes call({
    String? id,
    String? name,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$canteen<TRes>
    implements CopyWith$Fragment$canteen<TRes> {
  _CopyWithImpl$Fragment$canteen(
    this._instance,
    this._then,
  );

  final Fragment$canteen _instance;

  final TRes Function(Fragment$canteen) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? name = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$canteen(
        id: id == _undefined || id == null ? _instance.id : (id as String),
        name: name == _undefined || name == null
            ? _instance.name
            : (name as String),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Fragment$canteen<TRes>
    implements CopyWith$Fragment$canteen<TRes> {
  _CopyWithStubImpl$Fragment$canteen(this._res);

  TRes _res;

  call({
    String? id,
    String? name,
    String? $__typename,
  }) =>
      _res;
}

const fragmentDefinitioncanteen = FragmentDefinitionNode(
  name: NameNode(value: 'canteen'),
  typeCondition: TypeConditionNode(
      on: NamedTypeNode(
    name: NameNode(value: 'Canteen'),
    isNonNull: false,
  )),
  directives: [],
  selectionSet: SelectionSetNode(selections: [
    FieldNode(
      name: NameNode(value: 'id'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'name'),
      alias: null,
      arguments: [],
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
);
const documentNodeFragmentcanteen = DocumentNode(definitions: [
  fragmentDefinitioncanteen,
]);

extension ClientExtension$Fragment$canteen on graphql.GraphQLClient {
  void writeFragment$canteen({
    required Fragment$canteen data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) =>
      this.writeFragment(
        graphql.FragmentRequest(
          idFields: idFields,
          fragment: const graphql.Fragment(
            fragmentName: 'canteen',
            document: documentNodeFragmentcanteen,
          ),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );
  Fragment$canteen? readFragment$canteen({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'canteen',
          document: documentNodeFragmentcanteen,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$canteen.fromJson(result);
  }
}

class Variables$Fragment$mealPlan {
  factory Variables$Fragment$mealPlan({required String date}) =>
      Variables$Fragment$mealPlan._({
        r'date': date,
      });

  Variables$Fragment$mealPlan._(this._$data);

  factory Variables$Fragment$mealPlan.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$date = data['date'];
    result$data['date'] = (l$date as String);
    return Variables$Fragment$mealPlan._(result$data);
  }

  Map<String, dynamic> _$data;

  String get date => (_$data['date'] as String);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$date = date;
    result$data['date'] = l$date;
    return result$data;
  }

  CopyWith$Variables$Fragment$mealPlan<Variables$Fragment$mealPlan>
      get copyWith => CopyWith$Variables$Fragment$mealPlan(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (!(other is Variables$Fragment$mealPlan) ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$date = date;
    final lOther$date = other.date;
    if (l$date != lOther$date) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$date = date;
    return Object.hashAll([l$date]);
  }
}

abstract class CopyWith$Variables$Fragment$mealPlan<TRes> {
  factory CopyWith$Variables$Fragment$mealPlan(
    Variables$Fragment$mealPlan instance,
    TRes Function(Variables$Fragment$mealPlan) then,
  ) = _CopyWithImpl$Variables$Fragment$mealPlan;

  factory CopyWith$Variables$Fragment$mealPlan.stub(TRes res) =
      _CopyWithStubImpl$Variables$Fragment$mealPlan;

  TRes call({String? date});
}

class _CopyWithImpl$Variables$Fragment$mealPlan<TRes>
    implements CopyWith$Variables$Fragment$mealPlan<TRes> {
  _CopyWithImpl$Variables$Fragment$mealPlan(
    this._instance,
    this._then,
  );

  final Variables$Fragment$mealPlan _instance;

  final TRes Function(Variables$Fragment$mealPlan) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? date = _undefined}) =>
      _then(Variables$Fragment$mealPlan._({
        ..._instance._$data,
        if (date != _undefined && date != null) 'date': (date as String),
      }));
}

class _CopyWithStubImpl$Variables$Fragment$mealPlan<TRes>
    implements CopyWith$Variables$Fragment$mealPlan<TRes> {
  _CopyWithStubImpl$Variables$Fragment$mealPlan(this._res);

  TRes _res;

  call({String? date}) => _res;
}

class Fragment$mealPlan {
  Fragment$mealPlan({
    required this.lines,
    this.$__typename = 'Canteen',
  });

  factory Fragment$mealPlan.fromJson(Map<String, dynamic> json) {
    final l$lines = json['lines'];
    final l$$__typename = json['__typename'];
    return Fragment$mealPlan(
      lines: (l$lines as List<dynamic>)
          .map((e) =>
              Fragment$mealPlan$lines.fromJson((e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Fragment$mealPlan$lines> lines;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$lines = lines;
    _resultData['lines'] = l$lines.map((e) => e.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$lines = lines;
    final l$$__typename = $__typename;
    return Object.hashAll([
      Object.hashAll(l$lines.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (!(other is Fragment$mealPlan) || runtimeType != other.runtimeType) {
      return false;
    }
    final l$lines = lines;
    final lOther$lines = other.lines;
    if (l$lines.length != lOther$lines.length) {
      return false;
    }
    for (int i = 0; i < l$lines.length; i++) {
      final l$lines$entry = l$lines[i];
      final lOther$lines$entry = lOther$lines[i];
      if (l$lines$entry != lOther$lines$entry) {
        return false;
      }
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Fragment$mealPlan on Fragment$mealPlan {
  CopyWith$Fragment$mealPlan<Fragment$mealPlan> get copyWith =>
      CopyWith$Fragment$mealPlan(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Fragment$mealPlan<TRes> {
  factory CopyWith$Fragment$mealPlan(
    Fragment$mealPlan instance,
    TRes Function(Fragment$mealPlan) then,
  ) = _CopyWithImpl$Fragment$mealPlan;

  factory CopyWith$Fragment$mealPlan.stub(TRes res) =
      _CopyWithStubImpl$Fragment$mealPlan;

  TRes call({
    List<Fragment$mealPlan$lines>? lines,
    String? $__typename,
  });
  TRes lines(
      Iterable<Fragment$mealPlan$lines> Function(
              Iterable<
                  CopyWith$Fragment$mealPlan$lines<Fragment$mealPlan$lines>>)
          _fn);
}

class _CopyWithImpl$Fragment$mealPlan<TRes>
    implements CopyWith$Fragment$mealPlan<TRes> {
  _CopyWithImpl$Fragment$mealPlan(
    this._instance,
    this._then,
  );

  final Fragment$mealPlan _instance;

  final TRes Function(Fragment$mealPlan) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? lines = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$mealPlan(
        lines: lines == _undefined || lines == null
            ? _instance.lines
            : (lines as List<Fragment$mealPlan$lines>),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  TRes lines(
          Iterable<Fragment$mealPlan$lines> Function(
                  Iterable<
                      CopyWith$Fragment$mealPlan$lines<
                          Fragment$mealPlan$lines>>)
              _fn) =>
      call(
          lines:
              _fn(_instance.lines.map((e) => CopyWith$Fragment$mealPlan$lines(
                    e,
                    (i) => i,
                  ))).toList());
}

class _CopyWithStubImpl$Fragment$mealPlan<TRes>
    implements CopyWith$Fragment$mealPlan<TRes> {
  _CopyWithStubImpl$Fragment$mealPlan(this._res);

  TRes _res;

  call({
    List<Fragment$mealPlan$lines>? lines,
    String? $__typename,
  }) =>
      _res;

  lines(_fn) => _res;
}

const fragmentDefinitionmealPlan = FragmentDefinitionNode(
  name: NameNode(value: 'mealPlan'),
  typeCondition: TypeConditionNode(
      on: NamedTypeNode(
    name: NameNode(value: 'Canteen'),
    isNonNull: false,
  )),
  directives: [],
  selectionSet: SelectionSetNode(selections: [
    FieldNode(
      name: NameNode(value: 'lines'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FieldNode(
          name: NameNode(value: 'id'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'name'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'canteen'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: SelectionSetNode(selections: [
            FragmentSpreadNode(
              name: NameNode(value: 'canteen'),
              directives: [],
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
        FieldNode(
          name: NameNode(value: 'meals'),
          alias: null,
          arguments: [
            ArgumentNode(
              name: NameNode(value: 'date'),
              value: VariableNode(name: NameNode(value: 'date')),
            )
          ],
          directives: [],
          selectionSet: SelectionSetNode(selections: [
            FragmentSpreadNode(
              name: NameNode(value: 'mealInfo'),
              directives: [],
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
        FieldNode(
          name: NameNode(value: '__typename'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
      ]),
    ),
    FieldNode(
      name: NameNode(value: '__typename'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
  ]),
);
const documentNodeFragmentmealPlan = DocumentNode(definitions: [
  fragmentDefinitionmealPlan,
  fragmentDefinitioncanteen,
  fragmentDefinitionmealInfo,
  fragmentDefinitionprice,
  fragmentDefinitionnutritionData,
]);

extension ClientExtension$Fragment$mealPlan on graphql.GraphQLClient {
  void writeFragment$mealPlan({
    required Fragment$mealPlan data,
    required Map<String, dynamic> idFields,
    required Variables$Fragment$mealPlan variables,
    bool broadcast = true,
  }) =>
      this.writeFragment(
        graphql.FragmentRequest(
          idFields: idFields,
          fragment: const graphql.Fragment(
            fragmentName: 'mealPlan',
            document: documentNodeFragmentmealPlan,
          ),
          variables: variables.toJson(),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );
  Fragment$mealPlan? readFragment$mealPlan({
    required Map<String, dynamic> idFields,
    required Variables$Fragment$mealPlan variables,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'mealPlan',
          document: documentNodeFragmentmealPlan,
        ),
        variables: variables.toJson(),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$mealPlan.fromJson(result);
  }
}

class Fragment$mealPlan$lines {
  Fragment$mealPlan$lines({
    required this.id,
    required this.name,
    required this.canteen,
    this.meals,
    this.$__typename = 'Line',
  });

  factory Fragment$mealPlan$lines.fromJson(Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$name = json['name'];
    final l$canteen = json['canteen'];
    final l$meals = json['meals'];
    final l$$__typename = json['__typename'];
    return Fragment$mealPlan$lines(
      id: (l$id as String),
      name: (l$name as String),
      canteen: Fragment$canteen.fromJson((l$canteen as Map<String, dynamic>)),
      meals: (l$meals as List<dynamic>?)
          ?.map((e) => Fragment$mealInfo.fromJson((e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final String id;

  final String name;

  final Fragment$canteen canteen;

  final List<Fragment$mealInfo>? meals;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$name = name;
    _resultData['name'] = l$name;
    final l$canteen = canteen;
    _resultData['canteen'] = l$canteen.toJson();
    final l$meals = meals;
    _resultData['meals'] = l$meals?.map((e) => e.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$name = name;
    final l$canteen = canteen;
    final l$meals = meals;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$name,
      l$canteen,
      l$meals == null ? null : Object.hashAll(l$meals.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (!(other is Fragment$mealPlan$lines) ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
      return false;
    }
    final l$canteen = canteen;
    final lOther$canteen = other.canteen;
    if (l$canteen != lOther$canteen) {
      return false;
    }
    final l$meals = meals;
    final lOther$meals = other.meals;
    if (l$meals != null && lOther$meals != null) {
      if (l$meals.length != lOther$meals.length) {
        return false;
      }
      for (int i = 0; i < l$meals.length; i++) {
        final l$meals$entry = l$meals[i];
        final lOther$meals$entry = lOther$meals[i];
        if (l$meals$entry != lOther$meals$entry) {
          return false;
        }
      }
    } else if (l$meals != lOther$meals) {
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

extension UtilityExtension$Fragment$mealPlan$lines on Fragment$mealPlan$lines {
  CopyWith$Fragment$mealPlan$lines<Fragment$mealPlan$lines> get copyWith =>
      CopyWith$Fragment$mealPlan$lines(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Fragment$mealPlan$lines<TRes> {
  factory CopyWith$Fragment$mealPlan$lines(
    Fragment$mealPlan$lines instance,
    TRes Function(Fragment$mealPlan$lines) then,
  ) = _CopyWithImpl$Fragment$mealPlan$lines;

  factory CopyWith$Fragment$mealPlan$lines.stub(TRes res) =
      _CopyWithStubImpl$Fragment$mealPlan$lines;

  TRes call({
    String? id,
    String? name,
    Fragment$canteen? canteen,
    List<Fragment$mealInfo>? meals,
    String? $__typename,
  });
  CopyWith$Fragment$canteen<TRes> get canteen;
  TRes meals(
      Iterable<Fragment$mealInfo>? Function(
              Iterable<CopyWith$Fragment$mealInfo<Fragment$mealInfo>>?)
          _fn);
}

class _CopyWithImpl$Fragment$mealPlan$lines<TRes>
    implements CopyWith$Fragment$mealPlan$lines<TRes> {
  _CopyWithImpl$Fragment$mealPlan$lines(
    this._instance,
    this._then,
  );

  final Fragment$mealPlan$lines _instance;

  final TRes Function(Fragment$mealPlan$lines) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? name = _undefined,
    Object? canteen = _undefined,
    Object? meals = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$mealPlan$lines(
        id: id == _undefined || id == null ? _instance.id : (id as String),
        name: name == _undefined || name == null
            ? _instance.name
            : (name as String),
        canteen: canteen == _undefined || canteen == null
            ? _instance.canteen
            : (canteen as Fragment$canteen),
        meals: meals == _undefined
            ? _instance.meals
            : (meals as List<Fragment$mealInfo>?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Fragment$canteen<TRes> get canteen {
    final local$canteen = _instance.canteen;
    return CopyWith$Fragment$canteen(local$canteen, (e) => call(canteen: e));
  }

  TRes meals(
          Iterable<Fragment$mealInfo>? Function(
                  Iterable<CopyWith$Fragment$mealInfo<Fragment$mealInfo>>?)
              _fn) =>
      call(
          meals: _fn(_instance.meals?.map((e) => CopyWith$Fragment$mealInfo(
                e,
                (i) => i,
              )))?.toList());
}

class _CopyWithStubImpl$Fragment$mealPlan$lines<TRes>
    implements CopyWith$Fragment$mealPlan$lines<TRes> {
  _CopyWithStubImpl$Fragment$mealPlan$lines(this._res);

  TRes _res;

  call({
    String? id,
    String? name,
    Fragment$canteen? canteen,
    List<Fragment$mealInfo>? meals,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$canteen<TRes> get canteen =>
      CopyWith$Fragment$canteen.stub(_res);

  meals(_fn) => _res;
}

class Fragment$mealInfo {
  Fragment$mealInfo({
    required this.id,
    required this.name,
    required this.mealType,
    required this.price,
    required this.allergens,
    required this.additives,
    this.nutritionData,
    required this.statistics,
    required this.ratings,
    required this.images,
    required this.sides,
    this.$__typename = 'Meal',
  });

  factory Fragment$mealInfo.fromJson(Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$name = json['name'];
    final l$mealType = json['mealType'];
    final l$price = json['price'];
    final l$allergens = json['allergens'];
    final l$additives = json['additives'];
    final l$nutritionData = json['nutritionData'];
    final l$statistics = json['statistics'];
    final l$ratings = json['ratings'];
    final l$images = json['images'];
    final l$sides = json['sides'];
    final l$$__typename = json['__typename'];
    return Fragment$mealInfo(
      id: (l$id as String),
      name: (l$name as String),
      mealType: fromJson$Enum$FoodType((l$mealType as String)),
      price: Fragment$price.fromJson((l$price as Map<String, dynamic>)),
      allergens: (l$allergens as List<dynamic>)
          .map((e) => fromJson$Enum$Allergen((e as String)))
          .toList(),
      additives: (l$additives as List<dynamic>)
          .map((e) => fromJson$Enum$Additive((e as String)))
          .toList(),
      nutritionData: l$nutritionData == null
          ? null
          : Fragment$nutritionData.fromJson(
              (l$nutritionData as Map<String, dynamic>)),
      statistics: Fragment$mealInfo$statistics.fromJson(
          (l$statistics as Map<String, dynamic>)),
      ratings: Fragment$mealInfo$ratings.fromJson(
          (l$ratings as Map<String, dynamic>)),
      images: (l$images as List<dynamic>)
          .map((e) =>
              Fragment$mealInfo$images.fromJson((e as Map<String, dynamic>)))
          .toList(),
      sides: (l$sides as List<dynamic>)
          .map((e) =>
              Fragment$mealInfo$sides.fromJson((e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final String id;

  final String name;

  final Enum$FoodType mealType;

  final Fragment$price price;

  final List<Enum$Allergen> allergens;

  final List<Enum$Additive> additives;

  final Fragment$nutritionData? nutritionData;

  final Fragment$mealInfo$statistics statistics;

  final Fragment$mealInfo$ratings ratings;

  final List<Fragment$mealInfo$images> images;

  final List<Fragment$mealInfo$sides> sides;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$name = name;
    _resultData['name'] = l$name;
    final l$mealType = mealType;
    _resultData['mealType'] = toJson$Enum$FoodType(l$mealType);
    final l$price = price;
    _resultData['price'] = l$price.toJson();
    final l$allergens = allergens;
    _resultData['allergens'] =
        l$allergens.map((e) => toJson$Enum$Allergen(e)).toList();
    final l$additives = additives;
    _resultData['additives'] =
        l$additives.map((e) => toJson$Enum$Additive(e)).toList();
    final l$nutritionData = nutritionData;
    _resultData['nutritionData'] = l$nutritionData?.toJson();
    final l$statistics = statistics;
    _resultData['statistics'] = l$statistics.toJson();
    final l$ratings = ratings;
    _resultData['ratings'] = l$ratings.toJson();
    final l$images = images;
    _resultData['images'] = l$images.map((e) => e.toJson()).toList();
    final l$sides = sides;
    _resultData['sides'] = l$sides.map((e) => e.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$name = name;
    final l$mealType = mealType;
    final l$price = price;
    final l$allergens = allergens;
    final l$additives = additives;
    final l$nutritionData = nutritionData;
    final l$statistics = statistics;
    final l$ratings = ratings;
    final l$images = images;
    final l$sides = sides;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$name,
      l$mealType,
      l$price,
      Object.hashAll(l$allergens.map((v) => v)),
      Object.hashAll(l$additives.map((v) => v)),
      l$nutritionData,
      l$statistics,
      l$ratings,
      Object.hashAll(l$images.map((v) => v)),
      Object.hashAll(l$sides.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (!(other is Fragment$mealInfo) || runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
      return false;
    }
    final l$mealType = mealType;
    final lOther$mealType = other.mealType;
    if (l$mealType != lOther$mealType) {
      return false;
    }
    final l$price = price;
    final lOther$price = other.price;
    if (l$price != lOther$price) {
      return false;
    }
    final l$allergens = allergens;
    final lOther$allergens = other.allergens;
    if (l$allergens.length != lOther$allergens.length) {
      return false;
    }
    for (int i = 0; i < l$allergens.length; i++) {
      final l$allergens$entry = l$allergens[i];
      final lOther$allergens$entry = lOther$allergens[i];
      if (l$allergens$entry != lOther$allergens$entry) {
        return false;
      }
    }
    final l$additives = additives;
    final lOther$additives = other.additives;
    if (l$additives.length != lOther$additives.length) {
      return false;
    }
    for (int i = 0; i < l$additives.length; i++) {
      final l$additives$entry = l$additives[i];
      final lOther$additives$entry = lOther$additives[i];
      if (l$additives$entry != lOther$additives$entry) {
        return false;
      }
    }
    final l$nutritionData = nutritionData;
    final lOther$nutritionData = other.nutritionData;
    if (l$nutritionData != lOther$nutritionData) {
      return false;
    }
    final l$statistics = statistics;
    final lOther$statistics = other.statistics;
    if (l$statistics != lOther$statistics) {
      return false;
    }
    final l$ratings = ratings;
    final lOther$ratings = other.ratings;
    if (l$ratings != lOther$ratings) {
      return false;
    }
    final l$images = images;
    final lOther$images = other.images;
    if (l$images.length != lOther$images.length) {
      return false;
    }
    for (int i = 0; i < l$images.length; i++) {
      final l$images$entry = l$images[i];
      final lOther$images$entry = lOther$images[i];
      if (l$images$entry != lOther$images$entry) {
        return false;
      }
    }
    final l$sides = sides;
    final lOther$sides = other.sides;
    if (l$sides.length != lOther$sides.length) {
      return false;
    }
    for (int i = 0; i < l$sides.length; i++) {
      final l$sides$entry = l$sides[i];
      final lOther$sides$entry = lOther$sides[i];
      if (l$sides$entry != lOther$sides$entry) {
        return false;
      }
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Fragment$mealInfo on Fragment$mealInfo {
  CopyWith$Fragment$mealInfo<Fragment$mealInfo> get copyWith =>
      CopyWith$Fragment$mealInfo(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Fragment$mealInfo<TRes> {
  factory CopyWith$Fragment$mealInfo(
    Fragment$mealInfo instance,
    TRes Function(Fragment$mealInfo) then,
  ) = _CopyWithImpl$Fragment$mealInfo;

  factory CopyWith$Fragment$mealInfo.stub(TRes res) =
      _CopyWithStubImpl$Fragment$mealInfo;

  TRes call({
    String? id,
    String? name,
    Enum$FoodType? mealType,
    Fragment$price? price,
    List<Enum$Allergen>? allergens,
    List<Enum$Additive>? additives,
    Fragment$nutritionData? nutritionData,
    Fragment$mealInfo$statistics? statistics,
    Fragment$mealInfo$ratings? ratings,
    List<Fragment$mealInfo$images>? images,
    List<Fragment$mealInfo$sides>? sides,
    String? $__typename,
  });
  CopyWith$Fragment$price<TRes> get price;
  CopyWith$Fragment$nutritionData<TRes> get nutritionData;
  CopyWith$Fragment$mealInfo$statistics<TRes> get statistics;
  CopyWith$Fragment$mealInfo$ratings<TRes> get ratings;
  TRes images(
      Iterable<Fragment$mealInfo$images> Function(
              Iterable<
                  CopyWith$Fragment$mealInfo$images<Fragment$mealInfo$images>>)
          _fn);
  TRes sides(
      Iterable<Fragment$mealInfo$sides> Function(
              Iterable<
                  CopyWith$Fragment$mealInfo$sides<Fragment$mealInfo$sides>>)
          _fn);
}

class _CopyWithImpl$Fragment$mealInfo<TRes>
    implements CopyWith$Fragment$mealInfo<TRes> {
  _CopyWithImpl$Fragment$mealInfo(
    this._instance,
    this._then,
  );

  final Fragment$mealInfo _instance;

  final TRes Function(Fragment$mealInfo) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? name = _undefined,
    Object? mealType = _undefined,
    Object? price = _undefined,
    Object? allergens = _undefined,
    Object? additives = _undefined,
    Object? nutritionData = _undefined,
    Object? statistics = _undefined,
    Object? ratings = _undefined,
    Object? images = _undefined,
    Object? sides = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$mealInfo(
        id: id == _undefined || id == null ? _instance.id : (id as String),
        name: name == _undefined || name == null
            ? _instance.name
            : (name as String),
        mealType: mealType == _undefined || mealType == null
            ? _instance.mealType
            : (mealType as Enum$FoodType),
        price: price == _undefined || price == null
            ? _instance.price
            : (price as Fragment$price),
        allergens: allergens == _undefined || allergens == null
            ? _instance.allergens
            : (allergens as List<Enum$Allergen>),
        additives: additives == _undefined || additives == null
            ? _instance.additives
            : (additives as List<Enum$Additive>),
        nutritionData: nutritionData == _undefined
            ? _instance.nutritionData
            : (nutritionData as Fragment$nutritionData?),
        statistics: statistics == _undefined || statistics == null
            ? _instance.statistics
            : (statistics as Fragment$mealInfo$statistics),
        ratings: ratings == _undefined || ratings == null
            ? _instance.ratings
            : (ratings as Fragment$mealInfo$ratings),
        images: images == _undefined || images == null
            ? _instance.images
            : (images as List<Fragment$mealInfo$images>),
        sides: sides == _undefined || sides == null
            ? _instance.sides
            : (sides as List<Fragment$mealInfo$sides>),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Fragment$price<TRes> get price {
    final local$price = _instance.price;
    return CopyWith$Fragment$price(local$price, (e) => call(price: e));
  }

  CopyWith$Fragment$nutritionData<TRes> get nutritionData {
    final local$nutritionData = _instance.nutritionData;
    return local$nutritionData == null
        ? CopyWith$Fragment$nutritionData.stub(_then(_instance))
        : CopyWith$Fragment$nutritionData(
            local$nutritionData, (e) => call(nutritionData: e));
  }

  CopyWith$Fragment$mealInfo$statistics<TRes> get statistics {
    final local$statistics = _instance.statistics;
    return CopyWith$Fragment$mealInfo$statistics(
        local$statistics, (e) => call(statistics: e));
  }

  CopyWith$Fragment$mealInfo$ratings<TRes> get ratings {
    final local$ratings = _instance.ratings;
    return CopyWith$Fragment$mealInfo$ratings(
        local$ratings, (e) => call(ratings: e));
  }

  TRes images(
          Iterable<Fragment$mealInfo$images> Function(
                  Iterable<
                      CopyWith$Fragment$mealInfo$images<
                          Fragment$mealInfo$images>>)
              _fn) =>
      call(
          images:
              _fn(_instance.images.map((e) => CopyWith$Fragment$mealInfo$images(
                    e,
                    (i) => i,
                  ))).toList());

  TRes sides(
          Iterable<Fragment$mealInfo$sides> Function(
                  Iterable<
                      CopyWith$Fragment$mealInfo$sides<
                          Fragment$mealInfo$sides>>)
              _fn) =>
      call(
          sides:
              _fn(_instance.sides.map((e) => CopyWith$Fragment$mealInfo$sides(
                    e,
                    (i) => i,
                  ))).toList());
}

class _CopyWithStubImpl$Fragment$mealInfo<TRes>
    implements CopyWith$Fragment$mealInfo<TRes> {
  _CopyWithStubImpl$Fragment$mealInfo(this._res);

  TRes _res;

  call({
    String? id,
    String? name,
    Enum$FoodType? mealType,
    Fragment$price? price,
    List<Enum$Allergen>? allergens,
    List<Enum$Additive>? additives,
    Fragment$nutritionData? nutritionData,
    Fragment$mealInfo$statistics? statistics,
    Fragment$mealInfo$ratings? ratings,
    List<Fragment$mealInfo$images>? images,
    List<Fragment$mealInfo$sides>? sides,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$price<TRes> get price => CopyWith$Fragment$price.stub(_res);

  CopyWith$Fragment$nutritionData<TRes> get nutritionData =>
      CopyWith$Fragment$nutritionData.stub(_res);

  CopyWith$Fragment$mealInfo$statistics<TRes> get statistics =>
      CopyWith$Fragment$mealInfo$statistics.stub(_res);

  CopyWith$Fragment$mealInfo$ratings<TRes> get ratings =>
      CopyWith$Fragment$mealInfo$ratings.stub(_res);

  images(_fn) => _res;

  sides(_fn) => _res;
}

const fragmentDefinitionmealInfo = FragmentDefinitionNode(
  name: NameNode(value: 'mealInfo'),
  typeCondition: TypeConditionNode(
      on: NamedTypeNode(
    name: NameNode(value: 'Meal'),
    isNonNull: false,
  )),
  directives: [],
  selectionSet: SelectionSetNode(selections: [
    FieldNode(
      name: NameNode(value: 'id'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'name'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'mealType'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'price'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FragmentSpreadNode(
          name: NameNode(value: 'price'),
          directives: [],
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
    FieldNode(
      name: NameNode(value: 'allergens'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'additives'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'nutritionData'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FragmentSpreadNode(
          name: NameNode(value: 'nutritionData'),
          directives: [],
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
    FieldNode(
      name: NameNode(value: 'statistics'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FieldNode(
          name: NameNode(value: 'lastServed'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'nextServed'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'frequency'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'new'),
          alias: null,
          arguments: [],
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
    FieldNode(
      name: NameNode(value: 'ratings'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FieldNode(
          name: NameNode(value: 'averageRating'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'personalRating'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'ratingsCount'),
          alias: null,
          arguments: [],
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
    FieldNode(
      name: NameNode(value: 'images'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FieldNode(
          name: NameNode(value: 'id'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'url'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'rank'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'personalDownvote'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'personalUpvote'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'downvotes'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'upvotes'),
          alias: null,
          arguments: [],
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
    FieldNode(
      name: NameNode(value: 'sides'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: SelectionSetNode(selections: [
        FieldNode(
          name: NameNode(value: 'id'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'name'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'additives'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'allergens'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: null,
        ),
        FieldNode(
          name: NameNode(value: 'price'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: SelectionSetNode(selections: [
            FragmentSpreadNode(
              name: NameNode(value: 'price'),
              directives: [],
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
        FieldNode(
          name: NameNode(value: 'nutritionData'),
          alias: null,
          arguments: [],
          directives: [],
          selectionSet: SelectionSetNode(selections: [
            FragmentSpreadNode(
              name: NameNode(value: 'nutritionData'),
              directives: [],
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
        FieldNode(
          name: NameNode(value: 'mealType'),
          alias: null,
          arguments: [],
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
    FieldNode(
      name: NameNode(value: '__typename'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
  ]),
);
const documentNodeFragmentmealInfo = DocumentNode(definitions: [
  fragmentDefinitionmealInfo,
  fragmentDefinitionprice,
  fragmentDefinitionnutritionData,
]);

extension ClientExtension$Fragment$mealInfo on graphql.GraphQLClient {
  void writeFragment$mealInfo({
    required Fragment$mealInfo data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) =>
      this.writeFragment(
        graphql.FragmentRequest(
          idFields: idFields,
          fragment: const graphql.Fragment(
            fragmentName: 'mealInfo',
            document: documentNodeFragmentmealInfo,
          ),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );
  Fragment$mealInfo? readFragment$mealInfo({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'mealInfo',
          document: documentNodeFragmentmealInfo,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$mealInfo.fromJson(result);
  }
}

class Fragment$mealInfo$statistics {
  Fragment$mealInfo$statistics({
    this.lastServed,
    this.nextServed,
    required this.frequency,
    required this.$new,
    this.$__typename = 'MealStatistics',
  });

  factory Fragment$mealInfo$statistics.fromJson(Map<String, dynamic> json) {
    final l$lastServed = json['lastServed'];
    final l$nextServed = json['nextServed'];
    final l$frequency = json['frequency'];
    final l$$new = json['new'];
    final l$$__typename = json['__typename'];
    return Fragment$mealInfo$statistics(
      lastServed: (l$lastServed as String?),
      nextServed: (l$nextServed as String?),
      frequency: (l$frequency as int),
      $new: (l$$new as bool),
      $__typename: (l$$__typename as String),
    );
  }

  final String? lastServed;

  final String? nextServed;

  final int frequency;

  final bool $new;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$lastServed = lastServed;
    _resultData['lastServed'] = l$lastServed;
    final l$nextServed = nextServed;
    _resultData['nextServed'] = l$nextServed;
    final l$frequency = frequency;
    _resultData['frequency'] = l$frequency;
    final l$$new = $new;
    _resultData['new'] = l$$new;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$lastServed = lastServed;
    final l$nextServed = nextServed;
    final l$frequency = frequency;
    final l$$new = $new;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$lastServed,
      l$nextServed,
      l$frequency,
      l$$new,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (!(other is Fragment$mealInfo$statistics) ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$lastServed = lastServed;
    final lOther$lastServed = other.lastServed;
    if (l$lastServed != lOther$lastServed) {
      return false;
    }
    final l$nextServed = nextServed;
    final lOther$nextServed = other.nextServed;
    if (l$nextServed != lOther$nextServed) {
      return false;
    }
    final l$frequency = frequency;
    final lOther$frequency = other.frequency;
    if (l$frequency != lOther$frequency) {
      return false;
    }
    final l$$new = $new;
    final lOther$$new = other.$new;
    if (l$$new != lOther$$new) {
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

extension UtilityExtension$Fragment$mealInfo$statistics
    on Fragment$mealInfo$statistics {
  CopyWith$Fragment$mealInfo$statistics<Fragment$mealInfo$statistics>
      get copyWith => CopyWith$Fragment$mealInfo$statistics(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Fragment$mealInfo$statistics<TRes> {
  factory CopyWith$Fragment$mealInfo$statistics(
    Fragment$mealInfo$statistics instance,
    TRes Function(Fragment$mealInfo$statistics) then,
  ) = _CopyWithImpl$Fragment$mealInfo$statistics;

  factory CopyWith$Fragment$mealInfo$statistics.stub(TRes res) =
      _CopyWithStubImpl$Fragment$mealInfo$statistics;

  TRes call({
    String? lastServed,
    String? nextServed,
    int? frequency,
    bool? $new,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$mealInfo$statistics<TRes>
    implements CopyWith$Fragment$mealInfo$statistics<TRes> {
  _CopyWithImpl$Fragment$mealInfo$statistics(
    this._instance,
    this._then,
  );

  final Fragment$mealInfo$statistics _instance;

  final TRes Function(Fragment$mealInfo$statistics) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? lastServed = _undefined,
    Object? nextServed = _undefined,
    Object? frequency = _undefined,
    Object? $new = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$mealInfo$statistics(
        lastServed: lastServed == _undefined
            ? _instance.lastServed
            : (lastServed as String?),
        nextServed: nextServed == _undefined
            ? _instance.nextServed
            : (nextServed as String?),
        frequency: frequency == _undefined || frequency == null
            ? _instance.frequency
            : (frequency as int),
        $new: $new == _undefined || $new == null
            ? _instance.$new
            : ($new as bool),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Fragment$mealInfo$statistics<TRes>
    implements CopyWith$Fragment$mealInfo$statistics<TRes> {
  _CopyWithStubImpl$Fragment$mealInfo$statistics(this._res);

  TRes _res;

  call({
    String? lastServed,
    String? nextServed,
    int? frequency,
    bool? $new,
    String? $__typename,
  }) =>
      _res;
}

class Fragment$mealInfo$ratings {
  Fragment$mealInfo$ratings({
    required this.averageRating,
    this.personalRating,
    required this.ratingsCount,
    this.$__typename = 'Ratings',
  });

  factory Fragment$mealInfo$ratings.fromJson(Map<String, dynamic> json) {
    final l$averageRating = json['averageRating'];
    final l$personalRating = json['personalRating'];
    final l$ratingsCount = json['ratingsCount'];
    final l$$__typename = json['__typename'];
    return Fragment$mealInfo$ratings(
      averageRating: (l$averageRating as num).toDouble(),
      personalRating: (l$personalRating as int?),
      ratingsCount: (l$ratingsCount as int),
      $__typename: (l$$__typename as String),
    );
  }

  final double averageRating;

  final int? personalRating;

  final int ratingsCount;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$averageRating = averageRating;
    _resultData['averageRating'] = l$averageRating;
    final l$personalRating = personalRating;
    _resultData['personalRating'] = l$personalRating;
    final l$ratingsCount = ratingsCount;
    _resultData['ratingsCount'] = l$ratingsCount;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$averageRating = averageRating;
    final l$personalRating = personalRating;
    final l$ratingsCount = ratingsCount;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$averageRating,
      l$personalRating,
      l$ratingsCount,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (!(other is Fragment$mealInfo$ratings) ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$averageRating = averageRating;
    final lOther$averageRating = other.averageRating;
    if (l$averageRating != lOther$averageRating) {
      return false;
    }
    final l$personalRating = personalRating;
    final lOther$personalRating = other.personalRating;
    if (l$personalRating != lOther$personalRating) {
      return false;
    }
    final l$ratingsCount = ratingsCount;
    final lOther$ratingsCount = other.ratingsCount;
    if (l$ratingsCount != lOther$ratingsCount) {
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

extension UtilityExtension$Fragment$mealInfo$ratings
    on Fragment$mealInfo$ratings {
  CopyWith$Fragment$mealInfo$ratings<Fragment$mealInfo$ratings> get copyWith =>
      CopyWith$Fragment$mealInfo$ratings(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Fragment$mealInfo$ratings<TRes> {
  factory CopyWith$Fragment$mealInfo$ratings(
    Fragment$mealInfo$ratings instance,
    TRes Function(Fragment$mealInfo$ratings) then,
  ) = _CopyWithImpl$Fragment$mealInfo$ratings;

  factory CopyWith$Fragment$mealInfo$ratings.stub(TRes res) =
      _CopyWithStubImpl$Fragment$mealInfo$ratings;

  TRes call({
    double? averageRating,
    int? personalRating,
    int? ratingsCount,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$mealInfo$ratings<TRes>
    implements CopyWith$Fragment$mealInfo$ratings<TRes> {
  _CopyWithImpl$Fragment$mealInfo$ratings(
    this._instance,
    this._then,
  );

  final Fragment$mealInfo$ratings _instance;

  final TRes Function(Fragment$mealInfo$ratings) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? averageRating = _undefined,
    Object? personalRating = _undefined,
    Object? ratingsCount = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$mealInfo$ratings(
        averageRating: averageRating == _undefined || averageRating == null
            ? _instance.averageRating
            : (averageRating as double),
        personalRating: personalRating == _undefined
            ? _instance.personalRating
            : (personalRating as int?),
        ratingsCount: ratingsCount == _undefined || ratingsCount == null
            ? _instance.ratingsCount
            : (ratingsCount as int),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Fragment$mealInfo$ratings<TRes>
    implements CopyWith$Fragment$mealInfo$ratings<TRes> {
  _CopyWithStubImpl$Fragment$mealInfo$ratings(this._res);

  TRes _res;

  call({
    double? averageRating,
    int? personalRating,
    int? ratingsCount,
    String? $__typename,
  }) =>
      _res;
}

class Fragment$mealInfo$images {
  Fragment$mealInfo$images({
    required this.id,
    required this.url,
    required this.rank,
    required this.personalDownvote,
    required this.personalUpvote,
    required this.downvotes,
    required this.upvotes,
    this.$__typename = 'Image',
  });

  factory Fragment$mealInfo$images.fromJson(Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$url = json['url'];
    final l$rank = json['rank'];
    final l$personalDownvote = json['personalDownvote'];
    final l$personalUpvote = json['personalUpvote'];
    final l$downvotes = json['downvotes'];
    final l$upvotes = json['upvotes'];
    final l$$__typename = json['__typename'];
    return Fragment$mealInfo$images(
      id: (l$id as String),
      url: (l$url as String),
      rank: (l$rank as num).toDouble(),
      personalDownvote: (l$personalDownvote as bool),
      personalUpvote: (l$personalUpvote as bool),
      downvotes: (l$downvotes as int),
      upvotes: (l$upvotes as int),
      $__typename: (l$$__typename as String),
    );
  }

  final String id;

  final String url;

  final double rank;

  final bool personalDownvote;

  final bool personalUpvote;

  final int downvotes;

  final int upvotes;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$url = url;
    _resultData['url'] = l$url;
    final l$rank = rank;
    _resultData['rank'] = l$rank;
    final l$personalDownvote = personalDownvote;
    _resultData['personalDownvote'] = l$personalDownvote;
    final l$personalUpvote = personalUpvote;
    _resultData['personalUpvote'] = l$personalUpvote;
    final l$downvotes = downvotes;
    _resultData['downvotes'] = l$downvotes;
    final l$upvotes = upvotes;
    _resultData['upvotes'] = l$upvotes;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$url = url;
    final l$rank = rank;
    final l$personalDownvote = personalDownvote;
    final l$personalUpvote = personalUpvote;
    final l$downvotes = downvotes;
    final l$upvotes = upvotes;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$url,
      l$rank,
      l$personalDownvote,
      l$personalUpvote,
      l$downvotes,
      l$upvotes,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (!(other is Fragment$mealInfo$images) ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$url = url;
    final lOther$url = other.url;
    if (l$url != lOther$url) {
      return false;
    }
    final l$rank = rank;
    final lOther$rank = other.rank;
    if (l$rank != lOther$rank) {
      return false;
    }
    final l$personalDownvote = personalDownvote;
    final lOther$personalDownvote = other.personalDownvote;
    if (l$personalDownvote != lOther$personalDownvote) {
      return false;
    }
    final l$personalUpvote = personalUpvote;
    final lOther$personalUpvote = other.personalUpvote;
    if (l$personalUpvote != lOther$personalUpvote) {
      return false;
    }
    final l$downvotes = downvotes;
    final lOther$downvotes = other.downvotes;
    if (l$downvotes != lOther$downvotes) {
      return false;
    }
    final l$upvotes = upvotes;
    final lOther$upvotes = other.upvotes;
    if (l$upvotes != lOther$upvotes) {
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

extension UtilityExtension$Fragment$mealInfo$images
    on Fragment$mealInfo$images {
  CopyWith$Fragment$mealInfo$images<Fragment$mealInfo$images> get copyWith =>
      CopyWith$Fragment$mealInfo$images(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Fragment$mealInfo$images<TRes> {
  factory CopyWith$Fragment$mealInfo$images(
    Fragment$mealInfo$images instance,
    TRes Function(Fragment$mealInfo$images) then,
  ) = _CopyWithImpl$Fragment$mealInfo$images;

  factory CopyWith$Fragment$mealInfo$images.stub(TRes res) =
      _CopyWithStubImpl$Fragment$mealInfo$images;

  TRes call({
    String? id,
    String? url,
    double? rank,
    bool? personalDownvote,
    bool? personalUpvote,
    int? downvotes,
    int? upvotes,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$mealInfo$images<TRes>
    implements CopyWith$Fragment$mealInfo$images<TRes> {
  _CopyWithImpl$Fragment$mealInfo$images(
    this._instance,
    this._then,
  );

  final Fragment$mealInfo$images _instance;

  final TRes Function(Fragment$mealInfo$images) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? url = _undefined,
    Object? rank = _undefined,
    Object? personalDownvote = _undefined,
    Object? personalUpvote = _undefined,
    Object? downvotes = _undefined,
    Object? upvotes = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$mealInfo$images(
        id: id == _undefined || id == null ? _instance.id : (id as String),
        url: url == _undefined || url == null ? _instance.url : (url as String),
        rank: rank == _undefined || rank == null
            ? _instance.rank
            : (rank as double),
        personalDownvote:
            personalDownvote == _undefined || personalDownvote == null
                ? _instance.personalDownvote
                : (personalDownvote as bool),
        personalUpvote: personalUpvote == _undefined || personalUpvote == null
            ? _instance.personalUpvote
            : (personalUpvote as bool),
        downvotes: downvotes == _undefined || downvotes == null
            ? _instance.downvotes
            : (downvotes as int),
        upvotes: upvotes == _undefined || upvotes == null
            ? _instance.upvotes
            : (upvotes as int),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Fragment$mealInfo$images<TRes>
    implements CopyWith$Fragment$mealInfo$images<TRes> {
  _CopyWithStubImpl$Fragment$mealInfo$images(this._res);

  TRes _res;

  call({
    String? id,
    String? url,
    double? rank,
    bool? personalDownvote,
    bool? personalUpvote,
    int? downvotes,
    int? upvotes,
    String? $__typename,
  }) =>
      _res;
}

class Fragment$mealInfo$sides {
  Fragment$mealInfo$sides({
    required this.id,
    required this.name,
    required this.additives,
    required this.allergens,
    required this.price,
    this.nutritionData,
    required this.mealType,
    this.$__typename = 'Side',
  });

  factory Fragment$mealInfo$sides.fromJson(Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$name = json['name'];
    final l$additives = json['additives'];
    final l$allergens = json['allergens'];
    final l$price = json['price'];
    final l$nutritionData = json['nutritionData'];
    final l$mealType = json['mealType'];
    final l$$__typename = json['__typename'];
    return Fragment$mealInfo$sides(
      id: (l$id as String),
      name: (l$name as String),
      additives: (l$additives as List<dynamic>)
          .map((e) => fromJson$Enum$Additive((e as String)))
          .toList(),
      allergens: (l$allergens as List<dynamic>)
          .map((e) => fromJson$Enum$Allergen((e as String)))
          .toList(),
      price: Fragment$price.fromJson((l$price as Map<String, dynamic>)),
      nutritionData: l$nutritionData == null
          ? null
          : Fragment$nutritionData.fromJson(
              (l$nutritionData as Map<String, dynamic>)),
      mealType: fromJson$Enum$FoodType((l$mealType as String)),
      $__typename: (l$$__typename as String),
    );
  }

  final String id;

  final String name;

  final List<Enum$Additive> additives;

  final List<Enum$Allergen> allergens;

  final Fragment$price price;

  final Fragment$nutritionData? nutritionData;

  final Enum$FoodType mealType;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$name = name;
    _resultData['name'] = l$name;
    final l$additives = additives;
    _resultData['additives'] =
        l$additives.map((e) => toJson$Enum$Additive(e)).toList();
    final l$allergens = allergens;
    _resultData['allergens'] =
        l$allergens.map((e) => toJson$Enum$Allergen(e)).toList();
    final l$price = price;
    _resultData['price'] = l$price.toJson();
    final l$nutritionData = nutritionData;
    _resultData['nutritionData'] = l$nutritionData?.toJson();
    final l$mealType = mealType;
    _resultData['mealType'] = toJson$Enum$FoodType(l$mealType);
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$id = id;
    final l$name = name;
    final l$additives = additives;
    final l$allergens = allergens;
    final l$price = price;
    final l$nutritionData = nutritionData;
    final l$mealType = mealType;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$name,
      Object.hashAll(l$additives.map((v) => v)),
      Object.hashAll(l$allergens.map((v) => v)),
      l$price,
      l$nutritionData,
      l$mealType,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (!(other is Fragment$mealInfo$sides) ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$id = id;
    final lOther$id = other.id;
    if (l$id != lOther$id) {
      return false;
    }
    final l$name = name;
    final lOther$name = other.name;
    if (l$name != lOther$name) {
      return false;
    }
    final l$additives = additives;
    final lOther$additives = other.additives;
    if (l$additives.length != lOther$additives.length) {
      return false;
    }
    for (int i = 0; i < l$additives.length; i++) {
      final l$additives$entry = l$additives[i];
      final lOther$additives$entry = lOther$additives[i];
      if (l$additives$entry != lOther$additives$entry) {
        return false;
      }
    }
    final l$allergens = allergens;
    final lOther$allergens = other.allergens;
    if (l$allergens.length != lOther$allergens.length) {
      return false;
    }
    for (int i = 0; i < l$allergens.length; i++) {
      final l$allergens$entry = l$allergens[i];
      final lOther$allergens$entry = lOther$allergens[i];
      if (l$allergens$entry != lOther$allergens$entry) {
        return false;
      }
    }
    final l$price = price;
    final lOther$price = other.price;
    if (l$price != lOther$price) {
      return false;
    }
    final l$nutritionData = nutritionData;
    final lOther$nutritionData = other.nutritionData;
    if (l$nutritionData != lOther$nutritionData) {
      return false;
    }
    final l$mealType = mealType;
    final lOther$mealType = other.mealType;
    if (l$mealType != lOther$mealType) {
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

extension UtilityExtension$Fragment$mealInfo$sides on Fragment$mealInfo$sides {
  CopyWith$Fragment$mealInfo$sides<Fragment$mealInfo$sides> get copyWith =>
      CopyWith$Fragment$mealInfo$sides(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Fragment$mealInfo$sides<TRes> {
  factory CopyWith$Fragment$mealInfo$sides(
    Fragment$mealInfo$sides instance,
    TRes Function(Fragment$mealInfo$sides) then,
  ) = _CopyWithImpl$Fragment$mealInfo$sides;

  factory CopyWith$Fragment$mealInfo$sides.stub(TRes res) =
      _CopyWithStubImpl$Fragment$mealInfo$sides;

  TRes call({
    String? id,
    String? name,
    List<Enum$Additive>? additives,
    List<Enum$Allergen>? allergens,
    Fragment$price? price,
    Fragment$nutritionData? nutritionData,
    Enum$FoodType? mealType,
    String? $__typename,
  });
  CopyWith$Fragment$price<TRes> get price;
  CopyWith$Fragment$nutritionData<TRes> get nutritionData;
}

class _CopyWithImpl$Fragment$mealInfo$sides<TRes>
    implements CopyWith$Fragment$mealInfo$sides<TRes> {
  _CopyWithImpl$Fragment$mealInfo$sides(
    this._instance,
    this._then,
  );

  final Fragment$mealInfo$sides _instance;

  final TRes Function(Fragment$mealInfo$sides) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? name = _undefined,
    Object? additives = _undefined,
    Object? allergens = _undefined,
    Object? price = _undefined,
    Object? nutritionData = _undefined,
    Object? mealType = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$mealInfo$sides(
        id: id == _undefined || id == null ? _instance.id : (id as String),
        name: name == _undefined || name == null
            ? _instance.name
            : (name as String),
        additives: additives == _undefined || additives == null
            ? _instance.additives
            : (additives as List<Enum$Additive>),
        allergens: allergens == _undefined || allergens == null
            ? _instance.allergens
            : (allergens as List<Enum$Allergen>),
        price: price == _undefined || price == null
            ? _instance.price
            : (price as Fragment$price),
        nutritionData: nutritionData == _undefined
            ? _instance.nutritionData
            : (nutritionData as Fragment$nutritionData?),
        mealType: mealType == _undefined || mealType == null
            ? _instance.mealType
            : (mealType as Enum$FoodType),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Fragment$price<TRes> get price {
    final local$price = _instance.price;
    return CopyWith$Fragment$price(local$price, (e) => call(price: e));
  }

  CopyWith$Fragment$nutritionData<TRes> get nutritionData {
    final local$nutritionData = _instance.nutritionData;
    return local$nutritionData == null
        ? CopyWith$Fragment$nutritionData.stub(_then(_instance))
        : CopyWith$Fragment$nutritionData(
            local$nutritionData, (e) => call(nutritionData: e));
  }
}

class _CopyWithStubImpl$Fragment$mealInfo$sides<TRes>
    implements CopyWith$Fragment$mealInfo$sides<TRes> {
  _CopyWithStubImpl$Fragment$mealInfo$sides(this._res);

  TRes _res;

  call({
    String? id,
    String? name,
    List<Enum$Additive>? additives,
    List<Enum$Allergen>? allergens,
    Fragment$price? price,
    Fragment$nutritionData? nutritionData,
    Enum$FoodType? mealType,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$price<TRes> get price => CopyWith$Fragment$price.stub(_res);

  CopyWith$Fragment$nutritionData<TRes> get nutritionData =>
      CopyWith$Fragment$nutritionData.stub(_res);
}

class Fragment$price {
  Fragment$price({
    required this.employee,
    required this.guest,
    required this.pupil,
    required this.student,
    this.$__typename = 'Price',
  });

  factory Fragment$price.fromJson(Map<String, dynamic> json) {
    final l$employee = json['employee'];
    final l$guest = json['guest'];
    final l$pupil = json['pupil'];
    final l$student = json['student'];
    final l$$__typename = json['__typename'];
    return Fragment$price(
      employee: (l$employee as int),
      guest: (l$guest as int),
      pupil: (l$pupil as int),
      student: (l$student as int),
      $__typename: (l$$__typename as String),
    );
  }

  final int employee;

  final int guest;

  final int pupil;

  final int student;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$employee = employee;
    _resultData['employee'] = l$employee;
    final l$guest = guest;
    _resultData['guest'] = l$guest;
    final l$pupil = pupil;
    _resultData['pupil'] = l$pupil;
    final l$student = student;
    _resultData['student'] = l$student;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$employee = employee;
    final l$guest = guest;
    final l$pupil = pupil;
    final l$student = student;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$employee,
      l$guest,
      l$pupil,
      l$student,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (!(other is Fragment$price) || runtimeType != other.runtimeType) {
      return false;
    }
    final l$employee = employee;
    final lOther$employee = other.employee;
    if (l$employee != lOther$employee) {
      return false;
    }
    final l$guest = guest;
    final lOther$guest = other.guest;
    if (l$guest != lOther$guest) {
      return false;
    }
    final l$pupil = pupil;
    final lOther$pupil = other.pupil;
    if (l$pupil != lOther$pupil) {
      return false;
    }
    final l$student = student;
    final lOther$student = other.student;
    if (l$student != lOther$student) {
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

extension UtilityExtension$Fragment$price on Fragment$price {
  CopyWith$Fragment$price<Fragment$price> get copyWith =>
      CopyWith$Fragment$price(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Fragment$price<TRes> {
  factory CopyWith$Fragment$price(
    Fragment$price instance,
    TRes Function(Fragment$price) then,
  ) = _CopyWithImpl$Fragment$price;

  factory CopyWith$Fragment$price.stub(TRes res) =
      _CopyWithStubImpl$Fragment$price;

  TRes call({
    int? employee,
    int? guest,
    int? pupil,
    int? student,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$price<TRes>
    implements CopyWith$Fragment$price<TRes> {
  _CopyWithImpl$Fragment$price(
    this._instance,
    this._then,
  );

  final Fragment$price _instance;

  final TRes Function(Fragment$price) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? employee = _undefined,
    Object? guest = _undefined,
    Object? pupil = _undefined,
    Object? student = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$price(
        employee: employee == _undefined || employee == null
            ? _instance.employee
            : (employee as int),
        guest: guest == _undefined || guest == null
            ? _instance.guest
            : (guest as int),
        pupil: pupil == _undefined || pupil == null
            ? _instance.pupil
            : (pupil as int),
        student: student == _undefined || student == null
            ? _instance.student
            : (student as int),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Fragment$price<TRes>
    implements CopyWith$Fragment$price<TRes> {
  _CopyWithStubImpl$Fragment$price(this._res);

  TRes _res;

  call({
    int? employee,
    int? guest,
    int? pupil,
    int? student,
    String? $__typename,
  }) =>
      _res;
}

const fragmentDefinitionprice = FragmentDefinitionNode(
  name: NameNode(value: 'price'),
  typeCondition: TypeConditionNode(
      on: NamedTypeNode(
    name: NameNode(value: 'Price'),
    isNonNull: false,
  )),
  directives: [],
  selectionSet: SelectionSetNode(selections: [
    FieldNode(
      name: NameNode(value: 'employee'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'guest'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'pupil'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'student'),
      alias: null,
      arguments: [],
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
);
const documentNodeFragmentprice = DocumentNode(definitions: [
  fragmentDefinitionprice,
]);

extension ClientExtension$Fragment$price on graphql.GraphQLClient {
  void writeFragment$price({
    required Fragment$price data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) =>
      this.writeFragment(
        graphql.FragmentRequest(
          idFields: idFields,
          fragment: const graphql.Fragment(
            fragmentName: 'price',
            document: documentNodeFragmentprice,
          ),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );
  Fragment$price? readFragment$price({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'price',
          document: documentNodeFragmentprice,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$price.fromJson(result);
  }
}

class Fragment$nutritionData {
  Fragment$nutritionData({
    required this.energy,
    required this.protein,
    required this.carbohydrates,
    required this.sugar,
    required this.fat,
    required this.saturatedFat,
    required this.salt,
    this.$__typename = 'NutritionData',
  });

  factory Fragment$nutritionData.fromJson(Map<String, dynamic> json) {
    final l$energy = json['energy'];
    final l$protein = json['protein'];
    final l$carbohydrates = json['carbohydrates'];
    final l$sugar = json['sugar'];
    final l$fat = json['fat'];
    final l$saturatedFat = json['saturatedFat'];
    final l$salt = json['salt'];
    final l$$__typename = json['__typename'];
    return Fragment$nutritionData(
      energy: (l$energy as int),
      protein: (l$protein as int),
      carbohydrates: (l$carbohydrates as int),
      sugar: (l$sugar as int),
      fat: (l$fat as int),
      saturatedFat: (l$saturatedFat as int),
      salt: (l$salt as int),
      $__typename: (l$$__typename as String),
    );
  }

  final int energy;

  final int protein;

  final int carbohydrates;

  final int sugar;

  final int fat;

  final int saturatedFat;

  final int salt;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$energy = energy;
    _resultData['energy'] = l$energy;
    final l$protein = protein;
    _resultData['protein'] = l$protein;
    final l$carbohydrates = carbohydrates;
    _resultData['carbohydrates'] = l$carbohydrates;
    final l$sugar = sugar;
    _resultData['sugar'] = l$sugar;
    final l$fat = fat;
    _resultData['fat'] = l$fat;
    final l$saturatedFat = saturatedFat;
    _resultData['saturatedFat'] = l$saturatedFat;
    final l$salt = salt;
    _resultData['salt'] = l$salt;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$energy = energy;
    final l$protein = protein;
    final l$carbohydrates = carbohydrates;
    final l$sugar = sugar;
    final l$fat = fat;
    final l$saturatedFat = saturatedFat;
    final l$salt = salt;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$energy,
      l$protein,
      l$carbohydrates,
      l$sugar,
      l$fat,
      l$saturatedFat,
      l$salt,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (!(other is Fragment$nutritionData) ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$energy = energy;
    final lOther$energy = other.energy;
    if (l$energy != lOther$energy) {
      return false;
    }
    final l$protein = protein;
    final lOther$protein = other.protein;
    if (l$protein != lOther$protein) {
      return false;
    }
    final l$carbohydrates = carbohydrates;
    final lOther$carbohydrates = other.carbohydrates;
    if (l$carbohydrates != lOther$carbohydrates) {
      return false;
    }
    final l$sugar = sugar;
    final lOther$sugar = other.sugar;
    if (l$sugar != lOther$sugar) {
      return false;
    }
    final l$fat = fat;
    final lOther$fat = other.fat;
    if (l$fat != lOther$fat) {
      return false;
    }
    final l$saturatedFat = saturatedFat;
    final lOther$saturatedFat = other.saturatedFat;
    if (l$saturatedFat != lOther$saturatedFat) {
      return false;
    }
    final l$salt = salt;
    final lOther$salt = other.salt;
    if (l$salt != lOther$salt) {
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

extension UtilityExtension$Fragment$nutritionData on Fragment$nutritionData {
  CopyWith$Fragment$nutritionData<Fragment$nutritionData> get copyWith =>
      CopyWith$Fragment$nutritionData(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Fragment$nutritionData<TRes> {
  factory CopyWith$Fragment$nutritionData(
    Fragment$nutritionData instance,
    TRes Function(Fragment$nutritionData) then,
  ) = _CopyWithImpl$Fragment$nutritionData;

  factory CopyWith$Fragment$nutritionData.stub(TRes res) =
      _CopyWithStubImpl$Fragment$nutritionData;

  TRes call({
    int? energy,
    int? protein,
    int? carbohydrates,
    int? sugar,
    int? fat,
    int? saturatedFat,
    int? salt,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$nutritionData<TRes>
    implements CopyWith$Fragment$nutritionData<TRes> {
  _CopyWithImpl$Fragment$nutritionData(
    this._instance,
    this._then,
  );

  final Fragment$nutritionData _instance;

  final TRes Function(Fragment$nutritionData) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? energy = _undefined,
    Object? protein = _undefined,
    Object? carbohydrates = _undefined,
    Object? sugar = _undefined,
    Object? fat = _undefined,
    Object? saturatedFat = _undefined,
    Object? salt = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$nutritionData(
        energy: energy == _undefined || energy == null
            ? _instance.energy
            : (energy as int),
        protein: protein == _undefined || protein == null
            ? _instance.protein
            : (protein as int),
        carbohydrates: carbohydrates == _undefined || carbohydrates == null
            ? _instance.carbohydrates
            : (carbohydrates as int),
        sugar: sugar == _undefined || sugar == null
            ? _instance.sugar
            : (sugar as int),
        fat: fat == _undefined || fat == null ? _instance.fat : (fat as int),
        saturatedFat: saturatedFat == _undefined || saturatedFat == null
            ? _instance.saturatedFat
            : (saturatedFat as int),
        salt:
            salt == _undefined || salt == null ? _instance.salt : (salt as int),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Fragment$nutritionData<TRes>
    implements CopyWith$Fragment$nutritionData<TRes> {
  _CopyWithStubImpl$Fragment$nutritionData(this._res);

  TRes _res;

  call({
    int? energy,
    int? protein,
    int? carbohydrates,
    int? sugar,
    int? fat,
    int? saturatedFat,
    int? salt,
    String? $__typename,
  }) =>
      _res;
}

const fragmentDefinitionnutritionData = FragmentDefinitionNode(
  name: NameNode(value: 'nutritionData'),
  typeCondition: TypeConditionNode(
      on: NamedTypeNode(
    name: NameNode(value: 'NutritionData'),
    isNonNull: false,
  )),
  directives: [],
  selectionSet: SelectionSetNode(selections: [
    FieldNode(
      name: NameNode(value: 'energy'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'protein'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'carbohydrates'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'sugar'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'fat'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'saturatedFat'),
      alias: null,
      arguments: [],
      directives: [],
      selectionSet: null,
    ),
    FieldNode(
      name: NameNode(value: 'salt'),
      alias: null,
      arguments: [],
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
);
const documentNodeFragmentnutritionData = DocumentNode(definitions: [
  fragmentDefinitionnutritionData,
]);

extension ClientExtension$Fragment$nutritionData on graphql.GraphQLClient {
  void writeFragment$nutritionData({
    required Fragment$nutritionData data,
    required Map<String, dynamic> idFields,
    bool broadcast = true,
  }) =>
      this.writeFragment(
        graphql.FragmentRequest(
          idFields: idFields,
          fragment: const graphql.Fragment(
            fragmentName: 'nutritionData',
            document: documentNodeFragmentnutritionData,
          ),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );
  Fragment$nutritionData? readFragment$nutritionData({
    required Map<String, dynamic> idFields,
    bool optimistic = true,
  }) {
    final result = this.readFragment(
      graphql.FragmentRequest(
        idFields: idFields,
        fragment: const graphql.Fragment(
          fragmentName: 'nutritionData',
          document: documentNodeFragmentnutritionData,
        ),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Fragment$nutritionData.fromJson(result);
  }
}

class Variables$Query$GetMealPlanForDay {
  factory Variables$Query$GetMealPlanForDay({required String date}) =>
      Variables$Query$GetMealPlanForDay._({
        r'date': date,
      });

  Variables$Query$GetMealPlanForDay._(this._$data);

  factory Variables$Query$GetMealPlanForDay.fromJson(
      Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$date = data['date'];
    result$data['date'] = (l$date as String);
    return Variables$Query$GetMealPlanForDay._(result$data);
  }

  Map<String, dynamic> _$data;

  String get date => (_$data['date'] as String);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$date = date;
    result$data['date'] = l$date;
    return result$data;
  }

  CopyWith$Variables$Query$GetMealPlanForDay<Variables$Query$GetMealPlanForDay>
      get copyWith => CopyWith$Variables$Query$GetMealPlanForDay(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (!(other is Variables$Query$GetMealPlanForDay) ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$date = date;
    final lOther$date = other.date;
    if (l$date != lOther$date) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$date = date;
    return Object.hashAll([l$date]);
  }
}

abstract class CopyWith$Variables$Query$GetMealPlanForDay<TRes> {
  factory CopyWith$Variables$Query$GetMealPlanForDay(
    Variables$Query$GetMealPlanForDay instance,
    TRes Function(Variables$Query$GetMealPlanForDay) then,
  ) = _CopyWithImpl$Variables$Query$GetMealPlanForDay;

  factory CopyWith$Variables$Query$GetMealPlanForDay.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$GetMealPlanForDay;

  TRes call({String? date});
}

class _CopyWithImpl$Variables$Query$GetMealPlanForDay<TRes>
    implements CopyWith$Variables$Query$GetMealPlanForDay<TRes> {
  _CopyWithImpl$Variables$Query$GetMealPlanForDay(
    this._instance,
    this._then,
  );

  final Variables$Query$GetMealPlanForDay _instance;

  final TRes Function(Variables$Query$GetMealPlanForDay) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({Object? date = _undefined}) =>
      _then(Variables$Query$GetMealPlanForDay._({
        ..._instance._$data,
        if (date != _undefined && date != null) 'date': (date as String),
      }));
}

class _CopyWithStubImpl$Variables$Query$GetMealPlanForDay<TRes>
    implements CopyWith$Variables$Query$GetMealPlanForDay<TRes> {
  _CopyWithStubImpl$Variables$Query$GetMealPlanForDay(this._res);

  TRes _res;

  call({String? date}) => _res;
}

class Query$GetMealPlanForDay {
  Query$GetMealPlanForDay({
    required this.getCanteens,
    this.$__typename = 'QueryRoot',
  });

  factory Query$GetMealPlanForDay.fromJson(Map<String, dynamic> json) {
    final l$getCanteens = json['getCanteens'];
    final l$$__typename = json['__typename'];
    return Query$GetMealPlanForDay(
      getCanteens: (l$getCanteens as List<dynamic>)
          .map((e) => Fragment$mealPlan.fromJson((e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Fragment$mealPlan> getCanteens;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$getCanteens = getCanteens;
    _resultData['getCanteens'] = l$getCanteens.map((e) => e.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$getCanteens = getCanteens;
    final l$$__typename = $__typename;
    return Object.hashAll([
      Object.hashAll(l$getCanteens.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (!(other is Query$GetMealPlanForDay) ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$getCanteens = getCanteens;
    final lOther$getCanteens = other.getCanteens;
    if (l$getCanteens.length != lOther$getCanteens.length) {
      return false;
    }
    for (int i = 0; i < l$getCanteens.length; i++) {
      final l$getCanteens$entry = l$getCanteens[i];
      final lOther$getCanteens$entry = lOther$getCanteens[i];
      if (l$getCanteens$entry != lOther$getCanteens$entry) {
        return false;
      }
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$GetMealPlanForDay on Query$GetMealPlanForDay {
  CopyWith$Query$GetMealPlanForDay<Query$GetMealPlanForDay> get copyWith =>
      CopyWith$Query$GetMealPlanForDay(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Query$GetMealPlanForDay<TRes> {
  factory CopyWith$Query$GetMealPlanForDay(
    Query$GetMealPlanForDay instance,
    TRes Function(Query$GetMealPlanForDay) then,
  ) = _CopyWithImpl$Query$GetMealPlanForDay;

  factory CopyWith$Query$GetMealPlanForDay.stub(TRes res) =
      _CopyWithStubImpl$Query$GetMealPlanForDay;

  TRes call({
    List<Fragment$mealPlan>? getCanteens,
    String? $__typename,
  });
  TRes getCanteens(
      Iterable<Fragment$mealPlan> Function(
              Iterable<CopyWith$Fragment$mealPlan<Fragment$mealPlan>>)
          _fn);
}

class _CopyWithImpl$Query$GetMealPlanForDay<TRes>
    implements CopyWith$Query$GetMealPlanForDay<TRes> {
  _CopyWithImpl$Query$GetMealPlanForDay(
    this._instance,
    this._then,
  );

  final Query$GetMealPlanForDay _instance;

  final TRes Function(Query$GetMealPlanForDay) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? getCanteens = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetMealPlanForDay(
        getCanteens: getCanteens == _undefined || getCanteens == null
            ? _instance.getCanteens
            : (getCanteens as List<Fragment$mealPlan>),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  TRes getCanteens(
          Iterable<Fragment$mealPlan> Function(
                  Iterable<CopyWith$Fragment$mealPlan<Fragment$mealPlan>>)
              _fn) =>
      call(
          getCanteens:
              _fn(_instance.getCanteens.map((e) => CopyWith$Fragment$mealPlan(
                    e,
                    (i) => i,
                  ))).toList());
}

class _CopyWithStubImpl$Query$GetMealPlanForDay<TRes>
    implements CopyWith$Query$GetMealPlanForDay<TRes> {
  _CopyWithStubImpl$Query$GetMealPlanForDay(this._res);

  TRes _res;

  call({
    List<Fragment$mealPlan>? getCanteens,
    String? $__typename,
  }) =>
      _res;

  getCanteens(_fn) => _res;
}

const documentNodeQueryGetMealPlanForDay = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.query,
    name: NameNode(value: 'GetMealPlanForDay'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'date')),
        type: NamedTypeNode(
          name: NameNode(value: 'NaiveDate'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      )
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'getCanteens'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FragmentSpreadNode(
            name: NameNode(value: 'mealPlan'),
            directives: [],
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
      FieldNode(
        name: NameNode(value: '__typename'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
    ]),
  ),
  fragmentDefinitionmealPlan,
  fragmentDefinitioncanteen,
  fragmentDefinitionmealInfo,
  fragmentDefinitionprice,
  fragmentDefinitionnutritionData,
]);
Query$GetMealPlanForDay _parserFn$Query$GetMealPlanForDay(
        Map<String, dynamic> data) =>
    Query$GetMealPlanForDay.fromJson(data);
typedef OnQueryComplete$Query$GetMealPlanForDay = FutureOr<void> Function(
  Map<String, dynamic>?,
  Query$GetMealPlanForDay?,
);

class Options$Query$GetMealPlanForDay
    extends graphql.QueryOptions<Query$GetMealPlanForDay> {
  Options$Query$GetMealPlanForDay({
    String? operationName,
    required Variables$Query$GetMealPlanForDay variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetMealPlanForDay? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$GetMealPlanForDay? onComplete,
    graphql.OnQueryError? onError,
  })  : onCompleteWithParsed = onComplete,
        super(
          variables: variables.toJson(),
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
                    data == null
                        ? null
                        : _parserFn$Query$GetMealPlanForDay(data),
                  ),
          onError: onError,
          document: documentNodeQueryGetMealPlanForDay,
          parserFn: _parserFn$Query$GetMealPlanForDay,
        );

  final OnQueryComplete$Query$GetMealPlanForDay? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onComplete == null
            ? super.properties
            : super.properties.where((property) => property != onComplete),
        onCompleteWithParsed,
      ];
}

class WatchOptions$Query$GetMealPlanForDay
    extends graphql.WatchQueryOptions<Query$GetMealPlanForDay> {
  WatchOptions$Query$GetMealPlanForDay({
    String? operationName,
    required Variables$Query$GetMealPlanForDay variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetMealPlanForDay? typedOptimisticResult,
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
          document: documentNodeQueryGetMealPlanForDay,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Query$GetMealPlanForDay,
        );
}

class FetchMoreOptions$Query$GetMealPlanForDay
    extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$GetMealPlanForDay({
    required graphql.UpdateQuery updateQuery,
    required Variables$Query$GetMealPlanForDay variables,
  }) : super(
          updateQuery: updateQuery,
          variables: variables.toJson(),
          document: documentNodeQueryGetMealPlanForDay,
        );
}

extension ClientExtension$Query$GetMealPlanForDay on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$GetMealPlanForDay>> query$GetMealPlanForDay(
          Options$Query$GetMealPlanForDay options) async =>
      await this.query(options);
  graphql.ObservableQuery<Query$GetMealPlanForDay> watchQuery$GetMealPlanForDay(
          WatchOptions$Query$GetMealPlanForDay options) =>
      this.watchQuery(options);
  void writeQuery$GetMealPlanForDay({
    required Query$GetMealPlanForDay data,
    required Variables$Query$GetMealPlanForDay variables,
    bool broadcast = true,
  }) =>
      this.writeQuery(
        graphql.Request(
          operation:
              graphql.Operation(document: documentNodeQueryGetMealPlanForDay),
          variables: variables.toJson(),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );
  Query$GetMealPlanForDay? readQuery$GetMealPlanForDay({
    required Variables$Query$GetMealPlanForDay variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation:
            graphql.Operation(document: documentNodeQueryGetMealPlanForDay),
        variables: variables.toJson(),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$GetMealPlanForDay.fromJson(result);
  }
}

graphql_flutter.QueryHookResult<Query$GetMealPlanForDay>
    useQuery$GetMealPlanForDay(Options$Query$GetMealPlanForDay options) =>
        graphql_flutter.useQuery(options);
graphql.ObservableQuery<Query$GetMealPlanForDay>
    useWatchQuery$GetMealPlanForDay(
            WatchOptions$Query$GetMealPlanForDay options) =>
        graphql_flutter.useWatchQuery(options);

class Query$GetMealPlanForDay$Widget
    extends graphql_flutter.Query<Query$GetMealPlanForDay> {
  Query$GetMealPlanForDay$Widget({
    widgets.Key? key,
    required Options$Query$GetMealPlanForDay options,
    required graphql_flutter.QueryBuilder<Query$GetMealPlanForDay> builder,
  }) : super(
          key: key,
          options: options,
          builder: builder,
        );
}

class Variables$Query$GetCanteenDate {
  factory Variables$Query$GetCanteenDate({
    required String canteenId,
    required String date,
  }) =>
      Variables$Query$GetCanteenDate._({
        r'canteenId': canteenId,
        r'date': date,
      });

  Variables$Query$GetCanteenDate._(this._$data);

  factory Variables$Query$GetCanteenDate.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$canteenId = data['canteenId'];
    result$data['canteenId'] = (l$canteenId as String);
    final l$date = data['date'];
    result$data['date'] = (l$date as String);
    return Variables$Query$GetCanteenDate._(result$data);
  }

  Map<String, dynamic> _$data;

  String get canteenId => (_$data['canteenId'] as String);

  String get date => (_$data['date'] as String);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$canteenId = canteenId;
    result$data['canteenId'] = l$canteenId;
    final l$date = date;
    result$data['date'] = l$date;
    return result$data;
  }

  CopyWith$Variables$Query$GetCanteenDate<Variables$Query$GetCanteenDate>
      get copyWith => CopyWith$Variables$Query$GetCanteenDate(
            this,
            (i) => i,
          );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (!(other is Variables$Query$GetCanteenDate) ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$canteenId = canteenId;
    final lOther$canteenId = other.canteenId;
    if (l$canteenId != lOther$canteenId) {
      return false;
    }
    final l$date = date;
    final lOther$date = other.date;
    if (l$date != lOther$date) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$canteenId = canteenId;
    final l$date = date;
    return Object.hashAll([
      l$canteenId,
      l$date,
    ]);
  }
}

abstract class CopyWith$Variables$Query$GetCanteenDate<TRes> {
  factory CopyWith$Variables$Query$GetCanteenDate(
    Variables$Query$GetCanteenDate instance,
    TRes Function(Variables$Query$GetCanteenDate) then,
  ) = _CopyWithImpl$Variables$Query$GetCanteenDate;

  factory CopyWith$Variables$Query$GetCanteenDate.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$GetCanteenDate;

  TRes call({
    String? canteenId,
    String? date,
  });
}

class _CopyWithImpl$Variables$Query$GetCanteenDate<TRes>
    implements CopyWith$Variables$Query$GetCanteenDate<TRes> {
  _CopyWithImpl$Variables$Query$GetCanteenDate(
    this._instance,
    this._then,
  );

  final Variables$Query$GetCanteenDate _instance;

  final TRes Function(Variables$Query$GetCanteenDate) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? canteenId = _undefined,
    Object? date = _undefined,
  }) =>
      _then(Variables$Query$GetCanteenDate._({
        ..._instance._$data,
        if (canteenId != _undefined && canteenId != null)
          'canteenId': (canteenId as String),
        if (date != _undefined && date != null) 'date': (date as String),
      }));
}

class _CopyWithStubImpl$Variables$Query$GetCanteenDate<TRes>
    implements CopyWith$Variables$Query$GetCanteenDate<TRes> {
  _CopyWithStubImpl$Variables$Query$GetCanteenDate(this._res);

  TRes _res;

  call({
    String? canteenId,
    String? date,
  }) =>
      _res;
}

class Query$GetCanteenDate {
  Query$GetCanteenDate({
    this.getCanteen,
    this.$__typename = 'QueryRoot',
  });

  factory Query$GetCanteenDate.fromJson(Map<String, dynamic> json) {
    final l$getCanteen = json['getCanteen'];
    final l$$__typename = json['__typename'];
    return Query$GetCanteenDate(
      getCanteen: l$getCanteen == null
          ? null
          : Fragment$mealPlan.fromJson((l$getCanteen as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Fragment$mealPlan? getCanteen;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$getCanteen = getCanteen;
    _resultData['getCanteen'] = l$getCanteen?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$getCanteen = getCanteen;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$getCanteen,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (!(other is Query$GetCanteenDate) || runtimeType != other.runtimeType) {
      return false;
    }
    final l$getCanteen = getCanteen;
    final lOther$getCanteen = other.getCanteen;
    if (l$getCanteen != lOther$getCanteen) {
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

extension UtilityExtension$Query$GetCanteenDate on Query$GetCanteenDate {
  CopyWith$Query$GetCanteenDate<Query$GetCanteenDate> get copyWith =>
      CopyWith$Query$GetCanteenDate(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Query$GetCanteenDate<TRes> {
  factory CopyWith$Query$GetCanteenDate(
    Query$GetCanteenDate instance,
    TRes Function(Query$GetCanteenDate) then,
  ) = _CopyWithImpl$Query$GetCanteenDate;

  factory CopyWith$Query$GetCanteenDate.stub(TRes res) =
      _CopyWithStubImpl$Query$GetCanteenDate;

  TRes call({
    Fragment$mealPlan? getCanteen,
    String? $__typename,
  });
  CopyWith$Fragment$mealPlan<TRes> get getCanteen;
}

class _CopyWithImpl$Query$GetCanteenDate<TRes>
    implements CopyWith$Query$GetCanteenDate<TRes> {
  _CopyWithImpl$Query$GetCanteenDate(
    this._instance,
    this._then,
  );

  final Query$GetCanteenDate _instance;

  final TRes Function(Query$GetCanteenDate) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? getCanteen = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetCanteenDate(
        getCanteen: getCanteen == _undefined
            ? _instance.getCanteen
            : (getCanteen as Fragment$mealPlan?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Fragment$mealPlan<TRes> get getCanteen {
    final local$getCanteen = _instance.getCanteen;
    return local$getCanteen == null
        ? CopyWith$Fragment$mealPlan.stub(_then(_instance))
        : CopyWith$Fragment$mealPlan(
            local$getCanteen, (e) => call(getCanteen: e));
  }
}

class _CopyWithStubImpl$Query$GetCanteenDate<TRes>
    implements CopyWith$Query$GetCanteenDate<TRes> {
  _CopyWithStubImpl$Query$GetCanteenDate(this._res);

  TRes _res;

  call({
    Fragment$mealPlan? getCanteen,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$mealPlan<TRes> get getCanteen =>
      CopyWith$Fragment$mealPlan.stub(_res);
}

const documentNodeQueryGetCanteenDate = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.query,
    name: NameNode(value: 'GetCanteenDate'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'canteenId')),
        type: NamedTypeNode(
          name: NameNode(value: 'UUID'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'date')),
        type: NamedTypeNode(
          name: NameNode(value: 'NaiveDate'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'getCanteen'),
        alias: null,
        arguments: [
          ArgumentNode(
            name: NameNode(value: 'canteenId'),
            value: VariableNode(name: NameNode(value: 'canteenId')),
          )
        ],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FragmentSpreadNode(
            name: NameNode(value: 'mealPlan'),
            directives: [],
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
      FieldNode(
        name: NameNode(value: '__typename'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
    ]),
  ),
  fragmentDefinitionmealPlan,
  fragmentDefinitioncanteen,
  fragmentDefinitionmealInfo,
  fragmentDefinitionprice,
  fragmentDefinitionnutritionData,
]);
Query$GetCanteenDate _parserFn$Query$GetCanteenDate(
        Map<String, dynamic> data) =>
    Query$GetCanteenDate.fromJson(data);
typedef OnQueryComplete$Query$GetCanteenDate = FutureOr<void> Function(
  Map<String, dynamic>?,
  Query$GetCanteenDate?,
);

class Options$Query$GetCanteenDate
    extends graphql.QueryOptions<Query$GetCanteenDate> {
  Options$Query$GetCanteenDate({
    String? operationName,
    required Variables$Query$GetCanteenDate variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetCanteenDate? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$GetCanteenDate? onComplete,
    graphql.OnQueryError? onError,
  })  : onCompleteWithParsed = onComplete,
        super(
          variables: variables.toJson(),
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
                    data == null ? null : _parserFn$Query$GetCanteenDate(data),
                  ),
          onError: onError,
          document: documentNodeQueryGetCanteenDate,
          parserFn: _parserFn$Query$GetCanteenDate,
        );

  final OnQueryComplete$Query$GetCanteenDate? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onComplete == null
            ? super.properties
            : super.properties.where((property) => property != onComplete),
        onCompleteWithParsed,
      ];
}

class WatchOptions$Query$GetCanteenDate
    extends graphql.WatchQueryOptions<Query$GetCanteenDate> {
  WatchOptions$Query$GetCanteenDate({
    String? operationName,
    required Variables$Query$GetCanteenDate variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetCanteenDate? typedOptimisticResult,
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
          document: documentNodeQueryGetCanteenDate,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Query$GetCanteenDate,
        );
}

class FetchMoreOptions$Query$GetCanteenDate extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$GetCanteenDate({
    required graphql.UpdateQuery updateQuery,
    required Variables$Query$GetCanteenDate variables,
  }) : super(
          updateQuery: updateQuery,
          variables: variables.toJson(),
          document: documentNodeQueryGetCanteenDate,
        );
}

extension ClientExtension$Query$GetCanteenDate on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$GetCanteenDate>> query$GetCanteenDate(
          Options$Query$GetCanteenDate options) async =>
      await this.query(options);
  graphql.ObservableQuery<Query$GetCanteenDate> watchQuery$GetCanteenDate(
          WatchOptions$Query$GetCanteenDate options) =>
      this.watchQuery(options);
  void writeQuery$GetCanteenDate({
    required Query$GetCanteenDate data,
    required Variables$Query$GetCanteenDate variables,
    bool broadcast = true,
  }) =>
      this.writeQuery(
        graphql.Request(
          operation:
              graphql.Operation(document: documentNodeQueryGetCanteenDate),
          variables: variables.toJson(),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );
  Query$GetCanteenDate? readQuery$GetCanteenDate({
    required Variables$Query$GetCanteenDate variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation: graphql.Operation(document: documentNodeQueryGetCanteenDate),
        variables: variables.toJson(),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$GetCanteenDate.fromJson(result);
  }
}

graphql_flutter.QueryHookResult<Query$GetCanteenDate> useQuery$GetCanteenDate(
        Options$Query$GetCanteenDate options) =>
    graphql_flutter.useQuery(options);
graphql.ObservableQuery<Query$GetCanteenDate> useWatchQuery$GetCanteenDate(
        WatchOptions$Query$GetCanteenDate options) =>
    graphql_flutter.useWatchQuery(options);

class Query$GetCanteenDate$Widget
    extends graphql_flutter.Query<Query$GetCanteenDate> {
  Query$GetCanteenDate$Widget({
    widgets.Key? key,
    required Options$Query$GetCanteenDate options,
    required graphql_flutter.QueryBuilder<Query$GetCanteenDate> builder,
  }) : super(
          key: key,
          options: options,
          builder: builder,
        );
}

class Variables$Query$GetMeal {
  factory Variables$Query$GetMeal({
    required String date,
    required String mealId,
    required String lineId,
  }) =>
      Variables$Query$GetMeal._({
        r'date': date,
        r'mealId': mealId,
        r'lineId': lineId,
      });

  Variables$Query$GetMeal._(this._$data);

  factory Variables$Query$GetMeal.fromJson(Map<String, dynamic> data) {
    final result$data = <String, dynamic>{};
    final l$date = data['date'];
    result$data['date'] = (l$date as String);
    final l$mealId = data['mealId'];
    result$data['mealId'] = (l$mealId as String);
    final l$lineId = data['lineId'];
    result$data['lineId'] = (l$lineId as String);
    return Variables$Query$GetMeal._(result$data);
  }

  Map<String, dynamic> _$data;

  String get date => (_$data['date'] as String);

  String get mealId => (_$data['mealId'] as String);

  String get lineId => (_$data['lineId'] as String);

  Map<String, dynamic> toJson() {
    final result$data = <String, dynamic>{};
    final l$date = date;
    result$data['date'] = l$date;
    final l$mealId = mealId;
    result$data['mealId'] = l$mealId;
    final l$lineId = lineId;
    result$data['lineId'] = l$lineId;
    return result$data;
  }

  CopyWith$Variables$Query$GetMeal<Variables$Query$GetMeal> get copyWith =>
      CopyWith$Variables$Query$GetMeal(
        this,
        (i) => i,
      );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (!(other is Variables$Query$GetMeal) ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$date = date;
    final lOther$date = other.date;
    if (l$date != lOther$date) {
      return false;
    }
    final l$mealId = mealId;
    final lOther$mealId = other.mealId;
    if (l$mealId != lOther$mealId) {
      return false;
    }
    final l$lineId = lineId;
    final lOther$lineId = other.lineId;
    if (l$lineId != lOther$lineId) {
      return false;
    }
    return true;
  }

  @override
  int get hashCode {
    final l$date = date;
    final l$mealId = mealId;
    final l$lineId = lineId;
    return Object.hashAll([
      l$date,
      l$mealId,
      l$lineId,
    ]);
  }
}

abstract class CopyWith$Variables$Query$GetMeal<TRes> {
  factory CopyWith$Variables$Query$GetMeal(
    Variables$Query$GetMeal instance,
    TRes Function(Variables$Query$GetMeal) then,
  ) = _CopyWithImpl$Variables$Query$GetMeal;

  factory CopyWith$Variables$Query$GetMeal.stub(TRes res) =
      _CopyWithStubImpl$Variables$Query$GetMeal;

  TRes call({
    String? date,
    String? mealId,
    String? lineId,
  });
}

class _CopyWithImpl$Variables$Query$GetMeal<TRes>
    implements CopyWith$Variables$Query$GetMeal<TRes> {
  _CopyWithImpl$Variables$Query$GetMeal(
    this._instance,
    this._then,
  );

  final Variables$Query$GetMeal _instance;

  final TRes Function(Variables$Query$GetMeal) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? date = _undefined,
    Object? mealId = _undefined,
    Object? lineId = _undefined,
  }) =>
      _then(Variables$Query$GetMeal._({
        ..._instance._$data,
        if (date != _undefined && date != null) 'date': (date as String),
        if (mealId != _undefined && mealId != null)
          'mealId': (mealId as String),
        if (lineId != _undefined && lineId != null)
          'lineId': (lineId as String),
      }));
}

class _CopyWithStubImpl$Variables$Query$GetMeal<TRes>
    implements CopyWith$Variables$Query$GetMeal<TRes> {
  _CopyWithStubImpl$Variables$Query$GetMeal(this._res);

  TRes _res;

  call({
    String? date,
    String? mealId,
    String? lineId,
  }) =>
      _res;
}

class Query$GetMeal {
  Query$GetMeal({
    this.getMeal,
    this.$__typename = 'QueryRoot',
  });

  factory Query$GetMeal.fromJson(Map<String, dynamic> json) {
    final l$getMeal = json['getMeal'];
    final l$$__typename = json['__typename'];
    return Query$GetMeal(
      getMeal: l$getMeal == null
          ? null
          : Fragment$mealInfo.fromJson((l$getMeal as Map<String, dynamic>)),
      $__typename: (l$$__typename as String),
    );
  }

  final Fragment$mealInfo? getMeal;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$getMeal = getMeal;
    _resultData['getMeal'] = l$getMeal?.toJson();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$getMeal = getMeal;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$getMeal,
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (!(other is Query$GetMeal) || runtimeType != other.runtimeType) {
      return false;
    }
    final l$getMeal = getMeal;
    final lOther$getMeal = other.getMeal;
    if (l$getMeal != lOther$getMeal) {
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

extension UtilityExtension$Query$GetMeal on Query$GetMeal {
  CopyWith$Query$GetMeal<Query$GetMeal> get copyWith => CopyWith$Query$GetMeal(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Query$GetMeal<TRes> {
  factory CopyWith$Query$GetMeal(
    Query$GetMeal instance,
    TRes Function(Query$GetMeal) then,
  ) = _CopyWithImpl$Query$GetMeal;

  factory CopyWith$Query$GetMeal.stub(TRes res) =
      _CopyWithStubImpl$Query$GetMeal;

  TRes call({
    Fragment$mealInfo? getMeal,
    String? $__typename,
  });
  CopyWith$Fragment$mealInfo<TRes> get getMeal;
}

class _CopyWithImpl$Query$GetMeal<TRes>
    implements CopyWith$Query$GetMeal<TRes> {
  _CopyWithImpl$Query$GetMeal(
    this._instance,
    this._then,
  );

  final Query$GetMeal _instance;

  final TRes Function(Query$GetMeal) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? getMeal = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetMeal(
        getMeal: getMeal == _undefined
            ? _instance.getMeal
            : (getMeal as Fragment$mealInfo?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  CopyWith$Fragment$mealInfo<TRes> get getMeal {
    final local$getMeal = _instance.getMeal;
    return local$getMeal == null
        ? CopyWith$Fragment$mealInfo.stub(_then(_instance))
        : CopyWith$Fragment$mealInfo(local$getMeal, (e) => call(getMeal: e));
  }
}

class _CopyWithStubImpl$Query$GetMeal<TRes>
    implements CopyWith$Query$GetMeal<TRes> {
  _CopyWithStubImpl$Query$GetMeal(this._res);

  TRes _res;

  call({
    Fragment$mealInfo? getMeal,
    String? $__typename,
  }) =>
      _res;

  CopyWith$Fragment$mealInfo<TRes> get getMeal =>
      CopyWith$Fragment$mealInfo.stub(_res);
}

const documentNodeQueryGetMeal = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.query,
    name: NameNode(value: 'GetMeal'),
    variableDefinitions: [
      VariableDefinitionNode(
        variable: VariableNode(name: NameNode(value: 'date')),
        type: NamedTypeNode(
          name: NameNode(value: 'NaiveDate'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
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
        variable: VariableNode(name: NameNode(value: 'lineId')),
        type: NamedTypeNode(
          name: NameNode(value: 'UUID'),
          isNonNull: true,
        ),
        defaultValue: DefaultValueNode(value: null),
        directives: [],
      ),
    ],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'getMeal'),
        alias: null,
        arguments: [
          ArgumentNode(
            name: NameNode(value: 'date'),
            value: VariableNode(name: NameNode(value: 'date')),
          ),
          ArgumentNode(
            name: NameNode(value: 'mealId'),
            value: VariableNode(name: NameNode(value: 'mealId')),
          ),
          ArgumentNode(
            name: NameNode(value: 'lineId'),
            value: VariableNode(name: NameNode(value: 'lineId')),
          ),
        ],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FragmentSpreadNode(
            name: NameNode(value: 'mealInfo'),
            directives: [],
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
      FieldNode(
        name: NameNode(value: '__typename'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
    ]),
  ),
  fragmentDefinitionmealInfo,
  fragmentDefinitionprice,
  fragmentDefinitionnutritionData,
]);
Query$GetMeal _parserFn$Query$GetMeal(Map<String, dynamic> data) =>
    Query$GetMeal.fromJson(data);
typedef OnQueryComplete$Query$GetMeal = FutureOr<void> Function(
  Map<String, dynamic>?,
  Query$GetMeal?,
);

class Options$Query$GetMeal extends graphql.QueryOptions<Query$GetMeal> {
  Options$Query$GetMeal({
    String? operationName,
    required Variables$Query$GetMeal variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetMeal? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$GetMeal? onComplete,
    graphql.OnQueryError? onError,
  })  : onCompleteWithParsed = onComplete,
        super(
          variables: variables.toJson(),
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
                    data == null ? null : _parserFn$Query$GetMeal(data),
                  ),
          onError: onError,
          document: documentNodeQueryGetMeal,
          parserFn: _parserFn$Query$GetMeal,
        );

  final OnQueryComplete$Query$GetMeal? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onComplete == null
            ? super.properties
            : super.properties.where((property) => property != onComplete),
        onCompleteWithParsed,
      ];
}

class WatchOptions$Query$GetMeal
    extends graphql.WatchQueryOptions<Query$GetMeal> {
  WatchOptions$Query$GetMeal({
    String? operationName,
    required Variables$Query$GetMeal variables,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetMeal? typedOptimisticResult,
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
          document: documentNodeQueryGetMeal,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Query$GetMeal,
        );
}

class FetchMoreOptions$Query$GetMeal extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$GetMeal({
    required graphql.UpdateQuery updateQuery,
    required Variables$Query$GetMeal variables,
  }) : super(
          updateQuery: updateQuery,
          variables: variables.toJson(),
          document: documentNodeQueryGetMeal,
        );
}

extension ClientExtension$Query$GetMeal on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$GetMeal>> query$GetMeal(
          Options$Query$GetMeal options) async =>
      await this.query(options);
  graphql.ObservableQuery<Query$GetMeal> watchQuery$GetMeal(
          WatchOptions$Query$GetMeal options) =>
      this.watchQuery(options);
  void writeQuery$GetMeal({
    required Query$GetMeal data,
    required Variables$Query$GetMeal variables,
    bool broadcast = true,
  }) =>
      this.writeQuery(
        graphql.Request(
          operation: graphql.Operation(document: documentNodeQueryGetMeal),
          variables: variables.toJson(),
        ),
        data: data.toJson(),
        broadcast: broadcast,
      );
  Query$GetMeal? readQuery$GetMeal({
    required Variables$Query$GetMeal variables,
    bool optimistic = true,
  }) {
    final result = this.readQuery(
      graphql.Request(
        operation: graphql.Operation(document: documentNodeQueryGetMeal),
        variables: variables.toJson(),
      ),
      optimistic: optimistic,
    );
    return result == null ? null : Query$GetMeal.fromJson(result);
  }
}

graphql_flutter.QueryHookResult<Query$GetMeal> useQuery$GetMeal(
        Options$Query$GetMeal options) =>
    graphql_flutter.useQuery(options);
graphql.ObservableQuery<Query$GetMeal> useWatchQuery$GetMeal(
        WatchOptions$Query$GetMeal options) =>
    graphql_flutter.useWatchQuery(options);

class Query$GetMeal$Widget extends graphql_flutter.Query<Query$GetMeal> {
  Query$GetMeal$Widget({
    widgets.Key? key,
    required Options$Query$GetMeal options,
    required graphql_flutter.QueryBuilder<Query$GetMeal> builder,
  }) : super(
          key: key,
          options: options,
          builder: builder,
        );
}

class Query$GetDefaultCanteen {
  Query$GetDefaultCanteen({
    required this.getCanteens,
    this.$__typename = 'QueryRoot',
  });

  factory Query$GetDefaultCanteen.fromJson(Map<String, dynamic> json) {
    final l$getCanteens = json['getCanteens'];
    final l$$__typename = json['__typename'];
    return Query$GetDefaultCanteen(
      getCanteens: (l$getCanteens as List<dynamic>)
          .map((e) => Fragment$canteen.fromJson((e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Fragment$canteen> getCanteens;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$getCanteens = getCanteens;
    _resultData['getCanteens'] = l$getCanteens.map((e) => e.toJson()).toList();
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$getCanteens = getCanteens;
    final l$$__typename = $__typename;
    return Object.hashAll([
      Object.hashAll(l$getCanteens.map((v) => v)),
      l$$__typename,
    ]);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) {
      return true;
    }
    if (!(other is Query$GetDefaultCanteen) ||
        runtimeType != other.runtimeType) {
      return false;
    }
    final l$getCanteens = getCanteens;
    final lOther$getCanteens = other.getCanteens;
    if (l$getCanteens.length != lOther$getCanteens.length) {
      return false;
    }
    for (int i = 0; i < l$getCanteens.length; i++) {
      final l$getCanteens$entry = l$getCanteens[i];
      final lOther$getCanteens$entry = lOther$getCanteens[i];
      if (l$getCanteens$entry != lOther$getCanteens$entry) {
        return false;
      }
    }
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$GetDefaultCanteen on Query$GetDefaultCanteen {
  CopyWith$Query$GetDefaultCanteen<Query$GetDefaultCanteen> get copyWith =>
      CopyWith$Query$GetDefaultCanteen(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Query$GetDefaultCanteen<TRes> {
  factory CopyWith$Query$GetDefaultCanteen(
    Query$GetDefaultCanteen instance,
    TRes Function(Query$GetDefaultCanteen) then,
  ) = _CopyWithImpl$Query$GetDefaultCanteen;

  factory CopyWith$Query$GetDefaultCanteen.stub(TRes res) =
      _CopyWithStubImpl$Query$GetDefaultCanteen;

  TRes call({
    List<Fragment$canteen>? getCanteens,
    String? $__typename,
  });
  TRes getCanteens(
      Iterable<Fragment$canteen> Function(
              Iterable<CopyWith$Fragment$canteen<Fragment$canteen>>)
          _fn);
}

class _CopyWithImpl$Query$GetDefaultCanteen<TRes>
    implements CopyWith$Query$GetDefaultCanteen<TRes> {
  _CopyWithImpl$Query$GetDefaultCanteen(
    this._instance,
    this._then,
  );

  final Query$GetDefaultCanteen _instance;

  final TRes Function(Query$GetDefaultCanteen) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? getCanteens = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetDefaultCanteen(
        getCanteens: getCanteens == _undefined || getCanteens == null
            ? _instance.getCanteens
            : (getCanteens as List<Fragment$canteen>),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));

  TRes getCanteens(
          Iterable<Fragment$canteen> Function(
                  Iterable<CopyWith$Fragment$canteen<Fragment$canteen>>)
              _fn) =>
      call(
          getCanteens:
              _fn(_instance.getCanteens.map((e) => CopyWith$Fragment$canteen(
                    e,
                    (i) => i,
                  ))).toList());
}

class _CopyWithStubImpl$Query$GetDefaultCanteen<TRes>
    implements CopyWith$Query$GetDefaultCanteen<TRes> {
  _CopyWithStubImpl$Query$GetDefaultCanteen(this._res);

  TRes _res;

  call({
    List<Fragment$canteen>? getCanteens,
    String? $__typename,
  }) =>
      _res;

  getCanteens(_fn) => _res;
}

const documentNodeQueryGetDefaultCanteen = DocumentNode(definitions: [
  OperationDefinitionNode(
    type: OperationType.query,
    name: NameNode(value: 'GetDefaultCanteen'),
    variableDefinitions: [],
    directives: [],
    selectionSet: SelectionSetNode(selections: [
      FieldNode(
        name: NameNode(value: 'getCanteens'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: SelectionSetNode(selections: [
          FragmentSpreadNode(
            name: NameNode(value: 'canteen'),
            directives: [],
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
      FieldNode(
        name: NameNode(value: '__typename'),
        alias: null,
        arguments: [],
        directives: [],
        selectionSet: null,
      ),
    ]),
  ),
  fragmentDefinitioncanteen,
]);
Query$GetDefaultCanteen _parserFn$Query$GetDefaultCanteen(
        Map<String, dynamic> data) =>
    Query$GetDefaultCanteen.fromJson(data);
typedef OnQueryComplete$Query$GetDefaultCanteen = FutureOr<void> Function(
  Map<String, dynamic>?,
  Query$GetDefaultCanteen?,
);

class Options$Query$GetDefaultCanteen
    extends graphql.QueryOptions<Query$GetDefaultCanteen> {
  Options$Query$GetDefaultCanteen({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetDefaultCanteen? typedOptimisticResult,
    Duration? pollInterval,
    graphql.Context? context,
    OnQueryComplete$Query$GetDefaultCanteen? onComplete,
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
                    data == null
                        ? null
                        : _parserFn$Query$GetDefaultCanteen(data),
                  ),
          onError: onError,
          document: documentNodeQueryGetDefaultCanteen,
          parserFn: _parserFn$Query$GetDefaultCanteen,
        );

  final OnQueryComplete$Query$GetDefaultCanteen? onCompleteWithParsed;

  @override
  List<Object?> get properties => [
        ...super.onComplete == null
            ? super.properties
            : super.properties.where((property) => property != onComplete),
        onCompleteWithParsed,
      ];
}

class WatchOptions$Query$GetDefaultCanteen
    extends graphql.WatchQueryOptions<Query$GetDefaultCanteen> {
  WatchOptions$Query$GetDefaultCanteen({
    String? operationName,
    graphql.FetchPolicy? fetchPolicy,
    graphql.ErrorPolicy? errorPolicy,
    graphql.CacheRereadPolicy? cacheRereadPolicy,
    Object? optimisticResult,
    Query$GetDefaultCanteen? typedOptimisticResult,
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
          document: documentNodeQueryGetDefaultCanteen,
          pollInterval: pollInterval,
          eagerlyFetchResults: eagerlyFetchResults,
          carryForwardDataOnException: carryForwardDataOnException,
          fetchResults: fetchResults,
          parserFn: _parserFn$Query$GetDefaultCanteen,
        );
}

class FetchMoreOptions$Query$GetDefaultCanteen
    extends graphql.FetchMoreOptions {
  FetchMoreOptions$Query$GetDefaultCanteen(
      {required graphql.UpdateQuery updateQuery})
      : super(
          updateQuery: updateQuery,
          document: documentNodeQueryGetDefaultCanteen,
        );
}

extension ClientExtension$Query$GetDefaultCanteen on graphql.GraphQLClient {
  Future<graphql.QueryResult<Query$GetDefaultCanteen>> query$GetDefaultCanteen(
          [Options$Query$GetDefaultCanteen? options]) async =>
      await this.query(options ?? Options$Query$GetDefaultCanteen());
  graphql.ObservableQuery<Query$GetDefaultCanteen> watchQuery$GetDefaultCanteen(
          [WatchOptions$Query$GetDefaultCanteen? options]) =>
      this.watchQuery(options ?? WatchOptions$Query$GetDefaultCanteen());
  void writeQuery$GetDefaultCanteen({
    required Query$GetDefaultCanteen data,
    bool broadcast = true,
  }) =>
      this.writeQuery(
        graphql.Request(
            operation: graphql.Operation(
                document: documentNodeQueryGetDefaultCanteen)),
        data: data.toJson(),
        broadcast: broadcast,
      );
  Query$GetDefaultCanteen? readQuery$GetDefaultCanteen(
      {bool optimistic = true}) {
    final result = this.readQuery(
      graphql.Request(
          operation:
              graphql.Operation(document: documentNodeQueryGetDefaultCanteen)),
      optimistic: optimistic,
    );
    return result == null ? null : Query$GetDefaultCanteen.fromJson(result);
  }
}

graphql_flutter.QueryHookResult<Query$GetDefaultCanteen>
    useQuery$GetDefaultCanteen([Options$Query$GetDefaultCanteen? options]) =>
        graphql_flutter.useQuery(options ?? Options$Query$GetDefaultCanteen());
graphql.ObservableQuery<Query$GetDefaultCanteen>
    useWatchQuery$GetDefaultCanteen(
            [WatchOptions$Query$GetDefaultCanteen? options]) =>
        graphql_flutter
            .useWatchQuery(options ?? WatchOptions$Query$GetDefaultCanteen());

class Query$GetDefaultCanteen$Widget
    extends graphql_flutter.Query<Query$GetDefaultCanteen> {
  Query$GetDefaultCanteen$Widget({
    widgets.Key? key,
    Options$Query$GetDefaultCanteen? options,
    required graphql_flutter.QueryBuilder<Query$GetDefaultCanteen> builder,
  }) : super(
          key: key,
          options: options ?? Options$Query$GetDefaultCanteen(),
          builder: builder,
        );
}
