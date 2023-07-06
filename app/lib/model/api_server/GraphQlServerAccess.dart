import 'package:app/model/api_server/requests/schema.graphql.dart';
import 'package:app/view_model/repository/data_classes/meal/ImageData.dart';

import 'package:app/view_model/repository/data_classes/meal/Meal.dart';

import 'package:app/view_model/repository/data_classes/mealplan/Canteen.dart';

import 'package:app/view_model/repository/data_classes/mealplan/MealPlan.dart';

import 'package:app/view_model/repository/data_classes/settings/ReportCategory.dart';

import 'package:app/view_model/repository/error_handling/Result.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

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
  @override
  Future<Result<Meal>> getMealFromId(String id) async {
    // TODO: implement getMealFromId
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Mealplan>>> updateAll() async {
    // TODO: implement updateAll
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Mealplan>>> updateCanteen(
      Canteen canteen, DateTime date) async {
    // TODO: implement updateCanteen
    throw UnimplementedError();
  }
}

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
