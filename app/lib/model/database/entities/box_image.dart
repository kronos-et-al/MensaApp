import 'package:objectbox/objectbox.dart';

@Entity()
class BoxImage {
  int id = 0;

  @Unique()
  String imageId;

  String url;
  double imageRank;
  int positiveRating;
  int negativeRating;
  int individualRating;

  BoxImage({
    required this.imageId,
    required this.url,
    required this.imageRank,
    required this.positiveRating,
    required this.negativeRating,
    required this.individualRating,
  });
}
