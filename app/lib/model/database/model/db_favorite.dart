import 'package:app/model/database/model/database_model.dart';
import 'package:app/view_model/repository/data_classes/meal/FoodType.dart';

/// This class represents a favorite in the database.
class DBFavorite implements DatabaseModel {
  final String _mealID;
  final String? _lastDate;
  final FoodType _foodType;
  final DateTime _servedDate;
  final String _servedLineId;
  final int _priceStudent;
  final int _priceEmployee;
  final int _pricePupil;
  final int _priceGuest;

  /// The name of the table in the database.
  static const String tableName = 'favorite';

  /// The name of the column for the favorite id.
  static const String columnMealID = 'mealID';

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

  /// The name of the column for the served date.
  static const String columnServedDate = 'servedDate';

  /// The name of the column for the served line id.
  static const String columnServedLineId = 'servedLineId';

  /// Creates a new instance of a favorite.
  DBFavorite(
      this._mealID,
      this._lastDate,
      this._foodType,
      this._priceStudent,
      this._priceEmployee,
      this._pricePupil,
      this._priceGuest,
      this._servedDate,
      this._servedLineId);

  @override
  Map<String, dynamic> toMap() {
    return {
      columnMealID: _mealID,
      columnLastDate: _lastDate,
      columnFoodType: _foodType.name,
      columnPriceStudent: _priceStudent,
      columnPriceEmployee: _priceEmployee,
      columnPricePupil: _pricePupil,
      columnPriceGuest: _priceGuest,
      columnServedDate: _servedDate.toIso8601String(),
      columnServedLineId: _servedLineId
    };
  }

  /// Creates a favorite from a map.
  static DBFavorite fromMap(Map<String, dynamic> map) {
    return DBFavorite(
        map[columnMealID],
        map[columnLastDate],
        FoodType.values.byName(map[columnFoodType]),
        map[columnPriceStudent],
        map[columnPriceEmployee],
        map[columnPricePupil],
        map[columnPriceGuest],
        DateTime.parse(map[columnServedDate]),
        map[columnServedLineId]);
  }

  /// Returns a string to create a table for a favorite.
  static String initTable() {
    return '''
    CREATE TABLE $tableName (
      $columnMealID TEXT PRIMARY KEY,
      $columnLastDate TEXT,
      $columnFoodType TEXT,
      $columnPriceStudent INTEGER CHECK($columnPriceStudent > 0),
      $columnPriceEmployee INTEGER CHECK($columnPriceEmployee > 0),
      $columnPricePupil INTEGER CHECK($columnPricePupil > 0),
      $columnPriceGuest INTEGER CHECK($columnPriceGuest > 0),
      $columnServedDate TEXT NOT NULL,
      $columnServedLineId TEXT NOT NULL
    )
  ''';
  }

  /// This method returns the price for guests.
  int get priceGuest => _priceGuest;

  /// This method returns the price for pupils.
  int get pricePupil => _pricePupil;

  /// This method returns the price for employees.
  int get priceEmployee => _priceEmployee;

  /// This method returns the price for students.
  int get priceStudent => _priceStudent;

  /// This method returns the food type of the favorite.
  FoodType get foodType => _foodType;

  /// This method returns the last date of the favorite.
  String? get lastDate => _lastDate;

  /// This method returns the id of the favorite.
  String get mealID => _mealID;

  /// This method returns the served date of the favorite.
  DateTime get servedDate => _servedDate;

  /// This method returns the served line id of the favorite.
  String get servedLineId => _servedLineId;
}
