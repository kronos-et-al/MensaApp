import 'package:app/model/database/model/database_model.dart';
import 'package:app/model/database/model/nutrition_data_mixin.dart';

/// This class represents a meal's nutrition data in the database.
class DBMealNutritionData with NutritionDataMixin implements DatabaseModel {
  /// The name of the table in the database.
  static const String tableName = 'mealNutritionData';

  DBMealNutritionData.empty();

  DBMealNutritionData.fromMap(Map<String, dynamic> map) {
    DBMealNutritionData.empty();
    loadFromMap(map);
  }

  DBMealNutritionData(String sideID, int energy, int protein, int carbohydrates, int sugar, int fat, int saturatedFat, int salt) {
    entityID = sideID;
    this.energy = energy;
    this.protein = protein;
    this.carbohydrates = carbohydrates;
    this.sugar = sugar;
    this.fat = fat;
    this.saturatedFat = saturatedFat;
    this.salt = salt;
  }

  static String initTable() {
    return NutritionDataMixin.initTable(tableName);
  }
}
