import 'package:app/view/core/meal_view_format/MealListEntry.dart';
import 'package:app/view_model/logic/favorite/IFavoriteMealAccess.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Favorites extends StatefulWidget {
  const Favorites({super.key});

  @override
  State<StatefulWidget> createState() => _FavoritesState();
}

class _FavoritesState extends State<Favorites>{
  @override
  Widget build(BuildContext context) {
    return Consumer<IFavoriteMealAccess>(builder: (context, favoriteAccess, child) => Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: FutureBuilder(future: Future.wait([favoriteAccess.getFavoriteMeals()]),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.hasError) {
          return const Column();
        }

        final mealPlan = snapshot.requireData as List<Meal>;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: mealPlan.length,
              itemBuilder: (context, index) {
                return MealListEntry(meal: mealPlan[index]);
              },
            ),
          ],
        );
      },
      ),
    ));
  }

}