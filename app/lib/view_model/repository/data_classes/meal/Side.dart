import 'Additive.dart';
import 'Allergen.dart';
import 'EnvironmentInfo.dart';
import 'FoodType.dart';
import 'NutritionData.dart';
import 'Price.dart';

/// This class represents a side.
class Side {
  final String _id;
  final String _name;
  final FoodType _foodType;
  final Price _price;
  final List<Allergen> _allergens;
  final List<Additive> _additives;
  final NutritionData? _nutritionData;
  final EnvironmentInfo? _environmentInfo;

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
    NutritionData? nutritionData,
    EnvironmentInfo? environmentInfo,
  })  : _id = id,
        _name = name,
        _foodType = foodType,
        _price = price,
        _allergens = allergens,
        _additives = additives,
        _nutritionData = nutritionData,
        _environmentInfo = environmentInfo;

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
    NutritionData? nutritionData,
    EnvironmentInfo? environmentInfo,
  })  : _id = id ?? side.id,
        _name = name ?? side.name,
        _foodType = foodType ?? side.foodType,
        _price = price ?? side.price,
        _allergens = allergens ?? side.allergens,
        _additives = additives ?? side.additives,
        _nutritionData = nutritionData ?? side.nutritionData,
        _environmentInfo = environmentInfo ?? side.environmentInfo;

  /// Returns the id of the side.
  String get id => _id;

  /// This method returns the name of the side.
  String get name => _name;

  /// Returns the food type of the side.
  FoodType get foodType => _foodType;

  /// Returns the price of the side.
  Price get price => _price;

  /// Returns the allergens of the side.
  List<Allergen> get allergens => _allergens;

  /// Returns the additives of the side.
  List<Additive> get additives => _additives;

  /// Returns nutrition data of the side.
  NutritionData? get nutritionData => _nutritionData;

  /// Returns the environment info of the side.
  EnvironmentInfo? get environmentInfo => _environmentInfo;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Side && runtimeType == other.runtimeType && _id == other._id;

  @override
  int get hashCode => _id.hashCode;
}
