import 'package:app/view_model/repository/data_classes/filter/Frequency.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

const _environmentThreshold =
    3; // currently, the api only provides integer values
const _photogenyThreshold = 5;

final _ratingColors = <Color>[
  Colors.red[800]!,
  Colors.deepOrange[800]!,
  Colors.orange[800]!,
  Colors.lime[800]!,
  Colors.green[800]!,
];

WidgetSpan assembleTag(String text, Color color, {TextStyle? style}) {
  return assembleTagRaw(Text(text, style: style), color);
}

WidgetSpan assembleTagRaw(Widget child, Color color) {
  return WidgetSpan(
    child: Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Badge(label: child, backgroundColor: color),
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

  if (meal.averageRating >= 4.5 && meal.numberOfRatings >= 100) {
    tags.add(
      assembleTag(
        FlutterI18n.translate(context, "tag.legendary"),
        Colors.deepPurple,
      ),
    );
  }

  if ((meal.images?.length ?? 0) >= _photogenyThreshold) {
    tags.add(
      assembleTag(
        FlutterI18n.translate(context, "tag.photogenic"),
        Colors.teal,
      ),
    );
  }
  if (meal.individualRating != 0) {
    tags.add(
      assembleTagRaw(
        RichText(
          text: TextSpan(
            text: "${meal.individualRating}",
            style: style,
            children: [
              WidgetSpan(
                child: Padding(
                  padding: const EdgeInsets.all(1),
                  child: Icon(
                    Icons.star,
                    color: Theme.of(context).colorScheme.onPrimary,
                    size: 14,
                  ),
                ),
              ),
            ],
          ),
        ),
        // FlutterI18n.translate(context, "tag.rated"),
        // Colors.deepPurple,
        _ratingColors[meal.individualRating - 1],
        // Colors.teal,
      ),
    );
  }

  return tags;
}

Color? getBorderColor(BuildContext context, Meal meal) {
  if (meal.isFavorite) {
    return Theme.of(context).colorScheme.primary;
  }
  if (meal.individualRating == 1) {
    return _ratingColors[0];
  }
  if (meal.relativeFrequency == Frequency.newMeal) {
    return Theme.of(context).colorScheme.secondary;
  }

  return null;
}
