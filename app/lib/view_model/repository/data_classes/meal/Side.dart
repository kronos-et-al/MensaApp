import 'Additive.dart';
import 'Allergen.dart';
import 'FoodType.dart';
import 'Price.dart';

class Side {
  final String _id;
  final String _name;
  final FoodType _foodType;
  final Price _price;
  final List<Allergen> _allergens;
  final List<Additive> _additives;

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

  String get id => _id;

  Map<String, dynamic> toMap() {
    return {
      'sideID': _id,
      'mealID': 0, // TODO implement mealID
      'name': _name,
      'foodType': _foodType,
      ..._price.toMap(),
    };
  }

  List<Map<String, dynamic>> additiveToMap() {
    return _additives.map((additive) => {
      'sideID': _id,
      'additive': additive,
    }).toList();
  }

  List<Map<String, dynamic>> allergenToMap() {
    return _allergens.map((allergen) => {
      'sideID': _id,
      'allergen': allergen,
    }).toList();
  }

  String get name => _name;

  FoodType get foodType => _foodType;

  Price get price => _price;

  List<Allergen> get allergens => _allergens;

  List<Additive> get additives => _additives;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Side && runtimeType == other.runtimeType && _id == other._id;

  @override
  int get hashCode => _id.hashCode;
}
