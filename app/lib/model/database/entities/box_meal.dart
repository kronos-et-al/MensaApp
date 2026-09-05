import 'package:objectbox/objectbox.dart';
import 'box_image.dart';
import 'box_price.dart';
import 'box_nutrition_data.dart';
import 'box_environment_info.dart';
import 'box_meal_plan.dart';

@Entity()
class BoxMeal {
  int id = 0;

  @Unique()
  String mealId;

  String name;
  String foodType; // store enum name
  int individualRating;
  int numberOfRatings;
  double averageRating;
  @Property(type: PropertyType.date)
  DateTime? lastServed;
  @Property(type: PropertyType.date)
  DateTime? nextServed;
  String? relativeFrequency; // store enum name
  List<String> allergens;
  List<String> additives;
  bool isSide;

  // Relations
  final price = ToOne<BoxPrice>();
  final nutritionData = ToOne<BoxNutritionData>();
  final environmentInfo = ToOne<BoxEnvironmentInfo>();
  final images = ToMany<BoxImage>();
  final sides = ToMany<BoxMeal>(); // Self-relation for meals that have sides

  @Backlink('meals')
  final plans = ToMany<BoxMealPlan>();

  BoxMeal({
    required this.mealId,
    required this.name,
    required this.foodType,
    required this.individualRating,
    required this.numberOfRatings,
    required this.averageRating,
    this.lastServed,
    this.nextServed,
    this.relativeFrequency,
    required this.allergens,
    required this.additives,
    required this.isSide,
  });
}
