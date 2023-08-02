import 'Additive.dart';
import 'Allergen.dart';
import 'FoodType.dart';
import 'Price.dart';

/// This class represents a side.
class Side {
  final String _id;
  final String _name;
  final FoodType _foodType;
  final Price _price;
  final List<Allergen> _allergens;
  final List<Additive> _additives;

  /// Constructor that creates a new side.
  ///
  /// The required values are the [id], [name], [foodType], [price], [allergens] and [additives] of the side.
  Side({
    required String id,
    required String name,
    required FoodType foodType,
    required Price price,
    required List<Allergen> allergens,
    required List<Additive> additives,
  })  : _id = id,
        _name = name,
        _foodType = foodType,
        _price = price,
        _allergens = allergens,
        _additives = additives;

  /// Constructor that creates a new side with the committed values.
  /// If any values are not committed these values are replaced with the values of [side].
  Side.copy({
    required Side side,
    String? id,
    String? name,
    FoodType? foodType,
    Price? price,
    List<Allergen>? allergens,
    List<Additive>? additives,
  })  : _id = id ?? side.id,
        _name = name ?? side.name,
        _foodType = foodType ?? side.foodType,
        _price = price ?? side.price,
        _allergens = allergens ?? side.allergens,
        _additives = additives ?? side.additives;

  /// Returns the id of the side.
  String get id => _id;

  /// Returns all attributes needed for the database.
  Map<String, dynamic> toMap() {
    return {
      'sideID': _id,
      'mealID': 0, // TODO implement mealID
      'name': _name,
      'foodType': _foodType,
      ..._price.toMap(),
    };
  }

  /// Returns the additives as a map.
  List<Map<String, dynamic>> additiveToMap() {
    return _additives
        .map((additive) => {
              'sideID': _id,
              'additive': additive,
            })
        .toList();
  }

  /// Returns the allerens as a map.
  List<Map<String, dynamic>> allergenToMap() {
    return _allergens
        .map((allergen) => {
              'sideID': _id,
              'allergen': allergen,
            })
        .toList();
  }

  /// Returns the name of the side.
  String get name => _name;

  /// Returns the food type of the side.
  FoodType get foodType => _foodType;

  /// Returns the price of the side.
  Price get price => _price;

  /// Returns the allergens of the side.
  List<Allergen> get allergens => _allergens;

  /// Returns the additives of the side.
  List<Additive> get additives => _additives;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Side && runtimeType == other.runtimeType && _id == other._id;

  @override
  int get hashCode => _id.hashCode;
}
