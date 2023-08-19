import 'package:app/view_model/logic/image/IImageAccess.dart';
import 'package:app/view_model/repository/data_classes/meal/ImageData.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:app/view_model/repository/data_classes/settings/ReportCategory.dart';
import 'package:app/view_model/repository/interface/IServerAccess.dart';
import 'package:app/view_model/repository/interface/IDatabaseAccess.dart';
import 'package:flutter/material.dart';

/// This class is the interface for the access to the image data. The access can be done via server.
class ImageAccess extends ChangeNotifier implements IImageAccess {
  final IServerAccess _api;
  final IDatabaseAccess _database;

  /// Stores the access to the server.
  /// @param api The access to the server.
  /// @return A new instance of the class.
  ImageAccess(this._api, this._database);

  @override
  Future<String?> deleteDownvote(ImageData image) async {
    final result = await _api.deleteDownvote(image);

    if (!result) {
      return "snackbar.voteError";
    }

    image.individualRating = 0;
    notifyListeners();
    return null;
  }

  @override
  Future<String?> deleteUpvote(ImageData image) async {
    final result = await _api.deleteUpvote(image);

    if (!result) {
      return "snackbar.voteError";
    }

    image.individualRating = 0;
    notifyListeners();
    return null;
  }

  @override
  Future<String?> downvoteImage(ImageData image) async {
    final result = await _api.downvoteImage(image);

    if (!result) {
      return "snackbar.voteError";
    }

    image.individualRating = -1;
    notifyListeners();
    return null;
  }

  @override
  Future<String> linkImage(String url, Meal meal) async {
    final result = await _api.linkImage(url, meal);

    if (!result) {
      return "snackbar.linkImageError";
    }

    notifyListeners();
    return "snackbar.linkImageSuccess";
  }

  @override
  Future<String> reportImage(
      Meal meal, ImageData image, ReportCategory reportReason) async {
    final result = await _api.reportImage(image, reportReason);

    if (!result) {
      return "snackbar.reportImageError";
    }

    _database.removeImage(image);
    meal.removeImage(image);
    notifyListeners();
    return "snackbar.reportImageSuccess";
  }

  @override
  Future<String?> upvoteImage(ImageData image) async {
    final result = await _api.upvoteImage(image);

    if (!result) {
      return "snackbar.voteError";
    }

    image.individualRating = 1;
    notifyListeners();
    return null;
  }
}
