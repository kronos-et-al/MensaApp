import 'dart:developer';

import 'package:app/model/api_server/GraphQlServerAccess.dart';
import 'package:app/view_model/repository/data_classes/meal/FoodType.dart';
import 'package:app/view_model/repository/data_classes/meal/ImageData.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:app/view_model/repository/data_classes/meal/Price.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Canteen.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Line.dart';
import 'package:app/view_model/repository/data_classes/settings/ReportCategory.dart';
import 'package:app/view_model/repository/error_handling/Result.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';

void main() async {
  final GraphQlServerAccess serverAccess =
      GraphQlServerAccess("1f16dcca-963e-4ceb-a8ca-843a7c9277a5");

  test('auth', () async { // TODO remove test
    String token = "";
    final httpLink = HttpLink(const String.fromEnvironment('API_URL'));
    final authLink = AuthLink(getToken: () => token);

    final GraphQLClient _client =
        GraphQLClient(link: authLink.concat(httpLink), cache: GraphQLCache());

    token =
        "Mensa MWQ3NWQzODAtY2YwNy00ZWRiLTkwNDYtYTJkOTgxYmMyMTlkOmFiYzoxMjM=";
    var result = await _client.query(QueryOptions(
      document: gql("""{
    getMyAuth{clientId,apiIdent,hash}
    }
        """),
    ));
    expect(result.data?["getMyAuth"]?["clientId"],
        "1d75d380-cf07-4edb-9046-a2d981bc219d");
  });

  test('environment endpoint defined', () {
    expect(const String.fromEnvironment('API_URL').isNotEmpty, true,
        reason:
            "define secret file with `--dart-define-from-file=<path to secret.json>`, see README");
  });

  test('remove downvote', () async {
    var deleted = await serverAccess.deleteDownvote(ImageData(
        id: "bd3c88f9-5dc8-4773-85dc-53305930e7b6",
        url: "url",
        imageRank: 0,
        positiveRating: 0,
        negativeRating: 0));
    expect(deleted, true);
  });

  test('remove upvote', () async {
    var deleted = await serverAccess.deleteUpvote(ImageData(
        id: "bd3c88f9-5dc8-4773-85dc-53305930e7b6",
        url: "url",
        imageRank: 0,
        positiveRating: 0,
        negativeRating: 0));
    expect(deleted, true);
  });

  test('add downvote', () async {
    var deleted = await serverAccess.downvoteImage(ImageData(
        id: "bd3c88f9-5dc8-4773-85dc-53305930e7b6",
        url: "url",
        imageRank: 0,
        positiveRating: 0,
        negativeRating: 0));
    expect(deleted, true);
  });

  test('add upvote', () async {
    var deleted = await serverAccess.upvoteImage(ImageData(
        id: "bd3c88f9-5dc8-4773-85dc-53305930e7b6",
        url: "url",
        imageRank: 0,
        positiveRating: 0,
        negativeRating: 0));
    expect(deleted, true);
  });

  test('link image', () async {
    var deleted = await serverAccess.linkImage(
        "https://image_url.de",
        Meal(
            id: "bd3c88f9-5dc8-4773-85dc-53305930e7b6",
            name: "Best meal",
            foodType: FoodType.vegetarian,
            price: Price(student: 1, employee: 23, pupil: 5, guest: 15)));
    expect(deleted, true);
  });

  test('report image', () async {
    var deleted = await serverAccess.reportImage(
        ImageData(
            id: "bd3c88f9-5dc8-4773-85dc-53305930e7b6",
            url: "http://image.de",
            imageRank: 0.89,
            positiveRating: 1,
            negativeRating: 22),
        ReportCategory.wrongMeal);
    expect(deleted, true);
  });

  test('rate meal', () async {
    var deleted = await serverAccess.updateMealRating(
        3,
        Meal(
            id: "bd3c88f9-5dc8-4773-85dc-53305930e7b6",
            name: "Best meal",
            foodType: FoodType.fish,
            price: Price(student: 22, employee: 33, pupil: 11, guest: 123)));
    expect(deleted, true);
  });

  test('date format', () {
    final dateFormat = DateFormat(GraphQlServerAccess.dateFormatPattern);
    expect(dateFormat.format(DateTime(2022, 3, 1)), "2022-03-01");
  });

  test('update all', () async {
    var result = await serverAccess.updateAll();

    var res = switch (result) {
      Success(value: final mealplan) => true, // TODO
      Failure(value: final exception) => expect(exception.toString(), ""),
    };
  });

  test('update canteen', () async {
    var result = await serverAccess.updateCanteen(
        Canteen(id: "bd3c88f9-5dc8-4773-85dc-53305930e7b6", name: "Canteen"),
        DateTime(2020, 11, 1));

    var res = switch (result) {
      Success(value: final mealplan) => true, //TODO
      Failure(value: final exception) => expect(exception.toString(), ""),
    };
  });

  test('meal from id', () async {
    var result = await serverAccess.getMealFromId(
        Meal(
            id: "bd3c88f9-5dc8-4773-85dc-53305930e7b6",
            name: "Best Meal",
            foodType: FoodType.porkAw,
            price: Price(student: 212, employee: 32, pupil: 123, guest: 342)),
        Line(
            id: "bd3c88f9-5dc8-4773-85dc-53305930e7b6",
            name: "Line name",
            canteen: Canteen(
                id: "bd3c88f9-5dc8-4773-85dc-53305930e7b6",
                name: "Canteen name"),
            position: 22),
        DateTime(2020, 11, 2));

    var res = switch (result) {
      Success(value: final mealplan) => true, // TODO better testing?
      Failure(value: final exception) =>
        expect(exception, true, reason: "exception while request"),
    };
  });

  test('get canteen', () async {
    var result = await serverAccess
        .getCanteenOrDefault("ad860196-74aa-48c2-a032-e327ec338290");

    var res = switch (result) {
      Success(value: final canteen) => true, // TODO better testing?
      Failure(value: final exception) =>
        expect(exception, true, reason: "exception while request"),
    };
  });

  test('get default canteen', () async {
    var result = await serverAccess.getCanteenOrDefault(null);

    var res = switch (result) {
      Success(value: final canteen) => true, // TODO better testing?
      Failure(value: final exception) =>
        expect(exception, true, reason: "exception while request"),
    };
  });
}
