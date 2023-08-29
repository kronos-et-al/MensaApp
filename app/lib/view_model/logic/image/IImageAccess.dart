import 'package:app/view_model/repository/data_classes/meal/ImageData.dart';
import 'package:app/view_model/repository/data_classes/settings/ReportCategory.dart';
import 'package:app/view_model/repository/error_handling/ImageUploadException.dart';
import 'package:app/view_model/repository/error_handling/Result.dart';
import 'package:flutter/material.dart';

import '../../repository/data_classes/meal/Meal.dart';

/// This class is the interface for the access to the image data.
abstract class IImageAccess with ChangeNotifier {
  /// This method links the committed url to the committed meal on the server.
  /// Returns a string that should be displayed in a temporal message.
  Future<Result<bool, ImageUploadException>> linkImage(String url, Meal meal);

  /// This method adds an upvote to the committed image on the server.
  /// It returns a non empty string that should be displayed in a temporal message,
  /// or a null, saying that nothing should be printed.
  Future<String?> upvoteImage(ImageData image);

  /// This method adds a downvote to the committed image on the server.
  /// It returns a non empty string that should be displayed in a temporal message,
  /// or a null, saying that nothing should be printed.
  Future<String?> downvoteImage(ImageData image);

  /// This method deletes an upvote from the committed image on the server.
  /// It returns a non empty string that should be displayed in a temporal message,
  /// or a null, saying that nothing should be printed.
  Future<String?> deleteUpvote(ImageData image);

  /// This method deletes a downvote from the committed image on the server.
  /// It returns a non empty string that should be displayed in a temporal message,
  /// or a null, saying that nothing should be printed.
  Future<String?> deleteDownvote(ImageData image);

  /// This method reports the committed image on the server.
  /// It returns a string that should be displayed in a temporal message.
  /// @param image The image that should be reported
  /// @param reportReason The reason why the image is reported
  /// @param context The context of the app used for displaying temporal messages.
  /// @return The string that should be displayed in a temporal message
  Future<bool> reportImage(Meal meal, ImageData image, ReportCategory reportReason);
}
