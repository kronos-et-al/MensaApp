import 'package:app/view_model/repository/data_classes/filter/Frequency.dart';
import 'package:app/view_model/repository/data_classes/meal/Additive.dart';
import 'package:app/view_model/repository/data_classes/meal/Allergen.dart';
import 'package:app/view_model/repository/data_classes/meal/FoodType.dart';
import 'package:app/view_model/repository/data_classes/meal/ImageData.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
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
  final List<Side> sides = [
    Side(
        id: id,
        name: name,
        foodType: foodType,
        price: price,
        allergens: allergens,
        additives: additives)
  ];
  const int numberOfRatings = 100;
  const double averageRating = 2000;
  final DateTime lastServed = DateTime.now();
  final DateTime nextServed = DateTime.now();
  const Frequency relativeFrequency = Frequency.newMeal;
  final List<ImageData> images = [
    ImageData(
        id: id,
        url: "url",
        imageRank: 2000,
        positiveRating: 234,
        negativeRating: 234)
  ];
  const int numberOfOccurances = 2345;

  int individualRating = 5;
  bool isFavortie = false;

  Meal meal = Meal(
      id: id,
      name: name,
      foodType: foodType,
      price: price,
      allergens: allergens,
      additives: additives,
      sides: sides,
      numberOfRatings: numberOfRatings,
      averageRating: averageRating,
      lastServed: lastServed,
      nextServed: nextServed,
      relativeFrequency: relativeFrequency,
      images: images,
      numberOfOccurance: numberOfOccurances,
      individualRating: individualRating,
      isFavorite: isFavortie);

  group("constructor", () {
    test("id", () => expect(meal.id, id));

    test("name", () => expect(meal.name, name));

    test("foodType", () => expect(meal.foodType, foodType));

    test("price", () => expect(meal.price, price));

    test("sides", () => expect(meal.sides, sides));

    test(
        "numberOfRatings", () => expect(meal.numberOfRatings, numberOfRatings));

    test("averageRating", () => expect(meal.averageRating, averageRating));

    test("lastServed", () => expect(meal.lastServed, lastServed));

    test("nextServed", () => expect(meal.nextServed, nextServed));

    test("relativeFrequency",
        () => expect(meal.relativeFrequency, relativeFrequency));

    test("images", () => expect(meal.images, images));

    test("numberOfOccurances",
        () => expect(meal.numberOfOccurance, numberOfOccurances));

    test("individualRating",
        () => expect(meal.individualRating, individualRating));

    test("isFavorite", () => expect(meal.isFavorite, isFavortie));

    test("allergens", () => expect(meal.allergens, allergens));

    test("additives", () => expect(meal.additives, additives));
  });

  group("copy constructor whole new Meal copied", () {
    final Meal copy = Meal.copy(meal: meal);

    test("id", () => expect(copy.id, id));

    test("name", () => expect(copy.name, name));

    test("foodType", () => expect(copy.foodType, foodType));

    test("price", () => expect(copy.price, price));

    test("sides", () => expect(copy.sides, sides));

    test(
        "numberOfRatings", () => expect(copy.numberOfRatings, numberOfRatings));

    test("averageRating", () => expect(copy.averageRating, averageRating));

    test("lastServed", () => expect(copy.lastServed, lastServed));

    test("nextServed", () => expect(copy.nextServed, nextServed));

    test("relativeFrequency",
        () => expect(copy.relativeFrequency, relativeFrequency));

    test("images", () => expect(copy.images, images));

    test("numberOfOccurances",
        () => expect(copy.numberOfOccurance, numberOfOccurances));

    test("individualRating",
        () => expect(copy.individualRating, individualRating));

    test("isFavorite", () => expect(copy.isFavorite, isFavortie));

    test("allergens", () => expect(copy.allergens, allergens));

    test("additives", () => expect(copy.additives, additives));
  });

  group("copy constructor nothing copied", () {
    final Meal min = Meal(
        id: "id",
        name: "name",
        foodType: FoodType.vegetarian,
        price: Price(student: 0, employee: 0, pupil: 0, guest: 0));
    final Meal copy = Meal.copy(meal: min,
      id: id,
      name: name,
      foodType: foodType,
      price: price,
      sides: sides,
      numberOfRatings: numberOfRatings,
      averageRating: averageRating,
      lastServed: lastServed,
      nextServed: nextServed,
      relativeFrequency: relativeFrequency,
      images: images,
      numberOfOccurance: numberOfOccurances,
      individualRating: individualRating,
      isFavorite: isFavortie,
      allergens: allergens,
      additives: additives,
    );

    test("id", () => expect(copy.id, id));

    test("name", () => expect(copy.name, name));

    test("foodType", () => expect(copy.foodType, foodType));

    test("price", () => expect(copy.price, price));

    test("sides", () => expect(copy.sides, sides));

    test(
        "numberOfRatings", () => expect(copy.numberOfRatings, numberOfRatings));

    test("averageRating", () => expect(copy.averageRating, averageRating));

    test("lastServed", () => expect(copy.lastServed, lastServed));

    test("nextServed", () => expect(copy.nextServed, nextServed));

    test("relativeFrequency",
        () => expect(copy.relativeFrequency, relativeFrequency));

    test("images", () => expect(copy.images, images));

    test("numberOfOccurances",
        () => expect(copy.numberOfOccurance, numberOfOccurances));

    test("individualRating",
        () => expect(copy.individualRating, individualRating));

    test("isFavorite", () => expect(copy.isFavorite, isFavortie));

    test("allergens", () => expect(copy.allergens, allergens));

    test("additives", () => expect(copy.additives, additives));
  });

  group("favorite", () {
    test("set favorite", () {
      meal.setFavorite();
      expect(meal.isFavorite, true);
    });

    test("delete favorite", () {
      meal.deleteFavorite();
      expect(meal.isFavorite, false);
    });
  });
}
