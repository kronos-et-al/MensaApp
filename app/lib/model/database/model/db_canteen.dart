import 'database_model.dart';

class DBCanteen implements DatabaseModel {
  final String _canteenID;
  final String _name;

  static const String tableName = 'canteen';

  static const String columnCanteenID = 'canteenID';
  static const String columnName = 'name';

  DBCanteen(this._canteenID, this._name);

  @override
  Map<String, dynamic> toMap() {
    return {
      columnCanteenID: _canteenID,
      columnName: _name
    };
  }

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

  String get name => _name;

  String get canteenID => _canteenID;
}