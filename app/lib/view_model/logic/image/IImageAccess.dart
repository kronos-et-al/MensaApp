import 'package:app/view_model/repository/data_classes/meal/ImageData.dart';
import 'package:app/view_model/repository/data_classes/settings/ReportCategory.dart';
import 'package:flutter/material.dart';

import '../../repository/data_classes/meal/Meal.dart';

/// This class is the interface for the access to the image data.
abstract class IImageAccess with ChangeNotifier {
  /// This method links the committed url to the committed meal on the server.
  /// It returns a string that should be displayed in a temporal message.
  /// @param url The url of the image
  /// @param meal The meal that is shown on the image of the url
  /// @param context The context of the app used for displaying temporal messages.
  /// @return The string that should be displayed in a temporal message
  Future<String> linkImage(String url, Meal meal);

  /// This method adds an upvote to the committed image on the server.
  /// It returns a non empty string that should be displayed in a temporal message,
  /// or a null, saying that nothing should be printed.
  /// @param image The image that should be upvoted
  /// @param context The context of the app used for displaying temporal messages.
  /// @return The string that should be displayed in a temporal message or null
  Future<String?> upvoteImage(ImageData image);

  /// This method adds a downvote to the committed image on the server.
  /// It returns a non empty string that should be displayed in a temporal message,
  /// or a null, saying that nothing should be printed.
  /// @param image The image that should be downvoted
  /// @param context The context of the app used for displaying temporal messages.
  /// @return The string that should be displayed in a temporal message or null
  Future<String?> downvoteImage(ImageData image);

  /// This method deletes an upvote from the committed image on the server.
  /// It returns a non empty string that should be displayed in a temporal message,
  /// or a null, saying that nothing should be printed.
  /// @param image The image that should be unupvoted
  /// @param context The context of the app used for displaying temporal messages.
  /// @return The string that should be displayed in a temporal message or null
  Future<String?> deleteUpvote(ImageData image);

  /// This method deletes a downvote from the committed image on the server.
  /// It returns a non empty string that should be displayed in a temporal message,
  /// or a null, saying that nothing should be printed.
  /// @param image The image that should be undownvoted
  /// @param context The context of the app used for displaying temporal messages.
  /// @return The string that should be displayed in a temporal message or null
  Future<String?> deleteDownvote(ImageData image);

  /// This method reports the committed image on the server.
  /// It returns a string that should be displayed in a temporal message.
  /// @param image The image that should be reported
  /// @param reportReason The reason why the image is reported
  /// @param context The context of the app used for displaying temporal messages.
  /// @return The string that should be displayed in a temporal message
  Future<String> reportImage(Meal meal, ImageData image, ReportCategory reportReason);
}
