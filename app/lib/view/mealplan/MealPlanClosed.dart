import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';

class MealPlanClosed extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return Center(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // todo add icon
          Text(FlutterI18n.translate(
              context, "mealplanException.closedCanteenException")),
        ]));
  }

}