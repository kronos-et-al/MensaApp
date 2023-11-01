import 'dart:io';

import 'package:app/view_model/logic/image/ImageAccess.dart';
import 'package:app/view_model/repository/data_classes/meal/FoodType.dart';
import 'package:app/view_model/repository/data_classes/meal/ImageData.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:app/view_model/repository/data_classes/meal/Price.dart';
import 'package:app/view_model/repository/data_classes/settings/ReportCategory.dart';
import 'package:app/view_model/repository/error_handling/ImageUploadException.dart';
import 'package:app/view_model/repository/error_handling/Result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mocktail/mocktail.dart';

import '../model/mocks/ApiMock.dart';
import '../model/mocks/DatabaseMock.dart';

void main() {
  final api = ApiMock();
  final database = DatabaseMock();

  final imageFile = File("test/test.jpg").readAsBytesSync();
  final mediaType = MediaType("image", "jpeg");

  ImageData image = ImageData(
      id: "42",
      url: "url",
      imageRank: 42,
      positiveRating: 42,
      negativeRating: 42);

  final Meal meal = Meal(
      id: "42",
      name: "name",
      foodType: FoodType.vegetarian,
      price: Price(student: 100, employee: 200, pupil: 300, guest: 400),
      images: [image]);

  ImageAccess images = ImageAccess(api, database);

  setUp(() => when(() => database.updateImage(image)).thenAnswer((_) async {}));

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

  group("link image", () {
    test("failed request", () async {
      when(() => api.linkImage(imageFile, mediaType, meal)).thenAnswer((_) async => Failure(ImageUploadException("error")));
      final result = switch (await images.linkImage(imageFile, mediaType, meal)) {
        Success(value: final value) => value,
        Failure(exception: final exception) => exception
      };
      expect(result is ImageUploadException, isTrue);
    });

    test("successful request", () async {
      when(() => api.linkImage(imageFile, mediaType, meal)).thenAnswer((_) async => const Success(true));
      final result = switch (await images.linkImage(imageFile, mediaType, meal)) {
        Success(value: final value) => value,
        Failure(exception: final exception) => exception
      };
      expect(result, isTrue);
    });
  });

  group("report image", () {
    test("failed report", () async {
      when(() => api.reportImage(image, ReportCategory.noMeal))
          .thenAnswer((_) async => false);
      expect(await images.reportImage(meal, image, ReportCategory.noMeal),
          false);
    });

    test("successful report", () async {
      when(() => api.reportImage(image, ReportCategory.noMeal))
          .thenAnswer((_) async => true);
      when(() => database.removeImage(image)).thenAnswer((_) async {});

      expect(await images.reportImage(meal, image, ReportCategory.noMeal),
          true);
      verify(() => database.removeImage(image)).called(1);
    });
  });
}
