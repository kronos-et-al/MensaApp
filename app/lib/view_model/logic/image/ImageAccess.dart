import 'package:app/view_model/logic/image/IImageAccess.dart';
import 'package:app/view_model/repository/data_classes/meal/ImageData.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:app/view_model/repository/data_classes/settings/ReportCategory.dart';
import 'package:app/view_model/repository/interface/IServerAccess.dart';
import 'package:flutter/material.dart';

// todo string for error and success
class ImageAccess extends ChangeNotifier implements IImageAccess {
  final IServerAccess _api;

  ImageAccess(this._api);

  @override
  Future<String?> deleteDownvote(ImageData image) async {
    final result = await _api.deleteDownvote(image);

    if (!result) {
      return "snackbar.voteError";
    }

    image.deleteRating();
    notifyListeners();
    return null;
  }

  @override
  Future<String?> deleteUpvote(ImageData image) async {
    final result = await _api.deleteUpvote(image);

    if (!result) {
      return "snackbar.voteError";
    }

    image.deleteRating();
    notifyListeners();
    return null;
  }

  @override
  Future<String?> downvoteImage(ImageData image) async {
    final result = await _api.downvoteImage(image);

    if (!result) {
      return "snackbar.voteError";
    }

    image.downvote();
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
  Future<String> reportImage(ImageData image, ReportCategory reportReason) async {
    final result = await _api.reportImage(image, reportReason);

    if (!result) {
      return "snackbar.reportImageError";
    }

    notifyListeners();
    return "snackbar.reportImageSuccess";
  }

  @override
  Future<String?> upvoteImage(ImageData image) async {
    final result = await _api.upvoteImage(image);

    if (!result) {
      return "snackbar.voteError";
    }

    image.upvote();
    notifyListeners();
    return null;
  }
}