import 'package:app/model/database/model/database_model.dart';
import 'package:app/view_model/repository/data_classes/meal/FoodType.dart';

import 'db_line.dart';

/// This class represents a favorite in the database.
class DBFavorite implements DatabaseModel {
  final String _favoriteID;
  final String _lineID;
  final String _lastDate;
  final FoodType _foodType;
  final int _priceStudent;
  final int _priceEmployee;
  final int _pricePupil;
  final int _priceGuest;

  /// The name of the table in the database.
  static const String tableName = 'favorite';

  /// The name of the column for the favorite id.
  static const String columnFavoriteID = 'favoriteID';

  /// The name of the column for the line id.
  static const String columnLineID = 'lineID';

  /// The name of the column for the last date.
  static const String columnLastDate = 'lastDate';

  /// The name of the column for the food type.
  static const String columnFoodType = 'foodType';

  /// The name of the column for the price for students.
  static const String columnPriceStudent = 'priceStudent';

  /// The name of the column for the price for employees.
  static const String columnPriceEmployee = 'priceEmployee';

  /// The name of the column for the price for pupils.
  static const String columnPricePupil = 'pricePupil';

  /// The name of the column for the price for guests.
  static const String columnPriceGuest = 'priceGuest';

  /// Creates a new instance of a favorite.
  /// @param _favoriteID The id of the favorite.
  /// @param _lineID The id of the line.
  /// @param _lastDate The last date of the favorite.
  /// @param _foodType The food type of the favorite.
  /// @param _priceStudent The price for students.
  /// @param _priceEmployee The price for employees.
  /// @param _pricePupil The price for pupils.
  /// @param _priceGuest The price for guests.
  /// @returns A new instance of a favorite.
  DBFavorite(
      this._favoriteID,
      this._lineID,
      this._lastDate,
      this._foodType,
      this._priceStudent,
      this._priceEmployee,
      this._pricePupil,
      this._priceGuest);

  @override
  Map<String, dynamic> toMap() {
    return {
      columnFavoriteID: _favoriteID,
      columnLineID: _lineID,
      columnLastDate: _lastDate,
      columnFoodType: _foodType.name,
      columnPriceStudent: _priceStudent,
      columnPriceEmployee: _priceEmployee,
      columnPricePupil: _pricePupil,
      columnPriceGuest: _priceGuest
    };
  }

  /// Creates a favorite from a map.
  /// @param map The map to create a favorite from.
  /// @returns A new instance of a favorite.
  static DBFavorite fromMap(Map<String, dynamic> map) {
    return DBFavorite(
        map[columnFavoriteID],
        map[columnLineID],
        map[columnLastDate],
        FoodType.values.byName(map[columnFoodType]),
        map[columnPriceStudent],
        map[columnPriceEmployee],
        map[columnPricePupil],
        map[columnPriceGuest]);
  }

  /// The string to create a table for a favorite.
  /// @returns The string to create a table for a favorite.
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

  /// This method returns the price for guests.
  /// @returns The price for guests.
  int get priceGuest => _priceGuest;

  /// This method returns the price for pupils.
  /// @returns The price for pupils.
  int get pricePupil => _pricePupil;

  /// This method returns the price for employees.
  /// @returns The price for employees.
  int get priceEmployee => _priceEmployee;

  /// This method returns the price for students.
  /// @returns The price for students.
  int get priceStudent => _priceStudent;

  /// This method returns the food type of the favorite.
  /// @returns The food type of the favorite.
  FoodType get foodType => _foodType;

  /// This method returns the last date of the favorite.
  /// @returns The last date of the favorite.
  String get lastDate => _lastDate;

  /// This method returns the id of the line.
  /// @returns The id of the line.
  String get lineID => _lineID;

  /// This method returns the id of the favorite.
  /// @returns The id of the favorite.
  String get favoriteID => _favoriteID;
}
