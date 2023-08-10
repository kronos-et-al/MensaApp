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

  int? _individualRating;
  int? _numberOfRatings;
  double? _averageRating;
  final DateTime? _lastServed;
  final DateTime? _nextServed;
  final Frequency? _relativeFrequency;
  final List<ImageData>? _images;
  final int? _numberOfOccurance; // is not stored in database
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
    int? numberOfOccurance,
    bool? isFavorite,
  })  : _id = id,
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
        _numberOfOccurance = numberOfOccurance,
        _isFavorite = isFavorite;

  /// This constructor creates a meal with the committed values.
  /// If any values are not committed these values are replaced with the values of the committed Meal.
  /// @param meal The meal that is copied
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
  Meal.copy({
    required Meal meal,
    String? id,
    String? name,
    FoodType? foodType,
    Price? price,
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
    int? numberOfOccurance,
    bool? isFavorite,
  })  : _id = id ?? meal.id,
        _name = name ?? meal.name,
        _foodType = foodType ?? meal.foodType,
        _price = price ?? meal.price,
        _allergens = allergens ?? meal.allergens,
        _additives = additives ?? meal.additives,
        _sides = sides ?? meal.sides,
        _individualRating = individualRating ?? meal.individualRating,
        _numberOfRatings = numberOfRatings ?? meal.numberOfRatings,
        _averageRating = averageRating ?? meal.averageRating,
        _lastServed = lastServed ?? meal.lastServed,
        _nextServed = nextServed ?? meal.nextServed,
        _relativeFrequency = relativeFrequency ?? meal.relativeFrequency,
        _images = images ?? meal.images,
        _numberOfOccurance = numberOfOccurance ?? meal._numberOfOccurance,
        _isFavorite = isFavorite ?? meal.isFavorite;

  /// This method returns the number of occurences in three months.
  /// @return The number of occurences in three months
  int? get numberOfOccurance => _numberOfOccurance;

  /// This method adds the meal to the favorites.
  /// If the meal is already a favorite, it does nothing.
  void setFavorite() {
    _isFavorite = true;
  }

  /// This method deletes the meal from the favorites.
  /// If the meal is not a favorite, it does nothing.
  void deleteFavorite() {
    _isFavorite = false;
  }

  /// This method returns the information of the meal that are stored in the database.
  /// @return The information of the meal that are stored in the database
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

  /// This method returns the additives as a map.
  /// @return The additives as a map
  List<Map<String, dynamic>> additiveToMap() {
    return _additives!
        .map((additive) => {
              'mealID': _id,
              'additive': additive,
            })
        .toList();
  }

  /// This method returns the allerens as a map.
  /// @return The allergens as a map
  List<Map<String, dynamic>> allergenToMap() {
    return _allergens!
        .map((allergen) => {
              'mealID': _id,
              'allergen': allergen,
            })
        .toList();
  }

  /// This method returns the sides as a map.
  /// @return The sides as a map
  String get id => _id;

  /// This method returns the name of the meal.
  /// @return The name of the meal
  String get name => _name;

  /// This method returns the food type of the meal.
  /// @return The food type of the meal
  FoodType get foodType => _foodType;

  /// This method returns the price of the meal.
  /// @return The price of the meal
  Price get price => _price;

  /// This method returns the allergens of the meal.
  /// @return The allergens of the meal
  List<Allergen>? get allergens => _allergens;

  /// This method returns the additives of the meal.
  /// @return The additives of the meal
  List<Additive>? get additives => _additives;

  /// This method returns the sides of the meal.
  /// @return The sides of the meal
  List<Side>? get sides => _sides;

  /// This method returns the individual rating of the meal.
  /// @return The individual rating of the meal
  int? get individualRating => _individualRating;

  /// This method returns the number of ratings of the meal.
  /// @return The number of ratings of the meal
  int? get numberOfRatings => _numberOfRatings;

  /// This method returns the average rating of the meal.
  /// @return The average rating of the meal
  double? get averageRating => _averageRating;

  /// This method returns the date when the meal was last served.
  /// @return The date when the meal was last served
  DateTime? get lastServed => _lastServed;

  /// This method returns the date when the meal will be served next.
  /// @return The date when the meal will be served next
  DateTime? get nextServed => _nextServed;

  /// This method returns the relative frequency of the meal.
  /// @return The relative frequency of the meal
  Frequency? get relativeFrequency => _relativeFrequency;

  /// This method returns the images of the meal.
  /// @return The images of the meal
  List<ImageData>? get images => _images;

  /// This method returns the favorite status of the meal.
  /// @return The favorite status of the meal
  bool get isFavorite => _isFavorite ?? false;


  set individualRating(int? value) {
    _individualRating = value;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Meal && runtimeType == other.runtimeType && _id == other._id;

  @override
  int get hashCode => _id.hashCode;

  set numberOfRatings(int? value) {
    _numberOfRatings = value;
  }

  set averageRating(double? value) {
    _averageRating = value;
  }
}
