import 'package:app/view_model/logic/image/IImageAccess.dart';
import 'package:app/view_model/repository/data_classes/meal/ImageData.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:app/view_model/repository/data_classes/settings/ReportCategory.dart';
import 'package:app/view_model/repository/interface/IServerAccess.dart';
import 'package:flutter/material.dart';

class ImageAccess extends ChangeNotifier implements IImageAccess {
  final IServerAccess _api;

  ImageAccess(this._api);

  @override
  Future<void> deleteDownvote(ImageData image, BuildContext context) async {
    final result = await _api.deleteDownvote(image);

    if (!result) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("error")));
      return;
    }

    notifyListeners();
  }

  @override
  Future<void> deleteUpvote(ImageData image, BuildContext context) async {
    final result = await _api.deleteUpvote(image);

    if (!result) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("error")));
      return;
    }

    notifyListeners();
  }

  @override
  Future<void> downvoteImage(ImageData image, BuildContext context) async {
    final result = await _api.downvoteImage(image);

    if (!result) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("error")));
      return;
    }

    notifyListeners();
  }

  @override
  Future<void> linkImage(String url, Meal meal, BuildContext context) async {
    final result = await _api.linkImage(url, meal);

    if (!result) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("error")));
      return;
    }

    // todo aktualisieren?

    notifyListeners();
  }

  @override
  Future<void> reportImage(ImageData image, ReportCategory reportReason,
      BuildContext context) async {
    final result = await _api.reportImage(image, reportReason);

    if (!result) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("error")));
      return;
    }

    // todo wie wird es nicht mehr angezeigt

    notifyListeners();
  }

  @override
  Future<void> upvoteImage(ImageData image, BuildContext context) async {
    final result = await _api.upvoteImage(image);

    if (!result) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("error")));
      return;
    }

    notifyListeners();
  }
}
