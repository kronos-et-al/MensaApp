import 'package:app/model/local_storage/SharedPreferenceAccess.dart';
import 'package:app/view_model/logic/preference/PreferenceAccess.dart';
import 'package:app/view_model/repository/data_classes/settings/MealPlanFormat.dart';
import 'package:app/view_model/repository/data_classes/settings/MensaColorScheme.dart';
import 'package:app/view_model/repository/data_classes/settings/PriceCategory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesMock extends Mock implements SharedPreferences {}

void main() {
  SharedPreferencesMock mock = SharedPreferencesMock();
  SharedPreferenceAccess localStorage = SharedPreferenceAccess(mock);
  late PreferenceAccess preferences;

  const id = "42";
  const colorScheme = MensaColorScheme.system;
  const priceCategory = PriceCategory.student;
  const mealPlanFormat = MealPlanFormat.grid;

  group("initialization", () {
    when(() => mock.getString("clientIdentifier")).thenAnswer((_) => null);
    when(() => mock.getString("colorScheme")).thenAnswer((_) => null);
    when(() => mock.getString("priceCategory")).thenAnswer((_) => null);
    when(() => mock.getString("mealPlanFormat")).thenAnswer((_) => null);

    when(() => mock.setString("priceCategory", "student"))
        .thenAnswer((_) async => true);
    when(() => mock.setString("clientIdentifier", any()))
        .thenAnswer((_) async => true);

    preferences = PreferenceAccess(localStorage);

    test("client identifier", () {
      verify(() => mock.setString("clientIdentifier", any())).called(1);
    });

    test("color scheme", () {
      expect(preferences.getColorScheme(), MensaColorScheme.system);
    });

    test("meal plan format", () {
      expect(preferences.getMealPlanFormat(), MealPlanFormat.grid);
    });

    test("price category", () {
      expect(preferences.getPriceCategory(), PriceCategory.student);
    });
  });

  group("initialization with values", () {
    when(() => mock.getString("clientIdentifier")).thenAnswer((_) => id);
    when(() => mock.getString("colorScheme")).thenAnswer((_) => colorScheme.toString());
    when(() => mock.getString("priceCategory")).thenAnswer((_) => priceCategory.toString());
    when(() => mock.getString("mealPlanFormat")).thenAnswer((_) => mealPlanFormat.toString());

    when(() => mock.setString("priceCategory", "student"))
        .thenAnswer((_) async => true);
    when(() => mock.setString("clientIdentifier", any()))
        .thenAnswer((_) async => true);

    preferences = PreferenceAccess(localStorage);

    test("client id", () {
      expect(preferences.getClientIdentifier(), id);
    });

    test("color scheme", () {
      expect(preferences.getColorScheme(), colorScheme);
    });

    test("meal plan format", () {
      expect(preferences.getMealPlanFormat(), mealPlanFormat);
    });

    test("price category", () {
      expect(preferences.getPriceCategory(), priceCategory);
    });
  });

  group("test setters", () {
    test("set ClientIdentifier", () async {
      when(() => mock.setString("clientIdentifier", any()))
          .thenAnswer((_) async => true);

      await preferences.setClientIdentifier(id);
      verify(() => mock.setString("clientIdentifier", id)).called(1);
      expect(preferences.getClientIdentifier(), id);
    });

    test("set Color Scheme", () async {
      when(() => mock.setString("colorScheme", colorScheme.toString()))
          .thenAnswer((_) async => true);

      await preferences.setColorScheme(colorScheme);
      verify(() => mock.setString("colorScheme", colorScheme.toString())).called(1);
      expect(preferences.getColorScheme(), colorScheme);
    });

    test("set Meal Plan Format", () async {
      when(() => mock.setString("mealPlanFormat", mealPlanFormat.toString()))
          .thenAnswer((_) async => true);

      await preferences.setMealPlanFormat(mealPlanFormat);
      verify(() => mock.setString("mealPlanFormat", mealPlanFormat.toString())).called(1);
      expect(preferences.getMealPlanFormat(), mealPlanFormat);
    });

    test("set Price Category", () async {
      when(() => mock.setString("priceCategory", priceCategory.toString()))
          .thenAnswer((_) async => true);

      await preferences.setPriceCategory(priceCategory);
      verify(() => mock.setString("priceCategory", priceCategory.toString())).called(1);
      expect(preferences.getPriceCategory(), priceCategory);
    });
  });
}
