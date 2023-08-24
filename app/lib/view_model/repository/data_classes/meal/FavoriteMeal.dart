import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Line.dart';

/// This class represents a favorite meal
class FavoriteMeal {
  final Meal _meal;
  final DateTime _servedDate;
  final Line _servedLine;

  /// Creates a new [FavoriteMeal] object
  FavoriteMeal(this._meal, this._servedDate, this._servedLine);

  /// Returns the meal of the favorite.
  Meal get meal => _meal;

  /// Returns a day when the meal was served
  DateTime get servedDate => _servedDate;

  /// Returns a line the meal was once served
  Line get servedLine => _servedLine;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteMeal &&
          runtimeType == other.runtimeType &&
          _meal == other._meal;

  @override
  int get hashCode => _meal.hashCode;
}
