import 'package:app/model/database/SQLiteDatabaseAccess.dart';
import 'package:app/view_model/repository/data_classes/meal/Allergen.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:app/view_model/repository/data_classes/meal/Price.dart';

import '../../../view_model/repository/data_classes/meal/Additive.dart';
import '../../../view_model/repository/data_classes/meal/Image.dart';
import '../../../view_model/repository/data_classes/meal/Side.dart';
import 'db_image.dart';
import 'db_meal.dart';
import 'db_side.dart';
import 'db_side_additive.dart';
import 'db_side_allergen.dart';
import 'db_meal_additive.dart';
import 'db_meal_allergen.dart';

abstract class DatabaseModel {
  Map<String, dynamic> toMap();
}

class DatabaseTransformer {
  static Meal fromDBMeal(
      DBMeal dbMeal,
      List<Allergen> allergens,
      List<Additive> additives,
      List<DBSide> sides,
      Map<DBSide, List<Allergen>> sideAllergens,
      Map<DBSide, List<Additive>> sideAdditives,
      List<DBImage> images,
      bool isFavorite
      ) {
    return Meal(
        id: dbMeal.mealID,
        name: dbMeal.name,
        foodType: dbMeal.foodType,
        price: Price(
            student: dbMeal.priceStudent,
            employee: dbMeal.priceEmployee,
            pupil: dbMeal.pricePupil,
            guest: dbMeal.priceGuest
        ),
        additives: additives,
        allergens: allergens,
        sides: sides.map((side) => fromDBSide(side, sideAllergens[side]!, sideAdditives[side]!)).toList(),
        individualRating: dbMeal.individualRating,
        numberOfRatings: dbMeal.numberOfRatings,
        averageRating: dbMeal.averageRating,
        lastServed: DateTime.tryParse(dbMeal.lastServed),
        nextServed: DateTime.tryParse(dbMeal.nextServed),
        relativeFrequency: dbMeal.relativeFrequency,
        images: images.map((image) => fromDBImage(image)).toList(),
        isFavorite: isFavorite
    );
  }

  static Side fromDBSide(DBSide side, List<Allergen> allergens, List<Additive> additives) {
    return Side(
        id: side.sideID,
        name: side.name,
        foodType: side.foodType,
        price: Price(
            student: side.priceStudent,
            employee: side.priceEmployee,
            pupil: side.pricePupil,
            guest: side.priceGuest
        ),
        allergens: allergens,
        additives: additives
    );
  }

  static Image fromDBImage(DBImage image) {
    return Image(
        id: image.imageID,
        url: image.url,
        imageRank: image.imageRank,
        individualRating: image.individualRating,
        positiveRating: image.positiveRating,
        negativeRating: image.positiveRating
    );
  }
}