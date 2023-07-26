import 'package:app/view/core/buttons/MensaButton.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:flutter/material.dart';

/// Displays a Meal's image.
class MealPreviewImage extends StatelessWidget {
  final Meal _meal;
  final bool _enableUploadButton;
  final bool _enableFavoriteButton;
  final BorderRadius _borderRadius;
  final double? _height;
  final double? _width;
  final Function? _onUploadButtonPressed;

  /// Creates a MealPreviewImage.
  /// @param meal The Meal to display.
  /// @param enableUploadButton Whether to display the upload button if no image exists.
  /// @param enableFavoriteButton Whether to display the favorite button.
  /// @param borderRadius The border radius of the image.
  /// @param height The height of the image.
  /// @param width The width of the image.
  /// @param key The key to use for this widget.
  /// @return A MealPreviewImage.
  const MealPreviewImage(
      {super.key,
      required Meal meal,
      bool displayFavorite = false,
      bool enableUploadButton = false,
      bool enableFavoriteButton = false,
      BorderRadius? borderRadius,
      double? height,
      double? width,
      Function? onUploadButtonPressed})
      : _meal = meal,
        _enableUploadButton = enableUploadButton,
        _enableFavoriteButton = enableFavoriteButton,
        _borderRadius = borderRadius ?? const BorderRadius.all(Radius.zero),
        _height = height,
        _width = width,
        _onUploadButtonPressed = onUploadButtonPressed;

  @override
  Widget build(BuildContext context) {
    if (_meal.images == null || _meal.images!.isEmpty) {
      return Container(
          width: _width,
          height: _height,
          decoration: BoxDecoration(
            borderRadius: _borderRadius,
            color: Theme.of(context).colorScheme.surface,
            image: const DecorationImage(
              image: AssetImage('assets/images/meal_placeholder.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: ClipRRect(
              borderRadius: _borderRadius,
              child: Stack(children: [
                Center(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_not_supported_outlined,
                        size: 32,
                        color: Theme.of(context).colorScheme.onSurface),
                    if (_enableUploadButton) const SizedBox(height: 16),
                    if (_enableUploadButton)
                      MensaButton(
                          onPressed: _onUploadButtonPressed,
                          text: "Bild hochladen")
                  ],
                )),
                if (_enableFavoriteButton && _meal.isFavorite)
                  Align(
                      alignment: const Alignment(1.0, -1.0),
                      child: Padding(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                              _meal.isFavorite
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              size: 24,
                              color: Theme.of(context).colorScheme.secondary))),
              ])));
    } else {
      return Container(
          width: _width,
          height: _height,
          decoration: BoxDecoration(
            borderRadius: _borderRadius,
            image: DecorationImage(
              image: NetworkImage(_meal.images!.first.url),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(children: [
            if (_enableFavoriteButton && _meal.isFavorite)
              Align(
                  alignment: const Alignment(1.0, -1.0),
                  child: Padding(
                      padding: const EdgeInsets.all(4),
                      child: Icon(
                          _meal.isFavorite
                              ? Icons.favorite
                              : Icons.favorite_border,
                          size: 24,
                          color: Theme.of(context).colorScheme.secondary))),
          ]));
    }
  }
}
