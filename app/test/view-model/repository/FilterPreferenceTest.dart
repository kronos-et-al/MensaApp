import 'package:app/view_model/repository/data_classes/filter/FilterPreferences.dart';
import 'package:app/view_model/repository/data_classes/filter/Frequency.dart';
import 'package:app/view_model/repository/data_classes/filter/Sorting.dart';
import 'package:app/view_model/repository/data_classes/meal/Allergen.dart';
import 'package:app/view_model/repository/data_classes/meal/FoodType.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final List<FoodType> categories = [FoodType.vegan, FoodType.vegetarian];
  final List<Allergen> allergens = [Allergen.ei, Allergen.ka];
  const int price = 42;
  const int rating = 42;
  const List<Frequency> frequency = [Frequency.newMeal, Frequency.rare];
  const bool onlyFavorites = true;
  const Sorting sorting = Sorting.rating;
  const bool ascending = false;

  FilterPreferences standard = FilterPreferences();
  FilterPreferences filter = FilterPreferences(
    categories: categories,
    allergens: allergens,
    price: price,
    rating: rating,
    frequency: frequency,
    onlyFavorite: onlyFavorites,
    sortedBy: sorting,
    ascending: ascending,
  );

  setUp(() {
    standard = FilterPreferences();
    filter = FilterPreferences(
      categories: categories,
      allergens: allergens,
      price: price,
      rating: rating,
      frequency: frequency,
      onlyFavorite: onlyFavorites,
      sortedBy: sorting,
      ascending: ascending,
    );
  });

  group("constructor with values", () {
    test("categories", () {
      for (final category in categories) {
        expect(filter.categories.contains(category), isTrue);
      }
      expect(filter.categories.length, categories.length);
    });
    test("allergens",
        () => expect(listEquals(filter.allergens, allergens), isTrue));
    test("price", () => expect(filter.price, price));
    test("rating", () => expect(filter.rating, rating));
    test("frequency",
        () => expect(listEquals(filter.frequency, frequency), isTrue));
    test("onlyFavorites", () => expect(filter.onlyFavorite, onlyFavorites));
    test("sorting", () => expect(filter.sortedBy, sorting));
    test("ascending", () => expect(filter.ascending, ascending));
  });

  group("constructor without values", () {
    standard = FilterPreferences();
    test("categories",
        () => expect(listEquals(standard.categories, FoodType.values), isTrue));
    test("allergens",
        () => expect(listEquals(standard.allergens, Allergen.values), isTrue));
    test("price", () => expect(standard.price, 1000));
    test("rating", () => expect(standard.rating, 1));
    test("frequency",
        () => expect(listEquals(standard.frequency, Frequency.values), isTrue));
    test("onlyFavorites", () => expect(standard.onlyFavorite, false));
    test("sorting", () => expect(standard.sortedBy, Sorting.line));
    test("ascending", () => expect(standard.ascending, true));
  });

  group("categories", () {
    filter = FilterPreferences(
      categories: categories,
      allergens: allergens,
      price: price,
      rating: rating,
      frequency: frequency,
      onlyFavorite: onlyFavorites,
      sortedBy: sorting,
      ascending: ascending,
    );

    test("set all categories", () {
      filter.setAllCategories();
      for (final category in FoodType.values) {
        expect(filter.categories.contains(category), isTrue);
      }
      expect(filter.categories.length, FoodType.values.length);
    });

    // meat categories add and remove
    test("remove Meat Category", () {
      filter.removeMeatCategory(FoodType.fish);
      expect(filter.categories.contains(FoodType.fish), false);
    });

    test("add Meat Category", () {
      filter.addMeatCategory(FoodType.fish);
      expect(filter.categories.contains(FoodType.fish), true);
    });

    // set categories vegan and vegetarian
    test("set categories vegan and vegetarian", () {
      filter.setCategoriesVegetarian();
      expect(
          listEquals(filter.categories,
              [FoodType.vegan, FoodType.vegetarian, FoodType.unknown]),
          isTrue);
    });

    // meat categories add and remove with wrong category
    test("remove Meat Category with wrong category", () {
      filter.removeMeatCategory(FoodType.vegetarian);
      expect(filter.categories.contains(FoodType.vegan), true);
    });

    test("set categories vegan", () {
      filter.setCategoriesVegan();
      expect(listEquals(filter.categories, [FoodType.vegan, FoodType.unknown]),
          isTrue);
    });

    test("add Meat Category with wrong category", () {
      filter.setCategoriesVegan();
      filter.addMeatCategory(FoodType.vegetarian);
      expect(filter.categories.contains(FoodType.vegetarian), false);
    });

    test("remove unknown category", () {
      filter.setAllCategories();
      filter.removeCategoryUnknown();
      expect(filter.categories.contains(FoodType.unknown), false);
    });

    test("add unknown category", () {
      filter.addCategoryUnknown();
      expect(filter.categories.contains(FoodType.unknown), true);
    });
  });

  group("frequencies", () {
    filter = FilterPreferences(
      categories: categories,
      allergens: allergens,
      price: price,
      rating: rating,
      frequency: frequency,
      onlyFavorite: onlyFavorites,
      sortedBy: sorting,
      ascending: ascending,
    );

    test("set all frequencies", () {
      filter.setAllFrequencies();
      expect(listEquals(filter.frequency, Frequency.values), isTrue);
    });

    test("set rare frequency", () {
      filter.setRareFrequency();
      expect(filter.frequency, [Frequency.rare]);
    });

    test("set new frequency", () {
      filter.setNewFrequency();
      expect(filter.frequency, [Frequency.newMeal]);
    });
  });

  group("setter", () {
    standard = FilterPreferences();
    test("allergens", () {
      standard.allergens = allergens;
      expect(listEquals(standard.allergens, allergens), isTrue);
    });

    test("price", () {
      standard.price = price;
      expect(standard.price, price);
    });

    test("rating", () {
      standard.rating = rating;
      expect(standard.rating, rating);
    });

    test("onlyFavorites", () {
      standard.onlyFavorite = onlyFavorites;
      expect(standard.onlyFavorite, onlyFavorites);
    });

    test("sorting", () {
      standard.sortedBy = sorting;
      expect(standard.sortedBy, sorting);
    });

    test("ascending", () {
      standard.ascending = ascending;
      expect(standard.ascending, ascending);
    });
  });
}
