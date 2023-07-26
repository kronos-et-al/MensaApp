import '../meal/Meal.dart';
import 'Line.dart';

class MealPlan {

  final DateTime _date;
  final Line _line;
  final bool _isClosed;
  final List<Meal> _meals;

  MealPlan({
    required DateTime date,
    required Line line,
    required bool isClosed,
    required List<Meal> meals,
  })  : _date = date,
        _line = line,
        _isClosed = isClosed,
        _meals = meals;

  DateTime get date => _date;

  Line get line => _line;

  bool get isClosed => _isClosed;

  List<Meal> get meals => _meals;

  Map<String, dynamic> toMap() {
    return {
      'date': _date,
      'lineID': _line.id,
      'isClosed': _isClosed,
    };
  }

}