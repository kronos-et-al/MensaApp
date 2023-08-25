import 'package:app/view_model/repository/data_classes/meal/FoodType.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:app/view_model/repository/data_classes/meal/Price.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Canteen.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Line.dart';
import 'package:app/view_model/repository/data_classes/mealplan/MealPlan.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final DateTime date = DateTime.now();
  final Line line = Line(
      id: "1", name: "2", canteen: Canteen(id: "1", name: "2"), position: 1);
  const bool isClosed = false;
  final List<Meal> meals = [
    Meal(
        id: "1",
        name: "2",
        foodType: FoodType.vegan,
        price: Price(student: 100, employee: 200, pupil: 300, guest: 400),
        allergens: [],
        additives: [])
  ];

  MealPlan mealPlan = MealPlan(
      date: date, line: line, isClosed: isClosed, meals: meals);

  group("constructor", () {
    test("date", () => expect(mealPlan.date, date));
    test("line", () => expect(mealPlan.line, line));
    test("isClosed", () => expect(mealPlan.isClosed, isClosed));
    test("meals", () => expect(mealPlan.meals, meals));
  });

  group("copy constructor all", () {
    MealPlan copy = MealPlan.copy(mealPlan: mealPlan);
    test("date", () => expect(copy.date, date));
    test("line", () => expect(copy.line, line));
    test("isClosed", () => expect(copy.isClosed, isClosed));
    test("meals", () => expect(copy.meals, meals));
  });

  group("copy constructor nothing copied", () {
    MealPlan min = MealPlan(
        date: DateTime.now(),
        line: Line(
            id: "42",
            name: "name",
            canteen: Canteen(id: "42", name: "name"),
            position: 12),
        isClosed: false,
        meals: []);

    MealPlan copy = MealPlan.copy(
        mealPlan: min,
        date: date,
        line: line,
        isClosed: isClosed,
        meals: meals);

    test("date", () => expect(copy.date, date));
    test("line", () => expect(copy.line, line));
    test("isClosed", () => expect(copy.isClosed, isClosed));
    test("meals", () => expect(copy.meals, meals));
  });
}
