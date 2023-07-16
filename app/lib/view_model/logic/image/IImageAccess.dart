
import 'package:app/view_model/repository/data_classes/meal/ImageData.dart';
import 'package:app/view_model/repository/data_classes/settings/ReportCategory.dart';
import 'package:flutter/cupertino.dart';

import '../../repository/data_classes/meal/Meal.dart';

/// This class is the interface for the access to the image data.
abstract class IImageAccess {
  /// This method links the committed url to the committed meal on the server.
  /// If the update is successful, a temporal success message is displayed.
  /// If the connection to the server fails, an temporal error message is displayed.
  /// @param url The url of the image
  /// @param meal The meal that is shown on the image of the url
  /// @param context The context of the app used for displaying temporal messages.
  /// @return The result of the update
  Future<void> linkImage(String url, Meal meal, BuildContext context);

  /// This method adds an upvote to the committed image on the server.
  /// If the update is successful, a temporal success message is displayed.
  /// If the connection to the server fails, an temporal error message is displayed.
  /// @param image The image that should be upvoted
  /// @param context The context of the app used for displaying temporal messages.
  /// @return The result of the update
  Future<void> upvoteImage(ImageData image, BuildContext context);

  /// This method adds a downvote to the committed image on the server.
  /// If the update is successful, a temporal success message is displayed.
  /// If the connection to the server fails, an temporal error message is displayed.
  /// @param image The image that should be downvoted
  /// @param context The context of the app used for displaying temporal messages.
  /// @return The result of the update
  Future<void> downvoteImage(ImageData image, BuildContext context);

  /// This method deletes an upvote from the committed image on the server.
  /// If the update is successful, a temporal success message is displayed.
  /// If the connection to the server fails, an temporal error message is displayed.
  /// @param image The image that should be unupvoted
  /// @param context The context of the app used for displaying temporal messages.
  /// @return The result of the update
  Future<void> deleteUpvote(ImageData image, BuildContext context);

  /// This method deletes a downvote from the committed image on the server.
  /// If the update is successful, a temporal success message is displayed.
  /// If the connection to the server fails, an temporal error message is displayed.
  /// @param image The image that should be undownvoted
  /// @param context The context of the app used for displaying temporal messages.
  /// @return The result of the update
  Future<void> deleteDownvote(ImageData image, BuildContext context);

  /// This method reports the committed image on the server.
  /// If the update is successful, a temporal success message is displayed.
  /// If the connection to the server fails, an temporal error message is displayed.
  /// @param image The image that should be reported
  /// @param reportReason The reason why the image is reported
  /// @param context The context of the app used for displaying temporal messages.
  /// @return The result of the update
  Future<void> reportImage(ImageData image, ReportCategory reportReason, BuildContext context);
}