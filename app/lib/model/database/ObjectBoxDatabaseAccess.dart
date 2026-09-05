import 'package:app/model/database/entities/box_canteen.dart';
import 'package:app/model/database/entities/box_favorite.dart';
import 'package:app/model/database/entities/box_image.dart';
import 'package:app/model/database/entities/box_line.dart';
import 'package:app/model/database/entities/box_meal.dart';
import 'package:app/model/database/entities/box_meal_plan.dart';
import 'package:app/model/database/entities/box_price.dart';
import 'package:app/model/database/entities/box_nutrition_data.dart';
import 'package:app/model/database/entities/box_environment_info.dart';
import 'package:app/view_model/repository/data_classes/meal/FavoriteMeal.dart';
import 'package:app/view_model/repository/data_classes/meal/ImageData.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:app/view_model/repository/data_classes/meal/Side.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Canteen.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Line.dart';
import 'package:app/view_model/repository/data_classes/mealplan/MealPlan.dart';
import 'package:app/view_model/repository/error_handling/MealPlanException.dart';
import 'package:app/view_model/repository/error_handling/NoMealException.dart';
import 'package:app/view_model/repository/error_handling/Result.dart';
import 'package:app/view_model/repository/interface/IDatabaseAccess.dart';
import 'package:app/model/database/objectbox.g.dart';

import 'package:app/view_model/repository/data_classes/meal/Additive.dart';
import 'package:app/view_model/repository/data_classes/meal/Allergen.dart';
import 'package:app/view_model/repository/data_classes/meal/EnvironmentInfo.dart';
import 'package:app/view_model/repository/data_classes/meal/FoodType.dart';
import 'package:app/view_model/repository/data_classes/meal/NutritionData.dart';
import 'package:app/view_model/repository/data_classes/meal/Price.dart';
import 'package:app/view_model/repository/data_classes/filter/Frequency.dart';

/// This class implements the [IDatabaseAccess] interface using ObjectBox.
class ObjectBoxDatabaseAccess implements IDatabaseAccess {
  final Store _store;

  /// Creates a new [ObjectBoxDatabaseAccess] with the committed [Store].
  ObjectBoxDatabaseAccess(this._store);

  @override
  Future<void> updateAll(List<MealPlan> mealplans) async {
    _store.runInTransaction(TxMode.write, () {
      for (final plan in mealplans) {
        final boxCanteen = _putCanteen(plan.line.canteen);
        final boxLine = _putLine(plan.line, boxCanteen);
        _putMealPlan(plan, boxLine);
      }
    });
  }

  @override
  Future<void> updateMeal(Meal meal) async {
    _store.runInTransaction(TxMode.write, () {
      _putMeal(meal);
    });
  }

  @override
  Future<void> updateImage(ImageData image) async {
    _store.runInTransaction(TxMode.write, () {
      _putImage(image);
    });
  }

  @override
  Future<void> updateCanteen(Canteen canteen) async {
    _store.runInTransaction(TxMode.write, () {
      _putCanteen(canteen);
    });
  }

  @override
  Future<Result<List<MealPlan>, MealPlanException>> getMealPlan(
    DateTime date,
    Canteen canteen,
  ) async {
    final boxCanteen = _getBoxCanteen(canteen.id);
    if (boxCanteen == null) {
      return Failure(NoDataException("Canteen not found in database."));
    }

    final dateMs = DateTime(
      date.year,
      date.month,
      date.day,
    ).millisecondsSinceEpoch;

    // Find lines for this canteen
    final linesQuery = _store
        .box<BoxLine>()
        .query(BoxLine_.canteen.equals(boxCanteen.id))
        .build();
    final lines = linesQuery.find();
    linesQuery.close();

    final resultPlans = <MealPlan>[];
    for (final line in lines) {
      final planQuery = _store
          .box<BoxMealPlan>()
          .query(
            BoxMealPlan_.date
                .equals(dateMs)
                .and(BoxMealPlan_.line.equals(line.id)),
          )
          .build();
      final boxPlan = planQuery.findFirst();
      planQuery.close();

      if (boxPlan != null) {
        resultPlans.add(_mapToDomainMealPlan(boxPlan));
      }
    }

    if (resultPlans.isEmpty) {
      return Failure(NoDataException("No meal plan found for this date."));
    }
    return Success(resultPlans);
  }

  @override
  Future<Result<Meal, NoMealException>> getMeal(Meal meal) async {
    final boxMeal = _getBoxMeal(meal.id);
    if (boxMeal != null) {
      return Success(_mapToDomainMeal(boxMeal));
    } else {
      return Failure(NoMealException("No meal found with id ${meal.id}"));
    }
  }

  @override
  Future<Result<Meal, Exception>> getMealFavorite(String id) async {
    final boxMealId = _getInternalBoxMealId(id);
    if (boxMealId == 0) return Failure(Exception("Meal not found."));

    final query = _store
        .box<BoxFavorite>()
        .query(BoxFavorite_.meal.equals(boxMealId))
        .build();
    final favorite = query.findFirst();
    query.close();

    if (favorite != null && favorite.meal.target != null) {
      return Success(_mapToDomainMeal(favorite.meal.target!));
    } else {
      return Failure(Exception("Meal is not a favorite."));
    }
  }

  @override
  Future<void> addFavorite(
    Meal meal,
    DateTime servedDate,
    Line servedLine,
  ) async {
    final boxFav = _store.box<BoxFavorite>();
    final boxMealId = _getInternalBoxMealId(meal.id);

    if (boxMealId != 0) {
      final query = boxFav.query(BoxFavorite_.meal.equals(boxMealId)).build();
      if (query.findFirst() != null) {
        query.close();
        return;
      }
      query.close();
    }

    _store.runInTransaction(TxMode.write, () {
      final boxMeal = _putMeal(meal);
      final boxCanteen = _putCanteen(servedLine.canteen);
      final boxLine = _putLine(servedLine, boxCanteen);

      final favorite = BoxFavorite(servedDate: servedDate);
      favorite.meal.target = boxMeal;
      favorite.line.target = boxLine;
      boxFav.put(favorite);
    });
  }

  @override
  Future<void> deleteFavorite(Meal meal) async {
    final boxMealId = _getInternalBoxMealId(meal.id);
    if (boxMealId == 0) return;

    final boxFav = _store.box<BoxFavorite>();
    final query = boxFav.query(BoxFavorite_.meal.equals(boxMealId)).build();
    final favorite = query.findFirst();
    query.close();

    if (favorite != null) {
      boxFav.remove(favorite.id);
    }
  }

  @override
  Future<List<FavoriteMeal>> getFavorites() async {
    final favorites = _store.box<BoxFavorite>().getAll();
    final result = <FavoriteMeal>[];
    for (final fav in favorites) {
      if (fav.meal.target != null && fav.line.target != null) {
        result.add(
          FavoriteMeal(
            _mapToDomainMeal(fav.meal.target!),
            fav.servedDate,
            _mapToDomainLine(fav.line.target!),
          ),
        );
      }
    }
    return result;
  }

  @override
  Future<Canteen?> getCanteenById(String id) async {
    final boxCanteen = _getBoxCanteen(id);
    return boxCanteen != null ? _mapToDomainCanteen(boxCanteen) : null;
  }

  @override
  Future<List<Canteen>?> getCanteens() async {
    final boxCanteens = _store.box<BoxCanteen>().getAll();
    if (boxCanteens.isEmpty) return null;
    return boxCanteens.map(_mapToDomainCanteen).toList();
  }

  @override
  Future<void> removeImage(ImageData image) async {
    final box = _store.box<BoxImage>();
    final query = box.query(BoxImage_.imageId.equals(image.id)).build();
    final boxImage = query.findFirst();
    query.close();
    if (boxImage != null) {
      box.remove(boxImage.id);
    }
  }

  @override
  Future<void> cleanUp() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final planBox = _store.box<BoxMealPlan>();
    final oldPlansQuery = planBox
        .query(BoxMealPlan_.date.lessThan(today.millisecondsSinceEpoch))
        .build();
    final oldPlans = oldPlansQuery.find();
    oldPlansQuery.close();

    _store.runInTransaction(TxMode.write, () {
      for (final plan in oldPlans) {
        for (final meal in plan.meals) {
          if (_isFavorite(meal.mealId)) continue;

          final qb = planBox.query(BoxMealPlan_.id.notEquals(plan.id));
          qb.linkMany(BoxMealPlan_.meals, BoxMeal_.id.equals(meal.id));
          final count = qb.build().count();

          if (count == 0) {
            _store.box<BoxImage>().removeMany(
              meal.images.map((i) => i.id).toList(),
            );

            final price = meal.price.target;
            if (price != null) {
              _store.box<BoxPrice>().remove(price.id);
            }
            final nutrition = meal.nutritionData.target;
            if (nutrition != null) {
              _store.box<BoxNutritionData>().remove(nutrition.id);
            }
            final environment = meal.environmentInfo.target;
            if (environment != null) {
              _store.box<BoxEnvironmentInfo>().remove(environment.id);
            }

            _store.box<BoxMeal>().remove(meal.id);
          }
        }
        planBox.remove(plan.id);
      }
    });
  }

  // --- Private Helpers ---

  BoxCanteen _putCanteen(Canteen canteen) {
    final box = _store.box<BoxCanteen>();
    final query = box.query(BoxCanteen_.canteenId.equals(canteen.id)).build();
    var boxCanteen = query.findFirst();
    query.close();

    if (boxCanteen == null) {
      boxCanteen = BoxCanteen(canteenId: canteen.id, name: canteen.name);
    } else {
      boxCanteen.name = canteen.name;
    }
    box.put(boxCanteen);
    return boxCanteen;
  }

  BoxLine _putLine(Line line, BoxCanteen boxCanteen) {
    final box = _store.box<BoxLine>();
    final query = box.query(BoxLine_.lineId.equals(line.id)).build();
    var boxLine = query.findFirst();
    query.close();

    if (boxLine == null) {
      boxLine = BoxLine(
        lineId: line.id,
        name: line.name,
        position: line.position,
      );
    } else {
      boxLine.name = line.name;
      boxLine.position = line.position;
    }
    boxLine.canteen.target = boxCanteen;
    box.put(boxLine);
    return boxLine;
  }

  void _putMealPlan(MealPlan plan, BoxLine boxLine) {
    final box = _store.box<BoxMealPlan>();
    final normalizedDate = DateTime(
      plan.date.year,
      plan.date.month,
      plan.date.day,
    );
    final dateMs = normalizedDate.millisecondsSinceEpoch;

    final query = box
        .query(
          BoxMealPlan_.date
              .equals(dateMs)
              .and(BoxMealPlan_.line.equals(boxLine.id)),
        )
        .build();
    var boxPlan = query.findFirst();
    query.close();

    if (boxPlan == null) {
      boxPlan = BoxMealPlan(date: normalizedDate, isClosed: plan.isClosed);
      boxPlan.line.target = boxLine;
    } else {
      boxPlan.isClosed = plan.isClosed;
      boxPlan.meals.clear();
    }

    for (final meal in plan.meals) {
      boxPlan.meals.add(_putMeal(meal));
    }
    box.put(boxPlan);
  }

  BoxMeal _putMeal(Meal meal, {bool isSide = false}) {
    final box = _store.box<BoxMeal>();
    final query = box.query(BoxMeal_.mealId.equals(meal.id)).build();
    var boxMeal = query.findFirst();
    query.close();

    if (boxMeal == null) {
      boxMeal = BoxMeal(
        mealId: meal.id,
        name: meal.name,
        foodType: meal.foodType.name,
        individualRating: meal.individualRating,
        numberOfRatings: meal.numberOfRatings,
        averageRating: meal.averageRating,
        lastServed: meal.lastServed,
        nextServed: meal.nextServed,
        relativeFrequency: meal.relativeFrequency?.name,
        allergens: meal.allergens?.map((e) => e.name).toList() ?? [],
        additives: meal.additives?.map((e) => e.name).toList() ?? [],
        isSide: isSide,
      );
    } else {
      boxMeal.name = meal.name;
      boxMeal.foodType = meal.foodType.name;
      boxMeal.individualRating = meal.individualRating;
      boxMeal.numberOfRatings = meal.numberOfRatings;
      boxMeal.averageRating = meal.averageRating;
      boxMeal.lastServed = meal.lastServed;
      boxMeal.nextServed = meal.nextServed;
      boxMeal.relativeFrequency = meal.relativeFrequency?.name;
      boxMeal.allergens = meal.allergens?.map((e) => e.name).toList() ?? [];
      boxMeal.additives = meal.additives?.map((e) => e.name).toList() ?? [];
      boxMeal.isSide = isSide;

      boxMeal.images.clear();
      boxMeal.sides.clear();
    }

    // Price
    var boxPrice = boxMeal.price.target;
    if (boxPrice == null) {
      boxPrice = BoxPrice(
        student: meal.price.student,
        employee: meal.price.employee,
        pupil: meal.price.pupil,
        guest: meal.price.guest,
      );
    } else {
      boxPrice.student = meal.price.student;
      boxPrice.employee = meal.price.employee;
      boxPrice.pupil = meal.price.pupil;
      boxPrice.guest = meal.price.guest;
    }
    _store.box<BoxPrice>().put(boxPrice);
    boxMeal.price.target = boxPrice;

    // Nutrition Data
    if (meal.nutritionData != null) {
      var boxNutrition = boxMeal.nutritionData.target;
      if (boxNutrition == null) {
        boxNutrition = BoxNutritionData(
          energy: meal.nutritionData!.energy,
          protein: meal.nutritionData!.protein,
          carbohydrates: meal.nutritionData!.carbohydrates,
          sugar: meal.nutritionData!.sugar,
          fat: meal.nutritionData!.fat,
          saturatedFat: meal.nutritionData!.saturatedFat,
          salt: meal.nutritionData!.salt,
        );
      } else {
        boxNutrition.energy = meal.nutritionData!.energy;
        boxNutrition.protein = meal.nutritionData!.protein;
        boxNutrition.carbohydrates = meal.nutritionData!.carbohydrates;
        boxNutrition.sugar = meal.nutritionData!.sugar;
        boxNutrition.fat = meal.nutritionData!.fat;
        boxNutrition.saturatedFat = meal.nutritionData!.saturatedFat;
        boxNutrition.salt = meal.nutritionData!.salt;
      }
      _store.box<BoxNutritionData>().put(boxNutrition);
      boxMeal.nutritionData.target = boxNutrition;
    } else if (boxMeal.nutritionData.target != null) {
      _store.box<BoxNutritionData>().remove(boxMeal.nutritionData.target!.id);
      boxMeal.nutritionData.target = null;
    }

    // Environment Info
    if (meal.environmentInfo != null) {
      var boxEnv = boxMeal.environmentInfo.target;
      if (boxEnv == null) {
        boxEnv = BoxEnvironmentInfo(
          averageRating: meal.environmentInfo!.averageRating,
          co2Rating: meal.environmentInfo!.co2Rating,
          co2Value: meal.environmentInfo!.co2Value,
          waterRating: meal.environmentInfo!.waterRating,
          waterValue: meal.environmentInfo!.waterValue,
          animalWelfareRating: meal.environmentInfo!.animalWelfareRating,
          rainforestRating: meal.environmentInfo!.rainforestRating,
          maxRating: meal.environmentInfo!.maxRating,
        );
      } else {
        boxEnv.averageRating = meal.environmentInfo!.averageRating;
        boxEnv.co2Rating = meal.environmentInfo!.co2Rating;
        boxEnv.co2Value = meal.environmentInfo!.co2Value;
        boxEnv.waterRating = meal.environmentInfo!.waterRating;
        boxEnv.waterValue = meal.environmentInfo!.waterValue;
        boxEnv.animalWelfareRating = meal.environmentInfo!.animalWelfareRating;
        boxEnv.rainforestRating = meal.environmentInfo!.rainforestRating;
        boxEnv.maxRating = meal.environmentInfo!.maxRating;
      }
      _store.box<BoxEnvironmentInfo>().put(boxEnv);
      boxMeal.environmentInfo.target = boxEnv;
    } else if (boxMeal.environmentInfo.target != null) {
      _store.box<BoxEnvironmentInfo>().remove(
        boxMeal.environmentInfo.target!.id,
      );
      boxMeal.environmentInfo.target = null;
    }

    if (meal.images != null) {
      for (final img in meal.images!) {
        boxMeal.images.add(_putImage(img));
      }
    }

    if (meal.sides != null) {
      for (final side in meal.sides!) {
        boxMeal.sides.add(_putSide(side));
      }
    }

    box.put(boxMeal);
    return boxMeal;
  }

  BoxMeal _putSide(Side side) {
    final box = _store.box<BoxMeal>();
    final query = box.query(BoxMeal_.mealId.equals(side.id)).build();
    var boxMeal = query.findFirst();
    query.close();

    if (boxMeal == null) {
      boxMeal = BoxMeal(
        mealId: side.id,
        name: side.name,
        foodType: side.foodType.name,
        individualRating: 0,
        numberOfRatings: 0,
        averageRating: 0.0,
        allergens: side.allergens.map((e) => e.name).toList(),
        additives: side.additives.map((e) => e.name).toList(),
        isSide: true,
      );
    } else {
      boxMeal.name = side.name;
      boxMeal.foodType = side.foodType.name;
      boxMeal.isSide = true;
      boxMeal.allergens = side.allergens.map((e) => e.name).toList();
      boxMeal.additives = side.additives.map((e) => e.name).toList();

      boxMeal.images.clear();
      boxMeal.sides.clear();
    }

    // Price
    var boxPrice = boxMeal.price.target;
    if (boxPrice == null) {
      boxPrice = BoxPrice(
        student: side.price.student,
        employee: side.price.employee,
        pupil: side.price.pupil,
        guest: side.price.guest,
      );
    } else {
      boxPrice.student = side.price.student;
      boxPrice.employee = side.price.employee;
      boxPrice.pupil = side.price.pupil;
      boxPrice.guest = side.price.guest;
    }
    _store.box<BoxPrice>().put(boxPrice);
    boxMeal.price.target = boxPrice;

    // Nutrition Data
    if (side.nutritionData != null) {
      var boxNutrition = boxMeal.nutritionData.target;
      if (boxNutrition == null) {
        boxNutrition = BoxNutritionData(
          energy: side.nutritionData!.energy,
          protein: side.nutritionData!.protein,
          carbohydrates: side.nutritionData!.carbohydrates,
          sugar: side.nutritionData!.sugar,
          fat: side.nutritionData!.fat,
          saturatedFat: side.nutritionData!.saturatedFat,
          salt: side.nutritionData!.salt,
        );
      } else {
        boxNutrition.energy = side.nutritionData!.energy;
        boxNutrition.protein = side.nutritionData!.protein;
        boxNutrition.carbohydrates = side.nutritionData!.carbohydrates;
        boxNutrition.sugar = side.nutritionData!.sugar;
        boxNutrition.fat = side.nutritionData!.fat;
        boxNutrition.saturatedFat = side.nutritionData!.saturatedFat;
        boxNutrition.salt = side.nutritionData!.salt;
      }
      _store.box<BoxNutritionData>().put(boxNutrition);
      boxMeal.nutritionData.target = boxNutrition;
    } else if (boxMeal.nutritionData.target != null) {
      _store.box<BoxNutritionData>().remove(boxMeal.nutritionData.target!.id);
      boxMeal.nutritionData.target = null;
    }

    // Environment Info
    if (side.environmentInfo != null) {
      var boxEnv = boxMeal.environmentInfo.target;
      if (boxEnv == null) {
        boxEnv = BoxEnvironmentInfo(
          averageRating: side.environmentInfo!.averageRating,
          co2Rating: side.environmentInfo!.co2Rating,
          co2Value: side.environmentInfo!.co2Value,
          waterRating: side.environmentInfo!.waterRating,
          waterValue: side.environmentInfo!.waterValue,
          animalWelfareRating: side.environmentInfo!.animalWelfareRating,
          rainforestRating: side.environmentInfo!.rainforestRating,
          maxRating: side.environmentInfo!.maxRating,
        );
      } else {
        boxEnv.averageRating = side.environmentInfo!.averageRating;
        boxEnv.co2Rating = side.environmentInfo!.co2Rating;
        boxEnv.co2Value = side.environmentInfo!.co2Value;
        boxEnv.waterRating = side.environmentInfo!.waterRating;
        boxEnv.waterValue = side.environmentInfo!.waterValue;
        boxEnv.animalWelfareRating = side.environmentInfo!.animalWelfareRating;
        boxEnv.rainforestRating = side.environmentInfo!.rainforestRating;
        boxEnv.maxRating = side.environmentInfo!.maxRating;
      }
      _store.box<BoxEnvironmentInfo>().put(boxEnv);
      boxMeal.environmentInfo.target = boxEnv;
    } else if (boxMeal.environmentInfo.target != null) {
      _store.box<BoxEnvironmentInfo>().remove(
        boxMeal.environmentInfo.target!.id,
      );
      boxMeal.environmentInfo.target = null;
    }

    box.put(boxMeal);
    return boxMeal;
  }

  BoxImage _putImage(ImageData image) {
    final box = _store.box<BoxImage>();
    final query = box.query(BoxImage_.imageId.equals(image.id)).build();
    var boxImage = query.findFirst();
    query.close();

    if (boxImage == null) {
      boxImage = BoxImage(
        imageId: image.id,
        url: image.url,
        imageRank: image.imageRank,
        positiveRating: image.positiveRating,
        negativeRating: image.negativeRating,
        individualRating: image.individualRating,
      );
    } else {
      boxImage.url = image.url;
      boxImage.imageRank = image.imageRank;
      boxImage.positiveRating = image.positiveRating;
      boxImage.negativeRating = image.negativeRating;
      boxImage.individualRating = image.individualRating;
    }
    box.put(boxImage);
    return boxImage;
  }

  BoxMeal? _getBoxMeal(String mealId) {
    final query = _store
        .box<BoxMeal>()
        .query(BoxMeal_.mealId.equals(mealId))
        .build();
    final boxMeal = query.findFirst();
    query.close();
    return boxMeal;
  }

  int _getInternalBoxMealId(String mealId) {
    return _getBoxMeal(mealId)?.id ?? 0;
  }

  BoxCanteen? _getBoxCanteen(String canteenId) {
    final query = _store
        .box<BoxCanteen>()
        .query(BoxCanteen_.canteenId.equals(canteenId))
        .build();
    final boxCanteen = query.findFirst();
    query.close();
    return boxCanteen;
  }

  bool _isFavorite(String mealId) {
    final queryBuilder = _store.box<BoxFavorite>().query();
    queryBuilder.link(BoxFavorite_.meal, BoxMeal_.mealId.equals(mealId));
    final query = queryBuilder.build();
    final isFav = query.findFirst() != null;
    query.close();
    return isFav;
  }

  // --- Domain Mappers ---

  MealPlan _mapToDomainMealPlan(BoxMealPlan boxPlan) {
    return MealPlan(
      date: boxPlan.date,
      isClosed: boxPlan.isClosed,
      line: _mapToDomainLine(boxPlan.line.target!),
      meals: boxPlan.meals.map(_mapToDomainMeal).toList(),
    );
  }

  Line _mapToDomainLine(BoxLine boxLine) {
    return Line(
      id: boxLine.lineId,
      name: boxLine.name,
      position: boxLine.position,
      canteen: _mapToDomainCanteen(boxLine.canteen.target!),
    );
  }

  Canteen _mapToDomainCanteen(BoxCanteen boxCanteen) {
    return Canteen(id: boxCanteen.canteenId, name: boxCanteen.name);
  }

  Meal _mapToDomainMeal(BoxMeal boxMeal) {
    final price = boxMeal.price.target!;
    final nutrition = boxMeal.nutritionData.target;
    final environment = boxMeal.environmentInfo.target;

    return Meal(
      id: boxMeal.mealId,
      name: boxMeal.name,
      foodType: FoodType.values.byName(boxMeal.foodType),
      price: Price(
        student: price.student,
        employee: price.employee,
        pupil: price.pupil,
        guest: price.guest,
      ),
      allergens: boxMeal.allergens
          .map((e) => Allergen.values.byName(e))
          .toList(),
      additives: boxMeal.additives
          .map((e) => Additive.values.byName(e))
          .toList(),
      sides: boxMeal.sides.map(_mapToDomainSide).toList(),
      nutritionData: nutrition != null
          ? NutritionData(
              energy: nutrition.energy,
              protein: nutrition.protein,
              carbohydrates: nutrition.carbohydrates,
              sugar: nutrition.sugar,
              fat: nutrition.fat,
              saturatedFat: nutrition.saturatedFat,
              salt: nutrition.salt,
            )
          : null,
      environmentInfo: environment != null
          ? EnvironmentInfo(
              averageRating: environment.averageRating,
              co2Rating: environment.co2Rating,
              co2Value: environment.co2Value,
              waterRating: environment.waterRating,
              waterValue: environment.waterValue,
              animalWelfareRating: environment.animalWelfareRating,
              rainforestRating: environment.rainforestRating,
              maxRating: environment.maxRating,
            )
          : null,
      individualRating: boxMeal.individualRating,
      numberOfRatings: boxMeal.numberOfRatings,
      averageRating: boxMeal.averageRating,
      lastServed: boxMeal.lastServed,
      nextServed: boxMeal.nextServed,
      relativeFrequency: boxMeal.relativeFrequency != null
          ? Frequency.values.byName(boxMeal.relativeFrequency!)
          : null,
      images: boxMeal.images.map(_mapToDomainImage).toList(),
      isFavorite: _isFavorite(boxMeal.mealId),
    );
  }

  Side _mapToDomainSide(BoxMeal boxMeal) {
    final price = boxMeal.price.target!;
    final nutrition = boxMeal.nutritionData.target;
    final environment = boxMeal.environmentInfo.target;

    return Side(
      id: boxMeal.mealId,
      name: boxMeal.name,
      foodType: FoodType.values.byName(boxMeal.foodType),
      price: Price(
        student: price.student,
        employee: price.employee,
        pupil: price.pupil,
        guest: price.guest,
      ),
      allergens: boxMeal.allergens
          .map((e) => Allergen.values.byName(e))
          .toList(),
      additives: boxMeal.additives
          .map((e) => Additive.values.byName(e))
          .toList(),
      nutritionData: nutrition != null
          ? NutritionData(
              energy: nutrition.energy,
              protein: nutrition.protein,
              carbohydrates: nutrition.carbohydrates,
              sugar: nutrition.sugar,
              fat: nutrition.fat,
              saturatedFat: nutrition.saturatedFat,
              salt: nutrition.salt,
            )
          : null,
      environmentInfo: environment != null
          ? EnvironmentInfo(
              averageRating: environment.averageRating,
              co2Rating: environment.co2Rating,
              co2Value: environment.co2Value,
              waterRating: environment.waterRating,
              waterValue: environment.waterValue,
              animalWelfareRating: environment.animalWelfareRating,
              rainforestRating: environment.rainforestRating,
              maxRating: environment.maxRating,
            )
          : null,
    );
  }

  ImageData _mapToDomainImage(BoxImage boxImage) {
    return ImageData(
      id: boxImage.imageId,
      url: boxImage.url,
      imageRank: boxImage.imageRank,
      positiveRating: boxImage.positiveRating,
      negativeRating: boxImage.negativeRating,
      individualRating: boxImage.individualRating,
    );
  }
}
