import 'package:flutter/material.dart';

import '../../repository/data_classes/settings/MensaColorScheme.dart';
import '../../repository/data_classes/settings/MealPlanFormat.dart';
import '../../repository/data_classes/settings/PriceCategory.dart';

/// This is an interface for accessing the preferences.
abstract class IPreferenceAccess with ChangeNotifier {
  /// The client identifier is returned.
  /// @return The client identifier.
  Future<String> getClientIdentifier();

  /// The client identifier is set.
  /// @param identifier The new client identifier.
  /// @return The result of the update.
  Future<void> setClientIdentifier(String identifier);

  /// The saved ColorScheme is returned.
  /// @return The saved ColorScheme.
  MensaColorScheme getColorScheme();

  /// The committed ColorScheme is set.
  /// @param scheme The new ColorScheme.
  /// @return The result of the update.
  Future<void> setColorScheme(MensaColorScheme scheme);

  /// The saved PriceCategory is returned.
  /// @return The saved PriceCategory.
  Future<PriceCategory> getPriceCategory();

  /// The committed PriceCategory is set.
  /// @param category The new PriceCategory.
  /// @return The result of the update.
  Future<void> setPriceCategory(PriceCategory category);

  /// The saved MealPlanFormat is returned.
  /// @return The saved MealPlanFormat.
  Future<MealPlanFormat> getMealPlanFormat();

  /// The committed MealPlanFormat is set.
  /// @param format The new MealPlanFormat.
  /// @return The result of the update.
  Future<void> setMealPlanFormat(MealPlanFormat format);
}