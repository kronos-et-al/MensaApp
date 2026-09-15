import 'package:objectbox/objectbox.dart';

@Entity()
class BoxNutritionData {
  int id = 0;

  int energy;
  int protein;
  int carbohydrates;
  int sugar;
  int fat;
  int saturatedFat;
  int salt;

  BoxNutritionData({
    this.energy = 0,
    this.protein = 0,
    this.carbohydrates = 0,
    this.sugar = 0,
    this.fat = 0,
    this.saturatedFat = 0,
    this.salt = 0,
  });
}
