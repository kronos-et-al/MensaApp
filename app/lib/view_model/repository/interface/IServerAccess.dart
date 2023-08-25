import 'package:app/view_model/repository/data_classes/mealplan/Canteen.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Line.dart';
import 'package:app/view_model/repository/error_handling/ImageUploadException.dart';
import 'package:app/view_model/repository/error_handling/MealPlanException.dart';

import '../data_classes/meal/ImageData.dart';
import '../data_classes/meal/Meal.dart';
import '../data_classes/mealplan/MealPlan.dart';
import '../data_classes/settings/ReportCategory.dart';
import '../error_handling/Result.dart';

/// This class is the interface for the access to the server.
abstract class IServerAccess {
  /// This method requests all mealplans of all canteens for the next seven days from the server.
  ///
  /// The [Result] of the request or an [MealPlanException] is returned.
  Future<Result<List<MealPlan>, MealPlanException>> updateAll();

  /// The [Result] of the request in form of the [MealPlan] of the committed date and canteen or an [MealPlanException] is returned.
  Future<Result<List<MealPlan>, MealPlanException>> updateCanteen(
      Canteen canteen, DateTime date);

  /// Returns the [Meal] with the committed id or an [Exception].
  Future<Result<Meal, Exception>> getMeal(Meal meal, Line line, DateTime date);

  /// This method updates the rating of the committed meal on the server.
  /// Returns 'true' if the rating was updated successfully, otherwise 'false'.
  Future<bool> updateMealRating(int rating, Meal meal);

  /// This method link the committed url to the committed image.
  /// Returns 'true' if the linking was uploaded successfully, otherwise 'false'.
  Future<Result<bool, ImageUploadException>> linkImage(String url, Meal meal);

  /// This method adds an upvote to an image.
  /// Returns 'true' if the rating was updated successfully, otherwise 'false'.
  Future<bool> upvoteImage(ImageData image);

  /// This method adds an downvote to an image.
  /// Returns 'true' if the rating was updated successfully, otherwise 'false'.
  Future<bool> downvoteImage(ImageData image);

  /// This method removes an upvote of an image.
  /// Returns 'true' if the rating was updated successfully, otherwise 'false'.
  Future<bool> deleteUpvote(ImageData image);

  /// This method removes an downvote of an image.
  /// Returns 'true' if the rating was updated successfully, otherwise 'false'.
  Future<bool> deleteDownvote(ImageData image);

  /// This method reports an image and sends the committed report reason to the server.
  /// Returns 'true' if the image was reported successfully, otherwise 'false'.
  Future<bool> reportImage(ImageData image, ReportCategory reportReason);

  /// This method requests the default canteen from the server.
  /// Returns the default [Canteen] or null if no connection could be established.
  Future<Canteen?> getDefaultCanteen();

  /// This method requests all canteens from the server.
  /// Returns all canteens or null if no connection could be established.
  Future<List<Canteen>?> getCanteens();
}
