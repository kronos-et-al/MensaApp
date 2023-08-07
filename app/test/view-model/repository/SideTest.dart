import 'package:app/view_model/repository/data_classes/meal/Additive.dart';
import 'package:app/view_model/repository/data_classes/meal/Allergen.dart';
import 'package:app/view_model/repository/data_classes/meal/FoodType.dart';
import 'package:app/view_model/repository/data_classes/meal/Price.dart';
import 'package:app/view_model/repository/data_classes/meal/Side.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const String id = "42";
  const String name = "vegan Meal";
  const FoodType foodType = FoodType.vegan;
  final Price price =
      Price(student: 200, employee: 300, pupil: 400, guest: 500);
  const List<Allergen> allergens = [Allergen.ei, Allergen.ka];
  const List<Additive> additives = [
    Additive.antioxidantAgents,
    Additive.alcohol
  ];

  Side side = Side(
      id: id,
      name: name,
      foodType: foodType,
      price: price,
      allergens: allergens,
      additives: additives);

  group("constructor", () {
    test("id", () => expect(side.id, id));
    test("name", () => expect(side.name, name));
    test("foodType", () => expect(side.foodType, foodType));
    test("price", () => expect(side.price, price));
    test("allergens", () => expect(side.allergens, allergens));
    test("additives", () => expect(side.additives, additives));
  });

  group("copy constructor all", () {
    Side copy = Side.copy(side: side);
    test("id", () => expect(copy.id, id));
    test("name", () => expect(copy.name, name));
    test("foodType", () => expect(copy.foodType, foodType));
    test("price", () => expect(copy.price, price));
    test("allergens", () => expect(copy.allergens, allergens));
    test("additives", () => expect(copy.additives, additives));
  });

  group("copy constructor nothing copied", () {
    Side min = Side(
        id: "1",
        name: "2",
        foodType: FoodType.vegan,
        price: Price(student: 100, employee: 200, pupil: 300, guest: 400),
        allergens: [],
        additives: []);
    Side copy = Side.copy(
        side: side,
        id: id,
        name: name,
        foodType: foodType,
        price: price,
        allergens: allergens,
        additives: additives);

    test("id", () => expect(copy.id, id));
    test("name", () => expect(copy.name, name));
    test("foodType", () => expect(copy.foodType, foodType));
    test("price", () => expect(copy.price, price));
    test("allergens", () => expect(copy.allergens, allergens));
    test("additives", () => expect(copy.additives, additives));
  });

  group("equals", () {
    Side equal = Side(
        id: id,
        name: name,
        foodType: foodType,
        price: price,
        allergens: allergens,
        additives: additives);

    Side notEqual = Side(
        id: "1",
        name: "2",
        foodType: FoodType.vegan,
        price: Price(student: 100, employee: 200, pupil: 300, guest: 400),
        allergens: [],
        additives: []);

    test("equal", () => expect(side == equal, true));
    test("not equal", () => expect(side == notEqual, false));
  });
}
