
import 'package:app/view_model/repository/data_classes/filter/Frequency.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

List<WidgetSpan> getTags(BuildContext context, Meal meal, {TextStyle? style}) {
  switch (meal.relativeFrequency) {
    case null:
      break;
    case Frequency.newMeal:
      return [ WidgetSpan(
          child:
          Badge(
              label: Text(FlutterI18n.translate(context, "tag.new"), style: style,),
              backgroundColor: Theme
                  .of(context)
                  .colorScheme
                  .secondary)),

      ];
    case Frequency.rare:
      return [ WidgetSpan(
          child:
          Badge(
              label: Text(FlutterI18n.translate(context, "tag.rare"), style: style,),
              backgroundColor: Theme
                  .of(context)
                  .colorScheme
                  .tertiary)),

      ];
    case Frequency.regular:
      return [ WidgetSpan(
          child:
          Badge(
              label: Text(FlutterI18n.translate(context, "tag.regular"), style: style,),
              backgroundColor: Colors.brown)),

      ];
    case Frequency.normal:
      break;
  }
  return [];
}