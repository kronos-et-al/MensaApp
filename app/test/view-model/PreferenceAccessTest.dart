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

  setUp(() async {
    when(() => localStorage.getClientIdentifier()).thenAnswer((_) => Future.value(null));
    when(() => localStorage.getColorScheme()).thenAnswer((_) => Future.value(null));
    when(() => localStorage.getPriceCategory()).thenAnswer((_) => Future.value(null));
    when(() => localStorage.getMealPlanFormat()).thenAnswer((_) => Future.value(null));

    preferences = PreferenceAccess(localStorage);
  });

  group("initialization", () {
    test("client identifier", () async {
      expect(await preferences.getClientIdentifier(), "");
    });

    test("color scheme", () async {
      expect(await preferences.getColorScheme(), MensaColorScheme.system);
    });

    test("meal plan format", () async {
      expect(await preferences.getMealPlanFormat(), MealPlanFormat.grid);
    });

    test("price category", () async {
      expect(await preferences.getPriceCategory(), PriceCategory.student);
    });
  });

  group("test setters", () {
    test("set ClientIdentifier", () async {
      const string = "42";
      when(() => localStorage.setClientIdentifier(string)).thenAnswer((_) async {});

      await preferences.setClientIdentifier(string);
      verify(() => localStorage.setClientIdentifier(string)).called(1);
      expect(await preferences.getClientIdentifier(), string);
    });

    test("set Color Scheme", () async {
      const scheme = MensaColorScheme.light;
      when(() => localStorage.setColorScheme(scheme)).thenAnswer((_) async {});

      await preferences.setColorScheme(scheme);
      verify(() => localStorage.setColorScheme(scheme)).called(1);
      expect(await preferences.getColorScheme(), scheme);
    });

    test("set Meal Plan Format", () async {
      const format = MealPlanFormat.list;
      when(() => localStorage.setMealPlanFormat(format)).thenAnswer((_) async {});

      await preferences.setMealPlanFormat(format);
      verify(() => localStorage.setMealPlanFormat(format)).called(1);
      expect(await preferences.getMealPlanFormat(), format);
    });

    test("set Price Category", () async {
      const price = PriceCategory.employee;
      when(() => localStorage.setPriceCategory(price)).thenAnswer((_) async {});

      await preferences.setPriceCategory(price);
      verify(() => localStorage.setPriceCategory(price)).called(1);
      expect(await preferences.getPriceCategory(), price);
    });
  });

  group("initialization with non standard values", () {
    when(() => localStorage.getClientIdentifier()).thenAnswer((_) => Future.value("42"));
    when(() => localStorage.getColorScheme()).thenAnswer((_) => Future.value(MensaColorScheme.light));
    when(() => localStorage.getPriceCategory()).thenAnswer((_) => Future.value(PriceCategory.employee));
    when(() => localStorage.getMealPlanFormat()).thenAnswer((_) => Future.value(MealPlanFormat.list));

    preferencesPredefined = PreferenceAccess(localStorage);

    test("client identifier", () async {
      expect(await preferencesPredefined.getClientIdentifier(), "42");
    });

    test("color scheme", () async {
      expect(await preferencesPredefined.getColorScheme(), MensaColorScheme.light);
    });

    test("meal plan format", () async {
      expect(await preferencesPredefined.getMealPlanFormat(), MealPlanFormat.list);
    });

    test("price category", () async {
      expect(await preferencesPredefined.getPriceCategory(), PriceCategory.employee);
    });
  });

}