import 'package:app/model/database/SQLiteDatabaseAccess.dart';
import 'package:app/view_model/repository/data_classes/filter/Frequency.dart';
import 'package:app/view_model/repository/data_classes/meal/Additive.dart';
import 'package:app/view_model/repository/data_classes/meal/Allergen.dart';
import 'package:app/view_model/repository/data_classes/meal/FoodType.dart';
import 'package:app/view_model/repository/data_classes/meal/ImageData.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:app/view_model/repository/data_classes/meal/Price.dart';
import 'package:app/view_model/repository/data_classes/meal/Side.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Canteen.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Line.dart';
import 'package:app/view_model/repository/data_classes/mealplan/MealPlan.dart';
import 'package:app/view_model/repository/error_handling/Result.dart';
import 'package:app/view_model/repository/interface/IDatabaseAccess.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late IDatabaseAccess database;

  const String canteenID = "id";
  final Canteen canteen = Canteen(id: canteenID, name: "name");
  final Canteen otherCanteen = Canteen(id: "24", name: "other name");

  final List<Side> sides = [
    Side(
        id: "01",
        name: "Side vegan",
        foodType: FoodType.vegan,
        price: Price(student: 123, employee: 234, pupil: 345, guest: 356),
        allergens: [],
        additives: []),
    Side(
        id: "02",
        name: "Side vegetarian",
        foodType: FoodType.vegetarian,
        price: Price(student: 333, employee: 453, pupil: 345, guest: 356),
        allergens: [Allergen.lu, Allergen.ka, Allergen.kr],
        additives: []),
    Side(
        id: "03",
        name: "Side fish",
        foodType: FoodType.fish,
        price: Price(student: 143, employee: 654, pupil: 345, guest: 356),
        allergens: [Allergen.lu, Allergen.er, Allergen.kr],
        additives: [Additive.alcohol]),
    Side(
        id: "04",
        name: "Side beef",
        foodType: FoodType.beef,
        price: Price(student: 123, employee: 123, pupil: 345, guest: 356),
        allergens: [Allergen.sn, Allergen.ka, Allergen.kr],
        additives: []),
  ];

  final ImageData image = ImageData(
      id: "1",
      url: "url",
      imageRank: 234,
      positiveRating: 2,
      negativeRating: 3);

  final List<Meal> meals = [
    Meal(
        id: "1",
        name: "vegan Meal",
        foodType: FoodType.vegan,
        relativeFrequency: Frequency.newMeal,
        price: Price(student: 200, employee: 300, pupil: 400, guest: 500),
        allergens: [Allergen.lu, Allergen.ka],
        additives: [Additive.antioxidantAgents],
        images: [image],
        sides: [sides[0]],
        averageRating: 5,
        numberOfRatings: 2,
        individualRating: 1,
        isFavorite: true),
    Meal(
        id: "42",
        name: "vegetarian Meal",
        foodType: FoodType.vegetarian,
        relativeFrequency: Frequency.normal,
        price: Price(student: 200, employee: 300, pupil: 400, guest: 500),
        allergens: [Allergen.lu, Allergen.sn, Allergen.kr],
        additives: null,
        sides: [sides[1], sides[0]],
        averageRating: 4,
        isFavorite: true),
    Meal(
        id: "12",
        name: "fishi Meal",
        foodType: FoodType.fish,
        relativeFrequency: Frequency.rare,
        price: Price(student: 200, employee: 300, pupil: 400, guest: 500),
        allergens: [Allergen.sn, Allergen.er, Allergen.kr],
        additives: [],
        sides: [sides[2], sides[0], sides[1]],
        averageRating: 3,
        isFavorite: false),
    Meal(
        id: "34",
        name: "meal with beef",
        foodType: FoodType.beef,
        relativeFrequency: Frequency.rare,
        price: Price(student: 100, employee: 120, pupil: 130, guest: 140),
        allergens: [Allergen.sn, Allergen.ka, Allergen.kr],
        additives: [],
        sides: [sides[0], sides[1], sides[2], sides[3]],
        averageRating: 2,
        isFavorite: true),
    Meal(
        id: "54",
        name: "pig",
        foodType: FoodType.pork,
        relativeFrequency: Frequency.normal,
        price: Price(student: 123, employee: 456, pupil: 345, guest: 789),
        allergens: [Allergen.sn, Allergen.ka, Allergen.kr],
        additives: [],
        sides: [sides[0], sides[1], sides[2], sides[3]],
        averageRating: 1,
        isFavorite: false),
  ];

  final List<Line> lines = [
    Line(id: "1", name: "Linie 1", canteen: canteen, position: 1),
    Line(id: "2", name: "Linie 2", canteen: canteen, position: 2),
    Line(id: "3", name: "Linie 3", canteen: canteen, position: 3),
    Line(id: "4", name: "Linie 4", canteen: otherCanteen, position: 1)
  ];

  final List<MealPlan> mealplans = [
    MealPlan(
        date: DateTime.now(),
        line: lines[0],
        isClosed: false,
        meals: [meals[0], meals[1]]),
    MealPlan(
        date: DateTime.now(),
        line: lines[1],
        isClosed: false,
        meals: [meals[2]]),
    MealPlan(
        date: DateTime.now(),
        line: lines[2],
        isClosed: false,
        meals: [meals[3], meals[4]]),
    MealPlan(date: DateTime.now(), line: lines[3], isClosed: false, meals: []),
  ];

  setUpAll(() async {
    database = SQLiteDatabaseAccess();
  });

  test("update all", () async {
    await database.updateAll(mealplans);

    final List<MealPlan> result = switch (
    await database.getMealPlan(DateTime.now(), canteen)) {
      Success(value: final value) => value,
      Failure(exception: _) => []
    };

    expect(result.length, 3);
    for (int i = 0; i < 3; i++) {
      expect(result.map((e) => e.line.id).contains(lines[i].id), isTrue);
      expect(result
          .firstWhere((e) => e.line.id == lines[i].id)
          .isClosed,
          mealplans[i].isClosed);
      _hasMeals(mealplans[i].meals,
          result
              .firstWhere((e) => e.line.id == lines[i].id)
              .meals);
    }
  });

  test("update meal", () async {
    Meal updatedMeal = Meal.copy(meal: meals[0], individualRating: 5);

    await database.updateMeal(updatedMeal);
    final Meal storedMeal = switch (await database.getMeal(updatedMeal)) {
      Success(value: final value) => value,
      Failure(exception: _) => meals[0]
    };
    _compareFullMeal(storedMeal, updatedMeal);
  });

  test("get canteens", () async {
    final List<Canteen>? canteens = await database.getCanteens();
    expect(canteens?.length, 2);
    expect(canteens?.map((e) => e.id).contains(canteen.id), isTrue);
    expect(canteens?.map((e) => e.id).contains(otherCanteen.id), isTrue);
  });

  test("get canteen by id", () async {
    Canteen? result = await database.getCanteenById(canteen.id);
    expect(result?.id, canteen.id);
    expect(result?.name, canteen.name);
  });

  test("remove image", () async {
    await database.removeImage(image);
    final Meal storedMeal = switch (await database.getMeal(meals[0])) {
      Success(value: final value) => value,
      Failure(exception: _) => meals[0]
    };
    expect(storedMeal.images?.isEmpty, isTrue);
  });

  group("favorites", () {
    test("add favorite", () async {
      await database.addFavorite(meals[0], DateTime.now(), lines[0]);

      final result = await database.getFavorites();
      expect(result.map((e) => e.meal).contains(meals[0]), isTrue);
    });

    test("add favorite again", () async {
      await database.addFavorite(meals[0], DateTime.now(), lines[0]);

      final result = await database.getFavorites();
      expect(result.map((e) => e.meal).contains(meals[0]), isTrue);
    });

    test("get one favorite", () async {
      final Meal meal = switch (await database.getMealFavorite(meals[0].id)) {
        Success(value: final value) => value,
        Failure(exception: _) =>
            Meal(id: "id",
                name: "name",
                foodType: FoodType.vegetarian,
                price: Price(
                    student: 234, employee: 343, pupil: 345, guest: 543))
      };
      expect(meal, meals[0]);
    });

    test("delete favorite", () async {
      await database.deleteFavorite(meals[0]);

      expect(await database.getFavorites(), []);
    });

    test("delete favorite again", () async {
      await database.deleteFavorite(meals[0]);

      expect(await database.getFavorites(), []);
    });
  });
}

void _compareFullMeal(Meal actual, Meal expected) {
  expect(actual.id, expected.id);
  expect(actual.name, expected.name);
  expect(actual.foodType, expected.foodType);
  expect(actual.price, expected.price);
  _listEquals<Allergen>(actual.allergens ?? [], expected.allergens ?? []);
  _listEquals<Additive>(actual.additives ?? [], expected.additives ?? []);
  expect(listEquals(actual.sides, expected.sides), isTrue);
  expect(actual.individualRating, expected.individualRating);
  expect(actual.numberOfRatings, expected.numberOfRatings);
  expect(actual.averageRating, expected.averageRating);
  expect(actual.lastServed, expected.lastServed);
  expect(actual.nextServed, expected.nextServed);
  expect(actual.relativeFrequency, expected.relativeFrequency);
  _listEquals<ImageData>(actual.images ?? [], expected.images ?? []);
  expect(actual.numberOfOccurance, expected.numberOfOccurance);
  expect(actual.isFavorite, expected.isFavorite);
}

void _hasMeals(List<Meal> expected, List<Meal> actual) {
  expect(actual.length, expected.length);

  for (final meal in expected) {
    expect(actual.contains(meal), isTrue);
  }
}

void _listEquals<T>(List<T> actual, List<T> expected) {
  expect(actual.length, expected.length);

  for (final element in expected) {
    expect(actual.contains(element), isTrue);
  }
}
