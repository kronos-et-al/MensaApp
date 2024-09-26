import 'dart:async';
import 'dart:io';

import 'package:app/model/database/migration/migrations.dart';
import 'package:app/model/database/model/database_model.dart';
import 'package:app/model/database/model/db_meal_environment_info.dart';
import 'package:app/model/database/model/db_mealplan_side.dart';
import 'package:app/model/database/model/db_side_environment_info.dart';
import 'package:app/model/database/model/db_side_nutrition_data.dart';
import 'package:app/model/database/model/environment_info_mixin.dart';
import 'package:app/view_model/repository/data_classes/filter/Frequency.dart';
import 'package:app/view_model/repository/data_classes/meal/Additive.dart';
import 'package:app/view_model/repository/data_classes/meal/EnvironmentInfo.dart';
import 'package:app/view_model/repository/data_classes/meal/FavoriteMeal.dart';
import 'package:app/view_model/repository/data_classes/meal/ImageData.dart';
import 'package:app/view_model/repository/data_classes/meal/Meal.dart';
import 'package:app/view_model/repository/data_classes/meal/NutritionData.dart';
import 'package:app/view_model/repository/data_classes/meal/Price.dart';
import 'package:app/view_model/repository/data_classes/meal/Side.dart';
import 'package:app/view_model/repository/data_classes/mealplan/Canteen.dart';
import 'package:app/view_model/repository/data_classes/mealplan/MealPlan.dart';
import 'package:app/view_model/repository/error_handling/MealPlanException.dart';
import 'package:app/view_model/repository/error_handling/Result.dart';
import 'package:app/view_model/repository/interface/IDatabaseAccess.dart';
import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:uuid/uuid.dart';

import '../../view_model/repository/data_classes/meal/Allergen.dart';
import '../../view_model/repository/data_classes/mealplan/Line.dart';
import '../../view_model/repository/error_handling/NoMealException.dart';
import 'model/db_canteen.dart';
import 'model/db_favorite.dart';
import 'model/db_image.dart';
import 'model/db_line.dart';
import 'model/db_meal.dart';
import 'model/db_meal_additive.dart';
import 'model/db_meal_allergen.dart';
import 'model/db_meal_nutrition_data.dart';
import 'model/db_meal_plan.dart';
import 'model/db_mealplan_meal.dart';
import 'model/db_side.dart';
import 'model/db_side_additive.dart';
import 'model/db_side_allergen.dart';
import 'model/nutrition_data_mixin.dart';

enum NutritionEntity { meal, side }

/// This class accesses the database and uses it as local storage.
class SQLiteDatabaseAccess implements IDatabaseAccess {
  static final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  static List<String> _getDatabaseBuilder() {
    return [
      DBCanteen.initTable(),
      DBLine.initTable(),
      DBMealPlan.initTable(),
      DBMealPlanMeal.initTable(),
      DBMealPlanSide.initTable(),
      DBMeal.initTable(),
      DBSide.initTable(),
      DBImage.initTable(),
      DBMealAdditive.initTable(),
      DBMealAllergen.initTable(),
      DBMealNutritionData.initTable(),
      DBMealEnvironmentInfo.initTable(),
      DBSideAdditive.initTable(),
      DBSideAllergen.initTable(),
      DBSideNutritionData.initTable(),
      DBSideEnvironmentInfo.initTable(),
      DBFavorite.initTable()
    ];
  }

  // Database access is provided by a singleton instance to prevent several databases.
  static final SQLiteDatabaseAccess _databaseAccess =
      SQLiteDatabaseAccess._internal();

  /// Returns the singleton instance of this class.
  factory SQLiteDatabaseAccess() {
    return _databaseAccess;
  }

  SQLiteDatabaseAccess._internal() {
    database = _initiate();
  }

  static const String _dbName = 'meal_plan.db';
  late final Future<Database> database;

  static Future<Database> _initiate() async {
    WidgetsFlutterBinding.ensureInitialized();
    if (Platform.isWindows || Platform.isLinux) {
      databaseFactory = databaseFactoryFfi;
    }
    return await openDatabase(
      join(await getDatabasesPath(), _dbName),
      onCreate: (db, version) {
        for (String sql in _getDatabaseBuilder()) {
          db.execute(sql);
        }
      },
      onUpgrade: (db, oldVersion, newVersion) {
        for (var i = oldVersion; i < newVersion; i++) {
          if (dbMigrations.containsKey((i, i + 1))) {
            Future.forEach(dbMigrations[(i, i + 1)]!,
                (sql) async => await db.execute(sql));
          }
        }
      },
      version: 4,
    );
  }

  @override
  Future<int> addFavorite(
      Meal meal, DateTime servedDate, Line servedLine) async {
    var db = await database;
    var favorite = DBFavorite(
      meal.id,
      meal.lastServed != null ? _dateFormat.format(meal.lastServed!) : null,
      meal.foodType,
      meal.price.student,
      meal.price.employee,
      meal.price.pupil,
      meal.price.guest,
      servedDate,
      servedLine.id,
    );
    await _insertMeal(meal);
    return await db.insert(DBFavorite.tableName, favorite.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<int> deleteFavorite(Meal meal) async {
    var db = await database;
    return db.delete(DBFavorite.tableName,
        where: '${DBFavorite.columnMealID} = ?', whereArgs: [meal.id]);
  }

  @override
  Future<List<FavoriteMeal>> getFavorites() async {
    var db = await database;
    var meals = List<FavoriteMeal>.empty(growable: true);
    var dbFavoritesListResult = await db.query(DBFavorite.tableName);
    for (Map<String, dynamic> favoriteMap in dbFavoritesListResult) {
      DBFavorite? dbFavorite = DBFavorite.fromMap(favoriteMap);
      DBMeal? dbMeal = await _getDBMeal(dbFavorite.mealID);
      if (dbMeal != null) {
        Meal meal = DatabaseTransformer.fromDBMeal(
            dbMeal,
            Price(
                student: dbFavorite.priceStudent,
                employee: dbFavorite.priceEmployee,
                pupil: dbFavorite.priceEmployee,
                guest: dbFavorite.priceGuest),
            await _getMealAllergens(dbMeal.mealID),
            await _getMealAdditives(dbMeal.mealID),
            await _getDBMealNutritionData(dbMeal.mealID),
            [],
            {},
            {},
            {},
            {},
            await _getDBImages(dbMeal.mealID),
            dbFavorite.lastDate != null
                ? _dateFormat.parse(dbFavorite.lastDate!)
                : null,
            null,
            null,
            null,
            true);
        DBLine? dbLine = await _getDBLine(dbFavorite.servedLineId);
        DBCanteen? dbCanteen = await _getDBCanteen(dbLine!.canteenID);
        Line line = DatabaseTransformer.fromDBLine(dbLine, dbCanteen!);
        meals.add(FavoriteMeal(meal, dbFavorite.servedDate, line));
      }
    }
    return meals;
  }

  @override
  Future<Result<Meal, NoMealException>> getMealFavorite(String id) async {
    var db = await database;
    var result = await db.query(DBFavorite.tableName,
        where: '${DBFavorite.columnMealID} = ?', whereArgs: [id]);
    if (result.isNotEmpty) {
      DBFavorite dbFavorite = DBFavorite.fromMap(result.first);
      DBMeal? dbMeal = await _getDBMeal(dbFavorite.mealID);
      if (dbMeal != null) {
        return Success(DatabaseTransformer.fromDBMeal(
            dbMeal,
            Price(
                student: dbFavorite.priceStudent,
                employee: dbFavorite.priceEmployee,
                pupil: dbFavorite.priceEmployee,
                guest: dbFavorite.priceGuest),
            await _getMealAllergens(dbMeal.mealID),
            await _getMealAdditives(dbMeal.mealID),
            await _getDBMealNutritionData(dbMeal.mealID),
            [],
            {},
            {},
            {},
            {},
            (await _getDBImages(dbMeal.mealID)),
            dbFavorite.lastDate != null
                ? _dateFormat.parse(dbFavorite.lastDate!)
                : null,
            null,
            null,
            null,
            await _isFavorite(dbMeal.mealID)));
      } else {
        return Failure(NoMealException("Meal not found."));
      }
    } else {
      return Failure(NoMealException("Meal not found."));
    }
  }

  @override
  Future<Result<List<MealPlan>, NoDataException>> getMealPlan(
      DateTime date, Canteen canteen) async {
    var db = await database;
    var result = await db.query(
        '${DBMealPlan.tableName}, ${DBCanteen.tableName}, ${DBLine.tableName}',
        where:
            '${DBCanteen.tableName}.${DBCanteen.columnCanteenID} = ${DBLine.tableName}.${DBLine.columnCanteenID} AND ${DBLine.tableName}.${DBLine.columnLineID} = ${DBMealPlan.tableName}.${DBMealPlan.columnLineID} AND ${DBCanteen.tableName}.${DBCanteen.columnCanteenID} = ? AND ${DBMealPlan.tableName}.${DBMealPlan.columnDate} = ?',
        whereArgs: [canteen.id, _dateFormat.format(date)]);
    if (result.isNotEmpty) {
      List<MealPlan> mealPlans = List.empty(growable: true);
      for (DBMealPlan dbMealPlan
          in result.map((plan) => DBMealPlan.fromMap(plan))) {
        var dbLine = await _getDBLine(dbMealPlan.lineID);
        var dbCanteen = await _getDBCanteen(dbLine!.canteenID);
        var meals = await _getMealPlanMeals(dbMealPlan);
        mealPlans.add(DatabaseTransformer.fromDBMealPlan(
            dbMealPlan, dbLine, dbCanteen!, meals));
      }
      return Success(mealPlans);
    } else {
      return Failure(NoDataException("No meal plan found for this date."));
    }
  }

  Future<List<Meal>> _getMealPlanMeals(DBMealPlan dbMealPlan) async {
    List<DBMealPlanMeal> dbMealPlanMeals =
        await _getDBMealPlanMeals(dbMealPlan.mealPlanID);
    List<Meal> meals = List<Meal>.empty(growable: true);
    for (DBMealPlanMeal dbMealPlanMeal in dbMealPlanMeals) {
      DBMeal? dbMeal = await _getDBMeal(dbMealPlanMeal.mealID);
      if (dbMeal == null) {
        continue;
      }
      bool isFavorite = await _isFavorite(dbMeal.mealID);
      Meal meal = Meal(
          id: dbMeal.mealID,
          name: dbMeal.name,
          foodType: dbMeal.foodType,
          lastServed: dbMealPlanMeal.lastServed != null
              ? _dateFormat.parse(dbMealPlanMeal.lastServed!)
              : null,
          nextServed: dbMealPlanMeal.nextServed != null
              ? _dateFormat.parse(dbMealPlanMeal.nextServed!)
              : null,
          numberOfOccurance: dbMealPlanMeal.frequency,
          relativeFrequency: dbMealPlanMeal.relativeFrequency,
          additives: await _getMealAdditives(dbMeal.mealID),
          allergens: await _getMealAllergens(dbMeal.mealID),
          nutritionData: await _getMealNutritionData(dbMeal.mealID),
          environmentInfo: await _getMealEnvironmentInfo(dbMeal.mealID),
          averageRating: dbMeal.averageRating,
          individualRating: dbMeal.individualRating,
          numberOfRatings: dbMeal.numberOfRatings,
          images: (await _getDBImages(dbMeal.mealID))
              .map((dbImage) => ImageData(
                  id: dbImage.imageID,
                  url: dbImage.url,
                  imageRank: dbImage.imageRank,
                  negativeRating: dbImage.negativeRating,
                  positiveRating: dbImage.positiveRating,
                  individualRating: dbImage.individualRating))
              .toList(),
          sides: await _getMealPlanSides(dbMealPlan, dbMealPlanMeal),
          price: Price(
              student: dbMealPlanMeal.priceStudent,
              employee: dbMealPlanMeal.priceEmployee,
              pupil: dbMealPlanMeal.pricePupil,
              guest: dbMealPlanMeal.priceGuest),
          isFavorite: isFavorite);
      meals.add(meal);
    }
    return meals;
  }

  Future<List<Side>> _getMealPlanSides(
      DBMealPlan dbMealPlan, DBMealPlanMeal dbMealPlanMeal) async {
    List<DBMealPlanSide> dbMealPlanSides =
        await _getDBMealPlanSides(dbMealPlan.mealPlanID, dbMealPlanMeal.mealID);
    List<Side> sides = List<Side>.empty(growable: true);
    for (DBMealPlanSide dbMealPlanSide in dbMealPlanSides) {
      DBSide? dbSide = await _getDBSide(dbMealPlanSide.sideID);
      if (dbSide == null) {
        continue;
      }
      Side side = Side(
          id: dbSide.sideID,
          name: dbSide.name,
          foodType: dbSide.foodType,
          price: Price(
              student: dbMealPlanSide.priceStudent,
              employee: dbMealPlanSide.priceEmployee,
              pupil: dbMealPlanSide.pricePupil,
              guest: dbMealPlanSide.priceGuest),
          allergens: await _getSideAllergens(dbSide.sideID) ?? [],
          additives: await _getSideAdditive(dbSide.sideID) ?? [],
          nutritionData: await _getSideNutritionData(dbSide.sideID),
          environmentInfo: await _getSideEnvironmentInfo(dbSide.sideID));
      sides.add(side);
    }
    return sides;
  }

  Future<bool> _isFavorite(String id) async {
    var db = await database;
    var result = await db.query(DBFavorite.tableName,
        where: '${DBFavorite.columnMealID} = ?', whereArgs: [id]);
    return result.isNotEmpty;
  }

  @override
  Future<void> updateAll(List<MealPlan> mealPlans) async {
    for (MealPlan mealPlan in mealPlans) {
      await _insertCanteen(mealPlan.line.canteen);
      await _insertLine(mealPlan.line);
      await _insertMealPlan(mealPlan);
    }
  }

  @override
  Future<void> updateMeal(Meal meal) async {
    await _insertMeal(meal);
  }

  @override
  Future<void> updateImage(ImageData image) async {
    var db = await database;
    DBImage? dbImage = await _getDBImage(image.id);
    if (dbImage != null) {
      dbImage = DBImage(image.id, dbImage.mealID, image.url, image.imageRank,
          image.positiveRating, image.negativeRating, image.individualRating);
      await db.update(DBImage.tableName, dbImage.toMap(),
          where: '${DBImage.columnImageID} = ?', whereArgs: [image.id]);
    }
  }

  Future<int> _insertLine(Line line) async {
    var db = await database;
    var dbLine = DBLine(line.id, line.canteen.id, line.name, line.position);
    return db.insert(DBLine.tableName, dbLine.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> _insertCanteen(Canteen canteen) async {
    var db = await database;
    var dbCanteen = DBCanteen(canteen.id, canteen.name);
    return db.insert(DBCanteen.tableName, dbCanteen.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> _insertMealPlan(MealPlan mealPlan) async {
    var db = await database;
    var result = await db.query(DBMealPlan.tableName,
        where:
            '${DBMealPlan.columnLineID} = ? AND ${DBMealPlan.columnDate} = ?',
        whereArgs: [mealPlan.line.id, _dateFormat.format(mealPlan.date)]);
    DBMealPlan? dbMealPlan;
    if (result.isNotEmpty) {
      DBMealPlan oldDbMealPlan = DBMealPlan.fromMap(result.first);
      dbMealPlan = DBMealPlan(oldDbMealPlan.mealPlanID, mealPlan.line.id,
          _dateFormat.format(mealPlan.date), mealPlan.isClosed);
    } else {
      var uuid = const Uuid();
      dbMealPlan = DBMealPlan(uuid.v4(), mealPlan.line.id,
          _dateFormat.format(mealPlan.date), mealPlan.isClosed);
    }
    int id = await db.insert(DBMealPlan.tableName, dbMealPlan.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    await db.delete(DBMealPlanMeal.tableName,
        where: '${DBMeal.columnMealPlanID} = ?',
        whereArgs: [dbMealPlan.mealPlanID]);
    await db.delete(DBMealPlanSide.tableName,
        where: '${DBMealPlanSide.columnMealPlanID} = ?',
        whereArgs: [dbMealPlan.mealPlanID]);
    await Future.wait(
        mealPlan.meals.map((e) => _insertMealPlanMeal(e, dbMealPlan!)));
    return id;
  }

  Future<int> _insertMeal(Meal meal) async {
    var db = await database;

    await db.delete(DBMealAllergen.tableName,
        where: '${DBMealAllergen.columnMealID} = ?', whereArgs: [meal.id]);
    await db.delete(DBMealAdditive.tableName,
        where: '${DBMealAdditive.columnMealID} = ?', whereArgs: [meal.id]);
    await db.delete(DBImage.tableName,
        where: '${DBImage.columnMealID} = ?', whereArgs: [meal.id]);
    await db.delete(DBMealNutritionData.tableName,
        where: '${NutritionDataMixin.columnEntityID} = ?',
        whereArgs: [meal.id]);

    DBMeal dbMeal = DBMeal(meal.id, meal.name, meal.foodType,
        meal.individualRating, meal.numberOfRatings, meal.averageRating);

    await Future.wait(
        meal.allergens?.map((e) => _insertMealAllergen(e, dbMeal)).toList() ??
            []);
    await Future.wait(
        meal.additives?.map((e) => _insertMealAdditive(e, dbMeal)).toList() ??
            []);
    await Future.wait(
        meal.images?.map((e) => _insertImage(e, dbMeal)).toList() ?? []);

    if (meal.nutritionData != null) {
      await _insertMealNutritionData(meal.nutritionData!, dbMeal);
    }
    if (meal.environmentInfo != null) {
      await _insertMealEnvironmentInfo(meal.environmentInfo!, dbMeal);
    }

    return await db.insert(DBMeal.tableName, dbMeal.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> _insertMealPlanMeal(Meal meal, DBMealPlan mealPlan) async {
    var db = await database;

    await db.delete(DBMealAllergen.tableName,
        where: '${DBMealAllergen.columnMealID} = ?', whereArgs: [meal.id]);
    await db.delete(DBMealAdditive.tableName,
        where: '${DBMealAdditive.columnMealID} = ?', whereArgs: [meal.id]);
    await db.delete(DBImage.tableName,
        where: '${DBImage.columnMealID} = ?', whereArgs: [meal.id]);

    DBMeal dbMeal = DBMeal(meal.id, meal.name, meal.foodType,
        meal.individualRating, meal.numberOfRatings, meal.averageRating);
    DBMealPlanMeal mealPlanMeal = DBMealPlanMeal(
        mealPlan.mealPlanID,
        dbMeal.mealID,
        meal.price.student,
        meal.price.employee,
        meal.price.pupil,
        meal.price.guest,
        meal.lastServed != null ? _dateFormat.format(meal.lastServed!) : null,
        _dateFormat.format(meal.nextServed ?? DateTime.now()),
        meal.numberOfOccurance,
        meal.relativeFrequency ?? Frequency.normal);
    await Future.wait(
        meal.allergens?.map((e) => _insertMealAllergen(e, dbMeal)).toList() ??
            []);
    await Future.wait(
        meal.additives?.map((e) => _insertMealAdditive(e, dbMeal)).toList() ??
            []);
    await Future.wait(meal.sides!
        .map((e) => _insertMealPlanSide(e, dbMeal, mealPlan))
        .toList());
    await Future.wait(
        meal.images?.map((e) => _insertImage(e, dbMeal)).toList() ?? []);
    if (meal.nutritionData != null) {
      await _insertMealNutritionData(meal.nutritionData!, dbMeal);
    }
    if (meal.environmentInfo != null) {
      await _insertMealEnvironmentInfo(meal.environmentInfo!, dbMeal);
    }
    await db.insert(DBMeal.tableName, dbMeal.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return await db.insert(DBMealPlanMeal.tableName, mealPlanMeal.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> _insertMealPlanSide(
      Side side, DBMeal meal, DBMealPlan mealPlan) async {
    var db = await database;
    await db.delete(DBSideAllergen.tableName,
        where: '${DBSideAllergen.columnSideID} = ?', whereArgs: [side.id]);
    await db.delete(DBSideAdditive.tableName,
        where: '${DBSideAdditive.columnSideID} = ?', whereArgs: [side.id]);
    await db.delete(DBSideNutritionData.tableName,
        where: '${NutritionDataMixin.columnEntityID} = ?',
        whereArgs: [side.id]);
    DBSide dbSide = DBSide(side.id, side.name, side.foodType);
    DBMealPlanSide mealPlanSide = DBMealPlanSide(
        mealPlan.mealPlanID,
        meal.mealID,
        dbSide.sideID,
        side.price.student,
        side.price.employee,
        side.price.pupil,
        side.price.guest);
    await Future.wait(
        side.allergens.map((e) => _insertSideAllergen(e, dbSide)));
    await Future.wait(
        side.additives.map((e) => _insertSideAdditive(e, dbSide)));
    if (side.nutritionData != null) {
      await _insertSideNutritionData(side.nutritionData!, dbSide);
    }
    if (side.environmentInfo != null) {
      await _insertSideEnvironmentInfo(side.environmentInfo!, dbSide);
    }
    await db.insert(DBSide.tableName, dbSide.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
    return await db.insert(DBMealPlanSide.tableName, mealPlanSide.toMap());
  }

  Future<int> _insertMealAllergen(Allergen allergen, DBMeal meal) async {
    var db = await database;
    var dbMealAllergen = DBMealAllergen(meal.mealID, allergen);
    return await db.insert(DBMealAllergen.tableName, dbMealAllergen.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> _insertMealAdditive(Additive additive, DBMeal meal) async {
    var db = await database;
    var dbMealAdditive = DBMealAdditive(meal.mealID, additive);
    return await db.insert(DBMealAdditive.tableName, dbMealAdditive.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> _insertMealNutritionData(
      NutritionData nutritionData, DBMeal meal) async {
    var db = await database;
    var dbMealNutritionData = DBMealNutritionData(
      meal.mealID,
      nutritionData.energy,
      nutritionData.protein,
      nutritionData.carbohydrates,
      nutritionData.sugar,
      nutritionData.fat,
      nutritionData.saturatedFat,
      nutritionData.salt,
    );
    return await db.insert(
        DBMealNutritionData.tableName, dbMealNutritionData.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> _insertMealEnvironmentInfo(
      EnvironmentInfo environmentInfo, DBMeal meal) async {
    var db = await database;
    var dbMealEnvironmentInfo = DBMealEnvironmentInfo(
      meal.mealID,
      environmentInfo.averageRating,
      environmentInfo.co2Rating,
      environmentInfo.co2Value,
      environmentInfo.waterRating,
      environmentInfo.waterValue,
      environmentInfo.animalWelfareRating,
      environmentInfo.rainforestRating,
      environmentInfo.maxRating
    );
    return await db.insert(
        DBMealEnvironmentInfo.tableName, dbMealEnvironmentInfo.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> _insertSideAllergen(Allergen allergen, DBSide side) async {
    var db = await database;
    var dbSideAllergen = DBSideAllergen(side.sideID, allergen);
    return await db.insert(DBSideAllergen.tableName, dbSideAllergen.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> _insertSideAdditive(Additive additive, DBSide side) async {
    var db = await database;
    var dbSideAdditive = DBSideAdditive(side.sideID, additive);
    return await db.insert(DBSideAdditive.tableName, dbSideAdditive.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> _insertSideNutritionData(
      NutritionData nutritionData, DBSide side) async {
    var db = await database;
    var dbSideNutritionData = DBSideNutritionData(
      side.sideID,
      nutritionData.energy,
      nutritionData.protein,
      nutritionData.carbohydrates,
      nutritionData.sugar,
      nutritionData.fat,
      nutritionData.saturatedFat,
      nutritionData.salt,
    );
    return await db.insert(
        DBSideNutritionData.tableName, dbSideNutritionData.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> _insertSideEnvironmentInfo(
      EnvironmentInfo environmentInfo, DBSide side) async {
    var db = await database;
    var dbSideEnvironmentInfo = DBMealEnvironmentInfo(
        side.sideID,
        environmentInfo.averageRating,
        environmentInfo.co2Rating,
        environmentInfo.co2Value,
        environmentInfo.waterRating,
        environmentInfo.waterValue,
        environmentInfo.animalWelfareRating,
        environmentInfo.rainforestRating,
        environmentInfo.maxRating
    );
    return await db.insert(
        DBSideEnvironmentInfo.tableName, dbSideEnvironmentInfo.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> _insertImage(ImageData image, DBMeal meal) async {
    var db = await database;
    var dbImage = DBImage(image.id, meal.mealID, image.url, image.imageRank,
        image.positiveRating, image.negativeRating, image.individualRating);
    return await db.insert(DBImage.tableName, dbImage.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<DBCanteen?> _getDBCanteen(String canteenID) async {
    var db = await database;
    var result = await db.query(DBCanteen.tableName,
        where: '${DBCanteen.columnCanteenID} = ?', whereArgs: [canteenID]);
    if (result.isNotEmpty) {
      return DBCanteen.fromMap(result.first);
    } else {
      return null;
    }
  }

  Future<DBLine?> _getDBLine(String lineID) async {
    var db = await database;
    var result = await db.query(DBLine.tableName,
        where: '${DBLine.columnLineID} = ?', whereArgs: [lineID]);
    if (result.isNotEmpty) {
      return DBLine.fromMap(result.first);
    } else {
      return null;
    }
  }

  Future<DBMeal?> _getDBMeal(String mealID) async {
    var db = await database;
    var result = await db.query(DBMeal.tableName,
        where: '${DBMeal.columnMealID} = ?', whereArgs: [mealID]);
    if (result.isNotEmpty) {
      return DBMeal.fromMap(result.first);
    } else {
      return null;
    }
  }

  Future<DBSide?> _getDBSide(String sideID) async {
    var db = await database;
    var result = await db.query(DBSide.tableName,
        where: '${DBSide.columnSideID} = ?', whereArgs: [sideID]);
    if (result.isNotEmpty) {
      return DBSide.fromMap(result.first);
    } else {
      return null;
    }
  }

  Future<List<DBMealPlanMeal>> _getDBMealPlanMeals(String mealPlanID) async {
    var db = await database;
    var result = await db.query(DBMealPlanMeal.tableName,
        where: '${DBMealPlanMeal.columnMealPlanID} = ?',
        whereArgs: [mealPlanID]);
    return result.map((mealRow) => DBMealPlanMeal.fromMap(mealRow)).toList();
  }

  Future<List<DBMealPlanSide>> _getDBMealPlanSides(
      String mealPlanID, String mealID) async {
    var db = await database;
    var result = await db.query(DBMealPlanSide.tableName,
        where:
            '${DBMealPlanSide.columnMealPlanID} = ? AND ${DBMealPlanSide.columnMealID} = ?',
        whereArgs: [mealPlanID, mealID]);

    return result.map((sideRow) => DBMealPlanSide.fromMap(sideRow)).toList();
  }

  Future<DBImage?> _getDBImage(String imageID) async {
    var db = await database;
    var result = await db.query(DBImage.tableName,
        where: '${DBImage.columnImageID} = ?', whereArgs: [imageID]);
    if (result.isNotEmpty) {
      return DBImage.fromMap(result.first);
    } else {
      return null;
    }
  }

  Future<List<DBImage>> _getDBImages(String mealID) async {
    var db = await database;
    var result = await db.query(DBImage.tableName,
        where: '${DBImage.columnMealID} = ?', whereArgs: [mealID]);
    return result.map((imageRow) => DBImage.fromMap(imageRow)).toList();
  }

  Future<DBMealNutritionData?> _getDBMealNutritionData(String id) async {
    var result = await _getDBNutritionDataRaw(id, NutritionEntity.meal);
    return result.isNotEmpty ? DBMealNutritionData.fromMap(result.first) : null;
  }

  Future<DBMealNutritionData?> _getDBSideNutritionData(String id) async {
    var result = await _getDBNutritionDataRaw(id, NutritionEntity.side);
    return result.isNotEmpty ? DBMealNutritionData.fromMap(result.first) : null;
  }

  Future<List<Map<String, Object?>>> _getDBNutritionDataRaw(
      String id, NutritionEntity entity) async {
    var db = await database;
    var table = entity == NutritionEntity.meal
        ? DBMealNutritionData.tableName
        : DBSideNutritionData.tableName;
    return await db.query(table,
        where: '${NutritionDataMixin.columnEntityID} = ?', whereArgs: [id]);
  }

  Future<DBMealEnvironmentInfo?> _getDBMealEnvironmentInfo(String id) async {
    var db = await database;
    var result = await db.query(DBMealEnvironmentInfo.tableName,
        where: '${EnvironmentInfoMixin.columnEntityID} = ?', whereArgs: [id]);
    return result.isNotEmpty
        ? DBMealEnvironmentInfo.fromMap(result.first)
        : null;
  }

  Future<DBSideEnvironmentInfo?> _getDBSideEnvironmentInfo(String id) async {
    var db = await database;
    var result = await db.query(DBSideEnvironmentInfo.tableName,
        where: '${EnvironmentInfoMixin.columnEntityID} = ?', whereArgs: [id]);
    return result.isNotEmpty
        ? DBSideEnvironmentInfo.fromMap(result.first)
        : null;
  }

  Future<List<Allergen>?> _getMealAllergens(String id) async {
    var db = await database;
    var result = await db.query(DBMealAllergen.tableName,
        where: '${DBMealAllergen.columnMealID} = ?', whereArgs: [id]);
    return result
        .map((allergenMap) => DBMealAllergen.fromMap(allergenMap).allergen)
        .toList();
  }

  Future<List<Allergen>?> _getSideAllergens(String id) async {
    var db = await database;
    var result = await db.query(DBSideAllergen.tableName,
        where: '${DBSideAllergen.columnSideID} = ?', whereArgs: [id]);
    return result
        .map((allergenMap) => DBSideAllergen.fromMap(allergenMap).allergen)
        .toList();
  }

  Future<List<Additive>?> _getMealAdditives(String id) async {
    var db = await database;
    var result = await db.query(DBMealAdditive.tableName,
        where: '${DBMealAdditive.columnMealID} = ?', whereArgs: [id]);
    return result
        .map((allergenMap) => DBMealAdditive.fromMap(allergenMap).additive)
        .toList();
  }

  Future<List<Additive>?> _getSideAdditive(String id) async {
    var db = await database;
    var result = await db.query(DBSideAdditive.tableName,
        where: '${DBSideAdditive.columnSideID} = ?', whereArgs: [id]);
    return result
        .map((allergenMap) => DBSideAdditive.fromMap(allergenMap).additive)
        .toList();
  }

  Future<NutritionData?> _getMealNutritionData(String id) async {
    return _getNutritionData(id, NutritionEntity.meal);
  }

  Future<NutritionData?> _getSideNutritionData(String id) async {
    return _getNutritionData(id, NutritionEntity.side);
  }

  Future<EnvironmentInfo?> _getMealEnvironmentInfo(String id) async {
    var environmentInfo = await _getDBMealEnvironmentInfo(id);
    return environmentInfo != null
        ? EnvironmentInfo(
            averageRating: environmentInfo.averageRating,
            co2Rating: environmentInfo.co2Rating,
            co2Value: environmentInfo.co2Value,
            waterRating: environmentInfo.waterRating,
            waterValue: environmentInfo.waterValue,
            animalWelfareRating: environmentInfo.animalWelfareRating,
            rainforestRating: environmentInfo.rainforestRating,
            maxRating: environmentInfo.maxRating,
          )
        : null;
  }

  Future<EnvironmentInfo?> _getSideEnvironmentInfo(String id) async {
    var environmentInfo = await _getDBSideEnvironmentInfo(id);
    return environmentInfo != null
        ? EnvironmentInfo(
            averageRating: environmentInfo.averageRating,
            co2Rating: environmentInfo.co2Rating,
            co2Value: environmentInfo.co2Value,
            waterRating: environmentInfo.waterRating,
            waterValue: environmentInfo.waterValue,
            animalWelfareRating: environmentInfo.animalWelfareRating,
            rainforestRating: environmentInfo.rainforestRating,
            maxRating: environmentInfo.maxRating,
          )
        : null;
  }

  Future<NutritionData?> _getNutritionData(
      String id, NutritionEntity entity) async {
    NutritionDataMixin? dbNutritionData = entity == NutritionEntity.meal
        ? await _getDBMealNutritionData(id)
        : await _getDBSideNutritionData(id);
    return dbNutritionData != null
        ? NutritionData(
            energy: dbNutritionData.energy,
            protein: dbNutritionData.protein,
            carbohydrates: dbNutritionData.carbohydrates,
            sugar: dbNutritionData.sugar,
            fat: dbNutritionData.fat,
            saturatedFat: dbNutritionData.saturatedFat,
            salt: dbNutritionData.salt)
        : null;
  }

  @override
  Future<Canteen?> getCanteenById(String id) async {
    DBCanteen? canteen = await _getDBCanteen(id);
    if (canteen == null) {
      return null;
    }
    return DatabaseTransformer.fromDBCanteen(canteen);
  }

  @override
  Future<List<Canteen>?> getCanteens() async {
    var db = await database;
    var result = await db.query(DBCanteen.tableName);
    return Future.value(result.isNotEmpty
        ? result
            .map((canteenRow) => DBCanteen.fromMap(canteenRow))
            .map((e) => Canteen(id: e.canteenID, name: e.name))
            .toList()
        : null);
  }

  @override
  Future<Result<Meal, NoMealException>> getMeal(Meal meal) async {
    return _getDBMeal(meal.id).then((dbMeal) async {
      if (dbMeal != null) {
        Meal newMeal = Meal.copy(
            meal: meal,
            name: dbMeal.name,
            averageRating: dbMeal.averageRating,
            individualRating: dbMeal.individualRating,
            images: (await _getDBImages(dbMeal.mealID))
                .map((e) => DatabaseTransformer.fromDBImage(e))
                .toList(),
            environmentInfo: await _getMealEnvironmentInfo(dbMeal.mealID),
            allergens: await _getMealAllergens(dbMeal.mealID),
            additives: await _getMealAdditives(dbMeal.mealID),
            nutritionData: await _getMealNutritionData(dbMeal.mealID));
        return Success(newMeal);
      } else {
        return Failure(NoMealException("No meal found with id ${meal.id}"));
      }
    });
  }

  @override
  Future<void> removeImage(ImageData image) async {
    var db = await database;
    await db.delete(DBImage.tableName,
        where: '${DBImage.columnImageID} = ?', whereArgs: [image.id]);
  }

  @override
  Future<void> updateCanteen(Canteen canteen) async {
    var db = await database;
    await db.insert(
        DBCanteen.tableName, DBCanteen(canteen.id, canteen.name).toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  @override
  Future<void> cleanUp() async {
    var db = await database;
    print("Cleaning up database");

    List<DBMealPlan> mealPlans = (await db.query(DBMealPlan.tableName,
            where: '${DBMealPlan.columnDate} < ?',
            whereArgs: [
          _dateFormat.format(DateTime.now().subtract(const Duration(days: 1)))
        ]))
        .map((e) => DBMealPlan.fromMap(e))
        .toList();

    for (DBMealPlan mealPlan in mealPlans) {
      List<DBMealPlanMeal> mealPlanMeals = (await db.query(
              DBMealPlanMeal.tableName,
              where: '${DBMealPlanMeal.columnMealPlanID} = ?',
              whereArgs: [mealPlan.mealPlanID]))
          .map((e) => DBMealPlanMeal.fromMap(e))
          .toList();
      List<DBMealPlanSide> mealPlanSides = (await db.query(
              DBMealPlanSide.tableName,
              where: '${DBMealPlanSide.columnMealPlanID} = ?',
              whereArgs: [mealPlan.mealPlanID]))
          .map((e) => DBMealPlanSide.fromMap(e))
          .toList();
      for (DBMealPlanSide mealPlanSide in mealPlanSides) {
        if ((await db.query(DBMealPlanSide.tableName,
                    where: '${DBMealPlanSide.columnSideID} = ?',
                    whereArgs: [mealPlanSide.sideID]))
                .length >
            1) {
          print("Side ${mealPlanSide.sideID} is used in another meal plan");
          continue;
        }
        db.delete(DBSide.tableName,
            where: '${DBSide.columnSideID} = ?',
            whereArgs: [mealPlanSide.sideID]);
        db.delete(DBSideAllergen.tableName,
            where: '${DBSideAllergen.columnSideID} = ?',
            whereArgs: [mealPlanSide.sideID]);
        db.delete(DBSideAdditive.tableName,
            where: '${DBSideAdditive.columnSideID} = ?',
            whereArgs: [mealPlanSide.sideID]);
        db.delete(DBSideNutritionData.tableName,
            where: '${NutritionDataMixin.columnEntityID} = ?',
            whereArgs: [mealPlanSide.sideID]);
        db.delete(DBSideEnvironmentInfo.tableName,
            where: '${EnvironmentInfoMixin.columnEntityID} = ?',
            whereArgs: [mealPlanSide.sideID]);
        db.delete(DBMealPlanSide.tableName,
            where: '${DBMealPlanSide.columnSideID} = ?',
            whereArgs: [mealPlanSide.sideID]);
        print("Deleted side ${mealPlanSide.sideID}");
      }
      for (DBMealPlanMeal mealPlanMeal in mealPlanMeals) {
        if ((await db.query(DBFavorite.tableName,
                where: '${DBFavorite.columnMealID} = ?',
                whereArgs: [mealPlanMeal.mealID]))
            .isNotEmpty) {
          print("Meal ${mealPlanMeal.mealID} is a favorite");
          continue;
        }
        if ((await db.query(DBMealPlanMeal.tableName,
                    where: '${DBMealPlanMeal.columnMealID} = ?',
                    whereArgs: [mealPlanMeal.mealID]))
                .length >
            1) {
          print("Meal ${mealPlanMeal.mealID} is used in another meal plan");
          continue;
        }
        db.delete(DBMeal.tableName,
            where: '${DBMeal.columnMealID} = ?',
            whereArgs: [mealPlanMeal.mealID]);
        db.delete(DBMealAllergen.tableName,
            where: '${DBMealAllergen.columnMealID} = ?',
            whereArgs: [mealPlanMeal.mealID]);
        db.delete(DBMealAdditive.tableName,
            where: '${DBMealAdditive.columnMealID} = ?',
            whereArgs: [mealPlanMeal.mealID]);
        db.delete(DBMealNutritionData.tableName,
            where: '${NutritionDataMixin.columnEntityID} = ?',
            whereArgs: [mealPlanMeal.mealID]);
        db.delete(DBMealEnvironmentInfo.tableName,
            where: '${EnvironmentInfoMixin.columnEntityID} = ?',
            whereArgs: [mealPlanMeal.mealID]);
        db.delete(DBImage.tableName,
            where: '${DBImage.columnMealID} = ?',
            whereArgs: [mealPlanMeal.mealID]);
        db.delete(DBMealPlanMeal.tableName,
            where: '${DBMealPlanMeal.columnMealID} = ?',
            whereArgs: [mealPlanMeal.mealID]);
        print("Deleted meal ${mealPlanMeal.mealID}");
      }
      db.delete(DBMealPlan.tableName,
          where: '${DBMealPlan.columnMealPlanID} = ?',
          whereArgs: [mealPlan.mealPlanID]);
      print("Deleted meal plan ${mealPlan.mealPlanID}: ${mealPlan.date}");
    }
    print("cleanUp done");
  }
}
