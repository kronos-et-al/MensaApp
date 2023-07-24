import 'package:app/model/database/model/db_canteen.dart';

import 'database_model.dart';

class DBLine implements DatabaseModel {

  final String _lineID;
  final String _canteenID;
  final String _name;
  final int _position;

  static const String tableName = 'line';

  static const String columnLineID = 'lineID';
  static const String columnCanteenID = 'canteenID';
  static const String columnName = 'name';
  static const String columnPosition = 'position';

  DBLine(this._lineID, this._canteenID, this._name, this._position);

  @override
  Map<String, dynamic> toMap() {
    return {
      columnLineID: _lineID,
      columnCanteenID: _canteenID,
      columnName: _name,
      columnPosition: _position
    };
  }

  static DBLine fromMap(Map<String, dynamic> map) {
    return DBLine(map[columnLineID], map[columnCanteenID], map[columnName], map[columnPosition]);
  }

  /// The string to create a table for a line of a canteen.
  static String initTable() {
    return '''
    CREATE TABLE $tableName(
      $columnLineID TEXT PRIMARY KEY,
      $columnCanteenID TEXT NOT NULL,
      $columnName TEXT NOT NULL,
      $columnPosition INTEGER NOT NULL,
      FOREIGN KEY($columnCanteenID) REFERENCES ${DBCanteen.tableName}(${DBCanteen.columnCanteenID})
    )
  ''';
  }

  int get position => _position;

  String get name => _name;

  String get canteenID => _canteenID;

  String get lineID => _lineID;


}