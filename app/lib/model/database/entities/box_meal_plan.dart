import 'package:objectbox/objectbox.dart';
import 'box_line.dart';
import 'box_meal.dart';

@Entity()
class BoxMealPlan {
  int id = 0;

  @Property(type: PropertyType.date)
  DateTime date;
  bool isClosed;

  final line = ToOne<BoxLine>();
  final meals = ToMany<BoxMeal>();

  BoxMealPlan({required this.date, required this.isClosed});
}
