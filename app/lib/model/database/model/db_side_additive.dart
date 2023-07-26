import 'package:app/model/database/model/database_model.dart';
import 'package:app/model/database/model/db_side.dart';

import '../../../view_model/repository/data_classes/meal/Additive.dart';

class DBSideAdditive implements DatabaseModel {

  final String _sideID;
  final Additive _additive;

  static const String tableName = 'sideAdditive';

  static const String columnSideID = 'sideID';
  static const String columnAdditive = 'additive';

  DBSideAdditive(this._sideID, this._additive);

  @override
  Map<String, dynamic> toMap() {
    return {
      columnSideID: _sideID,
      columnAdditive: _additive
    };
  }

  static DBSideAdditive fromMap(Map<String, dynamic> map) {
    return DBSideAdditive(map[columnSideID], map[columnAdditive]);
  }

  /// The string to create a table for an additive of a side.
  static String initTable() {
    return '''
    CREATE TABLE $tableName (
      $columnSideID TEXT,
      $columnAdditive TEXT,
      FOREIGN KEY($columnSideID) REFERENCES ${DBSide.tableName}(${DBSide.columnSideID}),
      PRIMARY KEY($columnSideID, $columnAdditive)
    )
  ''';
  }

  Additive get additive => _additive;

  String get sideID => _sideID;
}