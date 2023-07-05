
import 'package:app/model/local_storage/SharedPreferenceAccess.dart';
import 'package:app/view_model/repository/data_classes/filter/FilterPreferences.dart';
import 'package:app/view_model/repository/data_classes/filter/Frequency.dart';
import 'package:app/view_model/repository/data_classes/filter/Sorting.dart';
import 'package:app/view_model/repository/data_classes/meal/Allergen.dart';
import 'package:app/view_model/repository/data_classes/meal/FoodType.dart';
import 'package:app/view_model/repository/data_classes/settings/MealPlanFormat.dart';
import 'package:app/view_model/repository/data_classes/settings/ColorScheme.dart';
import 'package:app/view_model/repository/data_classes/settings/PriceCategory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  final Map<String, Object> values = <String, Object>{'counter': 1};
  SharedPreferences.setMockInitialValues(values);
  SharedPreferenceAccess pref = SharedPreferenceAccess(await SharedPreferences.getInstance());

  FilterPreferences filter = FilterPreferences(
      categories: [FoodType.vegetarian, FoodType.vegan],
      allergens: [Allergen.ca, Allergen.di],
      price: 800,
      rating: 3,
      frequency: [Frequency.rare],
      onlyFavorite: true,
      sortedBy: Sorting.rating,
      ascending: false
  );
  late FilterPreferences filterResult;

  test('Client Identifier Test', () async {
    String id = "test";
    pref.setClientIdentifier(id);
    expect(await pref.getClientIdentifier(), id);
  });

  test('Meal Plan Format Test', () async {
    MealPlanFormat format = MealPlanFormat.list;
    pref.setMealPlanFormat(format);
    expect(await pref.getMealPlanFormat(), format);
  });

  test('Color Scheme Test', () async {
    ColorScheme scheme = ColorScheme.light;
    pref.setColorScheme(scheme);
    expect(await pref.getColorScheme(), scheme);
  });

  test('Price Category Test', () async {
    PriceCategory category = PriceCategory.employee;
    pref.setPriceCategory(category);
    expect(await pref.getPriceCategory(), category);
  });

  test('Canteen Test', () async {
    String canteen = "test";
    pref.setCanteen(canteen);
    expect(await pref.getCanteen(), canteen);
  });

  setUp(() async {
    pref.setFilterPreferences(filter);
    filterResult = await pref.getFilterPreferences();
  });

  group('FilterPreferences', () {
    test('price', () {
      expect(filterResult.price, filter.price);
    });

    test('rating', () {
      expect(filterResult.rating, filter.rating);
    });

    test('onlyFavorite', () {
      expect(filterResult.onlyFavorite, filter.onlyFavorite);
    });

    test('sortedBy', () {
      expect(filterResult.sortedBy, filter.sortedBy);
    });

    test('ascending', () {
      expect(filterResult.ascending, filter.ascending);
    });

    // test Lists
    test('frequency', () {
      expect(filterResult.frequency, filter.frequency);
    });

    test('allergens', () {
      expect(filterResult.allergens, filter.allergens);
    });

    test('categories', () {
      expect(filterResult.categories, filter.categories);
    });
  });
}