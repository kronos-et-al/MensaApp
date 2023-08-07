import 'package:app/model/local_storage/SharedPreferenceAccess.dart';
import 'package:app/view_model/repository/data_classes/filter/FilterPreferences.dart';
import 'package:app/view_model/repository/data_classes/filter/Frequency.dart';
import 'package:app/view_model/repository/data_classes/filter/Sorting.dart';
import 'package:app/view_model/repository/data_classes/meal/Allergen.dart';
import 'package:app/view_model/repository/data_classes/meal/FoodType.dart';
import 'package:app/view_model/repository/data_classes/settings/MealPlanFormat.dart';
import 'package:app/view_model/repository/data_classes/settings/MensaColorScheme.dart';
import 'package:app/view_model/repository/data_classes/settings/PriceCategory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesMock extends Mock implements SharedPreferences {}

/// This class tests the shared preferences access.
Future<void> main() async {
  // set test environment
  final Map<String, Object> values = <String, Object>{'counter': 1};
  SharedPreferences.setMockInitialValues(values);

  SharedPreferencesMock mock = SharedPreferencesMock();

  SharedPreferenceAccess pref = SharedPreferenceAccess(await SharedPreferences.getInstance());
  SharedPreferenceAccess prefMock = SharedPreferenceAccess(mock);

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

  group("empty preferences", () {
    test("id", () {
      when(() => mock.getString('clientIdentifier')).thenReturn(null);
      when(() => mock.setString('clientIdentifier', any())).thenAnswer((_) async => true);
      prefMock.getClientIdentifier();

      verify(() => mock.setString('clientIdentifier', any())).called(1);
    });

    test("color scheme", () {
      when(() => mock.getString('colorScheme')).thenReturn(null);

      expect(prefMock.getColorScheme(), MensaColorScheme.system);
    });

    test("price category", () {
      when(() => mock.getString('priceCategory')).thenReturn(null);

      expect(prefMock.getPriceCategory(), PriceCategory.student);
    });

    test("meal plan format", () {
      when(() => mock.getString('mealPlanFormat')).thenReturn(null);

      expect(prefMock.getMealPlanFormat(), MealPlanFormat.grid);
    });
  });

  /// This method tests the access to the client identifier.
  test('Client Identifier Test', () async {
    String id = "test";
    pref.setClientIdentifier(id);
    expect(await pref.getClientIdentifier(), id);
  });

  /// This method test the access to the meal plan format.
  test('Meal Plan Format Test', () async {
    MealPlanFormat format = MealPlanFormat.list;
    pref.setMealPlanFormat(format);
    expect(await pref.getMealPlanFormat(), format);
  });

  /// This method tests the access to the color scheme.
  test('Color Scheme Test', () async {
    MensaColorScheme scheme = MensaColorScheme.light;
    pref.setColorScheme(scheme);
    expect(await pref.getColorScheme(), scheme);
  });

  /// This method tests the access to the price category.
  test('Price Category Test', () async {
    PriceCategory category = PriceCategory.employee;
    pref.setPriceCategory(category);
    expect(await pref.getPriceCategory(), category);
  });

  /// This method tests the access to the canteen.
  test('Canteen Test', () async {
    String canteen = "test";
    pref.setCanteen(canteen);
    expect(await pref.getCanteen(), canteen);
  });

  /// This method prepares the access to the filter preferences.
  setUp(() async {
    pref.setFilterPreferences(filter);
    filterResult = await pref.getFilterPreferences() ?? FilterPreferences();
  });

  /// This group tests the access to the filter preferences
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