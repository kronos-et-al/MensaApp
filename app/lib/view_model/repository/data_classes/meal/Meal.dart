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

  int _individualRating;
  int _numberOfRatings;
  double _averageRating;
  final DateTime? _lastServed;
  final DateTime? _nextServed;
  final Frequency? _relativeFrequency;
  final List<ImageData>? _images;
  final int? _numberOfOccurance; // is not stored in database
  bool? _isFavorite;

  /// This constructor creates a meal with the committed values.
  ///
  /// The required values are the [id], [name], [foodType] and [price] of the meal.
  /// The other values are optional and can be null.
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
        _allergens = allergens ?? [],
        _additives = additives ?? [],
        _sides = sides ?? [],
        _individualRating = individualRating ?? 0,
        _numberOfRatings = numberOfRatings ?? 0,
        _averageRating = averageRating ?? 0,
        _lastServed = lastServed,
        _nextServed = nextServed,
        _relativeFrequency = relativeFrequency,
        _images = images ?? [],
        _numberOfOccurance = numberOfOccurance,
        _isFavorite = isFavorite;

  /// This constructor creates a meal with the committed values.
  /// If any values are not committed these values are replaced with the values of [meal].
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
        _individualRating = individualRating ?? meal.individualRating ?? 0,
        _numberOfRatings = numberOfRatings ?? meal.numberOfRatings ?? 0,
        _averageRating = averageRating ?? meal.averageRating ?? 0,
        _lastServed = lastServed ?? meal.lastServed,
        _nextServed = nextServed ?? meal.nextServed,
        _relativeFrequency = relativeFrequency ?? meal.relativeFrequency,
        _images = images ?? meal.images,
        _numberOfOccurance = numberOfOccurance ?? meal._numberOfOccurance,
        _isFavorite = isFavorite ?? meal.isFavorite;

  /// Returns the number of occurences in three months.
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

  /// This method returns the id of the meal.
  String get id => _id;

  /// Returns the name of the meal.
  String get name => _name;

  /// Returns the food type of the meal.
  FoodType get foodType => _foodType;

  /// Returns the price of the meal.
  Price get price => _price;

  /// Returns the allergens of the meal.
  List<Allergen>? get allergens => _allergens;

  /// Returns the additives of the meal.
  List<Additive>? get additives => _additives;

  /// Returns the sides of the meal.
  List<Side>? get sides => _sides;

  /// This method returns the individual rating of the meal.
  int get individualRating => _individualRating;

  /// This method returns the number of ratings of the meal.
  int get numberOfRatings => _numberOfRatings;

  /// This method returns the average rating of the meal.
  double get averageRating => _averageRating;

  /// Returns the date when the meal was last served.
  DateTime? get lastServed => _lastServed;

  /// Returns the date when the meal will be served next.
  DateTime? get nextServed => _nextServed;

  /// Returns the relative frequency of the meal.
  Frequency? get relativeFrequency => _relativeFrequency;

  /// Returns the images of the meal.
  List<ImageData>? get images => _images;

  /// Returns the favorite status of the meal.
  bool get isFavorite => _isFavorite ?? false;

  /// This method sets the individual rating.
  set individualRating(int value) {
    _individualRating = value;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Meal && runtimeType == other.runtimeType && _id == other._id;

  @override
  int get hashCode => _id.hashCode;

  /// This method sets the number of ratings
  set numberOfRatings(int value) {
    _numberOfRatings = value;
  }

  /// This method sets the average rating
  set averageRating(double value) {
    _averageRating = value;
  }

  /// This method removes the committed image form [images].
  void removeImage(ImageData image) {
    _images!.remove(image);
  }
}
