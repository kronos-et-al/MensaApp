
import '../data_classes/filter/FilterPreferences.dart';
import '../data_classes/settings/MensaColorScheme.dart';
import '../data_classes/settings/MealPlanFormat.dart';
import '../data_classes/settings/PriceCategory.dart';

/// This is an interface to the local storage.
abstract class ILocalStorage {
  /// The device identifier is returned.
  /// @return The device identifier.
  String? getClientIdentifier();

  /// The device identifier is set.
  /// @param identifier The new device identifier.
  /// @return The result of the update.
  Future<void> setClientIdentifier(String identifier);

  /// The saved FilterPreferences is returned.
  /// @return The saved FilterPreferences.
  FilterPreferences? getFilterPreferences();

  /// The committed FilterPreferences is set.
  /// @param filter The new FilterPreferences.
  /// @return The result of the update.
  Future<void> setFilterPreferences(FilterPreferences filter);

  /// The saved canteen id is returned.
  /// @return The saved canteen id.
  String? getCanteen();

  /// The committed id of the canteen is set.
  /// @param canteen The id of the new canteen.
  /// @return The result of the update.
  Future<void> setCanteen(String canteen);

  /// The saved ColorScheme is returned.
  /// @return The saved ColorScheme.
  MensaColorScheme? getColorScheme();

  /// The committed ColorScheme is set.
  /// @param scheme The new ColorScheme.
  /// @return The result of the update.
  Future<void> setColorScheme(MensaColorScheme scheme);

  /// The saved PriceCategory is returned.
  /// @return The saved PriceCategory.
  /// @return The result of the update.
  PriceCategory? getPriceCategory();

  /// The committed PriceCategory is set.
  /// @param category The new PriceCategory.
  /// @return The result of the update.
  Future<void> setPriceCategory(PriceCategory category);

  /// The saved MealPlanFormat is returned.
  /// @return The saved MealPlanFormat.
  MealPlanFormat? getMealPlanFormat();

  /// The committed MealPlanFormat is set.
  /// @param format The new MealPlanFormat.
  /// @return The result of the update.
  Future<void> setMealPlanFormat(MealPlanFormat format);
}