import 'package:app/model/database/model/database_model.dart';
import 'package:app/model/database/model/environment_info_mixin.dart';

/// This class represents a meal's environment info in the database.
class DBSideEnvironmentInfo with EnvironmentInfoMixin implements DatabaseModel {
  /// The name of the table in the database.
  static const String tableName = 'sideEnvironmentInfo';

  DBSideEnvironmentInfo.empty();

  DBSideEnvironmentInfo.fromMap(Map<String, dynamic> map) {
    DBSideEnvironmentInfo.empty();
    loadFromMap(map);
  }

  DBSideEnvironmentInfo(
      String sideID,
      int averageRating,
      int co2Rating,
      int co2Value,
      int waterRating,
      int waterValue,
      int animalWelfareRating,
      int rainforestRating,
      int maxRating) {
    this.entityID = sideID;
    this.averageRating = averageRating;
    this.co2Rating = co2Rating;
    this.co2Value = co2Value;
    this.waterRating = waterRating;
    this.waterValue = waterValue;
    this.animalWelfareRating = animalWelfareRating;
    this.rainforestRating = rainforestRating;
    this.maxRating = maxRating;
  }

  static String initTable() {
    return EnvironmentInfoMixin.initTable(tableName);
  }
}
