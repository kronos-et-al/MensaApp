import 'package:flutter/material.dart';

import '../../repository/data_classes/settings/MensaColorScheme.dart';
import '../../repository/data_classes/settings/MealPlanFormat.dart';
import '../../repository/data_classes/settings/PriceCategory.dart';

/// This is an interface for accessing the preferences.
abstract class IPreferenceAccess with ChangeNotifier {
  /// Returns the client identifier.
  String getClientIdentifier();

  /// Sets the client identifier.
  Future<void> setClientIdentifier(String identifier);

  /// Returns the saved ColorScheme.
  MensaColorScheme getColorScheme();

  /// Sets the committed ColorScheme.
  Future<void> setColorScheme(MensaColorScheme scheme);

  /// Returns the saved PriceCategory.
  PriceCategory getPriceCategory();

  /// Sets the committed PriceCategory.
  Future<void> setPriceCategory(PriceCategory category);

  /// Returns the saved MealPlanFormat.
  MealPlanFormat getMealPlanFormat();

  /// Sets the committed MealPlanFormat.
  Future<void> setMealPlanFormat(MealPlanFormat format);
}
