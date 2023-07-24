import '../filter/Frequency.dart';
import 'Additive.dart';
import 'Allergen.dart';
import 'FoodType.dart';
import 'ImageData.dart';
import 'Price.dart';
import 'Side.dart';

/// This class represents a meal.
class Meal {
  final String _id;
  final String _name;
  final FoodType _foodType;
  final Price _price;

  final List<Allergen>? _allergens;
  final List<Additive>? _additives;
  final List<Side>? _sides;

  final int? _individualRating;
  final int? _numberOfRatings;
  final double? _averageRating;
  final DateTime? _lastServed;
  final DateTime? _nextServed;
  final Frequency? _relativeFrequency;
  final List<ImageData>? _images;
  bool? _isFavorite;

  /// This constructor creates a meal with the committed values.
  /// @param id The id of the meal
  /// @param name The name of the meal
  /// @param foodType The food type of the meal
  /// @param price The price of the meal
  /// @param allergens The allergens of the meal
  /// @param additives The additives of the meal
  /// @param sides The sides of the meal
  /// @param individualRating The individual rating of the meal
  /// @param numberOfRatings The number of ratings of the meal
  /// @param averageRating The average rating of the meal
  /// @param lastServed The date when the meal was last served
  /// @param nextServed The date when the meal will be served next
  /// @param relativeFrequency The relative frequency of the meal
  /// @param images The images of the meal
  /// @param isFavorite The favorite status of the meal
  /// @return A meal with the committed values
  Meal({
    required String id,
    required String name,
    required FoodType foodType,
    required Price price,
    List<Allergen>? allergens,
    List<Additive>? additives,
    List<Side>? sides,
    int? individualRating,
    int? numberOfRatings,
    double? averageRating,
    DateTime? lastServed,
    DateTime? nextServed,
    Frequency? relativeFrequency,
    List<ImageData>? images,
    bool? isFavorite,
  })
      : _id = id,
        _name = name,
        _foodType = foodType,
        _price = price,
        _allergens = allergens,
        _additives = additives,
        _sides = sides,
        _individualRating = individualRating,
        _numberOfRatings = numberOfRatings,
        _averageRating = averageRating,
        _lastServed = lastServed,
        _nextServed = nextServed,
        _relativeFrequency = relativeFrequency,
        _images = images,
        _isFavorite = isFavorite;

  void setFavorite() {
    _isFavorite = true;
  }

  void deleteFavorite() {
    _isFavorite = false;
  }

  Map<String, dynamic> toMap() {
    return {
      'mealID': _id,
      'name': _name,
      'foodType': _foodType,
      ..._price.toMap(),
      'individualRating': _individualRating,
      'numberOfRatings': _numberOfRatings,
      'averageRating': _averageRating,
      'lastServed': _lastServed,
      'nextServed': _nextServed,
      'relativeFrequency': _relativeFrequency,
    };
  }

  List<Map<String, dynamic>> additiveToMap() {
    return _additives!.map((additive) => {
      'mealID': _id,
      'additive': additive,
    }).toList();
  }

  List<Map<String, dynamic>> allergenToMap() {
    return _allergens!.map((allergen) => {
      'mealID': _id,
      'allergen': allergen,
    }).toList();
  }

  String get id => _id;

  String get name => _name;

  FoodType get foodType => _foodType;

  Price get price => _price;

  List<Allergen>? get allergens => _allergens;

  List<Additive>? get additives => _additives;

  List<Side>? get sides => _sides;

  int? get individualRating => _individualRating;

  int? get numberOfRatings => _numberOfRatings;

  double? get averageRating => _averageRating;

  DateTime? get lastServed => _lastServed;

  DateTime? get nextServed => _nextServed;

  Frequency? get relativeFrequency => _relativeFrequency;

  List<ImageData>? get images => _images;

  bool get isFavorite => _isFavorite ?? false;
}
