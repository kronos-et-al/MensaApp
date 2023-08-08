import '../data_classes/filter/FilterPreferences.dart';
import '../data_classes/settings/MensaColorScheme.dart';
import '../data_classes/settings/MealPlanFormat.dart';
import '../data_classes/settings/PriceCategory.dart';

/// This is an interface to the local storage.
abstract class ILocalStorage {
  /// Returns the client identifier.
  String? getClientIdentifier();

  /// Sets the device identifier.
  Future<void> setClientIdentifier(String identifier);

  /// Returns the FilterPreferences.
  FilterPreferences? getFilterPreferences();

  /// Sets the FilterPreferences.
  Future<void> setFilterPreferences(FilterPreferences filter);

  /// Returns the saved canteen id.
  String? getCanteen();

  /// Sets the committed id of the canteen.
  Future<void> setCanteen(String canteen);

  /// Returns the saved ColorScheme.
  MensaColorScheme? getColorScheme();

  /// Sets the committed ColorScheme.
  Future<void> setColorScheme(MensaColorScheme scheme);

  /// Returns the saved PriceCategory.
  PriceCategory? getPriceCategory();

  /// Sets the committed PriceCategory.
  Future<void> setPriceCategory(PriceCategory category);

  /// Returns the saved MealPlanFormat.
  MealPlanFormat? getMealPlanFormat();

  /// Sets the committed MealPlanFormat.
  Future<void> setMealPlanFormat(MealPlanFormat format);
}