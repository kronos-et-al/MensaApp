import 'package:app/view/core/MensaAppBar.dart';
import 'package:app/view/core/meal_view_format/MealListEntry.dart';
import 'package:app/view_model/logic/favorite/IFavoriteMealAccess.dart';
import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:provider/provider.dart';

/// This widget is used to display the favorites.
class Favorites extends StatelessWidget {
  /// Creates a new Favorites widget.
  const Favorites({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<IFavoriteMealAccess>(
      builder: (context, favoriteAccess, child) => FutureBuilder(
        future: Future.wait([favoriteAccess.getFavoriteMeals()]),
        builder: (context, snapshot) {
          if (!snapshot.hasData || snapshot.hasError) {
            return Scaffold(
                appBar: MensaAppBar(
                    appBarHeight: kToolbarHeight,
                    child: Semantics(header: true, child: Center(
                      child: Text(
                          FlutterI18n.translate(context, "common.favorites"),
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ))),
                body: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [],
                ));
          }

          final mealPlan = snapshot.requireData[0];
          MensaAppBar appBar = MensaAppBar(
            appBarHeight: kToolbarHeight,
            child: Center(
                child: Text(
              FlutterI18n.translate(context, "common.favorites"),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            )),
          );

          if (mealPlan.isEmpty) {
            return Scaffold(
                appBar: appBar,
                body: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        FlutterI18n.translate(context, "common.noFavorites"),
                        textAlign: TextAlign.center,
                      )
                    ],
                  ),
                ));
          }

          return Scaffold(
              appBar: appBar,
              body: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: mealPlan.length,
                    itemBuilder: (context, index) {
                      return MealListEntry(
                          meal: mealPlan[index].meal,
                          line: mealPlan[index].servedLine,
                          date: mealPlan[index].servedDate);
                    },
                  )));
        },
      ),
    );
  }
}
