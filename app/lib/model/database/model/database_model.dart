import 'package:app/model/database/model/db_canteen.dart';
import 'package:app/model/database/model/db_meal_nutrition_data.dart';
import 'package:app/model/database/model/nutrition_data_mixin.dart';
import 'package:app/view_model/repository/data_classes/filter/Frequency.dart';
import 'package:app/view_model/repository/data_classes/meal/Allergen.dart';
import 'package:app/view_model/repository/data_classes/meal/ImageData.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:app/view_model/repository/data_classes/meal/NutritionData.dart';
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
  Map<String, dynamic> toMap();
}

/// This class transforms the database models to the data classes.
class DatabaseTransformer {
  /// This method transforms a meal plan from the database to a data class.
  static Meal fromDBMeal(
      DBMeal dbMeal,
      Price price,
      List<Allergen>? allergens,
      List<Additive>? additives,
      DBMealNutritionData? nutritionData,
      List<DBSide> sides,
      Map<DBSide, List<Allergen>> sideAllergens,
      Map<DBSide, List<Additive>> sideAdditives,
      Map<DBSide, Price> sidePrices,
      Map<DBSide, NutritionDataMixin> sideNutritionData,
      List<DBImage> images,
      DateTime? lastServed,
      DateTime? nextServed,
      int? frequency,
      Frequency? relativeFrequency,
      bool isFavorite) {
    return Meal(
        id: dbMeal.mealID,
        name: dbMeal.name,
        foodType: dbMeal.foodType,
        price: price,
        nutritionData: nutritionData != null ? fromDBNutritionData(nutritionData) : null,
        additives: additives,
        allergens: allergens,
        sides: sides
            .map((side) =>
                fromDBSide(side, sideAllergens[side]!, sideAdditives[side]!, sideNutritionData[side]!, sidePrices[side]!))
            .toList(),
        individualRating: dbMeal.individualRating,
        numberOfRatings: dbMeal.numberOfRatings,
        averageRating: dbMeal.averageRating,
        lastServed: lastServed,
        nextServed: nextServed,
        numberOfOccurance: frequency,
        relativeFrequency: relativeFrequency,
        images: images.map((image) => fromDBImage(image)).toList(),
        isFavorite: isFavorite);
  }

  /// This method transforms a side from the database to a data class.
  static Side fromDBSide(
      DBSide side, List<Allergen>? allergens, List<Additive>? additives, NutritionDataMixin? nutritionData, Price price) {
    return Side(
        id: side.sideID,
        name: side.name,
        foodType: side.foodType,
        price: price,
        allergens: allergens ?? [],
        additives: additives ?? [],
        nutritionData: nutritionData != null ? fromDBNutritionData(nutritionData) : null);
  }

  /// This method transforms an image from the database to a data class.
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
  static Line fromDBLine(DBLine line, DBCanteen canteen) {
    return Line(
        id: line.lineID,
        name: line.name,
        canteen: DatabaseTransformer.fromDBCanteen(canteen),
        position: line.position);
  }

  /// This method transforms a canteen from the database to a data class.
  static Canteen fromDBCanteen(DBCanteen canteen) {
    return Canteen(id: canteen.canteenID, name: canteen.name);
  }

  /// This method transforms a meal plan from the database to a data class.
  static MealPlan fromDBMealPlan(
      DBMealPlan plan, DBLine line, DBCanteen canteen, List<Meal> meals) {
    return MealPlan(
        date: DateTime.tryParse(plan.date)!,
        line: DatabaseTransformer.fromDBLine(line, canteen),
        isClosed: plan.isClosed,
        meals: meals);
  }

  /// This method transforms a nutrition data object from the database to a data class.
  static NutritionData fromDBNutritionData(NutritionDataMixin nutritionData) {
    return NutritionData(
        energy: nutritionData.energy,
        protein: nutritionData.protein,
        carbohydrates: nutritionData.carbohydrates,
        sugar: nutritionData.sugar,
        fat: nutritionData.fat,
        saturatedFat: nutritionData.saturatedFat,
        salt: nutritionData.salt);
  }
}
