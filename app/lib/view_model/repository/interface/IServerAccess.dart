import 'package:app/view_model/repository/data_classes/mealplan/Canteen.dart';

import '../data_classes/meal/Image.dart';
import '../data_classes/meal/Meal.dart';
import '../data_classes/mealplan/Mealplan.dart';
import '../data_classes/settings/ReportCategory.dart';
import '../error_handling/Result.dart';

abstract class IServerAccess {
  /// This method requests all mealplans of all canteens for the next seven days from the server.
  Future<Result<List<Mealplan>>> updateAll();

  /// This method requests the mealplan for the committed date of the committed canteen from the server.
  Future<Result<List<Mealplan>>> updateCanteen(Canteen canteen, DateTime date);

  /// This method returns the meal with the committed id.
  Future<Result<Meal>> getMealFromId(String id);

  /// This method updates the rating of the committed meal on the server.
  /// It returns false, if the rating could not be changed.
  Future<bool> updateMealRating(int rating, Meal meal);

  /// This method link the committed url to the committed image.
  /// It returns false, if the image could not be connected to the meal. For example because of an invalid link.
  Future<bool> linkImage(String url, Meal meal);

  /// This method adds an upvote to an image.
  /// It returns false, if the upvote could not be added.
  Future<bool> upvoteImage(Image image);

  /// This method adds an downvote to an image.
  /// It returns false, if the downvote could not be added.
  Future<bool> downvoteImage(Image image);

  /// This method removes an upvote to an image.
  /// It returns false, if the upvote could not be removed.
  Future<bool> deleteUpvote(Image image);

  /// This method removes an downvote to an image.
  /// It returns false, if the downvote could not be removed.
  Future<bool> deleteDownvote(Image image);

  /// This method reports an image and sends the committed report reason to the server.
  /// It returns false, if the report failed.
  Future<bool> reportImage(Image image, ReportCategory reportReason);
}