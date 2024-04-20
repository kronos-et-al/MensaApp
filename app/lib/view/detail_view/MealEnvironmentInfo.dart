import 'package:app/view/core/icons/environment_info/EnvironmentAnimalWelfareIcon.dart';
import 'package:app/view/core/icons/environment_info/EnvironmentCo2Icon.dart';
import 'package:app/view/core/icons/environment_info/EnvironmentRainforestIcon.dart';
import 'package:app/view/core/icons/environment_info/EnvironmentWaterIcon.dart';
import 'package:app/view/core/input_components/MensaRatingInput.dart';
import 'package:app/view_model/repository/data_classes/meal/EnvironmentInfo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:intl/intl.dart';

/// This class is used to display the nutrients of a meal.
class MealEnvironmentInfo extends StatelessWidget {
  final EnvironmentInfo _environmentInfo;

  /// Creates a MealNutrientsList widget.
  const MealEnvironmentInfo(
      {super.key, required EnvironmentInfo environmentInfo})
      : _environmentInfo = environmentInfo;

  @override
  Widget build(BuildContext context) {
    return Padding(padding: const EdgeInsets.only(right: 8, top: 4, bottom: 4), child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MealEnvironmentInfoItem(
            type: _MealEnvironmentInfoType.co2,
            value: _environmentInfo.co2Value,
            rating: _environmentInfo.co2Rating,
            maxRating: _environmentInfo.maxRating),
        _MealEnvironmentInfoItem(
            type: _MealEnvironmentInfoType.water,
            value: _environmentInfo.waterValue,
            rating: _environmentInfo.waterRating,
            maxRating: _environmentInfo.maxRating),
        _MealEnvironmentInfoItem(
            type: _MealEnvironmentInfoType.animalWelfare,
            value: _environmentInfo.animalWelfareRating,
            rating: _environmentInfo.animalWelfareRating,
            maxRating: _environmentInfo.maxRating),
        _MealEnvironmentInfoItem(
            type: _MealEnvironmentInfoType.rainforest,
            value: _environmentInfo.rainforestRating,
            rating: _environmentInfo.rainforestRating,
            maxRating: _environmentInfo.maxRating),
      ],
    ));
  }
}

enum _MealEnvironmentInfoType { co2, water, animalWelfare, rainforest }

class _MealEnvironmentInfoItem extends StatelessWidget {
  final NumberFormat _decimalFormat = NumberFormat.compact(locale: 'de_DE');

  final _MealEnvironmentInfoType _type;
  final int _value;
  final int _rating;
  final int _maxRating;

  _MealEnvironmentInfoItem(
      {required _MealEnvironmentInfoType type,
      required int value,
      required int rating,
      required int maxRating})
      : _type = type,
        _value = value,
        _rating = rating,
        _maxRating = maxRating;

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Padding(
            padding: const EdgeInsets.all(2),
            child: Ink(
              child: Padding(
                padding: const EdgeInsets.all(4),
                child: Column(
                  children: [
                    switch (_type) {
                      _MealEnvironmentInfoType.co2 =>
                        const EnvironmentCo2Icon(width: 48, height: 48),
                      _MealEnvironmentInfoType.water =>
                        const EnvironmentWaterIcon(width: 48, height: 48),
                      _MealEnvironmentInfoType.animalWelfare =>
                        const EnvironmentAnimalWelfareIcon(
                            width: 48, height: 48),
                      _MealEnvironmentInfoType.rainforest =>
                      const EnvironmentRainforestIcon(width: 48, height: 48),
                    },
                    Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      MensaRatingInput(
                        onChanged: (_) => {},
                        value: _rating.toDouble(),
                        max: _maxRating,
                        size: 16,)
                    ],),
                    Text(
                        switch (_type) {
                          _MealEnvironmentInfoType.co2 => FlutterI18n.translate(
                                context, "environmentInfo.co2Value",
                                translationParams: {
                                  "value": _decimalFormat.format(_value)
                                }),
                          _MealEnvironmentInfoType.water =>
                            FlutterI18n.translate(
                                context, "environmentInfo.waterValue",
                                translationParams: {
                                  "value": _decimalFormat.format(_value / 1000)
                                }),
                          _MealEnvironmentInfoType.animalWelfare =>
                            FlutterI18n.translate(
                                context, "environmentInfo.animalWelfareValue",
                                translationParams: {
                                  "value": switch (_value) {
                                    1 => FlutterI18n.translate(context,
                                        "environmentInfo.animalWelfareValue1"),
                                    2 => FlutterI18n.translate(context,
                                        "environmentInfo.animalWelfareValue2"),
                                    3 => FlutterI18n.translate(context,
                                        "environmentInfo.animalWelfareValue3"),
                                    _ => ""
                                  }
                                }),
                          _MealEnvironmentInfoType.rainforest =>
                            FlutterI18n.translate(
                                context, "environmentInfo.rainforestValue",
                                translationParams: {
                                  "value": switch (_value) {
                                    1 => FlutterI18n.translate(context,
                                        "environmentInfo.rainforestValue1"),
                                    2 => FlutterI18n.translate(context,
                                        "environmentInfo.rainforestValue2"),
                                    3 => FlutterI18n.translate(context,
                                        "environmentInfo.rainforestValue3"),
                                    _ => ""
                                  }
                                }),
                        },
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                            fontWeight: FontWeight.w300, fontSize: 12)),
                  ],
                ),
              ),
            )));
  }
}
