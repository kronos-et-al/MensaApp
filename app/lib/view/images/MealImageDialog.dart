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
import 'package:app/view_model/logic/image/IImageAccess.dart';
import 'package:app/view_model/logic/meal/IMealAccess.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:app/view_model/repository/error_handling/NoMealException.dart';
import 'package:app/view_model/repository/error_handling/Result.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
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
                return MensaFullscreenDialog(
                    appBar: MensaAppBar(
                        appBarHeight: kToolbarHeight,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: Row(
                            children: [
                              MensaIconButton(
                                  onPressed: () => Navigator.of(context).pop(),
                                  icon: const NavigationCloseIcon()),
                              const Spacer(),
                            ],
                          ),
                        )),
                    content: PageView.builder(
                      itemCount: (meal.images?.length ?? 0),
                      controller: pageController,
                      itemBuilder: (context, index) {
                        if (index >= meal.images!.length) {
                          return Center(
                              child: MensaButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) =>
                                    UploadImageDialog(meal: meal),
                              );
                            },
                            text: 'Bild hinzufügen',
                          ));
                        }
                        return Center(
                            child: Image.network(
                          meal.images![index].url,
                          fit: BoxFit.contain,
                        ));
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
                                    onPressed: () async {
                                      if (meal.images![currentPage]
                                              .individualRating ==
                                          1) {
                                        await imageAccess.deleteUpvote(
                                            meal.images![currentPage]);
                                      } else {
                                        await imageAccess.upvoteImage(
                                            meal.images![currentPage]);
                                      }
                                    },
                                    icon: meal.images![currentPage]
                                                .individualRating ==
                                            1
                                        ? const ThumbUpFilledIcon()
                                        : const ThumbUpOutlinedIcon()),
                                MensaIconButton(
                                    onPressed: () async {
                                      if (meal.images![currentPage]
                                              .individualRating ==
                                          -1) {
                                        await imageAccess.deleteDownvote(
                                            meal.images![currentPage]);
                                      } else {
                                        await imageAccess.downvoteImage(
                                            meal.images![currentPage]);
                                      }
                                    },
                                    icon: meal.images![currentPage]
                                                .individualRating ==
                                            -1
                                        ? const ThumbDownFilledIcon()
                                        : const ThumbDownOutlinedIcon()),
                                Text(meal.images![currentPage].negativeRating
                                    .toString()),
                                const Spacer(),
                                MensaIconButton(
                                    onPressed: () {
                                      showDialog(
                                        context: context,
                                        builder: (context) => ImageReportDialog(
                                            meal: meal,
                                            image: meal.images![currentPage]),
                                      );
                                    },
                                    icon: const ImageReportIcon()),
                              ],
                            )));
              case Failure<Meal, NoMealException> value:
                Navigator.of(context).pop();
                return const Center(child: Text("Fehler beim Laden"));
            }
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        });
  }
}
