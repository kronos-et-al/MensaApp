import 'package:app/model/database/model/database_model.dart';

import 'db_meal.dart';

class DBImage implements DatabaseModel {

  final String _imageID;
  final String _mealID;
  final String _url;

  static const String tableName = 'image';

  static const String columnImageID = 'imageID';
  static const String columnMealID = 'mealID';
  static const String columnUrl = 'url';

  DBImage(this._imageID, this._mealID, this._url);

  @override
  Map<String, dynamic> toMap() {
    return {
      columnImageID: _imageID,
      columnMealID: _mealID,
      columnUrl: _url
    };
  }

  static DBImage fromMap(Map<String, dynamic> map) {
    return DBImage(map[columnImageID], map[columnMealID], map[columnUrl]);
  }

  /// The string to create a table for an image.
  static String initTable() {
    return '''
    CREATE TABLE $tableName(
      $columnImageID TEXT PRIMARY KEY,
      $columnMealID TEXT NOT NULL,
      $columnUrl TEXT NOT NULL,
      FOREIGN KEY($columnMealID) REFERENCES ${DBMeal.tableName}(${DBMeal.columnMealID})
    )
  ''';
  }

  String get url => _url;

  String get mealID => _mealID;

  String get imageID => _imageID;
}