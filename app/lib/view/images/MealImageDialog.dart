import 'package:app/view/core/MensaAppBar.dart';
import 'package:app/view/core/buttons/MensaIconButton.dart';
import 'package:app/view/core/dialogs/MensaFullscreenDialog.dart';
import 'package:app/view/core/icons/image/ImageReportIcon.dart';
import 'package:app/view/core/icons/image/ThumbDownFilledIcon.dart';
import 'package:app/view/core/icons/image/ThumbDownOutlinedIcon.dart';
import 'package:app/view/core/icons/image/ThumbUpFilledIcon.dart';
import 'package:app/view/core/icons/image/ThumbUpOutlinedIcon.dart';
import 'package:app/view/core/icons/navigation/NavigationCloseIcon.dart';
import 'package:app/view/images/ImageReportDialog.dart';
import 'package:app/view_model/logic/image/IImageAccess.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MealImageDialog extends StatefulWidget {
  final Meal _meal;

  const MealImageDialog({super.key, required Meal meal}) : _meal = meal;

  @override
  State<MealImageDialog> createState() => _MealImageDialogState();
}

class _MealImageDialogState extends State<MealImageDialog> {
  int currentPage = 0;
  final PageController pageController = PageController();

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
    return MensaFullscreenDialog(
        appBar: MensaAppBar(
            appBarHeight: kToolbarHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
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
          itemCount: widget._meal.images?.length ?? 0,
          controller: pageController,
          itemBuilder: (context, index) {
            return Center(
                child: Image.network(
              widget._meal.images![index].url,
              fit: BoxFit.contain,
            ));
          },
        ),
        actions: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                MensaIconButton(
                    onPressed: () async {
                      if (widget._meal.images![currentPage].individualRating ==
                          1) {
                        await context
                            .read<IImageAccess>()
                            .deleteUpvote(widget._meal.images![currentPage]);
                      } else {
                        await context
                            .read<IImageAccess>()
                            .upvoteImage(widget._meal.images![currentPage]);
                      }
                    },
                    icon:
                        widget._meal.images![currentPage].individualRating == 1
                            ? const ThumbUpFilledIcon()
                            : const ThumbUpOutlinedIcon()),
                MensaIconButton(
                    onPressed: () async {
                      if (widget._meal.images![currentPage].individualRating ==
                          -1) {
                        await context
                            .read<IImageAccess>()
                            .deleteDownvote(widget._meal.images![currentPage]);
                      } else {
                        await context
                            .read<IImageAccess>()
                            .downvoteImage(widget._meal.images![currentPage]);
                      }
                    },
                    icon:
                        widget._meal.images![currentPage].individualRating == -1
                            ? const ThumbDownFilledIcon()
                            : const ThumbDownOutlinedIcon()),
                const Spacer(),
                MensaIconButton(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (context) => ImageReportDialog(
                            image: widget._meal.images![currentPage]),
                      );
                    },
                    icon: const ImageReportIcon()),
              ],
            )));
  }
}
