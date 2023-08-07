import 'package:app/view_model/repository/data_classes/meal/ImageData.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const String id = "42";
  const String url = "url";
  const double imageRank = 42;
  const int positiveRating = 42;
  const int negativeRating = 42;

  int individualRating = 0;

  ImageData image = ImageData(
      id: id,
      url: url,
      imageRank: imageRank,
      positiveRating: positiveRating,
      negativeRating: negativeRating);

  group("constructor", () {
    test("id", () => expect(image.id, id));
    test("url", () => expect(image.url, url));
    test("imageRank", () => expect(image.imageRank, imageRank));
    test("positiveRating", () => expect(image.positiveRating, positiveRating));
    test("negativeRating", () => expect(image.negativeRating, negativeRating));
    test("individualRating", () => expect(image.individualRating, individualRating));
  });

  group("votes", () {
    test("upvote", () {
      image.upvote();
      expect(image.individualRating, 1);
    });

    test("downvote", () {
      image.downvote();
      expect(image.individualRating, -1);
    });

    test("delete rating", () {
      image.deleteRating();
      expect(image.individualRating, 0);
    });
  });
}
