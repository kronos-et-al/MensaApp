import 'package:app/view_model/repository/data_classes/meal/FoodType.dart';

import 'database_model.dart';

/// This class represents a side in the database.
class DBSide implements DatabaseModel {
  final String _sideID;
  final String _name;
  final FoodType _foodType;

  /// The name of the table in the database.
  static const String tableName = 'side';

  /// The name of the column for the side id.
  static const String columnSideID = 'sideID';

  /// The name of the column for the name.
  static const String columnName = 'name';

  /// The name of the column for the food type.
  static const String columnFoodType = 'foodType';

  /// Creates a new instance of a side.
  /// Creates a new instance of a side as it is represented in the Database.
  DBSide(
      this._sideID,
      this._name,
      this._foodType);

  @override
  Map<String, dynamic> toMap() {
    return {
      columnSideID: _sideID,
      columnName: _name,
      columnFoodType: _foodType.name,
    };
  }

  /// Creates a side from a map.
  static DBSide fromMap(Map<String, dynamic> map) {
    return DBSide(
        map[columnSideID],
        map[columnName],
        FoodType.values.byName(map[columnFoodType]));
  }

  /// The string to create a table for a side.
  static String initTable() {
    return '''
    CREATE TABLE $tableName (
      $columnSideID TEXT PRIMARY KEY NOT NULL,
      $columnName TEXT NOT NULL,
      $columnFoodType TEXT NOT NULL
    )
  ''';
  }

  /// This method returns the food type of the side.
  FoodType get foodType => _foodType;

  /// This method returns the name of the side.
  String get name => _name;

  /// This method returns the id of the side.
  String get sideID => _sideID;
}
