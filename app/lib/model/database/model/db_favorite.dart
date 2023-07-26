
import 'package:app/model/database/model/database_model.dart';
import 'package:app/view_model/repository/data_classes/meal/FoodType.dart';

import 'db_line.dart';

class DBFavorite implements DatabaseModel {
  final String _favoriteID;
  final String _lineID;
  final String _lastDate;
  final FoodType _foodType;
  final int _priceStudent;
  final int _priceEmployee;
  final int _pricePupil;
  final int _priceGuest;

  static const String tableName = 'favorite';

  static const String columnFavoriteID = 'favoriteID';
  static const String columnLineID = 'lineID';
  static const String columnLastDate = 'lastDate';
  static const String columnFoodType = 'foodType';
  static const String columnPriceStudent = 'priceStudent';
  static const String columnPriceEmployee = 'priceEmployee';
  static const String columnPricePupil = 'pricePupil';
  static const String columnPriceGuest = 'priceGuest';

  DBFavorite(this._favoriteID, this._lineID, this._lastDate, this._foodType, this._priceStudent, this._priceEmployee, this._pricePupil, this._priceGuest);

  @override
  Map<String, dynamic> toMap() {
    return {
      columnFavoriteID: _favoriteID,
      columnLineID: _lineID,
      columnLastDate: _lastDate,
      columnFoodType: _foodType,
      columnPriceStudent: _priceStudent,
      columnPriceEmployee: _priceEmployee,
      columnPricePupil: _pricePupil,
      columnPriceGuest: _priceGuest
    };
  }

  static DBFavorite fromMap(Map<String, dynamic> map) {
    return DBFavorite(map[columnFavoriteID], map[columnLineID], map[columnLastDate], map[columnFoodType], map[columnPriceStudent], map[columnPriceEmployee], map[columnPricePupil], map[columnPriceGuest]);
  }

  /// The string to create a table for a favorite.
  static String initTable() {
    return '''
    CREATE TABLE $tableName (
      $columnFavoriteID TEXT PRIMARY KEY,
      $columnLineID TEXT NOT NULL,
      $columnLastDate TEXT NOT NULL,
      $columnFoodType TEXT,
      $columnPriceStudent INTEGER CHECK($columnPriceStudent > 0),
      $columnPriceEmployee INTEGER CHECK($columnPriceEmployee > 0),
      $columnPricePupil INTEGER CHECK($columnPricePupil > 0),
      $columnPriceGuest INTEGER CHECK($columnPriceGuest > 0),
      FOREIGN KEY($columnLineID) REFERENCES ${DBLine.tableName}(${DBLine.columnLineID})
    )
  ''';
  }

  int get priceGuest => _priceGuest;

  int get pricePupil => _pricePupil;

  int get priceEmployee => _priceEmployee;

  int get priceStudent => _priceStudent;

  FoodType get foodType => _foodType;

  String get lastDate => _lastDate;

  String get lineID => _lineID;

  String get favoriteID => _favoriteID;
}