import 'package:app/model/database/model/database_model.dart';

import 'db_meal.dart';

/// This class represents an image of a meal in the database.
class DBImage implements DatabaseModel {
  final String _imageID;
  final String _mealID;
  final String _url;
  final double _imageRank;
  final int _positiveRating;
  final int _negativeRating;
  final int _individualRating;

  /// The name of the table in the database.
  static const String tableName = 'image';

  /// The name of the column for the image id.
  static const String columnImageID = 'imageID';

  /// The name of the column for the meal id.
  static const String columnMealID = 'mealID';

  /// The name of the column for the url.
  static const String columnUrl = 'url';

  /// The name of the column for the image rank.
  static const String columnImageRank = 'imageRank';

  /// The name of the column for the positive rating.
  static const String columnPositiveRating = 'positiveRating';

  /// The name of the column for the negative rating.
  static const String columnNegativeRating = 'negativeRating';

  /// The name of the column for the individual rating.
  static const String columnIndividualRating = 'individualRating';

  /// Creates a new image.
  /// @param imageID The id of the image.
  /// @param mealID The id of the meal.
  /// @param url The url of the image.
  /// @param imageRank The rank of the image.
  /// @param positiveRating The positive rating of the image.
  /// @param negativeRating The negative rating of the image.
  /// @param individualRating The individual rating of the image.
  /// @returns A new image.
  DBImage(this._imageID, this._mealID, this._url, this._imageRank,
      this._positiveRating, this._negativeRating, this._individualRating);

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

  /// Creates a new image from a map.
  /// @param map The map to create the image from.
  static DBImage fromMap(Map<String, dynamic> map) {
    return DBImage(
        map[columnImageID],
        map[columnMealID],
        map[columnUrl],
        map[columnImageRank],
        map[columnPositiveRating],
        map[columnNegativeRating],
        map[columnIndividualRating]);
  }

  /// The string to create a table for an image.
  /// @returns The string to create a table for an image.
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

  /// This method returns the url of the image.
  /// @returns The url of the image.
  String get url => _url;

  /// This method returns the id of the meal.
  /// @returns The id of the meal.
  String get mealID => _mealID;

  /// This method returns the id of the image.
  /// @returns The id of the image.
  String get imageID => _imageID;

  /// This method returns the individual rating of the image.
  /// @returns The individual rating of the image.
  int get individualRating => _individualRating;

  /// This method returns the negative rating of the image.
  /// @returns The negative rating of the image.
  int get negativeRating => _negativeRating;

  /// This method returns the positive rating of the image.
  /// @returns The positive rating of the image.
  int get positiveRating => _positiveRating;

  /// This method returns the rank of the image.
  /// @returns The rank of the image.
  double get imageRank => _imageRank;
}
