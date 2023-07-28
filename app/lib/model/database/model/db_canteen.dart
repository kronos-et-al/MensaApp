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

  /// Creates a new instance of a canteen.
  /// @param _canteenID The id of the canteen.
  /// @param _name The name of the canteen.
  /// @returns A new instance of a canteen.
  DBCanteen(this._canteenID, this._name);

  @override
  Map<String, dynamic> toMap() {
    return {columnCanteenID: _canteenID, columnName: _name};
  }

  /// Creates a new instance of a canteen from a map.
  /// @param map The map to create the instance from.
  /// @returns A new instance of a canteen.
  static DBCanteen fromMap(Map<String, dynamic> map) {
    return DBCanteen(map[columnCanteenID], map[columnName]);
  }

  /// The string to create a table for the canteen.
  /// @returns The string to create a table for the canteen.
  static String initTable() {
    return '''
    CREATE TABLE $tableName (
      $columnCanteenID TEXT PRIMARY KEY,
      $columnName TEXT NOT NULL
    )
  ''';
  }

  /// This method returns the name of the canteen.
  /// @returns The name of the canteen.
  String get name => _name;

  /// This method returns the id of the canteen.
  /// @returns The id of the canteen.
  String get canteenID => _canteenID;
}
