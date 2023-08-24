import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Line.dart';

class FavoriteMeal {
  final Meal _meal;
  final DateTime _servedDate;
  final Line _servedLine;

  FavoriteMeal(this._meal, this._servedDate, this._servedLine);

  Meal get meal => _meal;

  DateTime get servedDate => _servedDate;

  Line get servedLine => _servedLine;
}
