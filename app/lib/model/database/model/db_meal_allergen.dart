import 'package:app/model/database/model/database_model.dart';

import '../../../view_model/repository/data_classes/meal/Allergen.dart';
import 'db_meal.dart';

class DBMealAllergen implements DatabaseModel {

  final String _mealID;
  final Allergen _allergen;

  static const String tableName = 'mealAllergen';

  static const String columnMealID = 'mealID';
  static const String columnAllergen = 'allergen';

  DBMealAllergen(this._mealID, this._allergen);

  @override
  Map<String, dynamic> toMap() {
    return {
      columnMealID: _mealID,
      columnAllergen: _allergen.name
    };
  }

  static DBMealAllergen fromMap(Map<String, dynamic> map) {
    return DBMealAllergen(map[columnMealID], Allergen.values.byName(map[columnAllergen]));
  }

  /// The string to create a table for an allergen of a meal.
  static String initTable() {
    return '''
    CREATE TABLE $tableName (
      $columnMealID TEXT,
      $columnAllergen TEXT,
      FOREIGN KEY($columnMealID) REFERENCES ${DBMeal.tableName}(${DBMeal.columnMealID}),
      PRIMARY KEY($columnMealID, $columnAllergen)
    )
  ''';
  }

  Allergen get allergen => _allergen;

  String get mealID => _mealID;
}