import 'package:app/model/database/model/database_model.dart';
import 'package:app/model/database/model/db_side.dart';

import '../../../view_model/repository/data_classes/meal/Additive.dart';

/// This class represents an additive of a side in the database.
class DBSideAdditive implements DatabaseModel {
  final String _sideID;
  final Additive _additive;

  /// The name of the table in the database.
  static const String tableName = 'sideAdditive';

  /// The name of the column for the side id.
  static const String columnSideID = 'sideID';

  /// The name of the column for the additive.
  static const String columnAdditive = 'additive';

  /// Creates a new instance of a side additive.
  /// @param _sideID The id of the side.
  /// @param _additive The additive of the side.
  /// @returns A new instance of a side additive.
  DBSideAdditive(this._sideID, this._additive);

  @override
  Map<String, dynamic> toMap() {
    return {columnSideID: _sideID, columnAdditive: _additive};
  }

  /// Creates a new instance of a side additive from a map.
  /// @param map The map to create the instance from.
  /// @returns A new instance of a side additive.
  static DBSideAdditive fromMap(Map<String, dynamic> map) {
    return DBSideAdditive(
        map[columnSideID], Additive.values.byName(map[columnAdditive]));
  }

  /// The string to create a table for an additive of a side.
  /// @returns The string to create a table for an additive of a side.
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

  /// This method returns the additive of the side.
  /// @returns The additive of the side.
  Additive get additive => _additive;

  /// This method returns the id of the side.
  /// @returns The id of the side.
  String get sideID => _sideID;
}
