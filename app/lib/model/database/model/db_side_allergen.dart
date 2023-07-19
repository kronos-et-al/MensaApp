import 'package:app/model/database/model/database_model.dart';
import 'package:app/model/database/model/db_side.dart';

import '../../../view_model/repository/data_classes/meal/Allergen.dart';

class DBSideAllergen implements DatabaseModel {

  final String _sideID;
  final Allergen _allergen;

  static const String tableName = 'sideAllergen';

  static const String columnSideID = 'sideID';
  static const String columnAllergen = 'allergen';

  DBSideAllergen(this._sideID, this._allergen);

  @override
  Map<String, dynamic> toMap() {
    return {
      columnSideID: _sideID,
      columnAllergen: _allergen
    };
  }

  static DBSideAllergen fromMap(Map<String, dynamic> map) {
    return DBSideAllergen(map[columnSideID], map[columnAllergen]);
  }

  /// The string to create a table for an allergen of a side.
  static String initTable() {
    return '''
    CREATE TABLE $tableName(
      $columnSideID TEXT,
      $columnAllergen TEXT CHECK IN (${Allergen.values.map((allergen) => "'$allergen'").join(', ')}),
      FOREIGN KEY($columnSideID) REFERENCES ${DBSide.tableName}(${DBSide.columnSideID}),
      PRIMARY KEY($columnSideID, $columnAllergen)
    )
  ''';
  }
}