import 'package:app/view_model/logic/preference/PreferenceAccess.dart';
import 'package:app/view_model/repository/data_classes/settings/MensaColorScheme.dart';
import 'package:app/view_model/repository/data_classes/settings/MealPlanFormat.dart';
import 'package:app/view_model/repository/data_classes/settings/PriceCategory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../model/mocks/LocalStorageMock.dart';

void main () {
  final localStorage = LocalStorageMock();

  late PreferenceAccess preferences;
  late PreferenceAccess preferencesPredefined;

  group("initialization", () {
    when(() => localStorage.getClientIdentifier()).thenReturn(null);
    when(() => localStorage.getColorScheme()).thenAnswer((_) => null);
    when(() => localStorage.getPriceCategory()).thenAnswer((_) => null);
    when(() => localStorage.getMealPlanFormat()).thenAnswer((_) => null);

    when(() => localStorage.setPriceCategory(PriceCategory.student))
        .thenAnswer((_) async {});

    preferences = PreferenceAccess(localStorage);

    test("client identifier", () {
      expect(preferences.getClientIdentifier(), "");
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

  group("test setters", () {
    test("set ClientIdentifier", () async {
      const string = "42";
      when(() => localStorage.setClientIdentifier(string)).thenAnswer((_) async {});

      await preferences.setClientIdentifier(string);
      verify(() => localStorage.setClientIdentifier(string)).called(1);
      expect(preferences.getClientIdentifier(), string);
    });

    test("set Color Scheme", () async {
      const scheme = MensaColorScheme.light;
      when(() => localStorage.setColorScheme(scheme)).thenAnswer((_) async {});

      await preferences.setColorScheme(scheme);
      verify(() => localStorage.setColorScheme(scheme)).called(1);
      expect(preferences.getColorScheme(), scheme);
    });

    test("set Meal Plan Format", () async {
      const format = MealPlanFormat.list;
      when(() => localStorage.setMealPlanFormat(format)).thenAnswer((_) async {});

      await preferences.setMealPlanFormat(format);
      verify(() => localStorage.setMealPlanFormat(format)).called(1);
      expect(preferences.getMealPlanFormat(), format);
    });

    test("set Price Category", () async {
      const price = PriceCategory.employee;
      when(() => localStorage.setPriceCategory(price)).thenAnswer((_) async {});

      await preferences.setPriceCategory(price);
      verify(() => localStorage.setPriceCategory(price)).called(1);
      expect(preferences.getPriceCategory(), price);
    });
  });

  group("initialization with non standard values", () {
    when(() => localStorage.getClientIdentifier()).thenAnswer((_) => "42");
    when(() => localStorage.getColorScheme()).thenAnswer((_) => MensaColorScheme.light);
    when(() => localStorage.getPriceCategory()).thenAnswer((_) => PriceCategory.employee);
    when(() => localStorage.getMealPlanFormat()).thenAnswer((_) => MealPlanFormat.list);

    when(() => localStorage.setPriceCategory(PriceCategory.student))
        .thenAnswer((_) async {});

    preferencesPredefined = PreferenceAccess(localStorage);

    test("client identifier", () {
      expect(preferencesPredefined.getClientIdentifier(), "42");
    });

    test("color scheme", () {
      expect(preferencesPredefined.getColorScheme(), MensaColorScheme.light);
    });

    test("meal plan format", () {
      expect(preferencesPredefined.getMealPlanFormat(), MealPlanFormat.list);
    });

    test("price category", () {
      expect(preferencesPredefined.getPriceCategory(), PriceCategory.employee);
    });
  });

}