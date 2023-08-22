import 'package:app/model/database/SQLiteDatabaseAccess.dart';
import 'package:app/view_model/logic/favorite/FavoriteMealAccess.dart';
import 'package:app/view_model/repository/data_classes/meal/FoodType.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:app/view_model/repository/data_classes/meal/Price.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  SQLiteDatabaseAccess database = SQLiteDatabaseAccess();
  FavoriteMealAccess access = FavoriteMealAccess(database);

  final meal = Meal(
      id: "bd3c88f9-5dc8-4773-85dc-53305930e7b6",
      name: "Best meal",
      foodType: FoodType.vegetarian,
      price: Price(student: 1, employee: 23, pupil: 5, guest: 15));

  test("add favorite meal", () async {
    await access.addFavoriteMeal(meal);

    expect(await access.isFavoriteMeal(meal), isTrue);
    final result = await access.getFavoriteMeals();
    expect(result.contains(meal), isTrue);

    // check if changes are updated in database
    final favorites = await database.getFavorites();
    expect(favorites.contains(meal), isTrue);
  });

  test("delete favorite meal", () async {
    await access.removeFavoriteMeal(meal);

    expect(await access.isFavoriteMeal(meal), isFalse);
    final result = await access.getFavoriteMeals();
    expect(result.contains(meal), isFalse);

    // check if changes are updated in database
    final favorites = await database.getFavorites();
    expect(favorites.contains(meal), isFalse);
  });
}