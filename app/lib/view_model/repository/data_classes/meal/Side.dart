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

  /// This constructor creates a new side.
  /// @param id The id of the side
  /// @param name The name of the side
  /// @param foodType The food type of the side
  /// @param price The price of the side
  /// @param allergens The allergens of the side
  /// @param additives The additives of the side
  /// @return A new side
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

  /// This constructor creates a new side with the committed values.
  /// If any values are not committed these values are replaced with the values of the committed side.
  /// @param side The side that should be copied
  /// @param id The id of the side
  /// @param name The name of the side
  /// @param foodType The food type of the side
  /// @param price The price of the side
  /// @param allergens The allergens of the side
  /// @param additives The additives of the side
  /// @return A new side with the committed values
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

  /// This method returns the id of the side.
  /// @return The id of the side
  String get id => _id;

  /// This method returns all attributes needed for the database.
  /// @return All attributes needed for the database
  Map<String, dynamic> toMap() {
    return {
      'sideID': _id,
      'mealID': 0, // TODO implement mealID
      'name': _name,
      'foodType': _foodType,
      ..._price.toMap(),
    };
  }

  /// This method returns the additives as a map.
  /// @return The additives as a map
  List<Map<String, dynamic>> additiveToMap() {
    return _additives
        .map((additive) => {
              'sideID': _id,
              'additive': additive,
            })
        .toList();
  }

  /// This method returns the allerens as a map.
  /// @return The allergens as a map
  List<Map<String, dynamic>> allergenToMap() {
    return _allergens
        .map((allergen) => {
              'sideID': _id,
              'allergen': allergen,
            })
        .toList();
  }

  /// This method returns the name of the side.
  /// @return The name of the side
  String get name => _name;

  /// This method returns the food type of the side.
  /// @return The food type of the side
  FoodType get foodType => _foodType;

  /// This method returns the price of the side.
  /// @return The price of the side
  Price get price => _price;

  /// This method returns the allergens of the side.
  /// @return The allergens of the side
  List<Allergen> get allergens => _allergens;

  /// This method returns the additives of the side.
  /// @return The additives of the side
  List<Additive> get additives => _additives;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Side && runtimeType == other.runtimeType && _id == other._id;

  @override
  int get hashCode => _id.hashCode;
}
