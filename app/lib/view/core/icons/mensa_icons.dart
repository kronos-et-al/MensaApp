import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

/// Registry of all SVG icon paths used in the app.
enum MensaIcons {
  // Navigation
  navBack('assets/icons/navigation/nav_back.svg'),
  navClose('assets/icons/navigation/nav_close.svg'),
  navAddImage('assets/icons/navigation/add_image.svg'),
  navMealPlan('assets/icons/navigation/nav_mealplan.svg'),
  navSettings('assets/icons/navigation/nav_settings.svg'),
  navFavorites('assets/icons/navigation/nav_favorites.svg'),
  arrowDown('assets/icons/navigation/arrow_down.svg'),
  arrowLeft('assets/icons/navigation/arrow_left.svg'),
  arrowRight('assets/icons/navigation/arrow_right.svg'),
  gridOutlined('assets/icons/navigation/grid_outlined.svg'),
  listOutlined('assets/icons/navigation/list_outlined.svg'),
  filterOutlined('assets/icons/navigation/filter_outlined.svg'),
  filterOutlinedDisabled(
    'assets/icons/navigation/filter_outlined_disabled.svg',
  ),

  // Filter
  filterRestore('assets/icons/filter/filter_restore.svg'),
  sortAscending('assets/icons/filter/sort_ascending.svg'),
  sortDescending('assets/icons/filter/sort_descending.svg'),

  // Favorites
  favoriteFilled('assets/icons/favorites/favorite_filled.svg'),
  favoriteOutlined('assets/icons/favorites/favorite_outlined.svg'),

  // Image
  camera('assets/icons/image/camera.svg'),
  imageReport('assets/icons/image/image_report.svg'),
  thumbUpFilled('assets/icons/image/thumb_up_filled.svg'),
  thumbDownFilled('assets/icons/image/thumb_down_filled.svg'),
  thumbUpOutlined('assets/icons/image/thumb_up_outlined.svg'),
  thumbDownOutlined('assets/icons/image/thumb_down_outlined.svg'),

  // Environment Info
  environmentCo2('assets/icons/environment_info/co2.svg'),
  environmentWater('assets/icons/environment_info/water.svg'),
  environmentRainforest('assets/icons/environment_info/rainforest.svg'),
  environmentAnimalWelfare('assets/icons/environment_info/animal_welfare.svg'),

  // Exceptions
  errorException('assets/icons/exceptions/error.svg'),
  filterException('assets/icons/exceptions/filter.svg'),
  noDataException('assets/icons/exceptions/no_data.svg'),
  canteenClosedException('assets/icons/exceptions/canteen_closed.svg'),

  // Misc
  logo('assets/icons/logo.svg'),
  mealLine('assets/icons/meal/meal_line.svg');

  final String path;
  const MensaIcons(this.path);
}

/// A generic widget to display any icon from the [MensaIcons] registry.
class MensaIcon extends StatelessWidget {
  final MensaIcons icon;
  final double? size;
  final Color? color;
  final bool useOriginalColor;

  /// Creates a new [MensaIcon].
  const MensaIcon(
    this.icon, {
    super.key,
    this.size = 24,
    this.color,
    this.useOriginalColor = false,
  });

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      icon.path,
      width: size,
      height: size,
      colorFilter: useOriginalColor
          ? null
          : ColorFilter.mode(
              color ?? Theme.of(context).colorScheme.onSurface,
              BlendMode.srcIn,
            ),
    );
  }
}
