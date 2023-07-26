import 'package:app/view_model/logic/preference/IPreferenceAccess.dart';
import 'package:app/view_model/repository/data_classes/settings/MealPlanFormat.dart';
import 'package:app/view_model/repository/data_classes/settings/MensaColorScheme.dart';
import 'package:app/view_model/repository/data_classes/settings/PriceCategory.dart';
import 'package:app/view_model/repository/interface/ILocalStorage.dart';

import 'package:flutter/foundation.dart';

// todo muss vor Combined Meal Plan Access initialisiert werden
class PreferenceAccess extends ChangeNotifier implements IPreferenceAccess {
  final ILocalStorage _access;

  late String _clientIdentifier;
  late MensaColorScheme _colorScheme;
  late PriceCategory _priceCategory;
  late MealPlanFormat _mealPlanFormat;

  PreferenceAccess(this._access) {
    _init();
  }

  void _init() {
    _clientIdentifier = _access.getClientIdentifier() ?? "";
    print("cidd: $_clientIdentifier");
    _colorScheme = _access.getColorScheme() ?? MensaColorScheme.system;
    print("cs: $_colorScheme");
    _mealPlanFormat = _access.getMealPlanFormat() ?? MealPlanFormat.grid;
    print("mpf: $_mealPlanFormat");

    PriceCategory? category = _access.getPriceCategory();
    print("pc: $category");
    if (category == null) {
      category = PriceCategory.student;
      _access.setPriceCategory(category);
    }

    _priceCategory = category;
  }

  @override
  Future<String> getClientIdentifier() async {
    return Future.value(_clientIdentifier);
  }

  @override
  MensaColorScheme getColorScheme() {
    return _colorScheme;
  }

  @override
  Future<MealPlanFormat> getMealPlanFormat() async {
    return Future.value(_mealPlanFormat);
  }

  @override
  Future<PriceCategory> getPriceCategory() async {
    return Future.value(_priceCategory);
  }

  @override
  Future<void> setClientIdentifier(String identifier) async {
    _clientIdentifier = identifier;
    await _access.setClientIdentifier(identifier);
    notifyListeners();
  }

  @override
  Future<void> setColorScheme(MensaColorScheme scheme) async {
    _colorScheme = scheme;
    await _access.setColorScheme(scheme);
    notifyListeners();
  }

  @override
  Future<void> setMealPlanFormat(MealPlanFormat format) async {
    _mealPlanFormat = format;
    await _access.setMealPlanFormat(format);
    notifyListeners();
  }

  @override
  Future<void> setPriceCategory(PriceCategory category) async {
    _priceCategory = category;
    await _access.setPriceCategory(category);
    notifyListeners();
  }
}
