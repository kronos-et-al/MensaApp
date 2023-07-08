import 'package:app/model/api_server/requests/querys.graphql.dart';
import 'package:app/model/api_server/requests/schema.graphql.dart';
import 'package:app/view_model/repository/data_classes/meal/FoodType.dart';
import 'package:app/view_model/repository/data_classes/meal/ImageData.dart';

import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:app/view_model/repository/data_classes/meal/Price.dart';

import 'package:app/view_model/repository/data_classes/mealplan/Canteen.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Line.dart';

import 'package:app/view_model/repository/data_classes/mealplan/MealPlan.dart';

import 'package:app/view_model/repository/data_classes/settings/ReportCategory.dart';

import 'package:app/view_model/repository/error_handling/Result.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:intl/intl.dart';

import '../../view_model/repository/interface/IServerAccess.dart';
import 'requests/mutations.graphql.dart';

class GraphQlServerAccess implements IServerAccess {
  final String _apiKey = const String.fromEnvironment('API_KEY');

  final GraphQLClient _client = GraphQLClient(
      link: HttpLink(const String.fromEnvironment('API_URL')),
      cache: GraphQLCache());
  final String _clientId;

  GraphQlServerAccess._(this._clientId);



  factory GraphQlServerAccess(String clientId) {
    return GraphQlServerAccess._(clientId);
  }

  // ---------------------- mutations ----------------------

  @override
  Future<bool> deleteDownvote(ImageData image) async {
    // TODO auth
    final result = await _client.mutate$RemoveDownvote(
        Options$Mutation$RemoveDownvote(
            variables: Variables$Mutation$RemoveDownvote(imageId: image.id)));
    final parsedData = result.parsedData;
    return parsedData?.removeDownvote ?? false;
  }

  @override
  Future<bool> deleteUpvote(ImageData image) async {
    // TODO auth
    final result = await _client.mutate$RemoveUpvote(
        Options$Mutation$RemoveUpvote(
            variables: Variables$Mutation$RemoveUpvote(imageId: image.id)));
    final parsedData = result.parsedData;
    return parsedData?.removeUpvote ?? false;
  }

  @override
  Future<bool> downvoteImage(ImageData image) async {
    // TODO auth
    final result = await _client.mutate$AddDownvote(
        Options$Mutation$AddDownvote(
            variables: Variables$Mutation$AddDownvote(imageId: image.id)));
    final parsedData = result.parsedData;
    return parsedData?.addDownvote ?? false;
  }

  @override
  Future<bool> upvoteImage(ImageData image) async {
    // TODO auth
    final result = await _client.mutate$AddUpvote(Options$Mutation$AddUpvote(
        variables: Variables$Mutation$AddUpvote(imageId: image.id)));
    final parsedData = result.parsedData;
    return parsedData?.addUpvote ?? false;
  }

  @override
  Future<bool> linkImage(String url, Meal meal) async {
    // TODO: auth
    final result = await _client.mutate$LinkImage(Options$Mutation$LinkImage(
        variables:
        Variables$Mutation$LinkImage(imageUrl: url, mealId: meal.id)));
    final parsedData = result.parsedData;
    return parsedData?.addImage ?? false;
  }

  @override
  Future<bool> reportImage(ImageData image, ReportCategory reportReason) async {
    // TODO: auth
    final result = await _client.mutate$ReportImage(
        Options$Mutation$ReportImage(
            variables: Variables$Mutation$ReportImage(
                imageId: image.id,
                reason: _convertToReportReason(reportReason))));
    final parsedData = result.parsedData;
    return parsedData?.reportImage ?? false;
  }

  @override
  Future<bool> updateMealRating(int rating, Meal meal) async {
    // TODO: auth
    final result = await _client.mutate$UpdateRating(
        Options$Mutation$UpdateRating(
            variables: Variables$Mutation$UpdateRating(
                mealId: meal.id, rating: rating)));
    final parsedData = result.parsedData;
    return parsedData?.setRating ?? false;
  }

  // ---------------------- queries ----------------------
  static const DAYS_TO_PARSE = 7;
  @override
  Future<Result<List<Mealplan>>> updateAll() async {
    final dateFormat = DateFormat("Y-m-d"); // TODO correct?
    final date = DateTime.now(); // TODO for next 7 days


    var completeList = <Mealplan>[];

    for (int offset = 0; offset < 7; offset++) {
      final offsetDate = date.add(Duration(days: offset));
      final result = await _client.query$GetMealPlanForDay(
          Options$Query$GetMealPlanForDay(
              variables: Variables$Query$GetMealPlanForDay(
                  date: dateFormat.format(offsetDate))));
      final parsedData = result.parsedData;


      final mealPlan = parsedData?.getCanteens.expand((e) =>
          e.lines.asMap().map((idx, e) =>
              MapEntry(idx,
                Mealplan(date: offsetDate,
                    line: Line(id: e.id,
                        name: e.name,
                        canteen: _convertCanteen(e.canteen),
                        position: idx),
                    isClosed: false, // TODO what to do when no data available
                    meals: _convertMeals(e.meals ?? [])),
              ),
          ).values.toList(),
      ).toList() ?? [];

      completeList.addAll(mealPlan);
    }
    return Success(completeList);
  }

  @override
  Future<Result<Meal>> getMealFromId(String id) async {
    // TODO: implement getMealFromId
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Mealplan>>> updateCanteen(Canteen canteen,
      DateTime date) async {
    // TODO: implement updateCanteen
    throw UnimplementedError();
  }
}


List<Meal> _convertMeals(List<Fragment$mealInfo> meals) {
  return meals.map((e) =>
      Meal(id: e.id,
          name: e.name,
          foodType: _convertMealType(e.mealType),
          price: _convertPrice(e.price))).toList();
}

FoodType _convertMealType(Enum$MealType mealType) {
  switch (mealType) {
    case Enum$MealType.BEEF:
      return FoodType.beef;
    case Enum$MealType.BEEF_AW:
      return FoodType.beefAw;
    case Enum$MealType.FISH:
      return FoodType.fish;
    case Enum$MealType.PORK:
      return FoodType.pork;
    case Enum$MealType.PORK_AW:
      return FoodType.porkAw;
    case Enum$MealType.VEGAN:
      return FoodType.vegan;
    case Enum$MealType.VEGETARIAN:
      return FoodType.vegetarian;
    case Enum$MealType.UNKNOWN:
      return FoodType.unknown;
    case Enum$MealType.$unknown:
      return FoodType.unknown;
  }
}

Price _convertPrice(Fragment$mealInfo$price price) {
  return Price(student: price.student,
      employee: price.employee,
      pupil: price.pupil,
      guest: price.guest);
}

Canteen _convertCanteen(
    Query$GetMealPlanForDay$getCanteens$lines$canteen canteen) {
  return Canteen(id: canteen.id, name: canteen.name);
}

// ---------------------- utility functions ----------------------

Enum$ReportReason _convertToReportReason(ReportCategory reportReason) {
  switch (reportReason) {
    case ReportCategory.offensive:
      return Enum$ReportReason.OFFENSIVE;
    case ReportCategory.advert:
      return Enum$ReportReason.ADVERT;
    case ReportCategory.noMeal:
      return Enum$ReportReason.NO_MEAL;
    case ReportCategory.violatesRights:
      return Enum$ReportReason.VIOLATES_RIGHTS;
    case ReportCategory.wrongMeal:
      return Enum$ReportReason.WRONG_MEAL;
    case ReportCategory.other:
      return Enum$ReportReason.OTHER;
  }
}
