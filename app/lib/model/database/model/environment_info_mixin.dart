mixin EnvironmentInfoMixin {
  late String entityID;
  late int averageRating;
  late int co2Rating;
  late int co2Value;
  late int waterRating;
  late int waterValue;
  late int animalWelfareRating;
  late int rainforestRating;
  late int maxRating;

  /// The name of the column for the meal / side id.
  static const String columnEntityID = 'entityID';

  /// The name of the column for the meal's / side's average rating.
  static const String columnAverageRating = 'averageRating';

  /// The name of the column for the meal's / side's CO2 rating.
  static const String columnCO2Rating = 'co2Rating';

  /// The name of the column for the meal's / side's CO2 value.
  static const String columnCO2Value = 'co2Value';

  /// The name of the column for the meal's / side's water rating.
  static const String columnWaterRating = 'waterRating';

  /// The name of the column for the meal's / side's water value.
  static const String columnWaterValue = 'waterValue';

  /// The name of the column for the meal's / side's animal welfare rating.
  static const String columnAnimalWelfareRating = 'animalWelfareRating';

  /// The name of the column for the meal's / side's rainforest rating.
  static const String columnRainforestRating = 'rainforestRating';

  /// The name of the column for the meal's / side's max rating.
  static const String columnMaxRating = 'maxRating';

  Map<String, dynamic> toMap() {
    return {
      columnEntityID: entityID,
      columnAverageRating: averageRating,
      columnCO2Rating: co2Rating,
      columnCO2Value: co2Value,
      columnWaterRating: waterRating,
      columnWaterValue: waterValue,
      columnAnimalWelfareRating: animalWelfareRating,
      columnRainforestRating: rainforestRating,
      columnMaxRating: maxRating,
    };
  }

  void loadFromMap(Map<String, dynamic> map) {
    entityID = map[columnEntityID];
    averageRating = map[columnAverageRating];
    co2Rating = map[columnCO2Rating];
    co2Value = map[columnCO2Value];
    waterRating = map[columnWaterRating];
    waterValue = map[columnWaterValue];
    animalWelfareRating = map[columnAnimalWelfareRating];
    rainforestRating = map[columnRainforestRating];
    maxRating = map[columnMaxRating];
  }

  static String initTable(String tableName) {
    return '''
    CREATE TABLE $tableName (
      $columnEntityID TEXT PRIMARY KEY,
      $columnAverageRating INTEGER,
      $columnCO2Rating INTEGER,
      $columnCO2Value INTEGER,
      $columnWaterRating INTEGER,
      $columnWaterValue INTEGER,
      $columnAnimalWelfareRating INTEGER,
      $columnRainforestRating INTEGER,
      $columnMaxRating INTEGER
    );
  ''';
  }
}
