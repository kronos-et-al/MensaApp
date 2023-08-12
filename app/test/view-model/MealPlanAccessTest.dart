import 'package:app/view_model/logic/meal/CombinedMealPlanAccess.dart';
import 'package:app/view_model/repository/data_classes/filter/FilterPreferences.dart';
import 'package:app/view_model/repository/data_classes/filter/Frequency.dart';
import 'package:app/view_model/repository/data_classes/meal/Allergen.dart';
import 'package:app/view_model/repository/data_classes/meal/FoodType.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:app/view_model/repository/data_classes/meal/Price.dart';
import 'package:app/view_model/repository/data_classes/meal/Side.dart';
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

class FilterPreferencesFake extends Fake implements FilterPreferences {}

void main() {
  final localStorage = LocalStorageMock();
  final api = ApiMock();
  final database = DatabaseMock();

  late CombinedMealPlanAccess mealPlanAccess;
  FilterPreferences filter = FilterPreferences();

  const String canteenID = "id";
  final Canteen canteen = Canteen(id: canteenID, name: "name");

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
        additives: []),
    Side(
        id: "04",
        name: "Side beef",
        foodType: FoodType.beef,
        price: Price(student: 123, employee: 123, pupil: 345, guest: 356),
        allergens: [Allergen.sn, Allergen.ka, Allergen.kr],
        additives: []),
  ];

  final List<Meal> meals = [
    Meal(
        id: "1",
        name: "vegan Meal",
        foodType: FoodType.vegan,
        relativeFrequency: Frequency.newMeal,
        price: Price(student: 200, employee: 300, pupil: 400, guest: 500),
        allergens: [Allergen.lu, Allergen.ka],
        additives: [],
        sides: [sides[0]],
        averageRating: 5,
        isFavorite: true),
    Meal(
        id: "42",
        name: "vegetarian Meal",
        foodType: FoodType.vegetarian,
        relativeFrequency: Frequency.normal,
        price: Price(student: 200, employee: 300, pupil: 400, guest: 500),
        allergens: [Allergen.lu, Allergen.sn, Allergen.kr],
        additives: [],
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

  final List<Meal> favorites = [meals[0], meals[1], meals[3]];

  setUpAll(() {
    registerFallbackValue(FilterPreferencesFake());
  });

  setUp(() {
    when(() => localStorage.getFilterPreferences()).thenAnswer((_) => null);
    when(() => localStorage.getCanteen()).thenAnswer((_) => canteenID);
    when(() => localStorage.getPriceCategory())
        .thenAnswer((_) => PriceCategory.student);

    when(() => api.updateAll())
        .thenAnswer((_) async => Failure(NoConnectionException("error")));

    when(() => database.getCanteenById(canteenID))
        .thenAnswer((_) async => canteen);
    when(() => database.updateAll(mealplans)).thenAnswer((_) async => {});
    when(() => database.getMealPlan(any(), canteen))
        .thenAnswer((_) async => Success(mealplans));
    when(() => database.getFavorites()).thenAnswer((_) async => []);

    mealPlanAccess = CombinedMealPlanAccess(localStorage, api, database);
  });

  group("initialization", () {
    test("simple initialization", () async {
      expect(await mealPlanAccess.getCanteen(), canteen);
      expect(await mealPlanAccess.getFilterPreferences(), FilterPreferences());

      final date = await mealPlanAccess.getDate();
      expect(date.year, DateTime.now().year);
      expect(date.month, DateTime.now().month);
      expect(date.day, DateTime.now().day);

      final returnedMealPlan = switch (await mealPlanAccess.getMealPlan()) {
        Success(value: final value) => value,
        Failure(exception: _) => []
      };

      for (MealPlan mealplan in mealplans) {
        expect(returnedMealPlan.contains(mealplan), true);
      }
    });
  });

  group("filter meals", () {
    when(() => localStorage.setFilterPreferences(filter))
        .thenAnswer((_) async {});
    when(() => database.getFavorites()).thenAnswer((_) async => favorites);
    when(() => localStorage.getPriceCategory())
        .thenAnswer((_) => PriceCategory.student);

    group("allergens", () {
      test("change allergens er", () async {
        List<Allergen> allergens = _getAllAllergen();
        allergens.remove(Allergen.er);

        filter.allergens = allergens;
        await mealPlanAccess.changeFilterPreferences(filter);

        final List<MealPlan> returnedMealPlan = switch (
            await mealPlanAccess.getMealPlan()) {
          Success(value: final value) => value,
          Failure(exception: _) => []
        };

        // first meal plan
        expect(returnedMealPlan[0].meals[0], meals[0]);
        expect(returnedMealPlan[0].meals[1], meals[1]);
        // sides first meal plan
        expect(returnedMealPlan[0].meals[0].sides?.length, 1);
        expect(returnedMealPlan[0].meals[1].sides?.length, 2);
        expect(returnedMealPlan[0].meals[1].sides?[0], sides[1]);
        expect(returnedMealPlan[0].meals[1].sides?[1], sides[0]);

        // second meal plan of [mealplans]
        // -> should be emplty
        expect(returnedMealPlan.length, 2);

        // third meal plan
        expect(returnedMealPlan[1].meals[0], meals[3]);
        expect(returnedMealPlan[1].meals[1], meals[4]);
        // sides third meal plan
        expect(returnedMealPlan[1].meals[0].sides?.length, 3);
        expect(returnedMealPlan[1].meals[1].sides?.length, 3);
        expect(returnedMealPlan[1].meals[0].sides?[0], sides[0]);
        expect(returnedMealPlan[1].meals[0].sides?[1], sides[1]);
        expect(returnedMealPlan[1].meals[0].sides?[2], sides[3]);
      });

      test("change allergens er and sn", () async {
        List<Allergen> allergens = _getAllAllergen();
        allergens.remove(Allergen.er);
        allergens.remove(Allergen.sn);

        filter.allergens = allergens;
        await mealPlanAccess.changeFilterPreferences(filter);

        final returnedMealPlan = switch (await mealPlanAccess.getMealPlan()) {
          Success(value: final value) => value,
          Failure(exception: _) => []
        };

        // first meal plan
        expect(returnedMealPlan[0].meals[0], meals[0]);
        // sides first meal plan
        expect(returnedMealPlan[0].meals[0].sides?.length, 1);
        expect(returnedMealPlan[0].meals[0].sides?[0], sides[0]);

        // second and third meal plan of [mealplans]
        // -> should be emplty
        expect(returnedMealPlan.length, 1);
      });

      test("change allergens er, sn and kr", () async {
        List<Allergen> allergens = _getAllAllergen();
        allergens.remove(Allergen.er);
        allergens.remove(Allergen.sn);
        allergens.remove(Allergen.kr);

        filter.allergens = allergens;
        await mealPlanAccess.changeFilterPreferences(filter);

        final returnedMealPlan = switch (await mealPlanAccess.getMealPlan()) {
          Success(value: final value) => value,
          Failure(exception: _) => []
        };

        // first meal plan
        expect(returnedMealPlan[0].meals[0], meals[0]);
        // sides first meal plan
        expect(returnedMealPlan[0].meals[0].sides?.length, 1);
        expect(returnedMealPlan[0].meals[0].sides?[0], sides[0]);

        // second and third meal plan of [mealplans]
        // -> should be emplty
        expect(returnedMealPlan.length, 1);
      });

      test("remove filter allergens", () async {
        List<Allergen> allergens = _getAllAllergen();

        filter.allergens = allergens;

        await mealPlanAccess.changeFilterPreferences(filter);

        final returnedMealPlan = switch (await mealPlanAccess.getMealPlan()) {
          Success(value: final value) => value,
          Failure(exception: _) => []
        };

        expect(returnedMealPlan, mealplans);
      });
    });

    group("frequency", () {
      test("only new", () async {
        filter.setNewFrequency();
        await mealPlanAccess.changeFilterPreferences(filter);

        final List<MealPlan> returnedMealPlan = switch (
            await mealPlanAccess.getMealPlan()) {
          Success(value: final value) => value,
          Failure(exception: _) => []
        };

        expect(returnedMealPlan.length, 1);
        expect(returnedMealPlan[0].meals.length, 1);
        expect(returnedMealPlan[0].meals[0], meals[0]);
      });

      test("only rare", () async {
        filter.setRareFrequency();
        await mealPlanAccess.changeFilterPreferences(filter);

        final List<MealPlan> returnedMealPlan = switch (
            await mealPlanAccess.getMealPlan()) {
          Success(value: final value) => value,
          Failure(exception: _) => []
        };

        expect(returnedMealPlan.length, 2);
        expect(returnedMealPlan[0].meals.length, 1);
        expect(returnedMealPlan[0].meals[0], meals[2]);
        expect(returnedMealPlan[1].meals.length, 1);
        expect(returnedMealPlan[1].meals[0], meals[3]);
      });

      test("all", () async {
        filter.setAllFrequencies();
        await mealPlanAccess.changeFilterPreferences(filter);

        final List<MealPlan> returnedMealPlan = switch (
            await mealPlanAccess.getMealPlan()) {
          Success(value: final value) => value,
          Failure(exception: _) => []
        };

        expect(returnedMealPlan, mealplans);
      });
    });

    group("favorites", () {
      test("only favorites", () async {
        filter.onlyFavorite = true;
        await mealPlanAccess.changeFilterPreferences(filter);

        final List<MealPlan> returnedMealPlan = switch (
            await mealPlanAccess.getMealPlan()) {
          Success(value: final value) => value,
          Failure(exception: _) => []
        };

        // first meal plan
        expect(returnedMealPlan[0].meals[0], meals[0]);
        expect(returnedMealPlan[0].meals[1], meals[1]);
        // sides first meal plan
        expect(returnedMealPlan[0].meals[0].sides?.length, 1);
        expect(returnedMealPlan[0].meals[1].sides?.length, 2);

        // second meal plan of [mealplans]
        // -> should be emplty
        expect(returnedMealPlan.length, 2);

        // third meal plan
        expect(returnedMealPlan[1].meals.length, 1);
        expect(returnedMealPlan[1].meals[0], meals[3]);
        // sides third meal plan
        expect(returnedMealPlan[1].meals[0].sides?.length, 4);
      });

      test("deactivate", () async {
        filter.onlyFavorite = true;
        await mealPlanAccess.changeFilterPreferences(filter);

        await mealPlanAccess.deactivateFilter();

        final List<MealPlan> returnedMealPlan = switch (
            await mealPlanAccess.getMealPlan()) {
          Success(value: final value) => value,
          Failure(exception: _) => []
        };

        expect(returnedMealPlan, mealplans);
      });

      test("activate", () async {
        filter.onlyFavorite = true;
        await mealPlanAccess.changeFilterPreferences(filter);

        await mealPlanAccess.activateFilter();

        final List<MealPlan> returnedMealPlan = switch (
            await mealPlanAccess.getMealPlan()) {
          Success(value: final value) => value,
          Failure(exception: _) => []
        };

        // first meal plan
        expect(returnedMealPlan[0].meals[0], meals[0]);
        expect(returnedMealPlan[0].meals[1], meals[1]);
        // sides first meal plan
        expect(returnedMealPlan[0].meals[0].sides?.length, 1);
        expect(returnedMealPlan[0].meals[1].sides?.length, 2);

        // second meal plan of [mealplans]
        // -> should be emplty
        expect(returnedMealPlan.length, 2);

        // third meal plan
        expect(returnedMealPlan[1].meals.length, 1);
        expect(returnedMealPlan[1].meals[0], meals[3]);
        // sides third meal plan
        expect(returnedMealPlan[1].meals[0].sides?.length, 4);
      });

      test("all", () async {
        filter.onlyFavorite = false;
        await mealPlanAccess.changeFilterPreferences(filter);

        final List<MealPlan> returnedMealPlan = switch (
            await mealPlanAccess.getMealPlan()) {
          Success(value: final value) => value,
          Failure(exception: _) => []
        };

        expect(returnedMealPlan, mealplans);
      });
    });

    group("rating", () {
      test("set rating limit", () async {
        filter.rating = 3;

        when(() => localStorage.setFilterPreferences(filter))
            .thenAnswer((_) async {});

        await mealPlanAccess.changeFilterPreferences(filter);

        final List<MealPlan> returnedMealPlan = switch (
            await mealPlanAccess.getMealPlan()) {
          Success(value: final value) => value,
          Failure(exception: _) => []
        };

        expect(returnedMealPlan.length, 2);
        expect(returnedMealPlan[0].meals.length, 2);
        expect(returnedMealPlan[0].meals[0], meals[0]);
        expect(returnedMealPlan[0].meals[1], meals[1]);
        expect(returnedMealPlan[1].meals.length, 1);
        expect(returnedMealPlan[1].meals[0], meals[2]);
        // sides
        expect(returnedMealPlan[0].meals[0].sides?.length, 1);
        expect(returnedMealPlan[0].meals[1].sides?.length, 2);
        expect(returnedMealPlan[1].meals[0].sides?.length, 3);
      });

      test("no rating limit", () async {
        filter = FilterPreferences();

        when(() => localStorage.setFilterPreferences(filter))
            .thenAnswer((_) async {});

        await mealPlanAccess.changeFilterPreferences(filter);

        final List<MealPlan> returnedMealPlan = switch (
            await mealPlanAccess.getMealPlan()) {
          Success(value: final value) => value,
          Failure(exception: _) => []
        };

        expect(returnedMealPlan, mealplans);
      });
    });

    group("food types", () {
      test("vegan", () async {
        filter.setCategoriesVegan();

        when(() => localStorage.setFilterPreferences(filter))
            .thenAnswer((_) async {});

        await mealPlanAccess.changeFilterPreferences(filter);

        final List<MealPlan> returnedMealPlan = switch (
            await mealPlanAccess.getMealPlan()) {
          Success(value: final value) => value,
          Failure(exception: _) => []
        };

        expect(returnedMealPlan.length, 1);
        expect(returnedMealPlan[0].meals.length, 1);
        expect(returnedMealPlan[0].meals[0], meals[0]);
        // sides
        expect(returnedMealPlan[0].meals[0].sides?.length, 1);
      });

      test("vegetarian", () async {
        filter.setCategoriesVegetarian();

        when(() => localStorage.setFilterPreferences(filter))
            .thenAnswer((_) async {});

        await mealPlanAccess.changeFilterPreferences(filter);

        final List<MealPlan> returnedMealPlan = switch (
            await mealPlanAccess.getMealPlan()) {
          Success(value: final value) => value,
          Failure(exception: _) => []
        };

        expect(returnedMealPlan.length, 1);
        expect(returnedMealPlan[0].meals.length, 2);
        expect(returnedMealPlan[0].meals[0], meals[0]);
        expect(returnedMealPlan[0].meals[1], meals[1]);
        // sides
        expect(returnedMealPlan[0].meals[0].sides?.length, 1);
        expect(returnedMealPlan[0].meals[1].sides?.length, 2);
      });

      test("all", () async {
        filter.setAllCategories();

        when(() => localStorage.setFilterPreferences(filter))
            .thenAnswer((_) async {});

        await mealPlanAccess.changeFilterPreferences(filter);

        final List<MealPlan> returnedMealPlan = switch (
            await mealPlanAccess.getMealPlan()) {
          Success(value: final value) => value,
          Failure(exception: _) => []
        };

        expect(returnedMealPlan, mealplans);
      });
    });

    group("price", () {
      test("price limit student", () async {
        filter.price = 130;

        when(() => localStorage.setFilterPreferences(filter))
            .thenAnswer((_) async {});

        await mealPlanAccess.changeFilterPreferences(filter);

        final List<MealPlan> returnedMealPlan = switch (
            await mealPlanAccess.getMealPlan()) {
          Success(value: final value) => value,
          Failure(exception: _) => []
        };

        expect(returnedMealPlan.length, 1);
        expect(returnedMealPlan[0].meals.length, 2);
        expect(returnedMealPlan[0].meals[0], meals[3]);
        expect(returnedMealPlan[0].meals[1], meals[4]);
        // sides
        expect(returnedMealPlan[0].meals[0].sides?.length, 2);
        expect(returnedMealPlan[0].meals[1].sides?.length, 2);
        expect(returnedMealPlan[0].meals[0].sides?[0], sides[0]);
        expect(returnedMealPlan[0].meals[0].sides?[1], sides[3]);
        expect(returnedMealPlan[0].meals[1].sides?[0], sides[0]);
        expect(returnedMealPlan[0].meals[1].sides?[1], sides[3]);
      });

      test("price limit employee", () async {
        when(() => localStorage.getPriceCategory())
            .thenAnswer((_) => PriceCategory.employee);
        when(() => database.getFavorites()).thenAnswer((_) async => favorites);

        mealPlanAccess.switchToMealPlanView();
        filter.price = 130;

        when(() => localStorage.setFilterPreferences(filter))
            .thenAnswer((_) async {});

        await mealPlanAccess.changeFilterPreferences(filter);

        final List<MealPlan> returnedMealPlan = switch (
            await mealPlanAccess.getMealPlan()) {
          Success(value: final value) => value,
          Failure(exception: _) => []
        };

        expect(returnedMealPlan.length, 1);
        expect(returnedMealPlan[0].meals.length, 1);
        expect(returnedMealPlan[0].meals[0], meals[3]);
        // sides
        expect(returnedMealPlan[0].meals[0].sides?.length, 1);
        expect(returnedMealPlan[0].meals[0].sides?[0], sides[3]);
      });
    });
  });

  group("reset", () {
    test("reset filter preferences", () async {
      filter = FilterPreferences();
      when(() => localStorage.setFilterPreferences(filter))
          .thenAnswer((_) async {});

      await mealPlanAccess.resetFilterPreferences();
      expect(await mealPlanAccess.getFilterPreferences(), filter);
    });
  });

  group("edge cases", () {
    test("closed canteen", () async {
      when(() => database.getMealPlan(any(), canteen))
          .thenAnswer((_) async => Success(closedCanteen));

      await mealPlanAccess.changeDate(DateTime.now());

      final result = switch (await mealPlanAccess.getMealPlan()) {
        Success(value: final value) => value,
        Failure(exception: final exception) => exception
      };

      expect(result is ClosedCanteenException, isTrue);
    });

    test("first line closed", () async {
      when(() => database.getMealPlan(any(), canteen))
          .thenAnswer((_) async => Success(closedLine));

      await mealPlanAccess.changeDate(DateTime.now());

      final List<MealPlan> result = switch (
          await mealPlanAccess.getMealPlan()) {
        Success(value: final value) => value,
        Failure(exception: _) => []
      };

      expect(result.isNotEmpty, isTrue);
      expect(result.length, 1);
    });

    test("no data yet", () async {
      when(() => database.getMealPlan(any(), canteen))
          .thenAnswer((_) async => Failure(NoDataException("error")));
      when(() => api.updateCanteen(canteen, any()))
          .thenAnswer((_) async => Failure(NoDataException("error")));

      await mealPlanAccess.changeDate(DateTime.now());

      final result = switch (await mealPlanAccess.getMealPlan()) {
        Success(value: final value) => value,
        Failure(exception: final exception) => exception
      };

      expect(result is NoDataException, isTrue);
    });

    test("no connection", () async {
      when(() => database.getMealPlan(any(), canteen))
          .thenAnswer((_) async => Failure(NoConnectionException("error")));

      await mealPlanAccess.changeDate(DateTime.now());

      final result = switch (await mealPlanAccess.getMealPlan()) {
        Success(value: final value) => value,
        Failure(exception: final exception) => exception
      };

      expect(result is NoConnectionException, isTrue);
    });

    test("all filtered", () async {
      when(() => database.getMealPlan(any(), canteen))
          .thenAnswer((_) async => Success(mealplans));

      await mealPlanAccess.changeDate(DateTime.now());

      filter.setCategoriesVegan();
      List<Allergen> allergens = _getAllAllergen();
      allergens.remove(Allergen.lu);

      filter.allergens = allergens;

      when(() => localStorage.setFilterPreferences(filter))
          .thenAnswer((_) async {});

      await mealPlanAccess.changeFilterPreferences(filter);

      final result = switch (await mealPlanAccess.getMealPlan()) {
        Success(value: final value) => value,
        Failure(exception: final exception) => exception
      };

      expect(result is FilteredMealException, isTrue);
    });
  });
}

List<Allergen> _getAllAllergen() {
  List<Allergen> list = [];
  for (Allergen allergen in Allergen.values) {
    list.add(allergen);
  }
  return list;
}
