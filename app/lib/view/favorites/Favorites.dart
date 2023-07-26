import 'package:app/view/core/MensaAppBar.dart';
import 'package:app/view/core/meal_view_format/MealListEntry.dart';
import 'package:app/view_model/logic/favorite/IFavoriteMealAccess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

class Favorites extends StatelessWidget {
  const Favorites({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<IFavoriteMealAccess>(
        builder: (context, favoriteAccess, child) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
              child: FutureBuilder(
                future: Future.wait([favoriteAccess.getFavoriteMeals()]),
                builder: (context, snapshot) {
                  if (!snapshot.hasData || snapshot.hasError) {
                    return Scaffold(
                        appBar: MensaAppBar(
                          appBarHeight: kToolbarHeight * 1.25,
                          child: Text(FlutterI18n.translate(
                              context, "common.favorites")),
                        ),
                        body: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [],
                        ));
                  }

                  final mealPlan = snapshot.requireData[0];
                  MensaAppBar appBar = MensaAppBar(
                    appBarHeight: kToolbarHeight * 1.25,
                    child: Text(
                      FlutterI18n.translate(context, "common.favorites"),
                      style: const TextStyle(
                          fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  );

                  if (mealPlan.isEmpty) {
                    return Scaffold(
                        appBar: appBar,
                        body: Center(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                FlutterI18n.translate(
                                    context, "common.noFavorites"),
                                style: DefaultTextStyle.of(context)
                                    .style
                                    .apply(fontSizeFactor: 1.5),
                                textAlign: TextAlign.center,
                              )
                            ],
                          ),
                        ));
                  }

                  return Scaffold(
                      appBar: appBar,
                      body: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListView.builder(
                            physics: const NeverScrollableScrollPhysics(),
                            shrinkWrap: true,
                            itemCount: mealPlan.length,
                            itemBuilder: (context, index) {
                              return MealListEntry(meal: mealPlan[index]);
                            },
                          )
                        ],
                      ));
                },
              ),
            ));
  }
}
