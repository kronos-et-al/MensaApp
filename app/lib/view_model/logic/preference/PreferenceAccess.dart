import 'package:app/view_model/logic/preference/IPreferenceAccess.dart';
import 'package:app/view_model/repository/data_classes/settings/ColorScheme.dart';
import 'package:app/view_model/repository/data_classes/settings/MealPlanFormat.dart';
import 'package:app/view_model/repository/data_classes/settings/PriceCategory.dart';
import 'package:app/view_model/repository/interface/ILocalStorage.dart';

import 'package:flutter/foundation.dart';

class PreferenceAccess extends ChangeNotifier implements IPreferenceAccess {
  late ILocalStorage access;

  late String _clientIdentifier;
  late ColorScheme _colorScheme;
  late PriceCategory _priceCategory;
  late MealPlanFormat _mealPlanFormat;

  PreferenceAccess(this.access) {
    _init();
  }

  Future<void> _init() async {
    _clientIdentifier = await access.getClientIdentifier() ?? "";
    _colorScheme = await access.getColorScheme() ?? ColorScheme.system;
    _priceCategory = await access.getPriceCategory() ?? PriceCategory.student;
    _mealPlanFormat = await access.getMealPlanFormat() ?? MealPlanFormat.grid;
  }

  @override
  Future<String> getClientIdentifier() {
    return Future.value(_clientIdentifier);
  }

  @override
  Future<ColorScheme> getColorScheme() async {
    return Future.value(_colorScheme);
  }

  @override
  Future<MealPlanFormat> getMealPlanFormat() {
    return Future.value(_mealPlanFormat);
  }

  @override
  Future<PriceCategory> getPriceCategory() {
    return Future.value(_priceCategory);
  }

  @override
  Future<void> setClientIdentifier(String identifier) async {
    _clientIdentifier = identifier;
    await setClientIdentifier(identifier);
    notifyListeners();
  }

  @override
  Future<void> setColorScheme(ColorScheme scheme) async {
    _colorScheme = scheme;
    await setColorScheme(scheme);
    notifyListeners();
  }

  @override
  Future<void> setMealPlanFormat(MealPlanFormat format) async {
    _mealPlanFormat = format;
    await setMealPlanFormat(format);
    notifyListeners();
  }

  @override
  Future<void> setPriceCategory(PriceCategory category) async {
    _priceCategory = category;
    await setPriceCategory(category);
    notifyListeners();
  }

}