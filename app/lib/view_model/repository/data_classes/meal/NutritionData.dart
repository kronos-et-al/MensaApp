class NutritionData {
  final int _energy;
  final int _protein;
  final int _carbohydrates;
  final int _sugar;
  final int _fat;
  final int _saturatedFat;
  final int _salt;

  NutritionData({
    required int energy,
    required int protein,
    required int carbohydrates,
    required int sugar,
    required int fat,
    required int saturatedFat,
    required int salt
  })  : _energy = energy,
        _protein = protein,
        _carbohydrates = carbohydrates,
        _sugar = sugar,
        _fat = fat,
        _saturatedFat = saturatedFat,
        _salt = salt;

  NutritionData.copy({
    required NutritionData nutritionData,
    int? energy,
    int? protein,
    int? carbohydrates,
    int? sugar,
    int? fat,
    int? saturatedFat,
    int? salt
})  : _energy = energy ?? nutritionData.energy,
      _protein = protein ?? nutritionData.protein,
      _carbohydrates = carbohydrates ?? nutritionData.carbohydrates,
      _sugar = sugar ?? nutritionData.sugar,
      _fat = fat ?? nutritionData.fat,
      _saturatedFat = saturatedFat ?? nutritionData.saturatedFat,
      _salt = salt ?? nutritionData.salt;

  int get salt => _salt;

  int get saturatedFat => _saturatedFat;

  int get fat => _fat;

  int get sugar => _sugar;

  int get carbohydrates => _carbohydrates;

  int get protein => _protein;

  int get energy => _energy;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NutritionData &&
          runtimeType == other.runtimeType &&
          _energy == other._energy &&
          _protein == other._protein &&
          _carbohydrates == other._carbohydrates &&
          _sugar == other._sugar &&
          _fat == other._fat &&
          _saturatedFat == other._saturatedFat &&
          _salt == other._salt;

  @override
  int get hashCode => _energy.hashCode ^ _protein.hashCode ^ _carbohydrates.hashCode ^ _sugar.hashCode ^ _fat.hashCode ^ _saturatedFat.hashCode ^ _salt.hashCode;
}
