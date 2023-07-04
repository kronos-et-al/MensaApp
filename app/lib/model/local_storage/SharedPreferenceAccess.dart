
import 'package:app/view_model/repository/data_classes/filter/FilterPreferences.dart';
import 'package:app/view_model/repository/data_classes/filter/Frequency.dart';
import 'package:app/view_model/repository/data_classes/meal/Allergen.dart';
import 'package:app/view_model/repository/data_classes/settings/ColorScheme.dart';
import 'package:app/view_model/repository/data_classes/settings/MealPlanFormat.dart';
import 'package:app/view_model/repository/data_classes/settings/PriceCategory.dart';
import 'package:app/view_model/repository/interface/ILocalStorage.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../view_model/repository/data_classes/filter/Sorting.dart';
import '../../view_model/repository/data_classes/meal/FoodType.dart';

class SharedPreferenceAccess implements ILocalStorage {

  SharedPreferenceAccess();
  
  @override
  Future<String> getClientIdentifier() async {
    final pref = await SharedPreferences.getInstance();
    final clientIdentifier = pref.getString('clientIdentifier') ?? "";
    return Future.value(clientIdentifier);
  }

  @override
  Future<ColorScheme> getColorScheme() async {
    final pref = await SharedPreferences.getInstance();
    final colorScheme = pref.getString('colorScheme');
    return Future.value(ColorScheme.values.firstWhere((e) => e.toString() == colorScheme));
  }

  @override
  Future<FilterPreferences> getFilterPreferences() async {
    final pref = await SharedPreferences.getInstance();

    // get data from shared preferences
    final categories = pref.getStringList('filterCategories');
    final allergens = pref.getStringList('filterAllergens');
    final price = pref.getInt('filterPrice');
    final rating = pref.getInt('filterRating');
    final frequency = pref.getStringList('filterFrequency');
    final onlyFavorites = pref.getBool('filterOnlyFavorites');
    final sortedBy = pref.getString('filterSort');
    final ascending = pref.getBool('filterSortAscending');

    // convert values to right format
    List<FoodType>? foodTypeEnum;
    if (categories != null) {
      foodTypeEnum = List.of(categories.map((e) => FoodType.values.firstWhere((element) => element.toString() == e)));
    }

    List<Allergen>? allergensEnum;
    if (allergens != null) {
      allergensEnum = List.of(allergens.map((e) => Allergen.values.firstWhere((element) => element.toString() == e)));
    }

    List<Frequency>? frequencyEnum;
    if (frequency != null) {
      frequencyEnum = List.of(frequency.map((e) => Frequency.values.firstWhere((element) => element.toString() == e)));
    }

    Sorting? sortedByEnum;
    if (categories != null) {
       sortedByEnum = Sorting.values.firstWhere((e) => e.toString() == sortedBy);
    }

    // return filter preferences
    return Future<FilterPreferences>.value(FilterPreferences(
      categories: foodTypeEnum,
      allergens: allergensEnum,
      price: price,
      rating: rating,
      frequency: frequencyEnum,
      onlyFavorite: onlyFavorites,
      sortedBy: sortedByEnum,
      ascending: ascending
    ));
  }

  @override
  Future<MealPlanFormat> getMealPlanFormat() async {
    final pref = await SharedPreferences.getInstance();
    final mealPlanFormat = pref.getString('mealPlanFormat');
    return Future.value(MealPlanFormat.values.firstWhere((e) => e.toString() == mealPlanFormat));
  }

  @override
  Future<PriceCategory> getPriceCategory() async {
    final pref = await SharedPreferences.getInstance();
    final priceCategory = pref.getString('priceCategory');
    return Future.value(PriceCategory.values.firstWhere((e) => e.toString() == priceCategory));

  }

  @override
  Future<void> setClientIdentifier(String identifier) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString('clientIdentifier', identifier);
  }

  @override
  Future<void> setColorScheme(ColorScheme scheme) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString('colorScheme', scheme.toString());
  }

  @override
  Future<void> setFilterPreferences(FilterPreferences filter) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setStringList('filterCategories', List.of(filter.categories.map((e) => e.toString())));
    await pref.setStringList('filterAllergens', List.of(filter.allergens.map((e) => e.toString())));
    await pref.setInt('filterPrice', filter.price);
    await pref.setInt('filterRating', filter.rating);
    await pref.setStringList('filterFrequency', List.of(filter.frequency.map((e) => e.toString())));
    await pref.setBool('filterFavorite', filter.onlyFavorite);
    await pref.setString('filterSort', filter.sortedBy.toString());
    await pref.setBool('filterSortAscending', filter.ascending);
  }

  @override
  Future<void> setMealPlanFormat(MealPlanFormat format) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString('mealPlanFormat', format.toString());
  }

  @override
  Future<void> setPriceCategory(PriceCategory category) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString('priceCategory', category.toString());
  }

  @override
  Future<String> getCanteen() async {
    final pref = await SharedPreferences.getInstance();
    final canteen = pref.getString('canteen') ?? "";
    return Future.value(canteen);
  }

  @override
  Future<void> setCanteen(String canteen) async {
    final pref = await SharedPreferences.getInstance();
    await pref.setString('canteen', canteen);
  }
}