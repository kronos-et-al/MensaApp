import 'package:flutter/foundation.dart';

import '../meal/Meal.dart';
import 'Line.dart';

/// This class represents a meal plan.
class MealPlan {
  final DateTime _date;
  final Line _line;
  final bool _isClosed;
  final List<Meal> _meals;

  /// This constructor creates a new meal plan.
  ///
  /// The values needed are the [date] as [DateTime] and the [line] of the meal plan, the information if the line is closed on the date of the meal plan and the [meals] of the meal plan.
  MealPlan({
    required DateTime date,
    required Line line,
    required bool isClosed,
    required List<Meal> meals,
  })  : _date = date,
        _line = line,
        _isClosed = isClosed,
        _meals = meals;

  /// This constructor creates a new meal plan with the committed values.
  /// If any values are not committed these values are replaced with the values of the committed [mealPlan].
  MealPlan.copy({
    required MealPlan mealPlan,
    DateTime? date,
    Line? line,
    bool? isClosed,
    List<Meal>? meals,
  })  : _date = date ?? mealPlan.date,
        _line = line ?? mealPlan.line,
        _isClosed = isClosed ?? mealPlan.isClosed,
        _meals = meals ?? mealPlan.meals;

  /// Returns the date of the meal plan.
  DateTime get date => _date;

  /// Returns the line of the meal plan.
  Line get line => _line;

  /// Returns the information if the line is closed on the date of the meal plan.
  bool get isClosed => _isClosed;

  /// Returns the meals of the meal plan.
  List<Meal> get meals => _meals;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MealPlan &&
          runtimeType == other.runtimeType &&
          _date.year == other._date.year &&
          _date.month == other._date.month &&
          _date.day == other._date.day &&
          _line == other._line &&
          _isClosed == other._isClosed &&
          listEquals(_meals, other._meals);

  @override
  int get hashCode =>
      _date.hashCode ^ _line.hashCode ^ _isClosed.hashCode ^ _meals.hashCode;
}
