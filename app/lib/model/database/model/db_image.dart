import 'package:app/model/database/model/database_model.dart';

import 'db_meal.dart';

class DBImage implements DatabaseModel {

  final String _imageID;
  final String _mealID;
  final String _url;
  final double _imageRank;
  final int _positiveRating;
  final int _negativeRating;
  final int _individualRating;

  static const String tableName = 'image';

  static const String columnImageID = 'imageID';
  static const String columnMealID = 'mealID';
  static const String columnUrl = 'url';
  static const String columnImageRank = 'imageRank';
  static const String columnPositiveRating = 'positiveRating';
  static const String columnNegativeRating = 'negativeRating';
  static const String columnIndividualRating = 'individualRating';

  DBImage(this._imageID, this._mealID, this._url, this._imageRank, this._positiveRating, this._negativeRating, this._individualRating);

  @override
  Map<String, dynamic> toMap() {
    return {
      columnImageID: _imageID,
      columnMealID: _mealID,
      columnUrl: _url,
      columnImageRank: _imageRank,
      columnPositiveRating: _positiveRating,
      columnNegativeRating: _negativeRating,
      columnIndividualRating: _negativeRating
    };
  }

  static DBImage fromMap(Map<String, dynamic> map) {
    return DBImage(map[columnImageID], map[columnMealID], map[columnUrl], map[columnImageRank], map[columnPositiveRating], map[columnNegativeRating], map[columnIndividualRating]);
  }

  /// The string to create a table for an image.
  static String initTable() {
    return '''
    CREATE TABLE $tableName (
      $columnImageID TEXT PRIMARY KEY,
      $columnMealID TEXT NOT NULL,
      $columnUrl TEXT NOT NULL,
      $columnImageRank REAL,
      $columnPositiveRating INTEGER,
      $columnNegativeRating INTEGER,
      $columnIndividualRating INTEGER,
      FOREIGN KEY($columnMealID) REFERENCES ${DBMeal.tableName}(${DBMeal.columnMealID})
    )
  ''';
  }

  String get url => _url;

  String get mealID => _mealID;

  String get imageID => _imageID;

  int get individualRating => _individualRating;

  int get negativeRating => _negativeRating;

  int get positiveRating => _positiveRating;

  double get imageRank => _imageRank;
}