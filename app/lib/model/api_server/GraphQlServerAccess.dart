import 'package:app/model/api_server/requests/deleteUpvote.graphql.dart';
import 'package:app/view_model/repository/data_classes/meal/ImageData.dart';

import 'package:app/view_model/repository/data_classes/meal/Meal.dart';

import 'package:app/view_model/repository/data_classes/mealplan/Canteen.dart';

import 'package:app/view_model/repository/data_classes/mealplan/MealPlan.dart';

import 'package:app/view_model/repository/data_classes/settings/ReportCategory.dart';

import 'package:app/view_model/repository/error_handling/Result.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

import '../../view_model/repository/interface/IServerAccess.dart';
import 'requests/deleteDownvote.graphql.dart';

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

  @override
  Future<bool> deleteDownvote(ImageData image) async {
    // TODO auth
    final result = await _client.mutate$RemoveDownvote(
        Options$Mutation$RemoveDownvote(
            variables: Variables$Mutation$RemoveDownvote(imageId: image.id)));
    final parsedData = result.parsedData;
    final success = parsedData?.removeDownvote ?? false;
    return success;
  }

  @override
  Future<bool> deleteUpvote(ImageData image) async {
    // TODO auth
    final result = await _client.mutate$RemoveUpvote(
        Options$Mutation$RemoveUpvote(
            variables: Variables$Mutation$RemoveUpvote(imageId: image.id)));
    final parsedData = result.parsedData;
    final success = parsedData?.removeUpvote ?? false;
    return success;
  }

  @override
  Future<bool> downvoteImage(ImageData image) {
    // TODO: implement downvoteImage
    throw UnimplementedError();
  }

  @override
  Future<Result<Meal>> getMealFromId(String id) {
    // TODO: implement getMealFromId
    throw UnimplementedError();
  }

  @override
  Future<bool> linkImage(String url, Meal meal) {
    // TODO: implement linkImage
    throw UnimplementedError();
  }

  @override
  Future<bool> reportImage(ImageData image, ReportCategory reportReason) {
    // TODO: implement reportImage
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Mealplan>>> updateAll() {
    // TODO: implement updateAll
    throw UnimplementedError();
  }

  @override
  Future<Result<List<Mealplan>>> updateCanteen(Canteen canteen, DateTime date) {
    // TODO: implement updateCanteen
    throw UnimplementedError();
  }

  @override
  Future<bool> updateMealRating(int rating, Meal meal) {
    // TODO: implement updateMealRating
    throw UnimplementedError();
  }

  @override
  Future<bool> upvoteImage(ImageData image) {
    // TODO: implement upvoteImage
    throw UnimplementedError();
  }
}
