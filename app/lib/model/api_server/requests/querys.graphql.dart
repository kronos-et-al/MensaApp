import 'dart:async';
import 'package:flutter/widgets.dart' as widgets;
import 'package:gql/ast.dart';
import 'package:graphql/client.dart' as graphql;
import 'package:graphql_flutter/graphql_flutter.dart' as graphql_flutter;
import 'schema.graphql.dart';

class Fragment$mealInfo {
  Fragment$mealInfo({
    required this.id,
    required this.name,
    required this.mealType,
    required this.price,
    required this.allergens,
    required this.additives,
    required this.statistics,
    required this.ratings,
    required this.images,
    this.$__typename = 'Meal',
  });

  factory Fragment$mealInfo.fromJson(Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$name = json['name'];
    final l$mealType = json['mealType'];
    final l$price = json['price'];
    final l$allergens = json['allergens'];
    final l$additives = json['additives'];
    final l$statistics = json['statistics'];
    final l$ratings = json['ratings'];
    final l$images = json['images'];
    final l$$__typename = json['__typename'];
    return Fragment$mealInfo(
      id: (l$id as String),
      name: (l$name as String),
      mealType: fromJson$Enum$MealType((l$mealType as String)),
      price:
          Fragment$mealInfo$price.fromJson((l$price as Map<String, dynamic>)),
      allergens: (l$allergens as List<dynamic>)
          .map((e) => fromJson$Enum$Allergen((e as String)))
          .toList(),
      additives: (l$additives as List<dynamic>)
          .map((e) => fromJson$Enum$Additive((e as String)))
          .toList(),
      statistics: Fragment$mealInfo$statistics.fromJson(
          (l$statistics as Map<String, dynamic>)),
      ratings: Fragment$mealInfo$ratings.fromJson(
          (l$ratings as Map<String, dynamic>)),
      images: (l$images as List<dynamic>)
          .map((e) =>
              Fragment$mealInfo$images.fromJson((e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final String id;

  final String name;

  final Enum$MealType mealType;

  final Fragment$mealInfo$price price;

  final List<Enum$Allergen> allergens;

  final List<Enum$Additive> additives;

  final Fragment$mealInfo$statistics statistics;

  final Fragment$mealInfo$ratings ratings;

  final List<Fragment$mealInfo$images> images;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$id = id;
    _resultData['id'] = l$id;
    final l$name = name;
    _resultData['name'] = l$name;
    final l$mealType = mealType;
    _resultData['mealType'] = toJson$Enum$MealType(l$mealType);
    final l$price = price;
    _resultData['price'] = l$price.toJson();
    final l$allergens = allergens;
    _resultData['allergens'] =
        l$allergens.map((e) => toJson$Enum$Allergen(e)).toList();
    final l$additives = additives;
    _resultData['additives'] =
        l$additives.map((e) => toJson$Enum$Additive(e)).toList();
    final l$statistics = statistics;
    _resultData['statistics'] = l$statistics.toJson();
    final l$ratings = ratings;
    _resultData['ratings'] = l$ratings.toJson();
    final l$images = images;
    _resultData['images'] = l$images.map((e) => e.toJson()).toList();
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
    final l$statistics = statistics;
    final l$ratings = ratings;
    final l$images = images;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$id,
      l$name,
      l$mealType,
      l$price,
      Object.hashAll(l$allergens.map((v) => v)),
      Object.hashAll(l$additives.map((v) => v)),
      l$statistics,
      l$ratings,
      Object.hashAll(l$images.map((v) => v)),
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
    Enum$MealType? mealType,
    Fragment$mealInfo$price? price,
    List<Enum$Allergen>? allergens,
    List<Enum$Additive>? additives,
    Fragment$mealInfo$statistics? statistics,
    Fragment$mealInfo$ratings? ratings,
    List<Fragment$mealInfo$images>? images,
    String? $__typename,
  });
  CopyWith$Fragment$mealInfo$price<TRes> get price;
  CopyWith$Fragment$mealInfo$statistics<TRes> get statistics;
  CopyWith$Fragment$mealInfo$ratings<TRes> get ratings;
  TRes images(
      Iterable<Fragment$mealInfo$images> Function(
              Iterable<
                  CopyWith$Fragment$mealInfo$images<Fragment$mealInfo$images>>)
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
    Object? statistics = _undefined,
    Object? ratings = _undefined,
    Object? images = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$mealInfo(
        id: id == _undefined || id == null ? _instance.id : (id as String),
        name: name == _undefined || name == null
            ? _instance.name
            : (name as String),
        mealType: mealType == _undefined || mealType == null
            ? _instance.mealType
            : (mealType as Enum$MealType),
        price: price == _undefined || price == null
            ? _instance.price
            : (price as Fragment$mealInfo$price),
        allergens: allergens == _undefined || allergens == null
            ? _instance.allergens
            : (allergens as List<Enum$Allergen>),
        additives: additives == _undefined || additives == null
            ? _instance.additives
            : (additives as List<Enum$Additive>),
        statistics: statistics == _undefined || statistics == null
            ? _instance.statistics
            : (statistics as Fragment$mealInfo$statistics),
        ratings: ratings == _undefined || ratings == null
            ? _instance.ratings
            : (ratings as Fragment$mealInfo$ratings),
        images: images == _undefined || images == null
            ? _instance.images
            : (images as List<Fragment$mealInfo$images>),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
  CopyWith$Fragment$mealInfo$price<TRes> get price {
    final local$price = _instance.price;
    return CopyWith$Fragment$mealInfo$price(local$price, (e) => call(price: e));
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
}

class _CopyWithStubImpl$Fragment$mealInfo<TRes>
    implements CopyWith$Fragment$mealInfo<TRes> {
  _CopyWithStubImpl$Fragment$mealInfo(this._res);

  TRes _res;

  call({
    String? id,
    String? name,
    Enum$MealType? mealType,
    Fragment$mealInfo$price? price,
    List<Enum$Allergen>? allergens,
    List<Enum$Additive>? additives,
    Fragment$mealInfo$statistics? statistics,
    Fragment$mealInfo$ratings? ratings,
    List<Fragment$mealInfo$images>? images,
    String? $__typename,
  }) =>
      _res;
  CopyWith$Fragment$mealInfo$price<TRes> get price =>
      CopyWith$Fragment$mealInfo$price.stub(_res);
  CopyWith$Fragment$mealInfo$statistics<TRes> get statistics =>
      CopyWith$Fragment$mealInfo$statistics.stub(_res);
  CopyWith$Fragment$mealInfo$ratings<TRes> get ratings =>
      CopyWith$Fragment$mealInfo$ratings.stub(_res);
  images(_fn) => _res;
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
          name: NameNode(value: 'relativeFrequency'),
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

class Fragment$mealInfo$price {
  Fragment$mealInfo$price({
    required this.employee,
    required this.guest,
    required this.pupil,
    required this.student,
    this.$__typename = 'Price',
  });

  factory Fragment$mealInfo$price.fromJson(Map<String, dynamic> json) {
    final l$employee = json['employee'];
    final l$guest = json['guest'];
    final l$pupil = json['pupil'];
    final l$student = json['student'];
    final l$$__typename = json['__typename'];
    return Fragment$mealInfo$price(
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
    if (!(other is Fragment$mealInfo$price) ||
        runtimeType != other.runtimeType) {
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

extension UtilityExtension$Fragment$mealInfo$price on Fragment$mealInfo$price {
  CopyWith$Fragment$mealInfo$price<Fragment$mealInfo$price> get copyWith =>
      CopyWith$Fragment$mealInfo$price(
        this,
        (i) => i,
      );
}

abstract class CopyWith$Fragment$mealInfo$price<TRes> {
  factory CopyWith$Fragment$mealInfo$price(
    Fragment$mealInfo$price instance,
    TRes Function(Fragment$mealInfo$price) then,
  ) = _CopyWithImpl$Fragment$mealInfo$price;

  factory CopyWith$Fragment$mealInfo$price.stub(TRes res) =
      _CopyWithStubImpl$Fragment$mealInfo$price;

  TRes call({
    int? employee,
    int? guest,
    int? pupil,
    int? student,
    String? $__typename,
  });
}

class _CopyWithImpl$Fragment$mealInfo$price<TRes>
    implements CopyWith$Fragment$mealInfo$price<TRes> {
  _CopyWithImpl$Fragment$mealInfo$price(
    this._instance,
    this._then,
  );

  final Fragment$mealInfo$price _instance;

  final TRes Function(Fragment$mealInfo$price) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? employee = _undefined,
    Object? guest = _undefined,
    Object? pupil = _undefined,
    Object? student = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$mealInfo$price(
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

class _CopyWithStubImpl$Fragment$mealInfo$price<TRes>
    implements CopyWith$Fragment$mealInfo$price<TRes> {
  _CopyWithStubImpl$Fragment$mealInfo$price(this._res);

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

class Fragment$mealInfo$statistics {
  Fragment$mealInfo$statistics({
    this.lastServed,
    this.nextServed,
    required this.relativeFrequency,
    this.$__typename = 'MealStatistics',
  });

  factory Fragment$mealInfo$statistics.fromJson(Map<String, dynamic> json) {
    final l$lastServed = json['lastServed'];
    final l$nextServed = json['nextServed'];
    final l$relativeFrequency = json['relativeFrequency'];
    final l$$__typename = json['__typename'];
    return Fragment$mealInfo$statistics(
      lastServed: (l$lastServed as String?),
      nextServed: (l$nextServed as String?),
      relativeFrequency: (l$relativeFrequency as num).toDouble(),
      $__typename: (l$$__typename as String),
    );
  }

  final String? lastServed;

  final String? nextServed;

  final double relativeFrequency;

  final String $__typename;

  Map<String, dynamic> toJson() {
    final _resultData = <String, dynamic>{};
    final l$lastServed = lastServed;
    _resultData['lastServed'] = l$lastServed;
    final l$nextServed = nextServed;
    _resultData['nextServed'] = l$nextServed;
    final l$relativeFrequency = relativeFrequency;
    _resultData['relativeFrequency'] = l$relativeFrequency;
    final l$$__typename = $__typename;
    _resultData['__typename'] = l$$__typename;
    return _resultData;
  }

  @override
  int get hashCode {
    final l$lastServed = lastServed;
    final l$nextServed = nextServed;
    final l$relativeFrequency = relativeFrequency;
    final l$$__typename = $__typename;
    return Object.hashAll([
      l$lastServed,
      l$nextServed,
      l$relativeFrequency,
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
    final l$relativeFrequency = relativeFrequency;
    final lOther$relativeFrequency = other.relativeFrequency;
    if (l$relativeFrequency != lOther$relativeFrequency) {
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
    double? relativeFrequency,
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
    Object? relativeFrequency = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Fragment$mealInfo$statistics(
        lastServed: lastServed == _undefined
            ? _instance.lastServed
            : (lastServed as String?),
        nextServed: nextServed == _undefined
            ? _instance.nextServed
            : (nextServed as String?),
        relativeFrequency:
            relativeFrequency == _undefined || relativeFrequency == null
                ? _instance.relativeFrequency
                : (relativeFrequency as double),
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
    double? relativeFrequency,
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
          .map((e) => Query$GetMealPlanForDay$getCanteens.fromJson(
              (e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Query$GetMealPlanForDay$getCanteens> getCanteens;

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
    List<Query$GetMealPlanForDay$getCanteens>? getCanteens,
    String? $__typename,
  });
  TRes getCanteens(
      Iterable<Query$GetMealPlanForDay$getCanteens> Function(
              Iterable<
                  CopyWith$Query$GetMealPlanForDay$getCanteens<
                      Query$GetMealPlanForDay$getCanteens>>)
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
            : (getCanteens as List<Query$GetMealPlanForDay$getCanteens>),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
  TRes getCanteens(
          Iterable<Query$GetMealPlanForDay$getCanteens> Function(
                  Iterable<
                      CopyWith$Query$GetMealPlanForDay$getCanteens<
                          Query$GetMealPlanForDay$getCanteens>>)
              _fn) =>
      call(
          getCanteens: _fn(_instance.getCanteens
              .map((e) => CopyWith$Query$GetMealPlanForDay$getCanteens(
                    e,
                    (i) => i,
                  ))).toList());
}

class _CopyWithStubImpl$Query$GetMealPlanForDay<TRes>
    implements CopyWith$Query$GetMealPlanForDay<TRes> {
  _CopyWithStubImpl$Query$GetMealPlanForDay(this._res);

  TRes _res;

  call({
    List<Query$GetMealPlanForDay$getCanteens>? getCanteens,
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

class Query$GetMealPlanForDay$getCanteens {
  Query$GetMealPlanForDay$getCanteens({
    required this.lines,
    this.$__typename = 'Canteen',
  });

  factory Query$GetMealPlanForDay$getCanteens.fromJson(
      Map<String, dynamic> json) {
    final l$lines = json['lines'];
    final l$$__typename = json['__typename'];
    return Query$GetMealPlanForDay$getCanteens(
      lines: (l$lines as List<dynamic>)
          .map((e) => Query$GetMealPlanForDay$getCanteens$lines.fromJson(
              (e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final List<Query$GetMealPlanForDay$getCanteens$lines> lines;

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
    if (!(other is Query$GetMealPlanForDay$getCanteens) ||
        runtimeType != other.runtimeType) {
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

extension UtilityExtension$Query$GetMealPlanForDay$getCanteens
    on Query$GetMealPlanForDay$getCanteens {
  CopyWith$Query$GetMealPlanForDay$getCanteens<
          Query$GetMealPlanForDay$getCanteens>
      get copyWith => CopyWith$Query$GetMealPlanForDay$getCanteens(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetMealPlanForDay$getCanteens<TRes> {
  factory CopyWith$Query$GetMealPlanForDay$getCanteens(
    Query$GetMealPlanForDay$getCanteens instance,
    TRes Function(Query$GetMealPlanForDay$getCanteens) then,
  ) = _CopyWithImpl$Query$GetMealPlanForDay$getCanteens;

  factory CopyWith$Query$GetMealPlanForDay$getCanteens.stub(TRes res) =
      _CopyWithStubImpl$Query$GetMealPlanForDay$getCanteens;

  TRes call({
    List<Query$GetMealPlanForDay$getCanteens$lines>? lines,
    String? $__typename,
  });
  TRes lines(
      Iterable<Query$GetMealPlanForDay$getCanteens$lines> Function(
              Iterable<
                  CopyWith$Query$GetMealPlanForDay$getCanteens$lines<
                      Query$GetMealPlanForDay$getCanteens$lines>>)
          _fn);
}

class _CopyWithImpl$Query$GetMealPlanForDay$getCanteens<TRes>
    implements CopyWith$Query$GetMealPlanForDay$getCanteens<TRes> {
  _CopyWithImpl$Query$GetMealPlanForDay$getCanteens(
    this._instance,
    this._then,
  );

  final Query$GetMealPlanForDay$getCanteens _instance;

  final TRes Function(Query$GetMealPlanForDay$getCanteens) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? lines = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetMealPlanForDay$getCanteens(
        lines: lines == _undefined || lines == null
            ? _instance.lines
            : (lines as List<Query$GetMealPlanForDay$getCanteens$lines>),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
  TRes lines(
          Iterable<Query$GetMealPlanForDay$getCanteens$lines> Function(
                  Iterable<
                      CopyWith$Query$GetMealPlanForDay$getCanteens$lines<
                          Query$GetMealPlanForDay$getCanteens$lines>>)
              _fn) =>
      call(
          lines: _fn(_instance.lines
              .map((e) => CopyWith$Query$GetMealPlanForDay$getCanteens$lines(
                    e,
                    (i) => i,
                  ))).toList());
}

class _CopyWithStubImpl$Query$GetMealPlanForDay$getCanteens<TRes>
    implements CopyWith$Query$GetMealPlanForDay$getCanteens<TRes> {
  _CopyWithStubImpl$Query$GetMealPlanForDay$getCanteens(this._res);

  TRes _res;

  call({
    List<Query$GetMealPlanForDay$getCanteens$lines>? lines,
    String? $__typename,
  }) =>
      _res;
  lines(_fn) => _res;
}

class Query$GetMealPlanForDay$getCanteens$lines {
  Query$GetMealPlanForDay$getCanteens$lines({
    required this.id,
    required this.name,
    required this.canteen,
    this.meals,
    this.$__typename = 'Line',
  });

  factory Query$GetMealPlanForDay$getCanteens$lines.fromJson(
      Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$name = json['name'];
    final l$canteen = json['canteen'];
    final l$meals = json['meals'];
    final l$$__typename = json['__typename'];
    return Query$GetMealPlanForDay$getCanteens$lines(
      id: (l$id as String),
      name: (l$name as String),
      canteen: Query$GetMealPlanForDay$getCanteens$lines$canteen.fromJson(
          (l$canteen as Map<String, dynamic>)),
      meals: (l$meals as List<dynamic>?)
          ?.map((e) => Fragment$mealInfo.fromJson((e as Map<String, dynamic>)))
          .toList(),
      $__typename: (l$$__typename as String),
    );
  }

  final String id;

  final String name;

  final Query$GetMealPlanForDay$getCanteens$lines$canteen canteen;

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
    if (!(other is Query$GetMealPlanForDay$getCanteens$lines) ||
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

extension UtilityExtension$Query$GetMealPlanForDay$getCanteens$lines
    on Query$GetMealPlanForDay$getCanteens$lines {
  CopyWith$Query$GetMealPlanForDay$getCanteens$lines<
          Query$GetMealPlanForDay$getCanteens$lines>
      get copyWith => CopyWith$Query$GetMealPlanForDay$getCanteens$lines(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetMealPlanForDay$getCanteens$lines<TRes> {
  factory CopyWith$Query$GetMealPlanForDay$getCanteens$lines(
    Query$GetMealPlanForDay$getCanteens$lines instance,
    TRes Function(Query$GetMealPlanForDay$getCanteens$lines) then,
  ) = _CopyWithImpl$Query$GetMealPlanForDay$getCanteens$lines;

  factory CopyWith$Query$GetMealPlanForDay$getCanteens$lines.stub(TRes res) =
      _CopyWithStubImpl$Query$GetMealPlanForDay$getCanteens$lines;

  TRes call({
    String? id,
    String? name,
    Query$GetMealPlanForDay$getCanteens$lines$canteen? canteen,
    List<Fragment$mealInfo>? meals,
    String? $__typename,
  });
  CopyWith$Query$GetMealPlanForDay$getCanteens$lines$canteen<TRes> get canteen;
  TRes meals(
      Iterable<Fragment$mealInfo>? Function(
              Iterable<CopyWith$Fragment$mealInfo<Fragment$mealInfo>>?)
          _fn);
}

class _CopyWithImpl$Query$GetMealPlanForDay$getCanteens$lines<TRes>
    implements CopyWith$Query$GetMealPlanForDay$getCanteens$lines<TRes> {
  _CopyWithImpl$Query$GetMealPlanForDay$getCanteens$lines(
    this._instance,
    this._then,
  );

  final Query$GetMealPlanForDay$getCanteens$lines _instance;

  final TRes Function(Query$GetMealPlanForDay$getCanteens$lines) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? name = _undefined,
    Object? canteen = _undefined,
    Object? meals = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetMealPlanForDay$getCanteens$lines(
        id: id == _undefined || id == null ? _instance.id : (id as String),
        name: name == _undefined || name == null
            ? _instance.name
            : (name as String),
        canteen: canteen == _undefined || canteen == null
            ? _instance.canteen
            : (canteen as Query$GetMealPlanForDay$getCanteens$lines$canteen),
        meals: meals == _undefined
            ? _instance.meals
            : (meals as List<Fragment$mealInfo>?),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
  CopyWith$Query$GetMealPlanForDay$getCanteens$lines$canteen<TRes> get canteen {
    final local$canteen = _instance.canteen;
    return CopyWith$Query$GetMealPlanForDay$getCanteens$lines$canteen(
        local$canteen, (e) => call(canteen: e));
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

class _CopyWithStubImpl$Query$GetMealPlanForDay$getCanteens$lines<TRes>
    implements CopyWith$Query$GetMealPlanForDay$getCanteens$lines<TRes> {
  _CopyWithStubImpl$Query$GetMealPlanForDay$getCanteens$lines(this._res);

  TRes _res;

  call({
    String? id,
    String? name,
    Query$GetMealPlanForDay$getCanteens$lines$canteen? canteen,
    List<Fragment$mealInfo>? meals,
    String? $__typename,
  }) =>
      _res;
  CopyWith$Query$GetMealPlanForDay$getCanteens$lines$canteen<TRes>
      get canteen =>
          CopyWith$Query$GetMealPlanForDay$getCanteens$lines$canteen.stub(_res);
  meals(_fn) => _res;
}

class Query$GetMealPlanForDay$getCanteens$lines$canteen {
  Query$GetMealPlanForDay$getCanteens$lines$canteen({
    required this.id,
    required this.name,
    this.$__typename = 'Canteen',
  });

  factory Query$GetMealPlanForDay$getCanteens$lines$canteen.fromJson(
      Map<String, dynamic> json) {
    final l$id = json['id'];
    final l$name = json['name'];
    final l$$__typename = json['__typename'];
    return Query$GetMealPlanForDay$getCanteens$lines$canteen(
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
    if (!(other is Query$GetMealPlanForDay$getCanteens$lines$canteen) ||
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
    final l$$__typename = $__typename;
    final lOther$$__typename = other.$__typename;
    if (l$$__typename != lOther$$__typename) {
      return false;
    }
    return true;
  }
}

extension UtilityExtension$Query$GetMealPlanForDay$getCanteens$lines$canteen
    on Query$GetMealPlanForDay$getCanteens$lines$canteen {
  CopyWith$Query$GetMealPlanForDay$getCanteens$lines$canteen<
          Query$GetMealPlanForDay$getCanteens$lines$canteen>
      get copyWith =>
          CopyWith$Query$GetMealPlanForDay$getCanteens$lines$canteen(
            this,
            (i) => i,
          );
}

abstract class CopyWith$Query$GetMealPlanForDay$getCanteens$lines$canteen<
    TRes> {
  factory CopyWith$Query$GetMealPlanForDay$getCanteens$lines$canteen(
    Query$GetMealPlanForDay$getCanteens$lines$canteen instance,
    TRes Function(Query$GetMealPlanForDay$getCanteens$lines$canteen) then,
  ) = _CopyWithImpl$Query$GetMealPlanForDay$getCanteens$lines$canteen;

  factory CopyWith$Query$GetMealPlanForDay$getCanteens$lines$canteen.stub(
          TRes res) =
      _CopyWithStubImpl$Query$GetMealPlanForDay$getCanteens$lines$canteen;

  TRes call({
    String? id,
    String? name,
    String? $__typename,
  });
}

class _CopyWithImpl$Query$GetMealPlanForDay$getCanteens$lines$canteen<TRes>
    implements
        CopyWith$Query$GetMealPlanForDay$getCanteens$lines$canteen<TRes> {
  _CopyWithImpl$Query$GetMealPlanForDay$getCanteens$lines$canteen(
    this._instance,
    this._then,
  );

  final Query$GetMealPlanForDay$getCanteens$lines$canteen _instance;

  final TRes Function(Query$GetMealPlanForDay$getCanteens$lines$canteen) _then;

  static const _undefined = <dynamic, dynamic>{};

  TRes call({
    Object? id = _undefined,
    Object? name = _undefined,
    Object? $__typename = _undefined,
  }) =>
      _then(Query$GetMealPlanForDay$getCanteens$lines$canteen(
        id: id == _undefined || id == null ? _instance.id : (id as String),
        name: name == _undefined || name == null
            ? _instance.name
            : (name as String),
        $__typename: $__typename == _undefined || $__typename == null
            ? _instance.$__typename
            : ($__typename as String),
      ));
}

class _CopyWithStubImpl$Query$GetMealPlanForDay$getCanteens$lines$canteen<TRes>
    implements
        CopyWith$Query$GetMealPlanForDay$getCanteens$lines$canteen<TRes> {
  _CopyWithStubImpl$Query$GetMealPlanForDay$getCanteens$lines$canteen(
      this._res);

  TRes _res;

  call({
    String? id,
    String? name,
    String? $__typename,
  }) =>
      _res;
}
