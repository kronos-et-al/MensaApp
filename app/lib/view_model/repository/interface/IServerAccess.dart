import 'package:app/view_model/repository/data_classes/mealplan/Canteen.dart';

import '../data_classes/meal/ImageData.dart';
import '../data_classes/meal/Meal.dart';
import '../data_classes/mealplan/MealPlan.dart';
import '../data_classes/settings/ReportCategory.dart';
import '../error_handling/Result.dart';

/// This class is the interface for the access to the server.
abstract class IServerAccess {
  /// This method requests all mealplans of all canteens for the next seven days from the server.
  /// @return The result of the update or an error
  Future<Result<List<Mealplan>>> updateAll();

  /// This method requests the mealplan for the committed date of the committed canteen from the server.
  /// @param date The date of the mealplan
  /// @param canteen The canteen of the mealplan
  /// @return The mealplan of the committed date of the committed canteen or an error
  Future<Result<List<Mealplan>>> updateCanteen(Canteen canteen, DateTime date);

  /// This method returns the meal with the committed id.
  /// @param id The id of the meal
  /// @return The meal with the committed id or an error
  Future<Result<Meal>> getMealFromId(String id);

  /// This method updates the rating of the committed meal on the server.
  /// @param rating The new rating of the meal
  /// @param meal The meal that should be updated
  /// @return The result of the update. It returns false, if the rating could not be changed.
  Future<bool> updateMealRating(int rating, Meal meal);

  /// This method link the committed url to the committed image.
  /// @param url The url of the image
  /// @param meal The meal displayed on the image
  /// @return The result of the update. It returns false, if the image could not be connected to the meal. For example because of an invalid link.
  Future<bool> linkImage(String url, Meal meal);

  /// This method adds an upvote to an image.
  /// @param image The image that should be upvoted.
  /// @return The result of the update. It returns false, if the upvote could not be added.
  Future<bool> upvoteImage(ImageData image);

  /// This method adds an downvote to an image.
  /// @param image The image that should be downvoted.
  /// @return The result of the update. It returns false, if the downvote could not be added.
  Future<bool> downvoteImage(ImageData image);

  /// This method removes an upvote to an image.
  /// @param image The image whose upvote should be deleted.
  /// @return The result of the update. It returns false, if the upvote could not be removed.
  Future<bool> deleteUpvote(ImageData image);

  /// This method removes an downvote to an image.
  /// @param image The image whose downvote should be deleted.
  /// @return The result of the update. It returns false, if the downvote could not be removed.
  Future<bool> deleteDownvote(ImageData image);

  /// This method reports an image and sends the committed report reason to the server.
  /// @param image The image that should be reported.
  /// @param reportReason The reason why the image should be reported.
  /// @return The result of the update. It returns false, if the report failed.
  Future<bool> reportImage(ImageData image, ReportCategory reportReason);
}