import 'package:app/view_model/logic/image/ImageAccess.dart';
import 'package:app/view_model/repository/data_classes/meal/ImageData.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import '../model/mocks/ApiMock.dart';

void main() {
  final api = ApiMock();

  ImageAccess images = ImageAccess(api);

  ImageData image = ImageData(id: "42",
      url: "url",
      imageRank: 42,
      positiveRating: 42,
      negativeRating: 42);

  group("upvote", () {
    test("failed upvote", () async {
      when(() => api.upvoteImage(image)).thenAnswer((_) async => false);
      await images.upvoteImage(image);
      expect(image.individualRating, 0);
    });

    test("successful upvote", () async {
      when(() => api.upvoteImage(image)).thenAnswer((_) async => true);
      await images.upvoteImage(image);
      expect(image.individualRating, 1);
    });
  });

  group("delete upvote", () {
    test("failed request", () async {
      when(() => api.deleteUpvote(image)).thenAnswer((_) async => false);
      await images.deleteUpvote(image);
      expect(image.individualRating, 1);
    });

    test("successful request", () async {
      when(() => api.deleteUpvote(image)).thenAnswer((_) async => true);
      await images.deleteUpvote(image);
      expect(image.individualRating, 0);
    });
  });

  group("downvote", () {
    test("failed request", () async {
      when(() => api.downvoteImage(image)).thenAnswer((_) async => false);
      await images.downvoteImage(image);
      expect(image.individualRating, 0);
    });

    test("successful request", () async {
      when(() => api.downvoteImage(image)).thenAnswer((_) async => true);
      await images.downvoteImage(image);
      expect(image.individualRating, -1);
    });
  });

  group("delete downvote", () {
    test("failed request", () async {
      when(() => api.deleteDownvote(image)).thenAnswer((_) async => false);
      await images.deleteDownvote(image);
      expect(image.individualRating, -1);
    });

    test("successful request", () async {
      when(() => api.deleteDownvote(image)).thenAnswer((_) async => true);
      await images.deleteDownvote(image);
      expect(image.individualRating, 0);
    });
  });
}