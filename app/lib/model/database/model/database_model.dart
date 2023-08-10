import 'package:app/model/database/model/db_canteen.dart';
import 'package:app/view_model/repository/data_classes/filter/Frequency.dart';
import 'package:app/view_model/repository/data_classes/meal/Allergen.dart';
import 'package:app/view_model/repository/data_classes/meal/ImageData.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:app/view_model/repository/data_classes/meal/Price.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Canteen.dart';
import 'package:app/view_model/repository/data_classes/mealplan/MealPlan.dart';

import '../../../view_model/repository/data_classes/meal/Additive.dart';
import '../../../view_model/repository/data_classes/meal/Side.dart';
import '../../../view_model/repository/data_classes/mealplan/Line.dart';
import 'db_image.dart';
import 'db_line.dart';
import 'db_meal.dart';
import 'db_meal_plan.dart';
import 'db_side.dart';

/// This class represents a model in the database.
abstract class DatabaseModel {
  /// This method returns the map of the model.
  /// @returns The map of the model.
  Map<String, dynamic> toMap();
}

/// This class transforms the database models to the data classes.
class DatabaseTransformer {
  /// This method transforms a meal plan from the database to a data class.
  /// @param dbLines The lines of the meal plan from the database.
  /// @param dbMeals The meals of the meal plan from the database.
  /// @param dbSides The sides of the meal plan from the database.
  /// @param dbSideAllergens The allergens of the sides of the meal plan from the database.
  /// @param dbSideAdditives The additives of the sides of the meal plan from the database.
  /// @param dbImages The images of the meal plan from the database.
  /// @returns The meal plan as a data class.
  static Meal fromDBMeal(
      DBMeal dbMeal,
      Price price,
      List<Allergen>? allergens,
      List<Additive>? additives,
      List<DBSide> sides,
      Map<DBSide, List<Allergen>> sideAllergens,
      Map<DBSide, List<Additive>> sideAdditives,
      Map<DBSide, Price> sidePrices,
      List<DBImage> images,
      DateTime? lastServed,
      DateTime? nextServed,
      Frequency? relativeFrequency,
      bool isFavorite) {
    return Meal(
        id: dbMeal.mealID,
        name: dbMeal.name,
        foodType: dbMeal.foodType,
        price: price,
        additives: additives,
        allergens: allergens,
        sides: sides
            .map((side) =>
                fromDBSide(side, sideAllergens[side]!, sideAdditives[side]!, sidePrices[side]!))
            .toList(),
        individualRating: dbMeal.individualRating,
        numberOfRatings: dbMeal.numberOfRatings,
        averageRating: dbMeal.averageRating,
        lastServed: lastServed,
        nextServed: nextServed,
        relativeFrequency: relativeFrequency,
        images: images.map((image) => fromDBImage(image)).toList(),
        isFavorite: isFavorite);
  }

  /// This method transforms a side from the database to a data class.
  /// @param side The side from the database.
  /// @param allergens The allergens of the side.
  /// @param additives The additives of the side.
  /// @param price The price of the side.
  /// @returns The side as a data class.
  static Side fromDBSide(
      DBSide side, List<Allergen>? allergens, List<Additive>? additives, Price price) {
    return Side(
        id: side.sideID,
        name: side.name,
        foodType: side.foodType,
        price: price,
        allergens: allergens ?? [],
        additives: additives ?? []);
  }

  /// This method transforms an image from the database to a data class.
  /// @param image The image from the database.
  /// @returns The image as a data class.
  static ImageData fromDBImage(DBImage image) {
    return ImageData(
        id: image.imageID,
        url: image.url,
        imageRank: image.imageRank,
        individualRating: image.individualRating,
        positiveRating: image.positiveRating,
        negativeRating: image.positiveRating);
  }

  /// This method transforms a line from the database to a data class.
  /// @param line The line from the database.
  /// @param canteen The canteen of the line.
  /// @returns The line as a data class.
  static Line fromDBLine(DBLine line, DBCanteen canteen) {
    return Line(
        id: line.lineID,
        name: line.name,
        canteen: DatabaseTransformer.fromDBCanteen(canteen),
        position: line.position);
  }

  /// This method transforms a canteen from the database to a data class.
  /// @param canteen The canteen from the database.
  /// @returns The canteen as a data class.
  static Canteen fromDBCanteen(DBCanteen canteen) {
    return Canteen(id: canteen.canteenID, name: canteen.name);
  }

  /// This method transforms a meal plan from the database to a data class.
  /// @param plan The meal plan from the database.
  /// @param line The line of the meal plan.
  /// @param canteen The canteen of the meal plan.
  /// @param meals The meals of the meal plan.
  /// @returns The meal plan as a data class.
  static MealPlan fromDBMealPlan(
      DBMealPlan plan, DBLine line, DBCanteen canteen, List<Meal> meals) {
    return MealPlan(
        date: DateTime.tryParse(plan.date)!,
        line: DatabaseTransformer.fromDBLine(line, canteen),
        isClosed: plan.isClosed,
        meals: meals);
  }
}
