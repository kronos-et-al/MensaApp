import 'dart:math';

import 'package:app/view/core/buttons/MensaButton.dart';
import 'package:app/view/core/icons/LogoIcon.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

/// Displays a Meal's image.
class MealPreviewImage extends StatelessWidget {
  final Meal _meal;
  final bool _enableUploadButton;
  final bool _enableFavoriteButton;
  final bool _enableImageCount;
  final BorderRadius _borderRadius;
  final double? _height;
  final double? _width;
  final Function? _onUploadButtonPressed;
  final void Function()? _onImagePressed;
  final Alignment _favoriteButtonAlignment;

  /// Creates a MealPreviewImage.
  const MealPreviewImage({
    super.key,
    required Meal meal,
    bool displayFavorite = false,
    bool enableUploadButton = false,
    bool enableFavoriteButton = false,
    bool enableImageCount = false,
    Alignment favoriteButtonAlignment = Alignment.topRight,
    BorderRadius? borderRadius,
    double? height,
    double? width,
    Function? onUploadButtonPressed,
    void Function()? onImagePressed,
  }) : _meal = meal,
       _enableUploadButton = enableUploadButton,
       _enableFavoriteButton = enableFavoriteButton,
       _enableImageCount = enableImageCount,
       _borderRadius = borderRadius ?? const BorderRadius.all(Radius.zero),
       _height = height,
       _width = width,
       _onUploadButtonPressed = onUploadButtonPressed,
       _onImagePressed = onImagePressed,
       _favoriteButtonAlignment = favoriteButtonAlignment;

  @override
  Widget build(BuildContext context) {
    ThemeData theme = Theme.of(context);
    if (_meal.images == null ||
        _meal.images!.isEmpty ||
        _meal.images!.first.url.isEmpty) {
      return Container(
        width: _width,
        height: _height,
        decoration: BoxDecoration(
          borderRadius: _borderRadius,
          color: theme.colorScheme.primary,
        ),
        child: ClipRRect(
          borderRadius: _borderRadius,
          child: Stack(
            children: [
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    LogoIcon(size: min(96, _height! - 16)),
                    if (_enableUploadButton) const SizedBox(height: 16),
                    if (_enableUploadButton)
                      MensaButton(
                        semanticLabel: FlutterI18n.translate(
                          context,
                          "semantics.imageUpload",
                        ),
                        onPressed: _onUploadButtonPressed,
                        text: "Bild hochladen",
                      ),
                  ],
                ),
              ),
              if (_enableFavoriteButton && _meal.isFavorite)
                Align(
                  alignment: _favoriteButtonAlignment,
                  child: Padding(
                    padding: const EdgeInsets.all(4),
                    child: Stack(
                      children: [
                        Icon(
                          Icons.favorite,
                          size: 28,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                        Icon(
                          Icons.favorite_border,
                          size: 28,
                          color: Theme.of(context).colorScheme.surface,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
    } else {
      return Material(
        borderRadius: _borderRadius,
        child: InkWell(
          borderRadius: _borderRadius,
          onTap: _onImagePressed,
          child: CachedNetworkImage(
            imageUrl: _meal.images!.first.url,
            placeholder:
                (context, url) => Container(
                  width: _width,
                  height: _height,
                  decoration: BoxDecoration(
                    borderRadius: _borderRadius,
                    color: theme.colorScheme.primary,
                  ),
                  child: ClipRRect(
                    borderRadius: _borderRadius,
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [LogoIcon(size: min(96, _height! - 16))],
                          ),
                        ),
                        if (_enableFavoriteButton && _meal.isFavorite)
                          Align(
                            alignment: _favoriteButtonAlignment,
                            child: Padding(
                              padding: const EdgeInsets.all(4),
                              child: Stack(
                                children: [
                                  Icon(
                                    Icons.favorite,
                                    size: 28,
                                    color:
                                        Theme.of(context).colorScheme.onSurface,
                                  ),
                                  Icon(
                                    Icons.favorite_border,
                                    size: 28,
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.surfaceDim,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
            imageBuilder:
                (context, imageProvider) => Container(
                  width: _width,
                  height: _height,
                  decoration: BoxDecoration(
                    borderRadius: _borderRadius,
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                  child: Stack(
                    children: [
                      if (_enableFavoriteButton && _meal.isFavorite)
                        Align(
                          alignment: _favoriteButtonAlignment,
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: Stack(
                              children: [
                                Icon(
                                  Icons.favorite,
                                  size: 28,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                Icon(
                                  Icons.favorite_border,
                                  size: 28,
                                  color:
                                      Theme.of(context).colorScheme.surfaceDim,
                                ),
                              ],
                            ),
                          ),
                        ),
                      if (_enableImageCount && (_meal.images?.length ?? 0) > 1)
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Badge(
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.surfaceDim.withAlpha(150),
                              padding: EdgeInsets.all(4),
                              label: Text(
                                "+${_meal.images!.length - 1}",
                                style: TextStyle(
                                  fontSize: 14,
                                  color:
                                      Theme.of(context).colorScheme.onSurface,
                                ),
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
          ),
        ),
      );
    }
  }
}
