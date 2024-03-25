mixin NutritionDataMixin {
  late String entityID;
  late int energy;
  late int protein;
  late int carbohydrates;
  late int sugar;
  late int fat;
  late int saturatedFat;
  late int salt;

  /// The name of the column for the meal / side id.
  static const String columnEntityID = 'entityID';

  /// The name of the column for the meal's / side's energy.
  static const String columnEnergy = 'energy';

  /// The name of the column for the meal's / side's proteins.
  static const String columnProtein = 'protein';

  /// The name of the column for the meal's / side's carbohydrates.
  static const String columnCarbohydrates = 'carbohydrates';

  /// The name of the column for the meal's / side's sugar.
  static const String columnSugar = 'sugar';

  /// The name of the column for the meal's / side's fat.
  static const String columnFat = 'fat';

  /// The name of the column for the meal's / side's saturatedFat.
  static const String columnSaturatedFat = 'saturatedFat';

  /// The name of the column for the meal's / side's salt.
  static const String columnSalt = 'salt';

  Map<String, dynamic> toMap() {
    return {
      columnEntityID: entityID,
      columnEnergy: energy,
      columnProtein: protein,
      columnCarbohydrates: carbohydrates,
      columnSugar: sugar,
      columnFat: fat,
      columnSaturatedFat: saturatedFat,
      columnSalt: salt,
    };
  }

  void loadFromMap(Map<String, dynamic> map) {
    entityID = map[columnEntityID];
    energy = map[columnEnergy];
    protein = map[columnProtein];
    carbohydrates = map[columnCarbohydrates];
    sugar = map[columnSugar];
    fat = map[columnFat];
    saturatedFat = map[columnSaturatedFat];
    salt = map[columnSalt];
  }

  static String initTable(String tableName) {
    return '''
    CREATE TABLE $tableName (
      $columnEntityID TEXT PRIMARY KEY,
      $columnEnergy INTEGER,
      $columnProtein INTEGER,
      $columnCarbohydrates INTEGER,
      $columnSugar INTEGER,
      $columnFat INTEGER,
      $columnSaturatedFat INTEGER,
      $columnSalt INTEGER
    );
  ''';
  }
}
