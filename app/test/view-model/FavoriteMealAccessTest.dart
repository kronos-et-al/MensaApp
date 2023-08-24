import 'package:app/view_model/logic/favorite/FavoriteMealAccess.dart';
import 'package:app/view_model/repository/data_classes/meal/FavoriteMeal.dart';
import 'package:app/view_model/repository/data_classes/meal/FoodType.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:app/view_model/repository/data_classes/meal/Price.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Canteen.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Line.dart';
import 'package:app/view_model/repository/error_handling/NoMealException.dart';
import 'package:app/view_model/repository/error_handling/Result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../model/mocks/ApiMock.dart';
import '../model/mocks/DatabaseMock.dart';

void main() {
  final database = DatabaseMock();

  final api = ApiMock();

  late FavoriteMealAccess favorites;

  final meal1 = Meal(
      id: "1",
      name: "vegan Meal",
      foodType: FoodType.vegan,
      price: Price(student: 200, employee: 300, pupil: 400, guest: 500));
  final meal2 = Meal(
      id: "42",
      name: "vegetarian Meal",
      foodType: FoodType.vegetarian,
      price: Price(student: 200, employee: 300, pupil: 400, guest: 500));
  final meal3 = Meal(
      id: "12",
      name: "fishi Meal",
      foodType: FoodType.fish,
      price: Price(student: 200, employee: 300, pupil: 400, guest: 500));
  var meals = [meal1, meal2];

  final line = Line(
      id: "sdf",
      name: "name",
      canteen: Canteen(id: "id", name: "name"),
      position: 1);

  setUpAll(() {
    when(() => database.getFavorites())
        .thenAnswer((_) async => _getFavoriteMeals(meals, line));
    when(() => api.getMeal(meal1, line, any())).thenAnswer((_) async => Failure(NoMealException("error")));
    when(() => api.getMeal(meal2, line, any())).thenAnswer((_) async => Failure(NoMealException("error")));
    favorites = FavoriteMealAccess(database, api);
  });

  test("Test initialisation", () async {
    _listEquals(await favorites.getFavoriteMeals(), _getFavoriteMeals(meals, line));
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
      await favorites.addFavoriteMeal(meal1, DateTime.now(), line);
      verifyNever(() => database.addFavorite(meal1, any(), line));
      expect(await favorites.getFavoriteMeals(), _getFavoriteMeals(meals, line));
    });

    test("remove meal not in meals", () async {
      await favorites.removeFavoriteMeal(meal3);
      verifyNever(() => database.deleteFavorite(meal3));
      expect(await favorites.getFavoriteMeals(), _getFavoriteMeals(meals, line));
    });

    test("add meal to meals (not in meals)", () async {
      final favoriteMeals = _getFavoriteMeals(meals, line);
      favoriteMeals.add(FavoriteMeal(meal3, DateTime.now(), line));

      when(() => database.getFavorites()).thenAnswer((_) async => favoriteMeals);
      when(() => database.addFavorite(meal3, any(), line)).thenAnswer((_) async {});
      await favorites.addFavoriteMeal(meal3, DateTime.now(), line);
      verify(() => database.addFavorite(meal3, any(), line)).called(1);

      expect(await favorites.isFavoriteMeal(meal3), isTrue);
    });

    test("remove meal from meals (that is in meals)", () async {
      when(() => database.getFavorites()).thenAnswer((_) async => _getFavoriteMeals(meals, line));
      when(() => database.deleteFavorite(meal1)).thenAnswer((_) async {});
      await favorites.removeFavoriteMeal(meal1);
      verify(() => database.deleteFavorite(meal1)).called(1);

      final List<FavoriteMeal> result = await favorites.getFavoriteMeals();
      expect(result.map((e) => e.meal).contains(meal3), isFalse);
    });
  });
}

void _listEquals<T>(List<T> actual, List<T> expected) {
  expect(actual.length, expected.length);

  for (final element in expected) {
    expect(actual.contains(element), isTrue);
  }
}

List<FavoriteMeal> _getFavoriteMeals(List<Meal> meals, line) {
  List<FavoriteMeal> favorites = List.empty(growable: true);
  for (final meal in meals) {
    favorites.add(FavoriteMeal(meal, DateTime.now(), line));
  }
  return favorites;
}
