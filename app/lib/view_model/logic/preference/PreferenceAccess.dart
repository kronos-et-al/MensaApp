import 'package:app/view_model/logic/preference/IPreferenceAccess.dart';
import 'package:app/view_model/repository/data_classes/settings/MensaColorScheme.dart';
import 'package:app/view_model/repository/data_classes/settings/MealPlanFormat.dart';
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

  // waits until _init() is finished initializing
  late Future _doneInitialization;

  PreferenceAccess(this._access) {
    _doneInitialization = _init();
  }

  Future<void> _init() async {
    _clientIdentifier = await _access.getClientIdentifier() ?? "";
    _colorScheme = await _access.getColorScheme() ?? MensaColorScheme.system;
    _mealPlanFormat = await _access.getMealPlanFormat() ?? MealPlanFormat.grid;

    PriceCategory? category = await _access.getPriceCategory();
    if (category == null) {
      category = PriceCategory.student;
      _access.setPriceCategory(category);
    }

    _priceCategory = category;
  }

  @override
  Future<String> getClientIdentifier() async {
    await _doneInitialization;
    return Future.value(_clientIdentifier);
  }

  @override
  Future<MensaColorScheme> getColorScheme() async {
    await _doneInitialization;
    return Future.value(_colorScheme);
  }

  @override
  Future<MealPlanFormat> getMealPlanFormat() async {
    await _doneInitialization;
    return Future.value(_mealPlanFormat);
  }

  @override
  Future<PriceCategory> getPriceCategory() async {
    await _doneInitialization;
    return Future.value(_priceCategory);
  }

  @override
  Future<void> setClientIdentifier(String identifier) async {
    await _doneInitialization;
    _clientIdentifier = identifier;
    await _access.setClientIdentifier(identifier);
    notifyListeners();
  }

  @override
  Future<void> setColorScheme(MensaColorScheme scheme) async {
    await _doneInitialization;
    _colorScheme = scheme;
    await _access.setColorScheme(scheme);
    notifyListeners();
  }

  @override
  Future<void> setMealPlanFormat(MealPlanFormat format) async {
    await _doneInitialization;
    _mealPlanFormat = format;
    await _access.setMealPlanFormat(format);
    notifyListeners();
  }

  @override
  Future<void> setPriceCategory(PriceCategory category) async {
    await _doneInitialization;
    _priceCategory = category;
    await _access.setPriceCategory(category);
    notifyListeners();
  }

}