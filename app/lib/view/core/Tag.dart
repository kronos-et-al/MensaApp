import 'package:app/view_model/repository/data_classes/filter/Frequency.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

const _environmentThreshold =
    3; // currently, the api only provides integer values

WidgetSpan assembleTag(String text, Color color, {TextStyle? style}) {
  return WidgetSpan(
    child: Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Badge(label: Text(text, style: style), backgroundColor: color),
    ),
  );
}

List<WidgetSpan> getTags(BuildContext context, Meal meal, {TextStyle? style}) {
  var tags = <WidgetSpan>[];
  switch (meal.relativeFrequency) {
    case null:
      break;
    case Frequency.newMeal:
      tags.add(
        assembleTag(
          FlutterI18n.translate(context, "tag.new"),
          Theme.of(context).colorScheme.secondary,
          style: style,
        ),
      );
      break;
    case Frequency.rare:
      tags.add(
        assembleTag(
          FlutterI18n.translate(context, "tag.rare"),
          Theme.of(context).colorScheme.tertiary,
          style: style,
        ),
      );
      break;
    case Frequency.regular:
      tags.add(
        assembleTag(
          FlutterI18n.translate(context, "tag.regular"),
          Colors.brown,
          style: style,
        ),
      );
      break;
    case Frequency.normal:
      break;
  }

  if ((meal.environmentInfo?.averageRating ?? 0) >= _environmentThreshold) {
    tags.add(
      assembleTag(
        FlutterI18n.translate(context, "tag.envScore"),
        Theme.of(context).colorScheme.primary,
      ),
    );
  }

  return tags;
}

Color? getBorderColor(BuildContext context, Meal meal) {
  if (meal.isFavorite) {
    return Theme.of(context).colorScheme.primary;
  }
  if (meal.relativeFrequency == Frequency.newMeal) {
    return Theme.of(context).colorScheme.secondary;
  }

  return null;
}
