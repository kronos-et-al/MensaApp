import 'package:app/view_model/logic/favorite/FavoriteMealAccess.dart';
import 'package:app/view_model/repository/data_classes/meal/FoodType.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:app/view_model/repository/data_classes/meal/Price.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../model/mocks/DatabaseMock.dart';

void main () {
  final database = DatabaseMock();

  late FavoriteMealAccess favorites;

  final meal1 = Meal(id: "1",
      name: "vegan Meal",
      foodType: FoodType.vegan,
      price: Price(student: 200, employee: 300, pupil: 400, guest: 500));
  final meal2 = Meal(id: "42",
      name: "vegetarian Meal",
      foodType: FoodType.vegetarian,
      price: Price(student: 200, employee: 300, pupil: 400, guest: 500));
  final meal3 = Meal(id: "12",
      name: "fishi Meal",
      foodType: FoodType.fish,
      price: Price(student: 200, employee: 300, pupil: 400, guest: 500));
  var meals = [meal1, meal2];

  setUp(() {
    when(() => database.getFavorites()).thenAnswer((_) async => meals);
    favorites = FavoriteMealAccess(database);
  });

  test("Test initialisation", () async {
    expect(await favorites.getFavoriteMeals(), meals);
  });

  group("Favorite check", () {
    test("is Favorite", () async {
      expect(await favorites.isFavoriteMeal(meal1), true);
    });

    test("is no favorite", () async {
      expect(await favorites.isFavoriteMeal(meal3), false);
    });
  });

  group("Test adding and removing meals", () {
    test("add meal already in meals", () async {
      await favorites.addFavoriteMeal(meal1);
      verifyNever(() => database.addFavorite(meal1));
      expect(await favorites.getFavoriteMeals(), meals);
    });

    test("remove meal not in meals", () async {
      await favorites.removeFavoriteMeal(meal3);
      verifyNever(() => database.deleteFavorite(meal3));
      expect(await favorites.getFavoriteMeals(), meals);
    });

    test("add meal to meals (not in meals)", () async {
      when(() => database.addFavorite(meal3)).thenAnswer((_) async {});
      await favorites.addFavoriteMeal(meal3);
      verify(() => database.addFavorite(meal3)).called(1);
      meals.add(meal3);
      expect(await favorites.getFavoriteMeals(), meals);
    });

    test("remove meal from meals (that is in meals)", () async {
      when(() => database.deleteFavorite(meal1)).thenAnswer((_) async {});
      await favorites.removeFavoriteMeal(meal1);
      verify(() => database.deleteFavorite(meal1)).called(1);
      meals.remove(meal1);
      expect(await favorites.getFavoriteMeals(), meals);
    });
  });
}