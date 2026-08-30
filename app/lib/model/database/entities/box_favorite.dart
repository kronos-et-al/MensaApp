import 'package:objectbox/objectbox.dart';
import 'box_line.dart';
import 'box_meal.dart';

@Entity()
class BoxFavorite {
  int id = 0;

  DateTime servedDate;

  final line = ToOne<BoxLine>();
  final meal = ToOne<BoxMeal>();

  BoxFavorite({required this.servedDate});
}
