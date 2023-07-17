import 'package:app/view_model/logic/meal/CombinedMealPlanAccess.dart';
import 'package:app/view_model/repository/data_classes/filter/FilterPreferences.dart';
import 'package:app/view_model/repository/data_classes/filter/Frequency.dart';
import 'package:app/view_model/repository/data_classes/meal/FoodType.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:app/view_model/repository/data_classes/meal/Price.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Canteen.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Line.dart';
import 'package:app/view_model/repository/data_classes/mealplan/MealPlan.dart';
import 'package:app/view_model/repository/data_classes/settings/PriceCategory.dart';
import 'package:app/view_model/repository/error_handling/MealPlanException.dart';
import 'package:app/view_model/repository/error_handling/Result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../model/mocks/ApiMock.dart';
import '../model/mocks/DatabaseMock.dart';
import '../model/mocks/LocalStorageMock.dart';

void main() {
  final localStorage = LocalStorageMock();
  final api = ApiMock();
  final database = DatabaseMock();

  late CombinedMealPlanAccess mealPlan;

  const String canteenID = "id";
  final Canteen canteen = Canteen(id: canteenID, name: "name");

  final List<Meal> meals = [
    Meal(
        id: "1",
        name: "vegan Meal",
        foodType: FoodType.vegan,
        relativeFrequency: Frequency.newMeal,
        price: Price(student: 200, employee: 300, pupil: 400, guest: 500)),
    Meal(
        id: "42",
        name: "vegetarian Meal",
        foodType: FoodType.vegetarian,
        relativeFrequency: Frequency.newMeal,
        price: Price(student: 200, employee: 300, pupil: 400, guest: 500)),
    Meal(
        id: "12",
        name: "fishi Meal",
        foodType: FoodType.fish,
        relativeFrequency: Frequency.newMeal,
        price: Price(student: 200, employee: 300, pupil: 400, guest: 500)),
    Meal(
        id: "34",
        name: "meal with beef",
        foodType: FoodType.beef,
        relativeFrequency: Frequency.newMeal,
        price: Price(student: 100, employee: 120, pupil: 130, guest: 140)),
    Meal(
        id: "54",
        name: "pig",
        foodType: FoodType.pork,
        relativeFrequency: Frequency.newMeal,
        price: Price(student: 123, employee: 456, pupil: 345, guest: 789)),
  ];

  final List<Line> lines = [
    Line(id: "1", name: "Linie 1", canteen: canteen, position: 1),
    Line(id: "2", name: "Linie 2", canteen: canteen, position: 2),
    Line(id: "3", name: "Linie 3", canteen: canteen, position: 3)
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
  ];

  final List<MealPlan> closedCanteen = [
    MealPlan(date: DateTime.now(), line: lines[1], isClosed: true, meals: []),
    MealPlan(date: DateTime.now(), line: lines[2], isClosed: true, meals: []),
  ];

  final List<MealPlan> closedLine = [
    MealPlan(date: DateTime.now(), line: lines[1], isClosed: true, meals: []),
    MealPlan(
        date: DateTime.now(),
        line: lines[2],
        isClosed: false,
        meals: [meals[3], meals[4]]),
  ];

  setUp(() {
    when(() => localStorage.getFilterPreferences())
        .thenAnswer((_) async => null);
    when(() => localStorage.getCanteen()).thenAnswer((_) async => canteenID);
    when(() => localStorage.getPriceCategory()).thenAnswer((_) async => PriceCategory.student);

    when(() => api.updateAll())
        .thenAnswer((_) async => Failure(NoConnectionException("error")));

    when(() => database.getCanteenById(canteenID))
        .thenAnswer((_) async => canteen);
    when(() => database.updateAll(mealplans)).thenAnswer((_) async => {});
    when(() => database.getMealPlan(any(), canteen))
        .thenAnswer((_) async => Success(mealplans));
    when(() => database.getFavorites()).thenAnswer((_) async => []);
    
    mealPlan = CombinedMealPlanAccess(localStorage, api, database);
  });
  
  group("initialization", () {
    test("simple initialization", () async {
      expect(await mealPlan.getCanteen(), canteen);
      expect(await mealPlan.getFilterPreferences(), FilterPreferences());

      final date = await mealPlan.getDate();
      expect(date.year, DateTime.now().year);
      expect(date.month, DateTime.now().month);
      expect(date.day, DateTime.now().day);

      final returnedMealPlan = switch (await mealPlan.getMealPlan()) {
        Success(value: final value) => value,
        Failure(exception: _) => []
      };

      for (MealPlan mealplan in mealplans) {
        expect(returnedMealPlan.contains(mealplan), true);
      }
    });

    // todo initialization with other values

  });

  group("change meal plan", () {
    // todo
    // change date
    // change canteen

  });

  group("filter meals", () {
    // todo write test cases
    // change allergens
    // change frequency
    // change favorites
    // change price
    // change rating
    // change category

    // filter sides
    // reset filters
  });

  group("edge cases", () {
    // todo
    // just first line is closed, other are open
    // all lines closed
    // no Data yet
    // all filterd
    // no connection
  });
}