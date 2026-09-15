import 'package:objectbox/objectbox.dart';

@Entity()
class BoxEnvironmentInfo {
  int id = 0;

  int averageRating;
  int co2Rating;
  int co2Value;
  int waterRating;
  int waterValue;
  int animalWelfareRating;
  int rainforestRating;
  int maxRating;

  BoxEnvironmentInfo({
    this.averageRating = 0,
    this.co2Rating = 0,
    this.co2Value = 0,
    this.waterRating = 0,
    this.waterValue = 0,
    this.animalWelfareRating = 0,
    this.rainforestRating = 0,
    this.maxRating = 0,
  });
}
