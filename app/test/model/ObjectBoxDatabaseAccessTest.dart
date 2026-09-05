import 'package:app/model/database/ObjectBoxDatabaseAccess.dart';
import 'package:app/model/database/objectbox.g.dart';
import 'package:app/view_model/repository/data_classes/meal/FoodType.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:app/view_model/repository/data_classes/meal/Price.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Canteen.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Line.dart';
import 'package:app/view_model/repository/data_classes/mealplan/MealPlan.dart';
import 'package:app/view_model/repository/error_handling/Result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late Store store;
  late ObjectBoxDatabaseAccess database;

  setUpAll(() async {
    store = await openStore(directory: 'memory:db-test');
    database = ObjectBoxDatabaseAccess(store);
  });

  tearDownAll(() {
    store.close();
  });

  final canteen = Canteen(id: "c1", name: "Canteen 1");
  final line = Line(id: "l1", name: "Line 1", canteen: canteen, position: 1);
  final meal = Meal(
    id: "m1",
    name: "Meal 1",
    foodType: FoodType.vegan,
    price: Price(student: 100, employee: 200, pupil: 300, guest: 400),
  );
  final date = DateTime(2023, 10, 12);
  final mealPlan = MealPlan(
    date: date,
    line: line,
    isClosed: false,
    meals: [meal],
  );

  test("update and get meal plan", () async {
    await database.updateAll([mealPlan]);
    final result = await database.getMealPlan(date, canteen);

    expect(result is Success, isTrue);
    final plans = (result as Success).value;
    expect(plans.length, 1);
    expect(plans[0].line.id, line.id);
    expect(plans[0].meals[0].id, meal.id);
  });

  test("favorite operations", () async {
    await database.addFavorite(meal, date, line);
    final favorites = await database.getFavorites();
    expect(favorites.any((f) => f.meal.id == meal.id), isTrue);

    await database.deleteFavorite(meal);
    final favoritesAfter = await database.getFavorites();
    expect(favoritesAfter.any((f) => f.meal.id == meal.id), isFalse);
  });
}
