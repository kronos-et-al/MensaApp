import 'dart:io';

import 'package:app/model/api_server/GraphQlServerAccess.dart';
import 'package:app/model/database/SQLiteDatabaseAccess.dart';
import 'package:app/view_model/logic/image/ImageAccess.dart';
import 'package:app/view_model/repository/data_classes/meal/FoodType.dart';
import 'package:app/view_model/repository/data_classes/meal/ImageData.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:app/view_model/repository/data_classes/meal/Price.dart';
import 'package:app/view_model/repository/data_classes/mealplan/MealPlan.dart';
import 'package:app/view_model/repository/data_classes/settings/ReportCategory.dart';
import 'package:app/view_model/repository/error_handling/Result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_parser/http_parser.dart';

import '../model/api_server/config.dart';

void main() {
  final GraphQlServerAccess api = GraphQlServerAccess(
      testServer, testApiKey, "1f16dcca-963e-4ceb-a8ca-843a7c9277a5");
  final SQLiteDatabaseAccess database = SQLiteDatabaseAccess();

  final ImageAccess access = ImageAccess(api, database);

  late final ImageData image;
  late final Meal meal;

  setUpAll(() async {
    final List<MealPlan> mealPlan = switch (await api.updateAll()) {
      Success(value: final value) => value,
      Failure(exception: _) => []
    };

    database.updateAll(mealPlan);
    meal = mealPlan.map((e) => e.meals).first.first;

    if (meal.images == null || meal.images!.isEmpty) {
      return;
    }
    image = meal.images!.first;
  });

  test("delete downvote", () async {
    final message = await access.deleteDownvote(image);
    expect(message, null);
  });

  test("delete upvote", () async {
    final message = await access.deleteUpvote(image);
    expect(message, null);
  });

  test("add upvote", () async {
    final message = await access.upvoteImage(image);
    expect(message, null);
  });

  test("add downvote", () async {
    final message = await access.downvoteImage(image);
    expect(message, null);
  });

  test("report image", () async {
    final message = await access.reportImage(meal, image, ReportCategory.other);
    final Meal result = switch (await database.getMeal(meal)) {
      Success(value: final value) => value,
      Failure(exception: _) => meal
    };

    expect(message, "snackbar.reportImageSuccess");
    expect(result.images?.contains(image), isFalse);
  });

  final imageFile = File("test/test.jpg").readAsBytesSync();
  final mediaType
  = MediaType("image", "jpeg");

  test("link image", () async {
    final message = await access.linkImage(
        imageFile,
        mediaType,
        Meal(
            id: "bd3c88f9-5dc8-4773-85dc-53305930e7b6",
            name: "Best meal",
            foodType: FoodType.vegetarian,
            price: Price(student: 1, employee: 23, pupil: 5, guest: 15)));
    expect(message, "snackbar.linkImageSuccess");
  });
}
