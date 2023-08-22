import 'database_model.dart';

/// This class represents a canteen in the database.
class DBCanteen implements DatabaseModel {
  final String _canteenID;
  final String _name;

  /// The name of the table in the database.
  static const String tableName = 'canteen';

  /// The name of the column for the canteen id.
  static const String columnCanteenID = 'canteenID';

  /// The name of the column for the name.
  static const String columnName = 'name';

  /// Creates a new instance of a canteen as it is represented in the database.
  DBCanteen(this._canteenID, this._name);

  @override
  Map<String, dynamic> toMap() {
    return {columnCanteenID: _canteenID, columnName: _name};
  }

  /// Creates a new instance of a canteen from a map.
  static DBCanteen fromMap(Map<String, dynamic> map) {
    return DBCanteen(map[columnCanteenID], map[columnName]);
  }

  /// The string to create a table for the canteen.
  static String initTable() {
    return '''
    CREATE TABLE $tableName (
      $columnCanteenID TEXT PRIMARY KEY,
      $columnName TEXT NOT NULL
    )
  ''';
  }

  /// Returns the name of the canteen.
  String get name => _name;

  /// Returns the id of the canteen.
  String get canteenID => _canteenID;
}
