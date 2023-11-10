import 'dart:math';

import 'package:app/view/core/MensaAppBar.dart';
import 'package:app/view/core/buttons/MensaButton.dart';
import 'package:app/view/core/buttons/MensaIconButton.dart';
import 'package:app/view/core/dialogs/MensaFullscreenDialog.dart';
import 'package:app/view/core/icons/image/ImageReportIcon.dart';
import 'package:app/view/core/icons/image/ThumbDownFilledIcon.dart';
import 'package:app/view/core/icons/image/ThumbDownOutlinedIcon.dart';
import 'package:app/view/core/icons/image/ThumbUpFilledIcon.dart';
import 'package:app/view/core/icons/image/ThumbUpOutlinedIcon.dart';
import 'package:app/view/core/icons/navigation/NavigationCloseIcon.dart';
import 'package:app/view/detail_view/UploadImageDialog.dart';
import 'package:app/view/images/ImageReportDialog.dart';
import 'package:app/view/images/MealImageView.dart';
import 'package:app/view_model/logic/image/IImageAccess.dart';
import 'package:app/view_model/logic/meal/IMealAccess.dart';
import 'package:app/view_model/repository/data_classes/meal/ImageData.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:app/view_model/repository/error_handling/NoMealException.dart';
import 'package:app/view_model/repository/error_handling/Result.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

/// This widget is used to display the images of a meal.
class MealImageDialog extends StatefulWidget {
  final Meal _meal;

  /// Creates a new meal image dialog.
  const MealImageDialog({super.key, required Meal meal}) : _meal = meal;

  @override
  State<MealImageDialog> createState() => _MealImageDialogState();
}

class _MealImageDialogState extends State<MealImageDialog> {
  int currentPage = 0;
  final PageController pageController = PageController();
  bool isClosing = false;

  bool _pagingEnabled = true;

  @override
  void initState() {
    super.initState();

    pageController.addListener(() {
      if (pageController.page?.round() != currentPage) {
        setState(() {
          currentPage = pageController.page!.round();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    IImageAccess imageAccess = Provider.of<IImageAccess>(context);
    IMealAccess mealAccess = Provider.of<IMealAccess>(context);
    currentPage = min(currentPage, widget._meal.images!.length - 1);
    ThemeData theme = Theme.of(context);
    return FutureBuilder(
        future: mealAccess.getMeal(widget._meal),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            switch (snapshot.requireData) {
              case Success<Meal, NoMealException> value:
                Meal meal = value.value;
                if (!isClosing &&
                    (meal.images == null || meal.images!.isEmpty)) {
                  isClosing = true;
                  SchedulerBinding.instance.addPostFrameCallback((_) {
                    Navigator.of(context).pop();
                  });
                }
                ImageData? currentImage =
                currentPage >= 0 ? meal.images![currentPage] : null;
                return MensaFullscreenDialog(
                    appBar: MensaAppBar(
                        appBarHeight: kToolbarHeight,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: Row(
                            children: [
                              MensaIconButton(
                                  semanticLabel: FlutterI18n.translate(
                                      context, "semantics.imageClose"),
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: const NavigationCloseIcon()),
                              const Spacer(),
                            ],
                          ),
                        )),
                    content: PageView.builder(
                      physics: _pagingEnabled ? const PageScrollPhysics() : const NeverScrollableScrollPhysics(),
                      itemCount: (meal.images?.length ?? 0),
                      controller: pageController,
                      itemBuilder: (context, index) {
                        if (index >= meal.images!.length) {
                          return Center(
                              child: MensaButton(
                                semanticLabel: FlutterI18n.translate(
                                    context, "semantics.imageUpload"),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) =>
                                        UploadImageDialog(meal: meal),
                                  );
                                },
                                text: FlutterI18n.translate(
                                    context, "image.newImageButton"),
                              ));
                        }
                        return MealImageView(imageData: meal.images![index], onScaleChanged: (scale) {
                          setState(() {
                            _pagingEnabled = scale <= 1.0;
                          });
                        });
                      },
                    ),
                    actions: (meal.images!.isEmpty ||
                        currentPage >= meal.images!.length ||
                        currentPage == -1)
                        ? const SizedBox(
                      height: 64,
                    )
                        : Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 8),
                        child: Row(
                          children: [
                            Text(meal.images![currentPage].positiveRating
                                .toString()),
                            MensaIconButton(
                                semanticLabel: FlutterI18n.translate(
                                    context,
                                    currentImage?.individualRating == 1
                                        ? "semantics.imageRatingsRemoveUpvote"
                                        : "semantics.imageRatingsAddUpvote"),
                                onPressed: () async {
                                  String? result;
                                  if (currentImage?.individualRating == 1) {
                                    result = await imageAccess
                                        .deleteUpvote(currentImage!);
                                  } else {
                                    result = await imageAccess
                                        .upvoteImage(currentImage!);
                                  }

                                  if (result != null && context.mounted) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                        backgroundColor: theme.colorScheme
                                            .error,
                                        content: Text(
                                            FlutterI18n.translate(
                                                context, result),
                                            style: TextStyle(
                                                color: theme.colorScheme
                                                    .onError))));
                                  }
                                },
                                icon: currentImage?.individualRating == 1
                                    ? const ThumbUpFilledIcon()
                                    : const ThumbUpOutlinedIcon()),
                            MensaIconButton(
                                semanticLabel: FlutterI18n.translate(
                                    context,
                                    currentImage?.individualRating == -1
                                        ? "semantics.imageRatingsRemoveDownvote"
                                        : "semantics.imageRatingsAddDownvote"),
                                onPressed: () async {
                                  String? result;
                                  if (currentImage!.individualRating == -1) {
                                    result =
                                    await imageAccess.deleteDownvote(
                                        currentImage);
                                  } else {
                                    result =
                                    await imageAccess.downvoteImage(
                                        currentImage);
                                  }

                                  if (result != null && context.mounted) {
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(SnackBar(
                                        backgroundColor: theme.colorScheme
                                            .error,
                                        content: Text(
                                            FlutterI18n.translate(
                                                context, result),
                                            style: TextStyle(
                                                color: theme.colorScheme
                                                    .onError))));
                                  }
                                },
                                icon: currentImage?.individualRating == -1
                                    ? const ThumbDownFilledIcon()
                                    : const ThumbDownOutlinedIcon()),
                            Text(meal.images![currentPage].negativeRating
                                .toString()),
                            const Spacer(),
                            MensaIconButton(
                                semanticLabel: FlutterI18n.translate(
                                    context, "semantics.imageReport"),
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) =>
                                        ImageReportDialog(
                                            meal: meal,
                                            image: meal.images![currentPage]),
                                  );
                                },
                                icon: const ImageReportIcon()),
                          ],
                        )));
              case Failure<Meal, NoMealException> _:
                Navigator.of(context).pop();
                return Center(
                    child: Text(FlutterI18n.translate(
                        context, "image.uploadException.noMeal")));
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}
